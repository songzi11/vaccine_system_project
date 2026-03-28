package com.tjut.edu.vaccine_system.model.vo;

import com.tjut.edu.vaccine_system.model.entity.Vaccine;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 疫苗视图对象
 * 用于API响应
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "疫苗视图对象")
public class VaccineVO {

    @Schema(description = "疫苗ID")
    private Long id;

    @Schema(description = "疫苗名称")
    private String vaccineName;

    @Schema(description = "分类：CLASS_I一类疫苗 CLASS_II二类疫苗")
    private String category;

    @Schema(description = "厂商")
    private String manufacturer;

    @Schema(description = "说明")
    private String description;

    @Schema(description = "不良反应说明")
    private String adverseReactionDesc;

    @Schema(description = "适用起始月龄")
    private Integer applicableAgeMonths;

    @Schema(description = "剂次间隔天数")
    private Integer intervalDays;

    @Schema(description = "价格")
    private BigDecimal price;

    @Schema(description = "状态：0已下架 1上架")
    private Integer status;

    @Schema(description = "创建时间")
    private java.time.LocalDateTime createTime;

    /**
     * 从Entity转换为VO
     */
    public static VaccineVO from(Vaccine vaccine) {
        if (vaccine == null) {
            return null;
        }
        return VaccineVO.builder()
                .id(vaccine.getId())
                .vaccineName(vaccine.getVaccineName())
                .category(vaccine.getCategory())
                .manufacturer(vaccine.getManufacturer())
                .description(vaccine.getDescription())
                .adverseReactionDesc(vaccine.getAdverseReactionDesc())
                .applicableAgeMonths(vaccine.getApplicableAgeMonths())
                .intervalDays(vaccine.getIntervalDays())
                .price(null)
                .status(vaccine.getStatus())
                .createTime(vaccine.getCreateTime())
                .build();
    }
}
