package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.mapper.VaccinationSiteMapper;
import com.tjut.edu.vaccine_system.model.entity.VaccinationSite;
import com.tjut.edu.vaccine_system.model.enums.SiteStatusEnum;
import com.tjut.edu.vaccine_system.service.StockTransferService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 接种点状态管理服务
 * 负责接种点启用/禁用状态管理
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VaccinationSiteStatusService {

    private final VaccinationSiteMapper vaccinationSiteMapper;
    private final StockTransferService stockTransferService;

    /**
     * 启用接种点
     * 接种点驻场医生不能重复：若本接种点已有驻场医生，启用前先将该医生从其他所有接种点清空并设为禁用
     *
     * @param id 接种点ID
     * @throws BizException 接种点不存在时抛出 NOT_FOUND
     */
    @Transactional(rollbackFor = Exception.class)
    public void enable(Long id) {
        log.info("开始启用接种点，接种点ID: {}", id);

        VaccinationSite site = vaccinationSiteMapper.selectById(id);
        if (site == null) {
            log.warn("启用接种点失败：接种点不存在，接种点ID: {}", id);
            throw new BizException(BizErrorCode.NOT_FOUND, "接种点不存在");
        }

        // 接种点驻场医生不能重复：若本接种点已有驻场医生，启用前先将该医生从其他所有接种点清空并设为禁用
        if (site.getCurrentDoctorId() != null) {
            List<VaccinationSite> others = vaccinationSiteMapper.selectList(
                    new LambdaQueryWrapper<VaccinationSite>()
                            .eq(VaccinationSite::getCurrentDoctorId, site.getCurrentDoctorId()));
            for (VaccinationSite other : others) {
                if (other.getId().equals(id)) {
                    continue;
                }
                log.debug("清空其他接种点的驻场医生，接种点ID: {}", other.getId());
                other.setCurrentDoctorId(null);
                other.setStatus(SiteStatusEnum.DISABLED.getCode());
                vaccinationSiteMapper.updateById(other);
                stockTransferService.returnAllSiteStockToWarehouse(other.getId(), null);
            }
        }

        site.setStatus(SiteStatusEnum.ENABLED.getCode());
        vaccinationSiteMapper.updateById(site);

        log.info("接种点启用成功，接种点ID: {}, 接种点名称: {}",
                id, site.getSiteName());
    }

    /**
     * 禁用接种点
     * 禁用时同步清空驻场医生，避免"禁用却仍显示驻场医生"的矛盾
     * 禁用后将该接种点所有疫苗可用库存退回到总仓（管理员库存）
     *
     * @param id 接种点ID
     * @throws BizException 接种点不存在时抛出 NOT_FOUND
     */
    @Transactional(rollbackFor = Exception.class)
    public void disable(Long id) {
        log.info("开始禁用接种点，接种点ID: {}", id);

        VaccinationSite site = vaccinationSiteMapper.selectById(id);
        if (site == null) {
            log.warn("禁用接种点失败：接种点不存在，接种点ID: {}", id);
            throw new BizException(BizErrorCode.NOT_FOUND, "接种点不存在");
        }

        site.setStatus(SiteStatusEnum.DISABLED.getCode());
        site.setCurrentDoctorId(null); // 禁用时同步清空驻场医生
        vaccinationSiteMapper.updateById(site);

        // 禁用后将该接种点所有疫苗可用库存退回到总仓（管理员库存）
        log.debug("退回接种点库存到总仓，接种点ID: {}", id);
        stockTransferService.returnAllSiteStockToWarehouse(id, null);

        log.info("接种点禁用成功，接种点ID: {}, 接种点名称: {}",
                id, site.getSiteName());
    }
}
