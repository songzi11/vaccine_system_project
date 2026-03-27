package com.tjut.edu.vaccine_system.task;

import com.tjut.edu.vaccine_system.service.DoctorScheduleGeneratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * 医生排班自动生成定时任务
 * 每月1日凌晨生成本月和次月的排班
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DoctorScheduleAutoGenerateTask {

    private final DoctorScheduleGeneratorService doctorScheduleGeneratorService;

    /**
     * 每月1日凌晨1点执行：自动生成本月和次月的医生排班
     * cron表达式：0 0 1 1 * ? （每月1日1点执行）
     */
    @Scheduled(cron = "0 0 1 1 * ?")
    public void autoGenerateMonthlySchedules() {
        try {
            log.info("开始执行医生排班自动生成任务");

            // 生成本月排班
            String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(currentMonth);

            // 生成次月排班
            String nextMonth = LocalDate.now().plusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(nextMonth);

            log.info("医生排班自动生成任务执行完成");
        } catch (Exception e) {
            log.error("医生排班自动生成任务执行失败", e);
        }
    }

    /**
     * 每日检查：确保本月和次月都有排班数据
     * 每天凌晨2点执行
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void dailyCheckAndGenerateSchedules() {
        try {
            log.info("开始执行每日排班检查任务");

            // 检查并生成本月排班（如果还没有）
            String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(currentMonth);

            // 检查并生成次月排班（如果还没有）
            String nextMonth = LocalDate.now().plusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(nextMonth);

            log.info("每日排班检查任务执行完成");
        } catch (Exception e) {
            log.error("每日排班检查任务执行失败", e);
        }
    }
}