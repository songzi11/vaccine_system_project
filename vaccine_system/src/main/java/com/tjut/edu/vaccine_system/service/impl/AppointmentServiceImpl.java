package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.model.dto.CreateAppointmentDTO;
import com.tjut.edu.vaccine_system.model.entity.Appointment;
import com.tjut.edu.vaccine_system.model.entity.ChildProfile;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationRecord;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.entity.Vaccine;
import com.tjut.edu.vaccine_system.model.enums.AppointmentStatusEnum;
import com.tjut.edu.vaccine_system.model.vo.AppointmentListVO;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationRecordMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.service.AppointmentService;
import com.tjut.edu.vaccine_system.service.ChildProfileService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import com.tjut.edu.vaccine_system.service.VaccineService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * 预约接种 Service 实现
 * 排班先行：家长选 doctor_schedule_id 预约 → 状态=已预约(1) → 签到(6)→预检(7/9)→完成接种(写记录、扣库存、状态=10留观→2已完成)
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements AppointmentService {

    private final ChildProfileService childProfileService;
    private final VaccineService vaccineService;
    private final VaccinationRecordMapper vaccinationRecordMapper;
    private final VaccinationSiteMapper vaccinationSiteMapper;

    // 专职服务类
    private final AppointmentCreateService appointmentCreateService;
    private final AppointmentCancelService appointmentCancelService;
    private final AppointmentExpireService appointmentExpireService;

    @Override
    public IPage<Appointment> pageAppointments(long current, long size, Long userId, Long vaccineId, Long siteId, Integer status, List<Integer> statusIn, LocalDate appointmentDate) {
        Page<Appointment> page = new Page<>(current, size);
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(userId != null, Appointment::getUserId, userId)
                .eq(vaccineId != null, Appointment::getVaccineId, vaccineId)
                .eq(siteId != null, Appointment::getSiteId, siteId)
                .eq(appointmentDate != null, Appointment::getAppointmentDate, appointmentDate);
        if (statusIn != null && !statusIn.isEmpty()) {
            wrapper.in(Appointment::getStatus, statusIn);
        } else if (status != null) {
            wrapper.eq(Appointment::getStatus, status);
        }
        wrapper.orderByDesc(Appointment::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public IPage<Appointment> pagePendingBySiteIds(long current, long size, List<Long> siteIds) {
        if (siteIds == null || siteIds.isEmpty()) {
            Page<Appointment> empty = new Page<>(current, size);
            empty.setRecords(List.of());
            empty.setTotal(0);
            return empty;
        }
        Page<Appointment> page = new Page<>(current, size);
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Appointment::getSiteId, siteIds)
                .eq(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode())
                .orderByDesc(Appointment::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public IPage<Appointment> pageTodayScheduled(long current, long size, Long siteId, Long doctorId) {
        Page<Appointment> page = new Page<>(current, size);
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode())
                .eq(Appointment::getAppointmentDate, LocalDate.now())
                .eq(siteId != null, Appointment::getSiteId, siteId)
                .eq(doctorId != null, Appointment::getDoctorId, doctorId);
        wrapper.orderByAsc(Appointment::getTimeSlot).orderByDesc(Appointment::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public IPage<Appointment> pageFutureScheduled(long current, long size, Long siteId, Long doctorId, LocalDate fromDateInclusive, LocalDate toDateInclusive) {
        if (fromDateInclusive == null || toDateInclusive == null || !fromDateInclusive.isBefore(toDateInclusive)) {
            Page<Appointment> empty = new Page<>(current, size);
            empty.setRecords(List.of());
            empty.setTotal(0);
            return empty;
        }
        Page<Appointment> page = new Page<>(current, size);
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode())
                .ge(Appointment::getAppointmentDate, fromDateInclusive)
                .le(Appointment::getAppointmentDate, toDateInclusive)
                .eq(siteId != null, Appointment::getSiteId, siteId)
                .eq(doctorId != null, Appointment::getDoctorId, doctorId);
        wrapper.orderByAsc(Appointment::getAppointmentDate)
                .orderByAsc(Appointment::getTimeSlot)
                .orderByDesc(Appointment::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public Appointment createOrderWithStockCheck(CreateAppointmentDTO dto) {
        log.info("开始创建预约: userId={}, childId={}, vaccineId={}",
                dto.getUserId(), dto.getChildId(), dto.getVaccineId());
        return appointmentCreateService.createOrderWithStockCheck(dto);
    }

    @Override
    public List<Appointment> listByDoctorId(Long doctorId) {
        if (doctorId == null) return List.of();
        return list(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getDoctorId, doctorId)
                .orderByDesc(Appointment::getAppointmentDate)
                .orderByDesc(Appointment::getCreateTime));
    }

    @Override
    public long countTodayByDoctorId(Long doctorId) {
        if (doctorId == null) return 0L;
        return count(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getDoctorId, doctorId)
                .eq(Appointment::getAppointmentDate, LocalDate.now()));
    }

    @Override
    public long countTodayBySiteId(Long siteId) {
        if (siteId == null) return 0L;
        return count(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getSiteId, siteId)
                .eq(Appointment::getAppointmentDate, LocalDate.now()));
    }

    @Override
    public IPage<AppointmentListVO> pageForUser(long current, long size, Long userId, Long childId, String statusType) {
        List<Integer> statusIn = null;
        if (statusType != null && !statusType.isBlank()) {
            switch (statusType.trim().toLowerCase()) {
                case "pending":
                    statusIn = List.of(AppointmentStatusEnum.BOOKED.getCode(), AppointmentStatusEnum.CHECKED_IN.getCode(),
                            AppointmentStatusEnum.PRE_CHECK_PASS.getCode(), AppointmentStatusEnum.OBSERVING.getCode());
                    break;
                case "approved":
                    statusIn = List.of(AppointmentStatusEnum.BOOKED.getCode(), AppointmentStatusEnum.CHECKED_IN.getCode(),
                            AppointmentStatusEnum.PRE_CHECK_PASS.getCode(), AppointmentStatusEnum.OBSERVING.getCode());
                    break;
                case "rejected":
                    statusIn = List.of(AppointmentStatusEnum.PRE_CHECK_FAIL.getCode(), AppointmentStatusEnum.CANCELLED.getCode());
                    break;
                case "ended":
                    statusIn = List.of(AppointmentStatusEnum.COMPLETED.getCode(), AppointmentStatusEnum.EXPIRED.getCode());
                    break;
                case "cancelled":
                    statusIn = List.of(AppointmentStatusEnum.CANCELLED.getCode());
                    break;
                default:
                    break;
            }
        }
        IPage<Appointment> page;
        if (childId != null) {
            Page<Appointment> p = new Page<>(current, size);
            LambdaQueryWrapper<Appointment> w = new LambdaQueryWrapper<>();
            w.eq(Appointment::getUserId, userId).eq(Appointment::getChildId, childId);
            if (statusIn != null && !statusIn.isEmpty()) w.in(Appointment::getStatus, statusIn);
            w.orderByDesc(Appointment::getCreateTime);
            page = page(p, w);
        } else {
            page = pageAppointments(current, size, userId, null, null, null, statusIn, null);
        }
        List<AppointmentListVO> voList = new ArrayList<>();
        for (Appointment a : page.getRecords()) {
            Vaccine v = a.getVaccineId() != null ? vaccineService.getById(a.getVaccineId()) : null;
            ChildProfile c = a.getChildId() != null ? childProfileService.getById(a.getChildId()) : null;
            VaccinationSite s = a.getSiteId() != null ? vaccinationSiteMapper.selectById(a.getSiteId()) : null;
            voList.add(AppointmentListVO.builder()
                    .id(a.getId())
                    .userId(a.getUserId())
                    .childId(a.getChildId())
                    .vaccineId(a.getVaccineId())
                    .siteId(a.getSiteId())
                    .appointmentDate(a.getAppointmentDate())
                    .timeSlot(a.getTimeSlot())
                    .status(a.getStatus())
                    .statusLabel(AppointmentStatusEnum.fromCode(a.getStatus()) != null ? AppointmentStatusEnum.fromCode(a.getStatus()).getDesc() : null)
                    .doctorId(a.getDoctorId())
                    .remark(a.getRemark())
                    .createTime(a.getCreateTime())
                    .updateTime(a.getUpdateTime())
                    .vaccineName(v != null ? v.getVaccineName() : null)
                    .childName(c != null ? c.getName() : null)
                    .siteName(s != null ? s.getSiteName() : null)
                    .doctorUnavailable(false)
                    .build());
        }
        Page<AppointmentListVO> result = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        result.setRecords(voList);
        return result;
    }

    @Override
    public int expireScheduledAfterSlotEndHours(int hoursAfterSlotEnd) {
        log.info("开始执行预约过期检查: hoursAfterSlotEnd={}", hoursAfterSlotEnd);
        return appointmentExpireService.expireScheduledAfterSlotEndHours(hoursAfterSlotEnd);
    }

    @Override
    public void cancelByUser(Long appointmentId, Long userId) {
        log.info("取消预约: appointmentId={}, userId={}", appointmentId, userId);
        appointmentCancelService.cancelByUser(appointmentId, userId);
    }

    @Override
    public boolean isDoctorSlotOccupied(Long doctorId, LocalDate appointmentDate, String timeSlot) {
        if (doctorId == null || appointmentDate == null || timeSlot == null) {
            return false;
        }

        List<Appointment> existingAppointments = list(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getDoctorId, doctorId)
                .eq(Appointment::getAppointmentDate, appointmentDate)
                .eq(Appointment::getTimeSlot, timeSlot)
                .in(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode(),
                    AppointmentStatusEnum.CHECKED_IN.getCode(),
                    AppointmentStatusEnum.PRE_CHECK_PASS.getCode(),
                    AppointmentStatusEnum.OBSERVING.getCode()));
        return !existingAppointments.isEmpty();
    }
}
