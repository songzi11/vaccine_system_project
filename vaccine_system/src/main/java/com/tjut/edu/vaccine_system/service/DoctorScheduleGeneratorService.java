package com.tjut.edu.vaccine_system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.enums.ScheduleStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 医生排班生成服务
 * 自动生成本月和次月的医生排班
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorScheduleGeneratorService {

    private final DoctorScheduleService doctorScheduleService;
    private final SysUserService sysUserService;
    private final VaccinationSiteService vaccinationSiteService;

    /**
     * 生成指定月份的医生排班
     * @param targetMonth 目标月份 (yyyy-MM格式)
     */
    public void generateMonthlySchedules(String targetMonth) {
        log.info("开始生成{}的医生排班", targetMonth);

        // 获取所有启用的接种点
        List<VaccinationSite> sites = vaccinationSiteService.listEnabledSites();
        if (sites.isEmpty()) {
            log.warn("没有启用的接种点，跳过排班生成");
            return;
        }

        // 获取所有正常状态的医生
        List<SysUser> doctors = sysUserService.listNormalDoctors();
        if (doctors.isEmpty()) {
            log.warn("没有正常状态的医生，跳过排班生成");
            return;
        }

        // 解析目标月份
        LocalDate firstDayOfMonth = LocalDate.parse(targetMonth + "-01");
        LocalDate lastDayOfMonth = firstDayOfMonth.with(TemporalAdjusters.lastDayOfMonth());

        // 为每个接种点生成排班
        for (VaccinationSite site : sites) {
            generateSchedulesForSite(site, doctors, firstDayOfMonth, lastDayOfMonth);
        }

        log.info("完成生成{}的医生排班", targetMonth);
    }

    /**
     * 为指定接种点生成排班
     */
    private void generateSchedulesForSite(VaccinationSite site, List<SysUser> doctors,
                                        LocalDate firstDay, LocalDate lastDay) {
        log.info("为接种点{}生成{}至{}的排班", site.getSiteName(), firstDay, lastDay);

        // 为每个工作日生成排班
        LocalDate currentDate = firstDay;
        Random random = new Random();

        while (!currentDate.isAfter(lastDay)) {
            // 只在工作日（周一到周五）生成排班
            DayOfWeek dayOfWeek = currentDate.getDayOfWeek();
            if (dayOfWeek != DayOfWeek.SATURDAY && dayOfWeek != DayOfWeek.SUNDAY) {
                // 检查该日期是否已有排班
                if (!hasExistingSchedules(site.getId(), currentDate)) {
                    // 为该日期生成排班
                    generateSchedulesForDate(site, doctors, currentDate, random);
                }
            }
            currentDate = currentDate.plusDays(1);
        }
    }

    /**
     * 检查指定日期是否已有排班
     */
    private boolean hasExistingSchedules(Long siteId, LocalDate date) {
        LambdaQueryWrapper<DoctorSchedule> query = new LambdaQueryWrapper<>();
        query.eq(DoctorSchedule::getSiteId, siteId)
             .eq(DoctorSchedule::getScheduleDate, date);
        return doctorScheduleService.count(query) > 0;
    }

    /**
     * 为指定日期生成排班
     */
    private void generateSchedulesForDate(VaccinationSite site, List<SysUser> doctors,
                                        LocalDate date, Random random) {
        // 生成每15分钟一个时间段，每天8点到17点，中午12点到14点休息
        List<String> timeSlots = generateTimeSlots();

        // 根据星期几确定医生数量和容量
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int doctorCount = getDoctorCountForDay(dayOfWeek);
        int maxCapacity = getMaxCapacityForDay(dayOfWeek);

        // 随机选择医生
        List<SysUser> selectedDoctors = selectRandomDoctors(doctors, doctorCount, random);

        // 为每个时间段生成排班
        for (int i = 0; i < timeSlots.size() && i < selectedDoctors.size(); i++) {
            SysUser doctor = selectedDoctors.get(i);
            String timeSlot = timeSlots.get(i);

            DoctorSchedule schedule = DoctorSchedule.builder()
                    .doctorId(doctor.getId())
                    .siteId(site.getId())
                    .scheduleDate(date)
                    .timeSlot(timeSlot)
                    .maxCapacity(maxCapacity)
                    .currentCount(0)
                    .status(ScheduleStatusEnum.ENABLED.getCode())
                    .build();

            doctorScheduleService.save(schedule);
            log.debug("为医生{}在{} {}于{}生成排班", doctor.getRealName(), site.getSiteName(), date, timeSlot);
        }
    }

    /**
     * 生成时间槽列表：每天8点到17点，每15分钟一个时间段，中午12点到14点休息
     * @return 时间槽列表
     */
    private List<String> generateTimeSlots() {
        List<String> timeSlots = new ArrayList<>();

        // 上午时段：08:00-12:00（每15分钟一个时段）
        for (int hour = 8; hour < 12; hour++) {
            for (int minute = 0; minute < 60; minute += 15) {
                String startTime = String.format("%02d:%02d", hour, minute);
                String endTime = String.format("%02d:%02d", hour, minute + 15);
                // 处理小时进位情况
                if (minute == 45) {
                    endTime = String.format("%02d:%02d", hour + 1, 0);
                }
                timeSlots.add(startTime + "-" + endTime);
            }
        }

        // 下午时段：14:00-17:00（每15分钟一个时段）
        for (int hour = 14; hour < 17; hour++) {
            for (int minute = 0; minute < 60; minute += 15) {
                String startTime = String.format("%02d:%02d", hour, minute);
                String endTime = String.format("%02d:%02d", hour, minute + 15);
                // 处理小时进位情况
                if (minute == 45) {
                    endTime = String.format("%02d:%02d", hour + 1, 0);
                }
                timeSlots.add(startTime + "-" + endTime);
            }
        }

        return timeSlots;
    }

    /**
     * 根据星期几确定医生数量
     */
    private int getDoctorCountForDay(DayOfWeek dayOfWeek) {
        switch (dayOfWeek) {
            case MONDAY:
            case WEDNESDAY:
            case FRIDAY:
                return 2; // 工作日安排2名医生
            case TUESDAY:
            case THURSDAY:
                return 3; // 周二周四安排3名医生
            case SATURDAY:
                return 4; // 周六安排4名医生
            case SUNDAY:
                return 2; // 周日安排2名医生
            default:
                return 2;
        }
    }

    /**
     * 根据星期几确定最大容量
     */
    private int getMaxCapacityForDay(DayOfWeek dayOfWeek) {
        switch (dayOfWeek) {
            case MONDAY:
            case WEDNESDAY:
            case FRIDAY:
                return 10; // 工作日每个时段10人
            case TUESDAY:
            case THURSDAY:
                return 15; // 周二周四每个时段15人
            case SATURDAY:
                return 20; // 周六每个时段20人
            case SUNDAY:
                return 8;  // 周日每个时段8人
            default:
                return 10;
        }
    }

    /**
     * 随机选择医生
     */
    private List<SysUser> selectRandomDoctors(List<SysUser> doctors, int count, Random random) {
        if (doctors.size() <= count) {
            return new ArrayList<>(doctors);
        }

        List<SysUser> selected = new ArrayList<>();
        List<SysUser> available = new ArrayList<>(doctors);

        for (int i = 0; i < count; i++) {
            int index = random.nextInt(available.size());
            selected.add(available.remove(index));
        }

        return selected;
    }
}