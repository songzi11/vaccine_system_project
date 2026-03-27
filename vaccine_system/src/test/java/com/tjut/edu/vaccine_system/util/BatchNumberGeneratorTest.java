package com.tjut.edu.vaccine_system.util;

import com.tjut.edu.vaccine_system.mapper.VaccineBatchMapper;
import com.tjut.edu.vaccine_system.model.entity.Vaccine;
import com.tjut.edu.vaccine_system.service.VaccineService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BatchNumberGeneratorTest {

    @Mock
    private VaccineService vaccineService;

    @Mock
    private VaccineBatchMapper vaccineBatchMapper;

    @InjectMocks
    private BatchNumberGenerator batchNumberGenerator;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGenerateBatchNumberWithShortCode() {
        // 准备测试数据
        Long vaccineId = 1L;
        Vaccine vaccine = new Vaccine();
        vaccine.setId(vaccineId);
        vaccine.setVaccineName("乙肝疫苗");
        vaccine.setShortCode("HBV");

        // 模拟服务调用
        when(vaccineService.getById(vaccineId)).thenReturn(vaccine);
        when(vaccineBatchMapper.getMaxSequenceByVaccineAndDateWithCode(vaccineId, "HBV", anyString())).thenReturn(1);

        // 执行测试
        String batchNumber = batchNumberGenerator.generateBatchNumber(vaccineId);

        // 验证结果
        String expectedPrefix = "HBV" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertTrue(batchNumber.startsWith(expectedPrefix));
        assertEquals(expectedPrefix + "002", batchNumber); // 序号应该是002，因为数据库中最大序号是1

        // 验证方法调用
        verify(vaccineService).getById(vaccineId);
        verify(vaccineBatchMapper).getMaxSequenceByVaccineAndDateWithCode(vaccineId, "HBV", LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
    }

    @Test
    void testGenerateBatchNumberWithoutShortCode() {
        // 准备测试数据
        Long vaccineId = 2L;
        Vaccine vaccine = new Vaccine();
        vaccine.setId(vaccineId);
        vaccine.setVaccineName("百白破疫苗");
        vaccine.setShortCode(null); // 没有简称

        // 模拟服务调用
        when(vaccineService.getById(vaccineId)).thenReturn(vaccine);
        when(vaccineBatchMapper.getMaxSequenceByVaccineAndDateWithCode(vaccineId, "百白破", anyString())).thenReturn(null);

        // 执行测试
        String batchNumber = batchNumberGenerator.generateBatchNumber(vaccineId);

        // 验证结果
        String expectedPrefix = "百白破" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertTrue(batchNumber.startsWith(expectedPrefix));
        assertEquals(expectedPrefix + "001", batchNumber); // 序号应该是001，因为数据库中没有记录

        // 验证方法调用
        verify(vaccineService).getById(vaccineId);
        verify(vaccineBatchMapper).getMaxSequenceByVaccineAndDateWithCode(vaccineId, "百白破", LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
    }

    @Test
    void testGenerateShortCodeFromName() {
        // 测试中文名称
        String chineseName = "乙肝疫苗";
        String shortCode1 = batchNumberGenerator.generateBatchNumber(1L); // 这会触发generateShortCodeFromName方法

        // 测试英文名称
        Vaccine vaccine2 = new Vaccine();
        vaccine2.setId(2L);
        vaccine2.setVaccineName("Hepatitis B Vaccine");
        vaccine2.setShortCode(null);

        when(vaccineService.getById(2L)).thenReturn(vaccine2);
        when(vaccineBatchMapper.getMaxSequenceByVaccineAndDateWithCode(2L, "HBV", anyString())).thenReturn(null);

        String batchNumber2 = batchNumberGenerator.generateBatchNumber(2L);
        String expectedPrefix2 = "HBV" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertTrue(batchNumber2.startsWith(expectedPrefix2));

        // 测试空名称
        Vaccine vaccine3 = new Vaccine();
        vaccine3.setId(3L);
        vaccine3.setVaccineName("");
        vaccine3.setShortCode(null);

        when(vaccineService.getById(3L)).thenReturn(vaccine3);
        when(vaccineBatchMapper.getMaxSequenceByVaccineAndDateWithCode(3L, "VAC", anyString())).thenReturn(null);

        String batchNumber3 = batchNumberGenerator.generateBatchNumber(3L);
        String expectedPrefix3 = "VAC" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertTrue(batchNumber3.startsWith(expectedPrefix3));
    }

    @Test
    void testInvalidVaccineIdException() {
        // 准备测试数据
        Long invalidVaccineId = 999L;

        // 模拟服务调用返回null
        when(vaccineService.getById(invalidVaccineId)).thenReturn(null);

        // 执行测试并验证异常
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            batchNumberGenerator.generateBatchNumber(invalidVaccineId);
        });

        // 验证异常消息
        assertEquals("疫苗不存在，ID: " + invalidVaccineId, exception.getMessage());

        // 验证方法调用
        verify(vaccineService).getById(invalidVaccineId);
        verify(vaccineBatchMapper, never()).getMaxSequenceByVaccineAndDateWithCode(anyLong(), anyString(), anyString());
    }
}