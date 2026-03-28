package com.tjut.edu.vaccine_system.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 疫苗查询请求DTO
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Schema(description = "疫苗查询请求")
public class VaccineQueryDTO extends PageQueryDTO {

    @Schema(description = "疫苗名称（模糊查询）")
    private String vaccineName;

    @Schema(description = "分类：CLASS_I一类疫苗 CLASS_II二类疫苗")
    private String category;

    @Schema(description = "厂商")
    private String manufacturer;

    @Schema(description = "上架状态：0已下架 1上架")
    private Integer status;
}
