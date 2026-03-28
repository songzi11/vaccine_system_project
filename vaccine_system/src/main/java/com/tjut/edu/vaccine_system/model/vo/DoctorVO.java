package com.tjut.edu.vaccine_system.model.vo;

import com.tjut.edu.vaccine_system.model.entity.SysUser;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 医生视图对象
 * 用于API响应，移除敏感信息
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "医生视图对象")
public class DoctorVO {

    @Schema(description = "医生ID")
    private Long id;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "姓名")
    private String realName;

    @Schema(description = "手机号")
    private String phone;

    @Schema(description = "所属接种点ID")
    private Long currentSiteId;

    @Schema(description = "所属接种点名称")
    private String currentSiteName;

    @Schema(description = "状态：0已禁用 1正常")
    private Integer status;

    /**
     * 从Entity转换为VO
     */
    public static DoctorVO from(SysUser user) {
        if (user == null) {
            return null;
        }
        return DoctorVO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .realName(user.getRealName())
                .phone(user.getPhone())
                .currentSiteId(null)
                .status(user.getStatus())
                .build();
    }
}
