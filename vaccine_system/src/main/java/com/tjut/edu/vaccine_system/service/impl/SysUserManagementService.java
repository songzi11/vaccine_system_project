package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.service.SysUserService;
import com.tjut.edu.vaccine_system.service.VaccinationSiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 *   用户状态管理和持久化服务
 * 负责用户注销/禁用/启用、保存和更新等状态管理操作
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysUserManagementService {

    private final SysUserMapper sysUserMapper;
    private final SysUserService sysUserService;
    @Lazy
    private final VaccinationSiteService vaccinationSiteService;

    /**
     * 注销用户
     * 管理员校验密码后，将用户状态改为已注销（不可恢复）
     * 如果是医生账户，需处理其驻场接种点
     *
     * @param targetUserId  被注销用户 ID
     * @param adminUserId  当前管理员用户 ID
     * @param adminPassword 管理员当前登录密码
     * @throws BizException 用户不存在或已注销时抛出相应异常
     */
    @Transactional(rollbackFor = Exception.class)
    public void deactivateUser(Long targetUserId, Long adminUserId, String adminPassword) {
        log.info("开始注销用户，目标用户ID: {}, 操作管理员ID: {}", targetUserId, adminUserId);

        SysUser target = sysUserService.getById(targetUserId);
        if (target == null) {
            log.warn("注销用户失败：用户不存在，用户ID: {}", targetUserId);
            throw new BizException(BizErrorCode.NOT_FOUND.getCode.getCode(), "用户不存在");
        }

        UserStatusEnum statusEnum = UserStatusEnum.fromCode(target.getStatus());
        if (statusEnum == UserStatusEnum.DEACTIVATED) {
            log.warn("注销用户失败：用户已注销，用户ID: {}", targetUserId);
            throw new BizException(BizErrorCode.USER_ALREADY_DEACTIVATED);
        }

        target.setStatus(UserStatusEnum.DEACTIVATED.getCode());
        sysUserService.updateById(target);

        // 使用 RoleConstants 替换魔法值
        // 医生账户注销后，其作为驻场医生的接种点自动转为禁用并清空驻场医生
        if (RoleConstants.isDoctor(target.getRole())) {
            log.info("用户为医生角色，开始处理驻场接种点，医生ID: {}", targetUserId);
            vaccinationSiteService.disableSitesByResidentDoctorId(targetUserId);
        }

        log.info("用户注销成功，用户ID: {}, 用户名: {}", targetUserId, target.getUsername());
    }

    /**
     * 禁用用户
     * 将用户状态改为已禁用（可恢复）
     * 如果是医生账户，需处理其驻场接种点
     *
     * @param userId 用户 ID
     * @throws BizException 用户不存在或已注销时抛出相应异常
     */
    @Transactional(rollbackFor = Exception.class)
    public void disableUser(Long userId) {
        log.info("开始禁用用户，用户ID: {}", userId);

        SysUser user = sysUserService.getById(userId);
        if (user == null) {
            log.warn("禁用用户失败：用户不存在，用户ID: {}", userId);
            throw new BizException(BizErrorCode.NOT_FOUND.getCode.getCode(), "用户不存在");
        }

        if (user.getStatus() != null && user.getStatus() == UserStatusEnum.DEACTIVATED.getCode()) {
            log.warn("禁用用户失败：用户已注销，用户ID: {}", userId);
            throw new BizException(BizErrorCode.USER_ALREADY_DEACTIVATED);
        }

        user.setStatus(UserStatusEnum.DISABLED.getCode());
        sysUserService.updateById(user);

        // 使用 RoleConstants 替换魔法值
        // 医生账户禁用后，其作为驻场医生的接种点自动转为禁用并清空驻场医生
        if (RoleConstants.isDoctor(user.getRole())) {
            log.info("用户为医生角色，开始处理驻场接种点，医生ID: {}", userId);
            vaccinationSiteService.disableSitesByResidentDoctorId(userId);
        }

        log.info("用户禁用成功，用户ID: {}, 用户名: {}", userId, user.getUsername());
    }

    /**
     * 启用用户
     * 将用户状态改为正常（仅对已禁用有效，已注销不可恢复）
     *
     * @param userId 用户 ID
     * @throws BizException 用户不存在或已注销时抛出相应异常
     */
    @Transactional(rollbackFor = Exception.class)
    public void enableUser(Long userId) {
        log.info("开始启用用户，用户ID: {}", userId);

        SysUser user = sysUserService.getById(userId);
        if (user == null) {
            log.warn("启用用户失败：用户不存在，用户ID: {}", userId);
            throw new BizException(BizErrorCode.NOT_FOUND.getCode.getCode(), "用户不存在");
        }

        if (user.getStatus() != null && user.getStatus() == UserStatusEnum.DEACTIVATED.getCode()) {
            log.warn("启用用户失败：用户已注销，无法恢复，用户ID: {}", userId);
            throw new BizException(BizErrorCode.USER_ALREADY_DEACTIVATED);
        }

        user.setStatus(UserStatusEnum.NORMAL.getCode());
        sysUserService.updateById(user);

        log.info("用户启用成功，用户ID: {}, 用户名: {}", userId, user.getUsername());
    }

    /**
     * 保存或更新用户
     * 处理用户信息的持久化，包括用户名唯一性验证
     *
     * @param user 用户实体
     * @throws BizException 用户名已存在时抛出 USERNAME_TAKEN
     */
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdateUser(SysUser user) {
        log.info("开始保存/更新用户，用户ID: {}", user.getId());

        if (user == null) {
            log.warn("保存/更新用户失败：用户对象为空");
            return;
        }

        if (StringUtils.hasText(user.getPassword())) {
            user.setPassword(user.getPassword().trim());
        }

        if (StringUtils.hasText(user.getUsername())) {
            Long existingId = sysUserMapper.selectIdByUsernameAny(user.getUsername().trim());
            if (existingId != null && !existingId.equals(user.getId())) {
                log.warn("保存/更新用户失败：用户名已存在，用户名: {}", user.getUsername());
                throw new BizException(BizErrorCode.USERNAME_TAKEN);
            }
        }

        sysUserService.saveOrUpdate(user);

        log.info("用户保存/更新成功，用户ID: {}, 用户名: {}", user.getId(), user.getUsername());
    }
}
