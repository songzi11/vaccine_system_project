package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.enums.ScheduleStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.model.vo.DoctorScheduleOverviewItemVO;
import com.tjut.edu.vaccine_system.model.vo.DoctorScheduleSimpleVO;
import com.tjut.edu.vaccine_system.model.vo.TodayScheduleOverviewVO;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.service.DoctorScheduleService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DoctorScheduleServiceImpl extends ServiceImpl<DoctorScheduleMapper, DoctorSchedule> implements DoctorScheduleService {

    private final SysUserService sysUserService;
    private final VaccinationSiteMapper vaccinationSiteMapper;

    @Override
    public List<DoctorSchedule> listAvailable(Long siteId, LocalDate fromDate, LocalDate toDate) {
        if (siteId == null) return List.of();
        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();
        w.eq(DoctorSchedule::getSiteId, siteId)
                .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode())
                .apply("current_count < max_capacity");
        if (fromDate != null) w.ge(DoctorSchedule::getScheduleDate, fromDate);
        if (toDate != null) w.le(DoctorSchedule::getScheduleDate, toDate);
        w.orderByAsc(DoctorSchedule::getScheduleDate).orderByAsc(DoctorSchedule::getTimeSlot);
        List<DoctorSchedule> list = list(w);
        return filterByDoctorStatus(list);
    }

    @Override
    public List<DoctorSchedule> listBySiteAndDateRange(Long siteId, LocalDate fromDate, LocalDate toDate) {
        if (siteId == null) return List.of();
        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();
        w.eq(DoctorSchedule::getSiteId, siteId)
                .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode());

        // 设置默认的 fromDate 为今天，避免返回已过期的排班
        LocalDate effectiveFromDate = fromDate != null ? fromDate : LocalDate.now();
        w.ge(DoctorSchedule::getScheduleDate, effectiveFromDate);

        if (toDate != null) w.le(DoctorSchedule::getScheduleDate, toDate);
        w.orderByAsc(DoctorSchedule::getScheduleDate).orderByAsc(DoctorSchedule::getTimeSlot);
        List<DoctorSchedule> list = list(w);

        // 过滤掉当天已过期的时间槽
        list = list.stream().filter(schedule -> {
            LocalDate scheduleDate = schedule.getScheduleDate();
            // 如果是未来的日期，直接通过
            if (scheduleDate.isAfter(LocalDate.now())) {
                return true;
            }
            // 如果是今天，检查时间槽是否已过期
            if (scheduleDate.isEqual(LocalDate.now())) {
                LocalTime slotEndTime = parseTimeSlotEnd(schedule.getTimeSlot());
                return LocalTime.now().isBefore(slotEndTime);
            }
            // 如果是过去的日期，不通过
            return false;
        }).collect(Collectors.toList());

        return filterByDoctorStatus(list);
    }

    /** 仅保留医生状态为正常的排班（注销/禁用医生的排班不在预约排班中显示、不可选） */
    private List<DoctorSchedule> filterByDoctorStatus(List<DoctorSchedule> list) {
        if (list == null || list.isEmpty()) return list;
        Set<Long> normalDoctorIds = list.stream()
                .map(DoctorSchedule::getDoctorId)
                .distinct()
                .filter(doctorId -> {
                    SysUser user = sysUserService.getById(doctorId);
                    return user != null && Integer.valueOf(UserStatusEnum.NORMAL.getCode()).equals(user.getStatus());
                })
                .collect(Collectors.toSet());
        return list.stream().filter(s -> normalDoctorIds.contains(s.getDoctorId())).collect(Collectors.toList());
    }

    @Override
    public IPage<DoctorSchedule> page(long current, long size, Long doctorId, Long siteId, LocalDate scheduleDate, Integer status) {
        Page<DoctorSchedule> page = new Page<>(current, size);
        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();

        // 添加子查询，只查询状态正常的医生的排班
        if (doctorId != null) {
            w.eq(DoctorSchedule::getDoctorId, doctorId);
        } else {
            // 如果没有指定具体医生，则只查询状态正常的医生（status=0）的排班
            w.inSql(DoctorSchedule::getDoctorId,
                "SELECT id FROM sys_user WHERE role = 'DOCTOR' AND status = 0");
        }

        w.eq(siteId != null, DoctorSchedule::getSiteId, siteId)
                .eq(scheduleDate != null, DoctorSchedule::getScheduleDate, scheduleDate)
                .eq(status != null, DoctorSchedule::getStatus, status)
                .orderByDesc(DoctorSchedule::getScheduleDate)
                .orderByAsc(DoctorSchedule::getTimeSlot);
        return page(page, w);
    }

    @Override
    public boolean incrementCurrentCount(Long scheduleId) {
        if (scheduleId == null) return false;
        DoctorSchedule schedule = getById(scheduleId);
        if (schedule == null) return false;
        if (!ScheduleStatusEnum.isEnabled(schedule.getStatus())) return false;
        if (schedule.getCurrentCount() == null) schedule.setCurrentCount(0);
        if (schedule.getMaxCapacity() == null || schedule.getCurrentCount() >= schedule.getMaxCapacity()) return false;
        boolean ok = update(new LambdaUpdateWrapper<DoctorSchedule>()
                .eq(DoctorSchedule::getId, scheduleId)
                .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode())
                .apply("current_count < max_capacity")
                .setSql("current_count = current_count + 1"));
        return ok;
    }

    @Override
    public boolean decrementCurrentCount(Long scheduleId) {
        if (scheduleId == null) return false;
        DoctorSchedule schedule = getById(scheduleId);
        if (schedule == null) return false;
        if (schedule.getCurrentCount() == null || schedule.getCurrentCount() <= 0) return false;
        return update(new LambdaUpdateWrapper<DoctorSchedule>()
                .eq(DoctorSchedule::getId, scheduleId)
                .apply("current_count > 0")
                .setSql("current_count = current_count - 1"));
    }

    /**
     * 解析时间槽的结束时间
     */
    private static LocalTime parseTimeSlotEnd(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) return LocalTime.of(23, 59);
        String s = timeSlot.trim();
        int dash = s.indexOf('-');
        if (dash >= 0 && dash < s.length() - 1) {
            String endPart = s.substring(dash + 1).trim();
            if (!endPart.isEmpty()) {
                try {
                    return LocalTime.parse(endPart);
                } catch (Exception ignored) {
                    // 如果解析失败，继续尝试其他格式
                }
            }
        }
        try {
            return LocalTime.parse(s);
        } catch (Exception ignored) {
            return LocalTime.of(23, 59);
        }
    }

    @Override
    public TodayScheduleOverviewVO getTodayOverview(LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }

        // 查询当天的所有排班记录
        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getScheduleDate, date)
                .orderByAsc(DoctorSchedule::getTimeSlot);
        List<DoctorSchedule> schedules = list(wrapper);

        // 按医生ID分组
        Map<Long, List<DoctorSchedule>> groupedByDoctor = schedules.stream()
                .collect(Collectors.groupingBy(DoctorSchedule::getDoctorId));

        List<DoctorScheduleOverviewItemVO> doctors = new ArrayList<>();

        for (Map.Entry<Long, List<DoctorSchedule>> entry : groupedByDoctor.entrySet()) {
            Long doctorId = entry.getKey();
            List<DoctorSchedule> doctorSchedules = entry.getValue();

            // 获取医生信息
            SysUser doctor = sysUserService.getById(doctorId);
            if (doctor == null) continue;

            // 获取接种点信息（取第一个排班记录的接种点）
            Long siteId = doctorSchedules.get(0).getSiteId();
            VaccinationSite site = vaccinationSiteMapper.selectById(siteId);

            // 统计上午/下午时段数
            int morningCount = 0;
            int afternoonCount = 0;
            int totalAppointments = 0;
            boolean allEnabled = true;

            for (DoctorSchedule schedule : doctorSchedules) {
                int startHour = parseTimeSlotStart(schedule.getTimeSlot());
                if (startHour >= 8 && startHour < 12) {
                    morningCount++;
                } else if (startHour >= 14 && startHour < 17) {
                    afternoonCount++;
                }

                totalAppointments += schedule.getCurrentCount() != null ? schedule.getCurrentCount() : 0;

                if (schedule.getStatus() == null || schedule.getStatus() != 1) {
                    allEnabled = false;
                }
            }

            // 转换为简单VO
            List<DoctorScheduleSimpleVO> scheduleVOs = doctorSchedules.stream()
                    .map(s -> DoctorScheduleSimpleVO.builder()
                            .id(s.getId())
                            .doctorId(s.getDoctorId())
                            .siteId(s.getSiteId())
                            .scheduleDate(s.getScheduleDate())
                            .timeSlot(s.getTimeSlot())
                            .maxCapacity(s.getMaxCapacity())
                            .currentCount(s.getCurrentCount())
                            .status(s.getStatus())
                            .build())
                    .collect(Collectors.toList());

            DoctorScheduleOverviewItemVO item = DoctorScheduleOverviewItemVO.builder()
                    .doctorId(doctorId)
                    .doctorName(doctor.getRealName())
                    .doctorGender(doctor.getGender())
                    .doctorPhone(doctor.getPhone())
                    .siteId(siteId)
                    .siteName(site != null ? site.getSiteName() : "")
                    .morningSlotCount(morningCount)
                    .afternoonSlotCount(afternoonCount)
                    .todayAppointmentCount(totalAppointments)
                    .status(allEnabled ? "normal" : "partial")
                    .schedules(scheduleVOs)
                    .build();

            doctors.add(item);
        }

        // 获取星期
        String dayOfWeek = date.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.CHINESE);

        return TodayScheduleOverviewVO.builder()
                .date(date)
                .dayOfWeek(dayOfWeek)
                .doctors(doctors)
                .build();
    }

    @Override
    public int batchReplaceByPeriod(Long oldDoctorId, Long newDoctorId, LocalDate date, String periodType) {
        if (oldDoctorId == null || newDoctorId == null || date == null) {
            return 0;
        }

        // 查询符合条件的排班记录
        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getDoctorId, oldDoctorId)
                .eq(DoctorSchedule::getScheduleDate, date);

        List<DoctorSchedule> toReplace = list(wrapper);
        List<Long> idsToUpdate = new ArrayList<>();

        for (DoctorSchedule schedule : toReplace) {
            int startHour = parseTimeSlotStart(schedule.getTimeSlot());
            boolean shouldUpdate = false;

            if ("all".equals(periodType)) {
                shouldUpdate = true;
            } else if ("morning".equals(periodType)) {
                shouldUpdate = (startHour >= 8 && startHour < 12);
            } else if ("afternoon".equals(periodType)) {
                shouldUpdate = (startHour >= 14 && startHour < 17);
            }

            if (shouldUpdate) {
                idsToUpdate.add(schedule.getId());
            }
        }

        // 批量更新
        if (!idsToUpdate.isEmpty()) {
            LambdaUpdateWrapper<DoctorSchedule> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.in(DoctorSchedule::getId, idsToUpdate)
                    .set(DoctorSchedule::getDoctorId, newDoctorId);
            return update(updateWrapper) ? idsToUpdate.size() : 0;
        }

        return 0;
    }

    /**
     * 解析时间槽的开始小时
     */
    private static int parseTimeSlotStart(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) return 0;
        String s = timeSlot.trim();
        int dash = s.indexOf('-');
        if (dash > 0) {
            String startPart = s.substring(0, dash).trim();
            if (!startPart.isEmpty()) {
                try {
                    return Integer.parseInt(startPart.substring(0, 2));
                } catch (Exception ignored) {
                }
            }
        }
        return 0;
    }
}