package com.tjut.edu.vaccine_system.util;

import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.mapper.VaccineBatchMapper;
import com.tjut.edu.vaccine_system.model.entity.Vaccine;
import com.tjut.edu.vaccine_system.service.VaccineService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Slf4j
@Component
public class BatchNumberGenerator {

    private final VaccineService vaccineService;
    private final VaccineBatchMapper vaccineBatchMapper;

    // 构造函数
    public BatchNumberGenerator(VaccineService vaccineService, VaccineBatchMapper vaccineBatchMapper) {
        this.vaccineService = vaccineService;
        this.vaccineBatchMapper = vaccineBatchMapper;
    }

    /**
     * 生成批次号：疫苗缩写+日期+三位序号
     * 格式如：HBV20260326001
     *
     * @param vaccineId 疫苗ID
     * @return 生成的批次号
     */
    public String generateBatchNumber(Long vaccineId) {
        if (vaccineId == null) {
            throw new BizException(BizErrorCode.BAD_REQUEST, "疫苗ID不能为空");
        }

        // 获取疫苗信息
        Vaccine vaccine = vaccineService.getById(vaccineId);
        if (vaccine == null) {
            throw new BizException(BizErrorCode.VACCINE_NOT_FOUND, "疫苗不存在，ID: " + vaccineId);
        }

        // 获取疫苗简称，如果为空则使用疫苗名称的首字母
        String shortCode = vaccine.getShortCode();
        if (shortCode == null || shortCode.trim().isEmpty()) {
            shortCode = generateShortCodeFromName(vaccine.getVaccineName());
        }

        // 获取当前日期
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        // 生成序号
        String sequence = "001"; // 默认序号
        try {
            sequence = getNextSequence(vaccineId, shortCode, dateStr);
        } catch (Exception e) {
            log.warn("获取序号失败，使用默认序号001", e);
        }

        return shortCode.toUpperCase() + dateStr + sequence;
    }

    /**
     * 根据疫苗名称生成简称
     *
     * @param vaccineName 疫苗名称
     * @return 疫苗简称
     */
    private String generateShortCodeFromName(String vaccineName) {
        if (vaccineName == null || vaccineName.isEmpty()) {
            return "VAC";
        }

        // 提取每个中文字符的拼音首字母或者英文单词首字母
        StringBuilder sb = new StringBuilder();
        String[] words = vaccineName.split("[\\s-]+");

        if (words.length == 1 && !vaccineName.matches(".*[a-zA-Z].*")) {
            // 如果是纯中文，提取关键字符
            String name = vaccineName.replaceAll("[\\W&&[^\\u4e00-\\u9fa5]]+", "");
            if (name.length() >= 3) {
                // 取前三个字的拼音首字母（这里简化处理）
                sb.append(name.substring(0, 3).toUpperCase());
            } else {
                sb.append(name.toUpperCase());
            }
        } else {
            // 英文名称或其他情况，取每个单词首字母
            for (String word : words) {
                if (!word.isEmpty()) {
                    sb.append(Character.toUpperCase(word.charAt(0)));
                    if (sb.length() >= 5) break; // 最多取5个字符
                }
            }
        }

        return sb.length() > 0 ? sb.toString() : "VAC";
    }

    /**
     * 获取下一个序号（按疫苗类型递增）
     *
     * @param vaccineId 疫苗ID
     * @param shortCode 疫苗简称
     * @param dateStr 日期字符串
     * @return 三位序号字符串
     */
    private String getNextSequence(Long vaccineId, String shortCode, String dateStr) {
        // 查询当天该疫苗的最大序号
        Integer maxSequence = null;
        try {
            maxSequence = vaccineBatchMapper.getMaxSequenceByVaccineAndDateWithCode(vaccineId, shortCode, dateStr);
        } catch (Exception e) {
            log.warn("查询最大序号失败", e);
        }

        // 计算下一个序号
        int nextSequence = (maxSequence == null) ? 1 : maxSequence + 1;

        // 格式化为三位数字字符串
        return String.format("%03d", nextSequence);
    }
}