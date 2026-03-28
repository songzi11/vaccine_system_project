package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.enums.SiteStatusEnum;
import com.tjut.edu.vaccine_system.service.SysUserService;
import com.com.tjut.edu.vaccine_system.service.DoctorDispatchService;
import com.tjut.edu.vaccine_system.service.StockTransferService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 接种点驻场医生分配和删除服务
 * 负责驻场医生分配、接种点删除、按医生禁用接种点等操作
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VaccinationSiteDoctorAssignService {

    private final VaccinationSiteMapper vaccinationSiteMapper;
    private final SysUserService sysUserService;
    private final StockTransferService stockTransferService;
    private final DoctorDispatchService doctorDispatchService;

    /**
     * 分配驻场医生
     * 接种点驻场医生不能重复：一个医生只能驻场一个接种点
     * 若该医生已是本接种点驻场医生，仅确保本接种点为启用状态，不重复推送
     *
     * @param siteId    接种点ID
     * @param doctorId  驻场医生ID（可为null，表示清空）
     * @throws BizException 接种点不存在或用户不是医生时抛出相应异常
     */
    @Transactional(rollbackFor = Exception.class)
    public void assignDoctor(Long siteId, Long doctorId) {
        log.info("开始分配驻场医生，接种点ID: {}, 医生ID: {}", siteId, doctorId);

        VaccinationSite site = vaccinationSiteMapper.selectById(siteId);
        if (site == null) {
            log.warn("分配驻场医生失败：接种点不存在，接种点ID: {}", siteId);
            throw new BizException(BizErrorCode.NOT_FOUND, "接种点不存在");
        }

        if (doctorId != null) {
            SysUser doctor = sysUserService.getById(doctorId);
            if (doctor == null) {
                log.warn("分配驻场医生失败：医生不存在，医生ID: {}", doctorId);
                throw new BizException(BizErrorCode.NOT_FOUND, "医生不存在");
            }

            // 使用 RoleConstants 替换魔法值
            if (!RoleConstants.isDoctor(doctor.getRole())) {
                log.warn("分配驻场医生失败：指定用户不是医生，用户ID: {}, 角色: {}",
                        doctorId, doctor.getRole());
                throw new BizException(BizErrorCode.BAD_REQUEST, "指定用户不是医生");
            }
        }

        Long fromSiteId = siteId;

        if (doctorId != null) {
            // 接种点驻场医生不能重复：一个医生只能驻场一个接种点
            List<VaccinationSite> fromSites = vaccinationSiteMapper.selectList(
                    new LambdaQueryWrapper<VaccinationSite>()
                            .eq(VaccinationSite::getCurrentDoctorId, doctorId));

            for (VaccinationSite other : fromSites) {
                if (other.getId().equals(siteId)) {
                    continue;
                }
                log.debug("清空其他接种点的驻场医生，接种点ID: {}", other.getId());
                other.setCurrentDoctorId(null);
                other.setStatus(SiteStatusEnum.DISABLED.getCode());
                vaccinationSiteMapper.updateById(other);
                stockTransferService.returnAllSiteStockToWarehouse(other.getId(), null);
            }

            if (!fromSites.isEmpty() && !fromSites.get(0).getId().equals(siteId)) {
                fromSiteId = fromSites.get(0).getId();
            }

            // 若该医生已是本接种点驻场医生，仅确保本接种点为启用状态，不重复推送
            if (doctorId.equals(site.getCurrentDoctorId())) {
                log.debug("医生已是本接种点驻场医生，仅启用接种点");
                site.setStatus(SiteStatusEnum.ENABLED.getCode());
                vaccinationSiteMapper.updateById(site);
                log.info("驻场医生分配完成（已是驻场医生），接种点ID: {}, 医生ID: {}",
                        siteId, doctorId);
                return;
            }
        } else {
            // 清空驻场场医生：该接种点自动变为禁用，直至管理员指派新驻场医生
            log.debug("清空驻场医生，接种点自动变为禁用");
            site.setCurrentDoctorId(null);
            site.setStatus(SiteStatusEnum.DISABLED.getCode());
            vaccinationSiteMapper.updateById(site);
            stockTransferService.returnAllSiteStockToWarehouse(siteId, null);

            log.info("清空驻场医生完成，接种点ID: {}", siteId);
            return;
        }

        site.setCurrentDoctorId(doctorId);
        site.setStatus(SiteStatusEnum.ENABLED.getCode());
        vaccinationSiteMapper.updateById(site);
        doctorDispatchService.notifyAssigned(doctorId, fromSiteId, siteId);

        log.info("驻场医生分配成功，接种点ID: {}, 医生ID: {}",
                siteId, doctorId);
    }

    /**
     * 删除接种点
     * 先将该接种点所有疫苗可用库存退回到总仓，再物理删除接种点记录
     *
     * @param id 接种点ID
     * @return 是否删除成功
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean removeSite(Long id) {
        log.info("开始删除接种点，接种点ID: {}", id);

        VaccinationSite site = vaccinationSiteMapper.selectById(id);
        if (site == null) {
            log.warn("删除接种点失败：接种点不存在，接种点ID: {}", id);
            return false;
        }

        log.debug("退回接种点库存到总仓，接种点ID: {}", id);
        stockTransferService.returnAllSiteStockToWarehouse(id, null);

        boolean ok = removeById(id);

        if (ok) {
            log.info("接种点删除成功，接种点ID: {}, 接种点名称: {}",
                    id, site.getSiteName());
        } else {
            log.error("接种点删除失败，接种点ID: {}", id);
        }

        return ok;
    }

    /**
     * 将指定医生作为驻场医生的所有接种点清空驻场医生并设为禁用
     * 用于医生账户被禁用或注销时，其驻场接种点自动转为禁用
     *
     * @param doctorId 驻场医生ID
     */
    @Transactional(rollbackFor = Exception.class)
    public void disableSitesByResidentDoctorId(Long doctorId) {
        log.info("开始根据驻场医生ID禁用接种点，医生ID: {}", doctorId);

        if (doctorId == null) {
            log.warn("根据驻场医生ID禁用接种点失败：医生ID为空");
            return;
        }

        List<VaccinationSite> sites = vaccinationSiteMapper.selectList(
                new LambdaQueryWrapper<VaccinationSite>()
                        .eq(VaccinationSite::getCurrentDoctorId, doctorId));

        for (VaccinationSite site : sites) {
            log.debug("禁用接种点，接种点ID: {}", site.getId());
            site.setCurrentDoctorId(null);
            site.setStatus(SiteStatusEnum.DISABLED.getCode());
            vaccinationSiteMapper.updateById(site);
            stockTransferService.returnAllSiteStockToWarehouse(site.getId(), null);
        }

        log.info("接种点禁用完成，医生ID: {}, 影响数量: {}", doctorId, sites.size());
    }
}
