package com.tjut.edu.vaccine_system.model.vo;

import com.tjut.edu.vaccine_system.model.entity.VaccineBatch;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 疫苗批次视图对象
 * 用于API响应
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "疫苗批次视图对象")
public class BatchVO {

    @Schema(description = "批次ID")
    private Long id;

    @Schema(description = "疫苗ID")
    private Long vaccineId;

    @Schema(description = "疫苗名称")
    private String vaccineName;

    @Schema(description = "批号")
    private String batchNo;

    @Schema(description = "生产日期")
    private LocalDate productionDate;

    @Schema(description = "有效期至")
    private LocalDate expiryDate;

    @Schema(description = "库存数量")
    private Integer stock;

    @Schema(description = "预警天数")
    private Integer warningDays;

    @Schema(description = "状态：0正常 1临期 2过期 3已销毁")
    private Integer status;

    @Schema(description = "创建时间")
    private java.time.LocalDateTime createTime;

    /**
     * 从Entity转换为VO
     */
    public static BatchVO from(VaccineBatch batch) {
        if (batch == null) {
            return null;
        }
        return BatchVO.builder()
                .id(batch.getId())
                .vaccineId(batch.getVaccineId())
                .batchNo(batch.getBatchNo())
                .productionDate(batch.getProductionDate())
                .expiryDate(batch.getExpiryDate())
                .stock(batch.getStock())
                .warningDays(batch.getWarningDays())
                .status(batch.getStatus())
                .createTime(batch.getCreatedAt())
                .build();
    }

    /**
     * 从Entity转换为VO（带疫苗名称）
     */
    public static BatchVO from(VaccineBatch batch, String vaccineName) {
        BatchVO vo = from(batch);
        if (vo != null) {
            vo.setVaccineName(vaccineName);
        }
        return vo;
    }
}
