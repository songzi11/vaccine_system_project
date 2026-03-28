package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.model.entity.Appointment;
import com.tjut.edu.vaccine_system.model.enums.AppointmentStatusEnum;
import com.tjut.edu.vaccine_system.service.DoctorScheduleService;
import com.tjut.edu.vaccine_system.service.SiteVaccineStockService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 预约取消服务
 * 负责预约取消的核心逻辑，包括状态校验、资源释放等
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentCancelService {

    private final AppointmentMapper appointmentMapper;
    private final DoctorScheduleService doctorScheduleService;
    private final SiteVaccineStockService siteVaccineStockService;

    /**
     * 用户取消预约
     * 仅本人、且状态为可取消(1/6/7/9/10)时允许，已预约(1)时回退排班名额
     *
     * @param appointmentId 预约ID
     * @param userId 用户ID
     */
    @Transactional(rollbackFor = Exception.class)
    public void cancelByUser(Long appointmentId, Long userId) {
        validateParams(appointmentId, userId);

        Appointment appointment = appointmentMapper.selectById(appointmentId);
        if (appointment == null) {
            log.warn("取消预约失败：预约不存在: appointmentId={}", appointmentId);
            throw new BizException(BizErrorCode.APPOINTMENT_NOT_FOUND, "预约不存在");
        }

        if (!userId.equals(appointment.getUserId())) {
            log.warn("取消预约失败：只能取消本人的预约: appointmentId={}, userId={}, actualUserId={}",
                    appointmentId, userId, appointment.getUserId());
            throw new BizException(BizErrorCode.BAD_REQUEST, "只能取消本人的预约");
        }

        int status = appointment.getStatus() != null ? appointment.getStatus() : -1;
        if (!canCancel(status)) {
            log.warn("取消预约失败：当前状态不可取消: appointmentId={}, status={}", appointmentId, status);
            throw new BizException(BizErrorCode.BAD_REQUEST, "当前状态不可取消（已完成/已取消/已过期）");
        }

        // 执行取消操作
        doCancel(appointment);

        log.info("预约取消成功: appointmentId={}, userId={}, status={}", appointmentId, userId, status);
    }

    /**
     * 验证参数
     */
    private void validateParams(Long appointmentId, Long userId) {
        if (appointmentId == null) {
            throw new BizException(BizErrorCode.BAD_REQUEST, "预约ID不能为空");
        }
        if (userId == null) {
            throw new BizException(BizErrorCode.BAD_REQUEST, "用户ID不能为空");
        }
    }

    /**
     * 判断预约是否可取消
     * 可取消：1已预约 6已签到 7预检通过 9预检未通过 10留观中
     */
    private boolean canCancel(int status) {
        return status == AppointmentStatusEnum.BOOKED.getCode()
                || status == AppointmentStatusEnum.CHECKED_IN.getCode()
                || status == AppointmentStatusEnum.PRE_CHECK_PASS.getCode()
                || status == AppointmentStatusEnum.PRE_CHECK_FAIL.getCode()
                || status == AppointmentStatusEnum.OBSERVING.getCode();
    }

    /**
     * 执行取消操作
     */
    private void doCancel(Appointment appointment) {
        // 如果是已预约状态，需要回退排班名额
        if (AppointmentStatusEnum.BOOKED.getCode() == appointment.getStatus()
                && appointment.getDoctorScheduleId() != null) {
            doctorScheduleService.decrementCurrentCount(appointment.getDoctorScheduleId());
            log.debug("回退排班名额: doctorScheduleId={}", appointment.getDoctorScheduleId());
        }

        // 回滚接种点锁定库存（site_vaccine_stock: locked -1, available +1）
        if (appointment.getBatchId() != null && appointment.getSiteId() != null) {
            siteVaccineStockService.unlockStock(appointment.getSiteId(), appointment.getBatchId());
            log.debug("回滚锁定库存: siteId={}, batchId={}", appointment.getSiteId(), appointment.getBatchId());
        }

        // 更新预约状态
        appointment.setStatus(AppointmentStatusEnum.CANCELLED.getCode());
        appointmentMapper.updateById(appointment);
    }
}
