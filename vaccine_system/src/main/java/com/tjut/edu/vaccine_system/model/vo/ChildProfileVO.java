package com.tjut.edu.vaccine_system.model.vo;

import com.tjut.edu.vaccine_system.model.entity.ChildProfile;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 儿童档案视图对象
 * 用于API响应
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "儿童档案视图对象")
public class ChildProfileVO {

    @Schema(description = "儿童ID")
    private Long id;

    @Schema(description = "家长ID")
    private Long parentId;

    @Schema(description = "家长姓名")
    private String parentName;

    @Schema(description = "儿童姓名")
    private String name;

    @Schema(description = "性别：0-男 1-女")
    private Integer gender;

    @Schema(description = "出生日期")
    private LocalDate birthDate;

    @Schema(description = "接种证号")
    private String vaccinationCardNo;

    @Schema(description = "禁忌症/过敏史")
    private String contraindicationAllergy;

    @Schema(description = "创建时间")
    private java.time.LocalDateTime createTime;

    /**
     * 从Entity转换为VO
     */
    public static ChildProfileVO from(ChildProfile child, String parentName) {
        if (child == null) {
            return null;
        }
        return ChildProfileVO.builder()
                .id(child.getId())
                .parentId(child.getParentId())
                .parentName(parentName)
                .name(child.getName())
                .gender(child.getGender())
                .birthDate(child.getBirthDate())
                .vaccinationCardNo(child.getVaccinationCardNo())
                .contraindicationAllergy(child.getContraindicationAllergy())
                .createTime(child.getCreateTime())
                .build();
    }
}
