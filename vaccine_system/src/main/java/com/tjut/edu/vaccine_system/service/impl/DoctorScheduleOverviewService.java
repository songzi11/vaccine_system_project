package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.vo.DoctorScheduleOverviewItemVO;
import com.tjut.edu.vaccine_system.model.vo.DoctorScheduleSimpleVO;
import com.tjut.edu.vaccine_system.model.vo.TodayScheduleOverviewVO;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.TextStyle;
import java.util.*;

/**
 * 医生排班概览服务
 * 负责今日排班概览的复杂查询和数据组装
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorScheduleOverviewService {

    private final DoctorScheduleMapper doctorScheduleMapper;
    private final SysUserService sysUserService;
    private final VaccinationSiteMapper vaccinationSiteMapper;

    /**
     * 获取今日排班概览
     * 按医生分组，统计上午/下午时段数、今日预约数等
     *
     * @param date 日期（默认为今天）
     * @return 今日排班概览VO
     */
    public TodayScheduleOverviewVO getTodayOverview(LocalDate date) {
        log.info("开始获取今日排班概览，日期: {}", date);

        if (date == null) {
            date = LocalDate.now();
        }

        // 查询当天的所有排班记录
        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getScheduleDate, date)
                .orderByAsc(DoctorSchedule::getTimeSlot);
        List<DoctorSchedule> schedules = doctorScheduleMapper.selectList(wrapper);
        log.debug("查询到排班记录数量: {}", schedules.size());

        // 按医生ID分组
        Map<Long, List<DoctorSchedule>> groupedByDoctor = schedules.stream()
                .collect(Collectors.groupingBy(DoctorSchedule::getDoctorId));

        List<DoctorScheduleOverviewItemVO> doctors = new ArrayList<>();

        for (Map.Entry<Long, List<DoctorSchedule>> entry : groupedByDoctor.entrySet()) {
            Long doctorId = entry.getKey();
            List<DoctorSchedule> doctorSchedules = entry.getValue();

            // 获取医生信息
            SysUser doctor = sysUserService.getById(doctorId);
            if (doctor == null) {
                log.debug("排班关联的医生不存在，医生ID: {}", doctorId);
                continue;
            }

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
                    .morningSlotCount(m(morningCount)
                    .afternoonSlotCount(afternoonCount)
                    .todayAppointmentCount(totalAppointments)
                    .status(allEnabled ? "normal" : "partial")
                    .schedules(scheduleVOs)
                    .build();

            doctors.add(item);
        }

        // 获取星期
        String dayOfWeek = date.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.CHINESE);

        TodayScheduleOverviewVO result = TodayScheduleOverviewVO.builder()
                .date(date)
                .dayOfWeek(dayOfWeek)
                .doctors(doctors)
                .build();

        log.info("今日排班概览获取完成，日期: {}, 医生数: {}", date, doctors.size());
        return result;
    }

    /**
     * 解析时间槽的结束时间
     *
     * @param timeSlot 时间槽字符串，如 "08:00-09:00"
     * @return 结束时间
     */
    private static LocalTime parseTimeSlotEnd(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) {
            return LocalTime.of(23, 59);
        }
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

    /**
     * 解析时间槽的开始小时
     *
     * @param timeSlot 时间槽字符串，如 "08:00-09:00"
     * @return 开始小时
     */
    private static int parseTimeSlotStart(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) {
            return 0;
        }
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
