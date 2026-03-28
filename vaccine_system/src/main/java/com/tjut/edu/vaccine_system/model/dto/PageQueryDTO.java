package com.tjut.edu.vaccine_system.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 分页查询请求DTO
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "分页查询请求")
public class PageQueryDTO {

    @Min(value = 1, message = "当前页码必须大于0")
    @Schema(description = "当前页码", defaultValue = "1")
    private Long current;

    @Min(value = 1, message = "每页大小必须大于0")
    @Schema(description = "每页大小", defaultValue = "20")
    private Long size;

    @Schema(description = "关键词搜索")
    private String keyword;

    @Schema(description = "状态")
    private Integer status;
}
