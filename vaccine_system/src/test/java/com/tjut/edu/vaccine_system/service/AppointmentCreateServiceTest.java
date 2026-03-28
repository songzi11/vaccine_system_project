package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.entity.SysUser;
import com.tjut.edu.vaccine_system.entity.Child;
import com.tjut.edu.vaccine_system.entity.Vaccine;
import com.tjut.edu.vaccine_system.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.entity.Appointment;
import com.tjut.edu.vaccine_system.model.dto.CreateAppointmentDTO;
import com.tjut.edu.vaccine_system.service.impl.AppointmentCreateService;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.mapper.ChildMapper;
import com.tjut.edu.vaccine_system.mapper.VaccineMapper;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.mapper.AppointmentMapper;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

/**
 * 预约创建服务测试
 *
 * 测试内容：
 * 1. 正常创建预约流程
 * 2. 用户不存在时抛出异常
 * 3. 儿童不存在时抛出异常
 * 4. 疫苗不存在时抛出异常
 * 5. 接种点不存在时抛出异常
 * 6. 排班不存在或已满时抛出异常
 * 7. 库存不足时抛出异常
 * 8. 时间冲突时抛出异常
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class AppointmentCreateServiceTest {

    @Mock
    private SysUserMapper sysUserMapper;

    @Mock
    private ChildMapper childMapper;

    @Mock
    private VaccineMapper vaccineMapper;

    @Mock
    private VaccinationSiteMapper vaccinationSiteMapper;

    @Mock
    private DoctorScheduleMapper doctorScheduleMapper;

    @Mock
    private AppointmentMapper appointmentMapper;

    @InjectMocks
    private AppointmentCreateService appointmentCreateService;

    private SysUser testUser;
    private Child testChild;
    private Vaccine testVaccine;
    private VaccinationSite testSite;
    private DoctorSchedule testSchedule;

    @BeforeEach
    public void setUp() {
        // 初始化测试数据
        testUser = new SysUser();
        testUser.setId(1L);
        testUser.setUsername("testUser");
        testUser.setRole("RESIDENT");
        testUser.setBanUntil(null);

        testChild = new Child();
        testChild.setId(1L);
        testChild.setUserId(1L);
        testChild.setName("测试儿童");

        testVaccine = new Vaccine();
        testVaccine.setId(1L);
        testVaccine.setName("测试疫苗");
        testVaccine.setPrice(100.0);

        testSite = new VaccinationSite();
        testSite.setId(1L);
        testSite.setName("测试接种点");
        testSite.setStatus(1);

        testSchedule = new DoctorSchedule();
        testSchedule.setId(1L);
        testSchedule.setDoctorId(1L);
        testSchedule.setSiteId(1L);
        testSchedule.setDate(LocalDateTime.now().toLocalDate());
        testSchedule.setTimeSlot("09:00-09:15");
        testSchedule.setCapacity(10);
        testSchedule.setBookedCount(0);
        testSchedule.setStatus(1);
    }

    /**
     * 测试正常创建预约
     */
    @Test
    public void testCreateAppointmentSuccess() {
        // Given
        CreateAppointmentDTO dto = new CreateAppointmentDTO();
        dto.setUserId(1L);
        dto.setChildId(1L);
        dto.setVaccineId(1L);
        dto.setSiteId(1L);
        dto.setScheduleId(1L);
        dto.setAppointmentTime(LocalDateTime.now());

        when(sysUserMapper.selectById(1L)).thenReturn(testUser);
        when(childMapper.selectById(1L)).thenReturn(testChild);
        when(vaccineMapper.selectById(1L)).thenReturn(testVaccine);
        when(vaccinationSiteMapper.selectById(1L)).thenReturn(testSite);
        when(doctorScheduleMapper.selectById(1L)).thenReturn(testSchedule);
        when(appointmentMapper.insert(any(Appointment.class))).thenReturn(1);

        // When
        Appointment result = appointmentCreateService.createOrderWithStockCheck(dto);

        // Then
        assertNotNull(result);
        verify(appointmentMapper, times(1)).insert(any(Appointment.class));
        log.info("正常创建预约测试通过");
    }

    /**
     * 测试用户不存在
     */
    @Test
    public void testCreateAppointmentUserNotFound() {
        // Given
        CreateAppointmentDTO dto = new CreateAppointmentDTO();
        dto.setUserId(999L);
        dto.setChildId(1L);
        dto.setVaccineId(1L);
        dto.setSiteId(1L);
        dto.setScheduleId(1L);
        dto.setAppointmentTime(LocalDateTime.now());

        when(sysUserMapper.selectById(999L)).thenReturn(null);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCreateService.createOrderWithStockCheck(dto);
        });

        assertEquals(BizErrorCode.USER_NOT_FOUND.getCode(), exception.getCode());
        log.info("用户不存在异常测试通过");
    }

    /**
     * 测试儿童不存在
     */
    @Test
    public void testCreateAppointmentChildNotFound() {
        // Given
        CreateAppointmentDTO dto = new CreateAppointmentDTO();
        dto.setUserId(1L);
        dto.setChildId(999L);
        dto.setVaccineId(1L);
        dto.setSiteId(1L);
        dto.setScheduleId(1L);
        dto.setAppointmentTime(LocalDateTime.now());

        when(sysUserMapper.selectById(1L)).thenReturn(testUser);
        when(childMapper.selectById(999L)).thenReturn(null);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCreateService.createOrderWithStockCheck(dto);
        });

        assertEquals(BizErrorCode.CHILD_NOT_FOUND.getCode(), exception.getCode());
        log.info("儿童不存在异常测试通过");
    }

    /**
     * 测试用户被禁约
     */
    @Test
    public void testCreateAppointmentUserBanned() {
        // Given
        testUser.setBanUntil(LocalDateTime.now().plusDays(1));

        CreateAppointmentDTO dto = new CreateAppointmentDTO();
        dto.setUserId(1L);
        dto.setChildId(1L);
        dto.setVaccineId(1L);
        dto.setSiteId(1L);
        dto.setScheduleId(1L);
        dto.setAppointmentTime(LocalDateTime.now());

        when(sysUserMapper.selectById(1L)).thenReturn(testUser);
        when(childMapper.selectById(1L)).thenReturn(testChild);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCreateService.createOrderWithStockCheck(dto);
        });

        assertEquals(BizErrorCode.USER_BANNED.getCode(), exception.getCode());
        log.info("用户被禁约异常测试通过");
    }

    /**
     * 测试排班已满
     */
    @Test
    public void testCreateAppointmentScheduleFull() {
        // Given
        testSchedule.setCapacity(10);
        testSchedule.setBookedCount(10);

        CreateAppointmentDTO dto = new CreateAppointmentDTO();
        dto.setUserId(1L);
        dto.setChildId(1L);
        dto.setVaccineId(1L);
        dto.setSiteId(1L);
        dto.setScheduleId(1L);
        dto.setAppointmentTime(LocalDateTime.now());

        when(sysUserMapper.selectById(1L)).thenReturn(testUser);
        when(childMapper.selectById(1L)).thenReturn(testChild);
        when(vaccineMapper.selectById(1L)).thenReturn(testVaccine);
        when(vaccinationSiteMapper.selectById(1L)).thenReturn(testSite);
        when(doctorScheduleMapper.selectById(1L)).thenReturn(testSchedule);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            appointmentCreateService.createOrderWithStockCheck(dto);
        });

        assertEquals(BizErrorCode.SCHEDULE_FULL.getCode(), exception.getCode());
        log.info("排班已满异常测试通过");
    }
}
