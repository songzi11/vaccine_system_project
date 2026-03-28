package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.entity.Appointment;
import com.tjut.edu.vaccine_system.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.mapper.SiteVaccineMapper;
import com.tjut.edu.vaccine_system.service.impl.AppointmentCancelService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

/**
 * 预约取消服务测试
 *
 * 测试内容：
 * 1. 正常取消预约
 * 2. 预约不存在时抛出异常
 * 3. 预约状态不正确时抛出异常
 * 4. 资源释放（排班名额、库存）验证
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class AppointmentCancelServiceTest {

    @Mock
    private AppointmentMapper appointmentMapper;

    @Mock
    private DoctorScheduleMapper doctorScheduleMapper;

    @Mock
    private SiteVaccineMapper siteVaccineMapper;

    @InjectMocks
    private AppointmentCancelService appointmentCancelService;

    private Appointment testAppointment;
    private DoctorSchedule testSchedule;

    @BeforeEach
    public void setUp() {
        // 初始化测试数据
        testAppointment = new Appointment();
        testAppointment.setId(1L);
        testAppointment.setUserId(1L);
        testAppointment.setChildId(1L);
        testAppointment.setVaccineId(1L);
        testAppointment.setSiteId(1L);
        testAppointment.setScheduleId(1L);
        testAppointment.setStatus("PENDING"); // 待审批状态
        testAppointment.setCreateTime(LocalDateTime.now());

        testSchedule = new DoctorSchedule();
        testSchedule.setId(1L);
        testSchedule.setCapacity(10);
        testSchedule.setBookedCount(5);
        testSchedule.setStatus(1);
    }

    /**
     * 测试正常取消预约
     */
    @Test
    public void testCancelAppointmentSuccess() {
        // Given
        when(appointmentMapper.selectById(1L)).thenReturn(testAppointment);
        when(doctorScheduleMapper.selectById(1L)).thenReturn(testSchedule);
        when(appointmentMapper.updateById(any(Appointment.class))).thenReturn(1);

        // When
        boolean result = appointmentCancelService.cancelAppointment(1L, 1L);

        // Then
        assertTrue(result);
        assertEquals("CANCELLED", testAppointment.getStatus());
        verify(appointmentMapper, times(1)).updateById(any(Appointment.class));
        verify(doctorScheduleMapper, times(1)).updateById(any(DoctorSchedule.class));
        log.info("正常取消预约测试通过");
    }

    /**
     * 测试预约不存在
     */
    @Test
    public void testCancelAppointmentNotFound() {
        // Given
        when(appointmentMapper.selectById(999L)).thenReturn(null);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCancelService.cancelAppointment(999L, 1L);
        });

        assertEquals(BizErrorCode.APPOINTMENT_NOT_FOUND.getCode(), exception.getCode());
        log.info("预约不存在异常测试通过");
    }

    /**
     * 测试预约权限校验
     */
    @Test
    public void testCancelAppointmentPermissionDenied() {
        // Given
        when(appointmentMapper.selectById(1L)).thenReturn(testAppointment);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            // 使用不同的用户ID（999L）尝试取消
            appointmentCancelService.cancelAppointment(1L, 999L);
        });

        log.info("预约权限校验测试通过");
    }

    /**
     * 测试预约状态校验
     */
    @Test
    public void testCancelAppointmentAlreadyCompleted() {
        // Given
        testAppointment.setStatus("COMPLETED"); // 已完成状态
        when(appointmentMapper.selectById(1L)).thenReturn(testAppointment);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCancelService.cancelAppointment(1L, 1L);
        });

        log.info("预约状态校验测试通过");
    }
}
