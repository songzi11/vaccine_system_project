package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import com.tjut.edu.vaccine_system.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.service.impl.DoctorScheduleQueryService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * 医生排班查询服务测试
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class DoctorScheduleQueryServiceTest {

    @Mock
    private DoctorScheduleMapper doctorScheduleMapper;

    @InjectMocks
    private DoctorScheduleQueryService doctorScheduleQueryService;

    /**
     * 测试查询医生排班列表
     */
    @Test
    public void testGetDoctorSchedules() {
        // Given
        List<DoctorSchedule> schedules = new ArrayList<>();
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setId(1L);
        schedule.setDoctorId(1L);
        schedule.setDate(LocalDate.now());
        schedules.add(schedule);

        when(doctorScheduleMapper.selectList(any())).thenReturn(schedules);

        // When
        List<DoctorSchedule> result = doctorScheduleQueryService.getDoctorSchedules(1L, LocalDate.now());

        // Then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        verify(doctorScheduleMapper, times(1)).selectList(any());
        log.info("查询医生排班列表测试通过");
    }

    /**
     * 测试查询接种点可用排班
     */
    @Test
    public void testGetAvailableSchedulesBySite() {
        // Given
        List<DoctorSchedule> schedules = new ArrayList<>();
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setId(1L);
        schedule.setSiteId(1L);
        schedule.setDate(LocalDate.now().plusDays(1));
        schedule.setCapacity(10);
        schedule.setBookedCount(5);
        schedule.setStatus(1);
        schedules.add(schedule);

        when(doctorScheduleMapper.selectList(any())).thenReturn(schedules);

        // When
        List<DoctorSchedule> result = doctorScheduleQueryService.getAvailableSchedulesBySite(
            1L, LocalDate.now().plusDays(1));

        // Then
        assertNotNull(result);
        verify(doctorScheduleMapper, times(1)).selectList(any());
        log.info("查询接种点可用排班测试通过");
    }

    /**
     * 测试查询排班详情
     */
    @Test
    public void testGetScheduleById() {
        // Given
        DoctorSchedule schedule = new DoctorSchedule();
        schedule.setId(1L);
        schedule.setDoctorId(1L);
        schedule.setSiteId(1L);

        when(doctorScheduleMapper.selectById(1L)).thenReturn(schedule);

        // When
        DoctorSchedule result = doctorScheduleQueryService.getScheduleById(1L);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(doctorScheduleMapper, times(1)).selectById(1L);
        log.info("查询排班详情测试通过");
    }
}
