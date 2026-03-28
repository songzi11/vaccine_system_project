package com.tjut.edu.vaccine_system.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

/**
 * 儿童查询请求DTO
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Getter
@Setter
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Schema(description = "儿童查询请求")
public class ChildQueryDTO extends PageQueryDTO {

    @Schema(description = "儿童姓名（模糊查询）")
    private String name;

    @Schema(description = "家长ID")
    private Long parentId;

    @Schema(description = "性别：0-男 1-女")
    private Integer gender;

    public ChildQueryDTO(String name, Long parentId, Integer gender) {
        this.name = name;
        this.parentId = parentId;
        this.gender = gender;
    }

    public ChildQueryDTO(Long current, Long size, String keyword, Integer status, String name, Long parentId, Integer gender) {
        super(current, size, keyword, status);
        this.name = name;
        this.parentId = parentId;
        this.gender = gender;
    }
}
