package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.constants.BusinessConstants;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationRecordMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.model.dto.CreateAppointmentDTO;
import com.tjut.edu.vaccine_system.model.entity.Appointment;
import com.tjut.edu.vaccine_system.model.entity.ChildProfile;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SiteVaccineStock;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationRecord;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.entity.Vaccine;
import com.tjut.edu.vaccine_system.model.enums.AppointmentStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.ScheduleStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.SiteStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.VaccineStatusEnum;
import com.tjut.edu.vaccine_system.service.ChildProfileService;
import com.tjut.edu.vaccine_system.service.DoctorScheduleService;
import com.tjut.edu.vaccine_system.service.SiteVaccineStockService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import com.tjut.edu.vaccine_system.service.VaccineBatchService;
import com.tjut.edu.vaccine_system.service.VaccineService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.regex.Pattern;

/**
 * 预约创建服务
 * 负责预约创建的核心逻辑，包括排班校验、库存校验、冲突检测等
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentCreateService {

    private static final Pattern SPLIT_KEYWORDS = Pattern.compile(BusinessConstants.SPLIT_KEYWORDS_PATTERN);

    private final AppointmentMapper appointmentMapper;
    private final SysUserService sysUserService;
    private final ChildProfileService childProfileService;
    private final VaccineService vaccineService;
    private final VaccinationSiteMapper vaccinationSiteMapper;
    private final VaccinationRecordMapper vaccinationRecordMapper;
    private final DoctorScheduleService doctorScheduleService;
    private final SiteVaccineStockService siteVaccineStockService;
    private final VaccineBatchService vaccineBatchService;

    /**
     * 创建预约（带库存检查）
     * 流程：校验用户 → 校验排班 → 校验接种点 → 校验儿童 → 校验疫苗 → 检查冲突 → 锁定库存 → 创建预约
     *
     * @param dto 预约创建请求DTO
     * @return 创建成功的预约实体
     */
    @Transactional(rollbackFor = Exception.class)
    public Appointment createOrderWithStockCheck(CreateAppointmentDTO dto) {
        Long userId = dto.getUserId();

        // 1. 校验用户
        SysUser user = validateUser(userId);

        // 2. 校验排班
        DoctorSchedule schedule = validateAndGetSchedule(dto.getDoctorScheduleId());
        Long siteId = schedule.getSiteId();
        Long doctorId = schedule.getDoctorId();
        LocalDate appointmentDate = schedule.getScheduleDate();
        String timeSlot = schedule.getTimeSlot() != null ? schedule.getTimeSlot() : "";

        // 3. 校验接种点
        validateSite(siteId);

        // 4. 校验儿童
        ChildProfile child = validateAndGetChild(dto.getChildId(), userId);

        // 5. 校验儿童预约冲突
        validateChildConflict(child.getId(), appointmentDate);

        // 6. 校验疫苗
        Vaccine vaccine = validateAndGetVaccine(dto.getVaccineId(), child, appointmentDate);

        // 7. 校验时间冲突
        validateDoctorTimeConflict(doctorId, appointmentDate, timeSlot);

        // 8. 锁定库存并获取批次ID
        Long batchId = lockStockAndGetBatchId(vaccine.getId(), siteId);

        // 9. 增加排班当前计数
        incrementScheduleCount(schedule.getId());

        // 10. 创建预约
        Appointment appointment = createAppointmentEntity(userId, child.getId(), vaccine.getId(), siteId, doctorId,
                schedule.getId(), appointmentDate, timeSlot, batchId, dto.getRemark());

        appointmentMapper.insert(appointment);

        log.info("预约创建成功: appointmentId={}, userId={}, childId={}, vaccineId={}, siteId={}, doctorId={}",
                appointment.getId(), userId, child.getId(), vaccine.getId(), siteId, doctorId);

        return appointmentMapper.selectById(appointment.getId());
    }

    /**
     * 校验用户状态
     */
    private SysUser validateUser(Long userId) {
        if (userId == null) {
            throw new BizException(BizErrorCode.LOGIN_REQUIRED);
        }

        SysUser user = sysUserService.getById(userId);
        if (user == null) {
            throw new BizException(BizErrorCode.USER_NOT_FOUND);
        }

        if (!RoleConstants.isResident(user.getRole())) {
            throw new BizException(BizErrorCode.ROLE_NOT_RESIDENT);
        }

        // 检查是否被禁约
        if (user.getReservationBanUntil() != null && LocalDateTime.now().isBefore(user.getReservationBanUntil())) {
            log.warn("用户被禁约: userId={}, banUntil={}", userId, user.getReservationBanUntil());
            throw new BizException(BizErrorCode.RESERVATION_BANNED,
                    "因爽约次数过多，三十日内不可预约。解禁时间：" + user.getReservationBanUntil().toLocalDate());
        }

        return user;
    }

    /**
     * 校验并获取排班信息
     */
    private DoctorSchedule validateAndGetSchedule(Long doctorScheduleId) {
        if (doctorScheduleId == null) {
            throw new BizException(BizErrorCode.SCHEDULE_REQUIRED);
        }

        DoctorSchedule schedule = doctorScheduleService.getById(doctorScheduleId);
        if (schedule == null) {
            throw new BizException(BizErrorCode.SCHEDULE_NOT_FOUND);
        }

        if (!ScheduleStatusEnum.isEnabled(schedule.getStatus())) {
            throw new BizException(BizErrorCode.SCHEDULE_NOT_AVAILABLE);
        }

        // 检查排班日期是否已过期
        LocalDate scheduleDate = schedule.getScheduleDate();
        LocalDate now = LocalDate.now();

        if (scheduleDate != null && scheduleDate.isBefore(now)) {
            throw new BizException(BizErrorCode.SCHEDULE_NOT_AVAILABLE, "该排班日期已过期，无法预约");
        }

        // 如果是当天，还需要检查时间槽是否已过期
        if (scheduleDate != null && scheduleDate.isEqual(now)) {
            LocalTime slotEndTime = parseTimeSlotEnd(schedule.getTimeSlot());
            if (slotEndTime != null && LocalTime.now().isAfter(slotEndTime)) {
                throw new BizException(BizErrorCode.SCHEDULE_NOT_AVAILABLE, "该排班时段已过期，无法预约");
            }
        }

        // 检查排班容量
        int maxCap = schedule.getMaxCapacity() != null ? schedule.getMaxCapacity() : 0;
        int curCount = schedule.getCurrentCount() != null ? schedule.getCurrentCount() : 0;
        if (curCount >= maxCap) {
            throw new BizException(BizErrorCode.SCHEDULE_NOT_AVAILABLE, "该排班时段已约满");
        }

        return schedule;
    }

    /**
     * 校验接种点状态
     */
    private void validateSite(Long siteId) {
        VaccinationSite site = vaccinationSiteMapper.selectById(siteId);
        if (site == null) {
            throw new BizException(BizErrorCode.SITE_NOT_FOUND);
        }
        if (!Integer.valueOf(SiteStatusEnum.ENABLED.getCode()).equals(site.getStatus())) {
            throw new BizException(BizErrorCode.SITE_DISABLED);
        }
    }

    /**
     * 校验并获取儿童信息
     */
    private ChildProfile validateAndGetChild(Long childId, Long userId) {
        if (childId == null) {
            throw new BizException(BizErrorCode.CHILD_REQUIRED);
        }

        ChildProfile child = childProfileService.getById(childId);
        if (child == null) {
            throw new BizException(BizErrorCode.CHILD_NOT_FOUND);
        }

        if (!child.getParentId().equals(userId)) {
            throw new BizException(BizErrorCode.CHILD_NOT_OWNED);
        }

        return child;
    }

    /**
     * 校验儿童预约冲突
     */
    private void validateChildConflict(Long childId, LocalDate appointmentDate) {
        // 检查是否有进行中的预约
        List<Appointment> pendingForChild = appointmentMapper.selectList(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getChildId, childId)
                        .in(Appointment::getStatus,
                                AppointmentStatusEnum.BOOKED.getCode(),
                                AppointmentStatusEnum.CHECKED_IN.getCode(),
                                AppointmentStatusEnum.PRE_CHECK_PASS.getCode(),
                                AppointmentStatusEnum.OBSERVING.getCode()));

        if (!pendingForChild.isEmpty()) {
            throw new BizException(BizErrorCode.DUPLICATE_PENDING_APPOINTMENT, "该儿童已有进行中的预约，请先完成或取消");
        }
    }

    /**
     * 校验并获取疫苗信息
     */
    private Vaccine validateAndGetVaccine(Long vaccineId, ChildProfile child, LocalDate appointmentDate) {
        Vaccine vaccine = vaccineService.getById(vaccineId);
        if (vaccine == null) {
            throw new BizException(BizErrorCode.VACCINE_NOT_FOUND);
        }

        if (!VaccineStatusEnum.isUp(vaccine.getStatus())) {
            throw new BizException(BizErrorCode.VACCINE_NOT_AVAILABLE, "该疫苗已下架，无法预约");
        }

        // 检查适用年龄
        if (vaccine.getApplicableAgeMonths() != null) {
            long ageMonths = ChronoUnit.MONTHS.between(child.getBirthDate(), appointmentDate);
            if (ageMonths < vaccine.getApplicableAgeMonths()) {
                throw new BizException(BizErrorCode.BAD_REQUEST,
                        "该疫苗适用起始月龄为" + vaccine.getApplicableAgeMonths() + "月，当前儿童未达适用年龄");
            }
        }

        // 检查禁忌症/过敏史
        checkContraindication(child, vaccine);

        // 检查接种间隔
        checkVaccineInterval(vaccine, child.getId(), appointmentDate);

        return vaccine;
    }

    /**
     * 检查儿童禁忌症/过敏史与疫苗说明的冲突
     */
    private void checkContraindication(ChildProfile child, Vaccine vaccine) {
        if (StringUtils.hasText(child.getContraindicationAllergy())) {
            String allergy = child.getContraindicationAllergy().trim();
            String desc = (vaccine.getDescription() != null ? vaccine.getDescription() : "")
                    + (vaccine.getAdverseReactionDesc() != null ? vaccine.getAdverseReactionDesc() : "");

            for (String keyword : SPLIT_KEYWORDS.split(allergy)) {
                String k = keyword.trim();
                if (k.isEmpty()) continue;

                if (desc.contains(k)) {
                    log.warn("儿童禁忌症冲突: childId={}, keyword={}, vaccine={}", child.getId(), k, vaccine.getVaccineName());
                    throw new BizException(BizErrorCode.BAD_REQUEST,
                            "儿童禁忌症/过敏史【" + k + "】与该疫苗说明存在冲突，请咨询医生后再预约");
                }
            }
        }
    }

    /**
     * 检查疫苗接种间隔
     */
    private void checkVaccineInterval(Vaccine vaccine, Long childId, LocalDate appointmentDate) {
        if (vaccine.getIntervalDays() == null || vaccine.getIntervalDays() <= 0) {
            return;
        }

        List<VaccinationRecord> lastList = vaccinationRecordMapper.selectList(
                new LambdaQueryWrapper<VaccinationRecord>()
                        .eq(VaccinationRecord::getChildId, childId)
                        .eq(VaccinationRecord::getVaccineId, vaccine.getId())
                        .orderByDesc(VaccinationRecord::getVaccinationDate)
                        .last("LIMIT 1"));

        if (lastList.isEmpty()) {
            return;
        }

        VaccinationRecord lastRecord = lastList.get(0);
        LocalDate lastDate = lastRecord.getVaccinationDate().toLocalDate();
        LocalDate earliestNext = lastDate.plusDays(vaccine.getIntervalDays());

        if (appointmentDate.isBefore(earliestNext)) {
            throw new BizException(BizErrorCode.BAD_REQUEST,
                    "该疫苗两剂间隔至少" + vaccine.getIntervalDays() + "天，下次可约日期不早于" + earliestNext);
        }
    }

    /**
     * 校验医生时间段冲突
     */
    private void validateDoctorTimeConflict(Long doctorId, LocalDate appointmentDate, String timeSlot) {
        List<Appointment> existingAppointments = appointmentMapper.selectList(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getDoctorId, doctorId)
                        .eq(Appointment::getAppointmentDate, appointmentDate)
                        .eq(Appointment::getTimeSlot, timeSlot)
                        .in(Appointment::getStatus,
                                AppointmentStatusEnum.BOOKED.getCode(),
                                AppointmentStatusEnum.CHECKED_IN.getCode(),
                                AppointmentStatusEnum.PRE_CHECK_PASS.getCode(),
                                AppointmentStatusEnum.OBSERVING.getCode()));

        if (!existingAppointments.isEmpty()) {
            throw new BizException(BizErrorCode.DOCTOR_SLOT_OCCUPIED, "该医生在此时段已有预约");
        }
    }

    /**
     * 锁定库存并获取批次ID
     */
    private Long lockStockAndGetBatchId(Long vaccineId, Long siteId) {
        // 从接种点库存（site_vaccine_stock）查可用量，FEFO 锁定
        int stock = siteVaccineStockService.getAvailableStock(vaccineId, siteId);
        if (stock <= 0) {
            throw new BizException(BizErrorCode.STOCK_INSUFFICIENT, "该疫苗库存不足");
        }

        SiteVaccineStock fefoRow = siteVaccineStockService.getFefoStockRow(siteId, vaccineId);
        if (fefoRow == null) {
            throw new BizException(BizErrorCode.NO_AVAILABLE_BATCH, "无可用的批次");
        }

        boolean locked = siteVaccineStockService.lockStock(fefoRow.getId());
        if (!locked) {
            throw new BizException(BizErrorCode.NO_AVAILABLE_BATCH, "库存锁定失败，请稍后重试");
        }

        log.info("库存锁定成功: siteId={}, vaccineId={}, batchId={}", siteId, vaccineId, fefoRow.getBatchId());
        return fefoRow.getBatchId();
    }

    /**
     * 增加排班当前计数
     */
    private void incrementScheduleCount(Long doctorScheduleId) {
        boolean incremented = doctorScheduleService.incrementCurrentCount(doctorScheduleId);
        if (!incremented) {
            throw new BizException(BizErrorCode.SCHEDULE_NOT_AVAILABLE, "排班计数增加失败，该排班可能已约满");
        }
    }

    /**
     * 创建预约实体
     */
    private Appointment createAppointmentEntity(Long userId, Long childId, Long vaccineId, Long siteId,
                                               Long doctorId, Long doctorScheduleId, LocalDate appointmentDate,
                                               String timeSlot, Long batchId, String remark) {
        Appointment appointment = new Appointment();
        appointment.setUserId(userId);
        appointment.setChildId(childId);
        appointment.setVaccineId(vaccineId);
        appointment.setSiteId(siteId);
        appointment.setDoctorScheduleId(doctorScheduleId);
        appointment.setDoctorId(doctorId);
        appointment.setAppointmentDate(appointmentDate);
        appointment.setTimeSlot(timeSlot);
        appointment.setRemark(remark);
        appointment.setStatus(AppointmentStatusEnum.BOOKED.getCode());
        appointment.setBatchId(batchId);
        return appointment;
    }

    /**
     * 解析时段字符串的结束时间
     * 格式 "HH:mm-HH:mm" 取后半段；否则按当日 23:59 计
     */
    private static LocalTime parseTimeSlotEnd(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) {
            return LocalTime.of(23, 59);
        }

        String s = timeSlot.trim();

        // 处理 HH:mm-HH:mm 格式
        int dash = s.indexOf('-');
        if (dash >= 0 && dash < s.length() - 1) {
            String endPart = s.substring(dash + 1).trim();
            if (!endPart.isEmpty()) {
                try {
                    return LocalTime.parse(endPart);
                } catch (DateTimeParseException ignored) {
                    // 如果解析失败，继续尝试其他格式
                }
            }
        }

        // 处理 HH:mm 格式
        try {
            return LocalTime.parse(s);
        } catch (DateTimeParseException ignored) {
            // 如果解析失败，返回默认值
            return LocalTime.of(23, 59);
        }
    }
}
