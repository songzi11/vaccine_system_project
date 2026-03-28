package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.constants.BusinessConstants;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.model.entity.Appointment;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.AppointmentStatusEnum;
import com.tjut.edu.vaccine_system.service.NoticeService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 预约过期服务
 * 负责预约过期的核心逻辑，包括过期检查、爽约惩罚等
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentExpireService {

    private final AppointmentMapper appointmentMapper;
    private final SysUserService sysUserService;
    private final NoticeService noticeService;

    /**
     * 将已预约且超过时段结束+指定小时未核销的预约标记为已过期
     *
     * @param hoursAfterSlotEnd 时段结束后的小时数
     * @return 过期的预约数量
     */
    @Transactional(rollbackFor = Exception.class)
    public int expireScheduledAfterSlotEndHours(int hoursAfterSlotEnd) {
        if (hoursAfterSlotEnd < 0) {
            log.warn("过期检查参数无效: hoursAfterSlotEnd={}", hoursAfterSlotEnd);
            return 0;
        }

        log.info("开始执行预约过期检查: hoursAfterSlotEnd={}", hoursAfterSlotEnd);

        // 查询所有已预约的预约
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode());
        java.util.List<Appointment> scheduled = appointmentMapper.selectList(wrapper);

        LocalDateTime now = LocalDateTime.now();
        int expiredCount = 0;

        for (Appointment appointment : scheduled) {
            if (shouldExpire(appointment, now, hoursAfterSlotEnd)) {
                expireAppointment(appointment);
                expiredCount++;
            }
        }

        log.info("预约过期检查完成: checkedCount={}, expiredCount={}", scheduled.size(), expiredCount);
        return expiredCount;
    }

    /**
     * 判断预约是否应该过期
     */
    private boolean shouldExpire(Appointment appointment, LocalDateTime now, int hoursAfterSlotEnd) {
        LocalDate date = appointment.getAppointmentDate();
        if (date == null) {
            return false;
        }

        LocalTime slotEndTime = parseTimeSlotEnd(appointment.getTimeSlot());
        LocalDateTime slotEnd = date.atTime(slotEndTime);
        LocalDateTime expireDeadline = slotEnd.plusHours(hoursAfterSlotEnd);

        return now.isAfter(expireDeadline);
    }

    /**
     * 执行预约过期操作
     */
    private void expireAppointment(Appointment appointment) {
        // 更新预约状态
        appointment.setStatus(AppointmentStatusEnum.EXPIRED.getCode());
        appointmentMapper.updateById(appointment);

        // 应用爽约惩罚
        applyNoShowPunishment(appointment.getUserId(), appointment.getAppointmentDate());

        log.info("预约已过期: appointmentId={}, userId={}, appointmentDate={}",
                appointment.getId(), appointment.getUserId(), appointment.getAppointmentDate());
    }

    /**
     * 应用爽约惩罚
     * 1. 推送警告公告
     * 2. 当日逾期未核销超过3次（≥4次）则禁约30日
     * 3. 累计爽约满3次推送冻结账号公告
     */
    private void applyNoShowPunishment(Long userId, LocalDate appointmentDate) {
        if (userId == null) {
            return;
        }

        log.info("应用爽约惩罚: userId={}, appointmentDate={}", userId, appointmentDate);

        // 1. 每次爽约：管理员端自动推送警告公告，仅该用户可见、红色框装饰
        noticeService.createSystemNoticeForUser(userId, "WARNING", "预约爽约警告",
                "您于" + appointmentDate + "的预约未按时核销，记爽约一次。请按时履约，累计爽约将影响预约资格。");

        // 2. 当日逾期未核销超过3次（即≥4次）则三十日内不得再次预约
        long sameDayExpired = countSameDayExpired(userId, appointmentDate);
        if (sameDayExpired >= BusinessConstants.DAILY_NO_SHOW_THRESHOLD) {
            banUserReservation(userId);
        }

        // 3. 累计爽约满3次：发送冻结账号功能公告（仅该用户可见）
        long totalExpired = countTotalExpired(userId);
        if (totalExpired == BusinessConstants.TOTAL_NO_SHOW_THRESHOLD) {
            noticeService.createSystemNoticeForUser(userId, "FROZEN", "账号预约冻结通知",
                    "您已累计爽约" + BusinessConstants.TOTAL_NO_SHOW_THRESHOLD + "次，三十日内不可预约，请按时履约。");
        }
    }

    /**
     * 统计当日过期预约数量
     */
    private long countSameDayExpired(Long userId, LocalDate appointmentDate) {
        return appointmentMapper.selectCount(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getUserId, userId)
                .eq(Appointment::getAppointmentDate, appointmentDate)
                .eq(Appointment::getStatus, AppointmentStatusEnum.EXPIRED.getCode()));
    }

    /**
     * 统计累计过期预约数量
     */
    private long countTotalExpired(Long userId) {
        return appointmentMapper.selectCount(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getUserId, userId)
                .eq(Appointment::getStatus, AppointmentStatusEnum.EXPIRED.getCode()));
    }

    /**
     * 禁用用户预约权限
     */
    private void banUserReservation(Long userId) {
        SysUser user = sysUserService.getById(userId);
        if (user != null) {
            user.setReservationBanUntil(LocalDateTime.now().plusDays(BusinessConstants.NO_SHOW_BAN_DAYS));
            sysUserService.updateById(user);
            log.warn("用户预约禁用: userId={}, banUntil={}", userId, user.getReservationBanUntil());
        }
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
                } catch (java.time.format.DateTimeParseException ignored) {
                    // 如果解析失败，继续尝试其他格式
                }
            }
        }

        // 处理 HH:mm 格式
        try {
            return LocalTime.parse(s);
        } catch (java.time.format.DateTimeParseException ignored) {
            // 如果解析失败，返回默认值
            return LocalTime.of(23, 59);
        }
    }
}
