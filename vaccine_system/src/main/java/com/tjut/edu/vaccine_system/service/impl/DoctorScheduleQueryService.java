package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.ScheduleStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 医生排班查询服务
 * 负责排班列表查询、可用排班筛选等查询相关逻辑
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorScheduleQueryService {

    private final DoctorScheduleMapper doctorScheduleMapper;
    private final SysUserService sysUserService;

    /**
     * 查询可用排班列表
     * 筛选条件：站点ID、日期范围、状态启用、未满员、医生状态正常
     *
     * @param siteId    站点ID
     * @param fromDate  开始日期
     * @param toDate    结束日期
     * @return 可用排班列表
     */
    public List<DoctorSchedule> listAvailable(Long siteId, LocalDate fromDate, LocalDate toDate) {
        log.info("开始查询可用排班，站点ID: {}, 开始日期: {}, 结束日期: {}", siteId, fromDate, toDate);

        if (siteId == null) {
            log.warn("查询可用排班失败：站点ID为空");
            return List.of();
        }

        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();
        w.eq(DoctorSchedule::getSiteId, siteId)
                .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode())
                .apply("current_count < max_capacity");
        if (fromDate != null) w.ge(DoctorSchedule::getScheduleDate, fromDate);
        if (toDate != null) w.le(DoctorSchedule::getScheduleDate, toDate);
        w.orderByAsc(DoctorSchedule::getScheduleDate).orderByAsc(DoctorSchedule::getTimeSlot);

        List<DoctorSchedule> list = doctorScheduleMapper.selectList(w);
        log.debug("查询到排班数量: {}", list.size());
        List<DoctorSchedule> result = filterByDoctorStatus(list);

        log.info("可用排班查询完成，站点ID: {}, 原始数量: {}, 过滤后数量: {}",
                siteId, list.size(), result.size());
        return result;
    }

    /**
     * 按站点和日期范围查询排班
     * 返回启用的排班（含已约满的），用于展示驻场医生排班与"已约"状态
     *
     * @param siteId    站点ID
     * @param fromDate  开始日期
     * @param toDate    结束日期
     * @return 排班列表
     */
    public List<DoctorSchedule> listBySiteAndDateRange(Long siteId, LocalDate fromDate, LocalDate toDate) {
        log.info("开始查询排班（按站点和日期范围），站点ID: {}, 开始日期: {}, 结束日期: {}",
                 siteId, fromDate, toDate);

        if (siteId == null) {
            log.warn("查询排班失败：站点ID为空");
            return List.of();
        }

        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();
        w.eq(DoctorSchedule::getSiteId, siteId)
                .eq(DoctorSchedule::getStatus, ScheduleStatusEnum.ENABLED.getCode());

        // 设置默认的 fromDate 为今天，避免返回已过期的排班
        LocalDate effectiveFromDate = fromDate != null ? fromDate : LocalDate.now();
        w.ge(DoctorSchedule::getScheduleDate, effectiveFromDate);

        if (toDate != null) w.le(DoctorSchedule::getScheduleDate, toDate);
        w.orderByAsc(DoctorSchedule::getScheduleDate).orderByAsc(DoctorSchedule::getTimeSlot);

        List<DoctorSchedule> list = doctorScheduleMapper.selectList(w);

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

        List<DoctorSchedule> result = filterByDoctorStatus(list);

        log.info("排班查询完成（按站点和日期范围），站点ID: {}, 过滤后数量: {}",
                 siteId, result.size());
        return result;
    }

    /**
     * 仅保留医生状态为正常的排班
     * 注销/禁用医生的排班不在预约排班中显示、不可选
     *
     * @param list 排班列表
     * @return 过滤后的排班列表
     */
    private List<DoctorSchedule> filterByDoctorStatus(List<DoctorSchedule> list) {
        if (list == null || list.isEmpty()) {
            return list;
        }

        Set<Long> normalDoctorIds = list.stream()
                .map(DoctorSchedule::getDoctorId)
                .distinct()
                .filter(doctorId -> {
                    SysUser user = sysUserService.getById(doctorId);
                    return user != null
                            && Integer.valueOf(UserStatusEnum.NORMAL.getCode()).equals(user.getStatus());
                })
                .collect(Collectors.toSet());

        return list.stream()
                .filter(s -> normalDoctorIds.contains(s.getDoctorId()))
                .collect(Collectors.toList());
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
}
