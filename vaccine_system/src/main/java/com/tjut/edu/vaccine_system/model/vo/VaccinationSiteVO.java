package com.tjut.edu.vaccine_system.model.vo;

import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 接种点视图对象
 * 用于API响应
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "接种点视图对象")
public class VaccinationSiteVO {

    @Schema(description = "接种点ID")
    private Long id;

    @Schema(description = "接种点名称")
    private String siteName;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "经度")
    private Double longitude;

    @Schema(description = "纬度")
    private Double latitude;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "营业时间")
    private String workTime;

    @Schema(description = "状态：0已禁用 1正常")
    private Integer status;

    @Schema(description = "创建时间")
    private java.time.LocalDateTime createTime;

    /**
     * 从Entity转换为VO
     */
    public static VaccinationSiteVO from(VaccinationSite site) {
        if (site == null) {
            return null;
        }
        return VaccinationSiteVO.builder()
                .id(site.getId())
                .siteName(site.getSiteName())
                .address(site.getAddress())
                .longitude(null)
                .latitude(null)
                .contactPhone(site.getContactPhone())
                .workTime(site.getWorkTime())
                .status(site.getStatus())
                .createTime(site.getCreateTime())
                .build();
    }
}
