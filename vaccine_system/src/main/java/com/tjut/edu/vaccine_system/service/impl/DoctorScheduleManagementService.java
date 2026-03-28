package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.enums.ScheduleStatusEnum;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * 医生排班状态管理服务
 * 负责排班当前人数增减、批量替换医生等状态管理操作
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorScheduleManagementService {

    private final DoctorScheduleMapper doctorScheduleMapper;

    /**
     * 排班已预约数 +1
     * 仅当 status=启用 且 current_count < max_capacity 时更新
     *
     * @param scheduleId 排班ID
     * @return 是否更新成功
     */
    public boolean incrementCurrentCount(Long scheduleId) {
        log.info("开始增加排班当前人数，排班ID: {}", scheduleId);

        if (scheduleId == null) {
            log.warn("增加排班当前人数失败：排班ID为空");
            return false;
        }

        DoctorSchedule schedule = doctorScheduleMapper.selectById(scheduleId);
        if (schedule == null) {
            log.warn("增加排班当前人数失败：排班不存在，排班ID: {}", scheduleId);
            return false;
        }

        if (!ScheduleStatusEnum.isEnabled(schedule.getStatus())) {
            log.warn("增加排班当前人数失败：排班未启用，排班ID: {}, 状态: {}",
                    scheduleId, schedule.getStatus());
            return false;
        }

        if (schedule.getCurrentCount() == null) {
            schedule.setCurrentCount(0);
        }

        if (schedule.getMaxCapacity() == null || schedule.getCurrentCount() >= schedule.getMaxCapacity()) {
            log.warn("增加排班当前人数失败：排班已满，排班ID: {}, 当前: {}, 最大: {}",
                    scheduleId, schedule.getCurrentCount(), schedule.getMaxCapacity());
            return false;
        }

        boolean ok = doctorScheduleMapper.update(null,
                new LambdaUpdateWrapper<DoctorSchedule>()
                        .eq(DoctorSchedule::getId, scheduleId)
                        .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode())
                        .apply("current_count < max_capacity")
                        .setSql("current_count = current_count + 1"));

        if (ok) {
            log.info("排班当前人数增加成功，排班ID: {}", scheduleId);
        } else {
            log.error("排班当前人数增加失败，排班ID: {}", scheduleId);
        }

        return ok;
    }

    /**
     * 排班已预约数 -1
     * 用户取消预约时回退名额，仅当 current_count > 0 时更新
     *
     * @param scheduleId 排班ID
     * @return 是否更新成功
     */
    public boolean decrementCurrentCount(Long scheduleId) {
        log.info("开始减少排班当前人数，排班ID: {}", scheduleId);

        if (scheduleId == null) {
            log.warn("减少排班当前人数失败：排班ID为空");
            return false;
        }

        DoctorSchedule schedule = doctorScheduleMapper.selectById(scheduleId);
        if (schedule == null) {
            log.warn("减少排班当前人数失败：排班不存在，排班ID: {}", scheduleId);
            return false;
        }

        if (schedule.getCurrentCount() == null || schedule.getCurrentCount() <= 0) {
            log.warn("减少排班当前人数失败：当前人数为0，排班ID: {}", scheduleId);
            return false;
        }

        boolean ok = doctorScheduleMapper.update(null,
                new LambdaUpdateWrapper<DoctorSchedule>()
                        .eq(DoctorSchedule::getId, scheduleId)
                        .apply("current_count > 0")
                        .setSql("current_count = current_count - 1"));

        if (ok) {
            log.info("排班当前人数减少成功，排班ID: {}", scheduleId);
        } else {
            log.error("排班当前人数减少失败，排班ID: {}", scheduleId);
        }

        return ok;
    }

    /**
     * 批量替换医生排班
     * 将指定日期的排班中的医生替换为新医生
     *
     * @param oldDoctorId 被替换的医生ID
     * @param newDoctorId 新医生ID
     * @param date       日期
     * @param periodType 上午/下午/全天
     * @return 实际替换的数量
     */
    @Transactional(rollbackFor = Exception.class)
    public int batchReplaceByPeriod(Long oldDoctorId, Long newDoctorId, LocalDate date, String periodType) {
        log.info("开始批量替换医生，原医生ID: {}, 新医生ID: {}, 日期: {}, 时段: {}",
                 oldDoctorId, newDoctorId, date, periodType);

        if (oldDoctorId == null || newDoctorId == null || date == null) {
            log.warn("批量替换医生失败：参数为空");
            return 0;
        }

        // 查询符合条件的排班记录
        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getDoctorId, oldDoctorId)
                .eq(DoctorSchedule::getScheduleDate, date);

        List<DoctorSchedule> toReplace = doctorScheduleMapper.selectList(wrapper);
        log.debug("查询到待替换的排班数量: {}", toReplace.size());

        List<Long> idsToUpdate = new java.util.ArrayList<>();

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

        log.debug("实际需要替换的排班数量: {}", idsToUpdate.size());

        // 批量更新
        if (!idsToUpdate.isEmpty()) {
            LambdaUpdateWrapper<DoctorSchedule> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.in(DoctorSchedule::getId, idsToUpdate)
                    .set(DoctorSchedule::getDoctorId, newDoctorId);
            boolean ok = doctorScheduleMapper.update(null, updateWrapper);

            int count = ok ? idsToUpdate.size() : 0;
            log.info("批量替换医生完成，实际替换数量: {}", count);
            return count;
        }

        log.info("批量替换医生完成：没有需要替换的排班，替换数量: 0");
        return 0;
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
