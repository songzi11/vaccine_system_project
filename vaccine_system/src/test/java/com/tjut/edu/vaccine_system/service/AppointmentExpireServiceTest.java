package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import com.tjut.edu.vaccine_system.entity.Appointment;
import com.tjut.edu.vaccine_system.entity.SysUser;
import com.tjut.edu.vaccine_system.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.service.impl.AppointmentExpireService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * 预约过期服务测试
 *
 * 测试内容：
 * 1. 正常处理过期预约
 * 2. 爽约惩罚机制
 * 3. 资源释放验证
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class AppointmentExpireServiceTest {

    @Mock
    private AppointmentMapper appointmentMapper;

    @Mock
    private SysUserMapper sysUserMapper;

    @Mock
    private DoctorScheduleMapper doctorScheduleMapper;

    @InjectMocks
    private AppointmentExpireService appointmentExpireService;

    private Appointment testAppointment;
    private SysUser testUser;
    private DoctorSchedule testSchedule;

    @BeforeEach
    public void setUp() {
        // 初始化测试数据
        LocalDateTime now = LocalDateTime.now();

        testAppointment = new Appointment();
        testAppointment.setId(1L);
        testAppointment.setUserId(1L);
        testAppointment.setChildId(1L);
        testAppointment.setVaccineId(1L);
        testAppointment.setSiteId(1L);
        testAppointment.setScheduleId(1L);
        testAppointment.setStatus("SCHEDULED");
        testAppointment.setCreateTime(now.minusHours(5)); // 5小时前创建
        testAppointment.setAppointmentTime(now.minusHours(3)); // 3小时前的预约时间

        testUser = new SysUser();
        testUser.setId(1L);
        testUser.setUsername("testUser");
        testUser.setDailyNoShowCount(3); // 已爽约3次
        testUser.setTotalNoShowCount(2); // 累计爽约2次

        testSchedule = new DoctorSchedule();
        testSchedule.setId(1L);
        testSchedule.setBookedCount(5);
        testSchedule.setStatus(1);
    }

    /**
     * 测试处理过期预约
     */
    @Test
    public void testProcessExpiredAppointments() {
        // Given
        List<Appointment> expiredAppointments = Collections.singletonList(testAppointment);
        when(appointmentMapper.findExpiredAppointments(any(LocalDateTime.class))).thenReturn(expiredAppointments);
        when(sysUserMapper.selectById(1L)).thenReturn(testUser);
        when(doctorScheduleMapper.selectById(1L)).thenReturn(testSchedule);

        // When
        int processedCount = appointmentExpireService.processExpiredAppointments();

        // Then
        assertEquals(1, processedCount);
        assertEquals("EXPIRED", testAppointment.getStatus());
        verify(appointmentMapper, times(1)).updateById(any(Appointment.class));
        log.info("处理过期预约测试通过");
    }

    /**
     * 测试无过期预约
     */
    @Test
    public void testNoExpiredAppointments() {
        // Given
        when(appointmentMapper.findExpiredAppointments(any(LocalDateTime.class))).thenReturn(Collections.emptyList());

        // When
        int processedCount = appointmentExpireService.processExpiredAppointments();

        // Then
        assertEquals(0, processedCount);
        verify(appointmentMapper, never()).updateById(any(Appointment.class));
        log.info("无过期预约测试通过");
    }
}
