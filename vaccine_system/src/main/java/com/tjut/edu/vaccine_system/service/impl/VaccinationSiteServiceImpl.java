package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.model.dto.SiteDTO;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.enums.SiteStatusEnum;
import com.tjut.edu.vaccine_system.model.vo.SiteDetailVO;
import com.tjut.edu.vaccine_system.model.vo.SiteVO;
import com.tjut.edu.vaccine_system.model.vo.SiteWithStockVO;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.service.AppointmentService;
import com.tjut.edu.vaccine_system.service.SiteVaccineStockService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import com.tjut.edu.vaccine_system.service.VaccinationSiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 接种点 Service 实现
 * 查询类操作保留在此，复杂业务逻辑委托给专职Service
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VaccinationSiteServiceImpl extends ServiceImpl<VaccinationSiteMapper, VaccinationSite>
        implements VaccinationSiteService {

    private final SysUserService sysUserService;
    private final SiteVaccineStockService siteVaccineStockService;
    private final AppointmentService appointmentService;

    // 专职服务委托
    private final VaccinationSiteStatusService vaccinationSiteStatusService;
    private final VaccinationSiteDoctorAssignService vaccinationSiteDoctorAssignService;

    @Override
    public IPage<VaccinationSite> pageSites(long current, long size, String siteName, Integer status) {
        log.debug("开始分页查询接种点，siteName: {}, status: {}", siteName, status);

        Page<VaccinationSite> page = new Page<>(current, size);
        LambdaQueryWrapper<VaccinationSite> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(siteName), VaccinationSite::getSiteName, siteName)
                .eq(status != null, VaccinationSite::getStatus, status)
                .orderByDesc(VaccinationSite::getCreateTime);

        IPage<VaccinationSite> result = page(page, wrapper);
        log.debug("分页查询接种点完成，结果数量: {}", result.getRecords().size());
        return result;
    }

    @Override
    public IPage<SiteVO> pageSitesAsVO(long current, long size, String siteName, Integer status) {
        log.debug("开始分页查询接种点VO，siteName: {}, status: {}", siteName, status);

        IPage<VaccinationSite> page = pageSites
(current, size, siteName, status);
        List<SiteVO> voList = page.getRecords().stream()
                .map(this::toSiteVO)
                .collect(Collectors.toList());
        Page<SiteVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(voList);

        log.debug("分页查询接种点VO完成，结果数量: {}", voList.size());
        return voPage;
    }

    @Override
    public void enable(Long id) {
        vaccinationSiteStatusService.enable(id);
    }

    @Override
    public void disable(Long id) {
        vaccinationSiteStatusService.disable(id);
    }

    @Override
    public void assignDoctor(Long siteId, Long doctorId) {
        vaccinationSiteDoctorAssignService.assignDoctor(siteId, doctorId);
    }

    @Override
    public SiteVO getSiteVOById(Long id) {
        log.debug("开始查询接种点VO，接种点ID: {}", id);
        VaccinationSite site = getById(id);
        SiteVO result = site != null ? toSiteVO(site) : null;
        log.debug("查询接种点VO完成，结果: {}", result != null);
        return result;
    }

    @Override
    public SiteDetailVO getDetailForAdmin(Long id) {
        log.info("开始查询接种点管理员详情，接种点ID: {}", id);

        VaccinationSite site = getById(id);
        if (site == null) {
            log.warn("查询接种点管理员详情失败：接种点不存在，接种点ID: {}", id);
            return null;
        }

        SiteDetailVO vo = toSiteDetailVO(site);
        // 使用调拨库存 site_vaccine_stock（与预约校验、用户端展示一致）
        vo.setStockList(siteVaccineStockService.listAvailableStockByVaccineForSite(id));
        vo.setTodayAppointmentCount(appointmentService.countTodayBySiteId(id));

        log.info("查询接种点管理员详情完成，接种点ID: {}", id);
        return vo;
    }

    @Override
    public List<SiteWithStockVO> listEnabledWithStockForUser() {
        log.info("开始查询启用且有库存的接种点列表");

        List<VaccinationSite> sites = list(new LambdaQueryWrapper<VaccinationSite>()
                .eq(VaccinationSite::getStatus, SiteStatusEnum.ENABLED.getCode())
                .orderByAsc(VaccinationSite::getId));

        List<SiteWithStockVO> result = new ArrayList<>();
        for (VaccinationSite site : sites) {
            SiteWithStockVO vo = SiteWithStockVO.builder()
                    .id(site.getId())
                    .siteName(site.getSiteName())
                    .address(site.getAddress())
                    .contactPhone(site.getContactPhone())
                    .workTime(site.getWorkTime())
                    .status(site.getStatus())
                    .statusDesc(SiteStatusEnum.fromCode(site.getStatus()) != null
                            ? SiteStatusEnum.fromCode(site.getStatus()).getDesc() : "")
                    .currentDoctorName(resolveCurrentDoctorName(site.getCurrentDoctorId()))
                    .build();

            // 使用调拨库存 site_vaccine_stock（与预约校验一致，避免"有库存却显示无库存"）
            vo.setStockList(siteVaccineStockService.listAvailableStockByVaccineForSite(site.getId()));
            result.add(vo);
        }

        log.info("查询启用且有库存的接种点列表完成，结果数量: {}", result.size());
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SiteVO saveFromDTO(SiteDTO dto) {
        log.info("开始保存接种点，接种点名称: {}", dto.getSiteName());

        VaccinationSite site = VaccinationSite.builder()
                .siteName(dto.getSiteName())
                .address(dto.getAddress())
                .contactPhone(dto.getContactPhone())
                .workTime(dto.getWorkTime())
                .status(dto.getStatus() != null ? dto.getStatus() : SiteStatusEnum.ENABLED.getCode())
                .description(dto.getDescription())
                .build();

        save(site);
        SiteVO result = toSiteVO(getById(site.getId()));

        log.info("保存接种点完成，接种点ID: {}, 接种点名称: {}",
                result.getId(), result.getSiteName());
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SiteVO updateFromDTO(Long id, SiteDTO dto) {
        log.info("开始更新接种点，接种点ID: {}, 接种点名称: {}", id, dto.getSiteName());

        VaccinationSite site = getById(id);
        if (site == null) {
            log.warn("更新接种点失败：接种点不存在，接种点ID: {}", id);
            throw new BizException(BizErrorCode.NOT_FOUND, "接种点不存在");
        }

        site.setSiteName(dto.getSiteName());
        site.setAddress(dto.getAddress());
        site.setContactPhone(dto.getContactPhone());
        site.setWorkTime(dto.getWorkTime());
        if (dto.getStatus() != null) {
            site.setStatus(dto.getStatus());
        }
        site.setDescription(dto.getDescription());
        updateById(site);

        SiteVO result = toSiteVO(getById(id));

        log.info("更新接种点完成，接种点ID: {}, 接种点名称: {}",
                id, result.getSiteName());
        return result;
    }

    /**
     * 仅当驻场医生存在且状态为正常时返回姓名，否则返回 null（页面驻场显示为空）
     */
    private String resolveCurrentDoctorName(Long currentDoctorId) {
        if (currentDoctorId == null) {
            return null;
        }
        SysUser user = sysUserService.getById(currentDoctorId);
        if (user == null || !com.tjut.edu.vaccine_system.model.enums.UserStatusEnum.NORMAL.getCode()
                .equals(user.getStatus())) {
            return null;
        }
        return user.getRealName();
    }

    private SiteVO toSiteVO(VaccinationSite site) {
        if (site == null) {
            return null;
        }

        String statusDesc = SiteStatusEnum.fromCode(site.getStatus()) != null
                ? SiteStatusEnum.fromCode(site.getStatus()).getDesc() : "";

        // 禁用状态下不展示驻场医生，避免"禁用却显示驻场医生"的歧义（含历史数据兜底）
        String doctorName = Integer.valueOf(SiteStatusEnum.DISABLED.getCode()).equals(site.getStatus())
                ? null
                : resolveCurrentDoctorName(site.getCurrentDoctorId());

        return SiteVO.builder()
                .id(site.getId())
                .siteName(site.getSiteName())
                .address(site.getAddress())
                .contactPhone(site.getContactPhone())
                .workTime(site.getWorkTime())
                .status(site.getStatus())
                .statusDesc(statusDesc)
                .description(site.getDescription())
                .currentDoctorId(site.getCurrentDoctorId())
                .currentDoctorName(doctorName)
                .createTime(site.getCreateTime())
                .updateTime(site.getUpdateTime())
                .build();
    }

    private SiteDetailVO toSiteDetailVO(VaccinationSite site) {
        if (site == null) {
            return null;
        }

        String statusDesc = SiteStatusEnum.fromCode(site.getStatus()) != null
                ? SiteStatusEnum.fromCode(site.getStatus()).getDesc() : "";

        // 禁用状态下不展示驻场医生，与列表展示一致
        String doctorName = Integer.valueOf(SiteStatusEnum.DISABLED.getCode()).equals(site.getStatus())
                ? null
                : resolveCurrentDoctorName(site.getCurrentDoctorId());

        return SiteDetailVO.builder()
                .id(site.getId())
                .siteName(site.getSiteName())
                .address(site.getAddress())
                .contactPhone(site.getContactPhone())
                .workTime(site.getWorkTime())
                .status(site.getStatus())
                .statusDesc(statusDesc)
                .description(site.getDescription())
                .currentDoctorId(site.getCurrentDoctorId())
                .currentDoctorName(doctorName)
                .createTime(site.getCreateTime())
                .updateTime(site.getUpdateTime())
                .build();
    }

    @Override
    public List<Long> listSiteIdsByCurrentDoctorId(Long doctorId) {
        log.debug("开始根据驻场医生ID列出接种点ID，医生ID: {}", doctorId);

        if (doctorId == null) {
            return List.of();
        }

        List<Long> result = list(new LambdaQueryWrapper<VaccinationSite>()
                .eq(VaccinationSite::getCurrentDoctorId, doctorId)
                .select(VaccinationSite::getId))
                .stream()
                .map(VaccinationSite::getId)
                .collect(Collectors.toList());

        log.debug("根据驻场医生ID列出接种点ID完成，结果数量: {}", result.size());
        return result;
    }

    @Override
    public void disableSitesByResidentDoctorId(Long doctorId) {
        vaccinationSiteDoctorAssignService.disableSitesByResidentDoctorId(doctorId);
    }

    @Override
    public boolean removeSite(Long id) {
        return vaccinationSiteDoctorAssignService.removeSite(id);
    }

    @Override
    public List<VaccinationSite> listEnabledSites() {
        log.debug("开始列出所有启用的接种点");

        List<VaccinationSite> result = list(new LambdaQueryWrapper<VaccinationSite>()
                .eq(VaccinationSite::getStatus, SiteStatusEnum.ENABLED.getCode()));

        log.debug("列出所有启用的接种点完成，结果数量: {}", result.size());
        return result;
    }
}
