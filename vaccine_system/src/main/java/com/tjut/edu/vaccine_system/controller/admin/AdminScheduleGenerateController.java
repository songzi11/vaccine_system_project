package com.tjut.edu.vaccine_system.controller.admin;

import com.tjut.edu.vaccine_system.common.result.Result;
import com.tjut.edu.vaccine_system.service.DoctorScheduleGeneratorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * 管理员-排班生成功能
 * 提供手动触发排班生成功能
 */
@Slf4j
@RestController
@RequestMapping(value = {"/admin/schedule-generate", "/api/admin/schedule-generate"})
@RequiredArgsConstructor
@Tag(name = "管理员-排班生成")
public class AdminScheduleGenerateController {

    private final DoctorScheduleGeneratorService doctorScheduleGeneratorService;

    @Operation(summary = "手动触发生成本月和次月排班")
    @PostMapping("/generate-current-and-next-month")
    public Result<String> generateCurrentAndNextMonthSchedules() {
        try {
            log.info("管理员手动触发生成本月和次月排班");

            // 生成本月排班
            String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(currentMonth);

            // 生成次月排班
            String nextMonth = LocalDate.now().plusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
            doctorScheduleGeneratorService.generateMonthlySchedules(nextMonth);

            String message = String.format("成功生成%s和%s的排班", currentMonth, nextMonth);
            log.info(message);
            return Result.ok(message);
        } catch (Exception e) {
            log.error("手动触发生成排班失败", e);
            return Result.fail(500, "生成排班失败：" + e.getMessage());
        }
    }

    @Operation(summary = "手动触发生成指定月份排班")
    @PostMapping("/generate-by-month")
    public Result<String> generateSchedulesByMonth(@RequestParam String targetMonth) {
        try {
            log.info("管理员手动触发生成{}排班", targetMonth);

            // 验证月份格式
            if (!targetMonth.matches("\\d{4}-\\d{2}")) {
                return Result.fail(400, "月份格式错误，应为 yyyy-MM 格式");
            }

            doctorScheduleGeneratorService.generateMonthlySchedules(targetMonth);

            String message = String.format("成功生成%s的排班", targetMonth);
            log.info(message);
            return Result.ok(message);
        } catch (Exception e) {
            log.error("手动触发生成{}排班失败", targetMonth, e);
            return Result.fail(500, "生成排班失败：" + e.getMessage());
        }
    }
}