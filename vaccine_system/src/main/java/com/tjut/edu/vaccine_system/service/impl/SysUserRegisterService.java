package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.dto.RegisterDTO;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 用户注册和管理员认证服务
 * 负责用户注册、管理员密码验证等核心逻辑
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysUserRegisterService {

    private final SysUserMapper sysUserMapper;

    /**
     * 用户注册
     * 验证用户名唯一性，创建用户并设置默认状态
     *
     * @param dto 注册请求DTO
     * @return 创建的用户实体
     * @throws BizException 用户名已存在时抛出 USERNAME_TAKEN
     */
    @Transactional(rollbackFor = Exception.class)
    public SysUser register(RegisterDTO dto) {
        String username = dto.getUsername() != null ? dto.getUsername().trim() : "";
        log.info("开始用户注册，用户名: {}", username);

        if (!StringUtils.hasText(username)) {
            log.error("用户注册失败：用户名不能为空");
            throw new BizException(BizErrorCode.BAD_REQUEST, "用户名不能为空");
        }

        // 验证用户名唯一性
        Long existingId = sysUserMapper.selectIdByUsernameAny(username);
        if (existingId != null) {
            log.warn("用户注册失败：用户名已存在，用户名: {}", username);
            throw new BizException(BizErrorCode.USERNAME_TAKEN);
        }

        // 创建用户
        SysUser user = new SysUser();
        user.setUsername(username);
        user.setPassword(dto.getPassword() != null ? dto.getPassword().trim() : "");
        // 使用 RoleConstants 替换魔法值
        user.setRole(dto.getRole() != null ? dto.getRole().trim().toUpperCase() : RoleConstants.RESIDENT);
        user.setRealName(StringUtils.hasText(dto.getRealName()) ? dto.getRealName().trim() : null);
        user.setPhone(StringUtils.hasText(dto.getPhone()) ? dto.getPhone().trim() : null);
        user.setAddress(StringUtils.hasText(dto.getAddress()) ? dto.getAddress().trim() : null);
        user.setStatus(UserStatusEnum.NORMAL.getCode());

        sysUserMapper.insert(user);
        SysUser result = sysUserMapper.selectById(user.getId());

        log.info("用户注册完成，用户ID: {}, 用户名: {}, 角色: {}",
                result.getId(), result.getUsername(), result.getRole());
        return result;
    }

    /**
     * 校验管理员密码
     * 用于二次验证，如指派医生、注销用户等敏感操作
     *
     * @param adminUserId  当前管理员用户 ID
     * @param adminPassword 管理员当前登录密码
     * @throws BizException 密码错误时抛出 ADMIN_PASSWORD_WRONG
     * @throws BizException 非管理员用户抛出 BAD_REQUEST
     */
    public void verifyAdminPassword(Long adminUserId, String adminPassword) {
        log.info("验证管理员密码，管理员ID: {}", adminUserId);

        if (adminUserId == null || !StringUtils.hasText(adminPassword)) {
            log.warn("管理员密码验证失败：参数为空，管理员ID: {}", adminUserId);
            throw new BizException(BizErrorCode.ADMIN_PASSWORD_WRONG);
        }

        SysUser admin = sysUserMapper.selectById(adminUserId);
        if (admin == null) {
            log.warn("管理员密码验证失败：管理员不存在，管理员ID: {}", adminUserId);
            throw new BizException(BizErrorCode.ADMIN_PASSWORD_WRONG);
        }

        // 使用 RoleConstants 替换魔法值
        if (!RoleConstants.isAdmin(admin.getRole())) {
            log.warn("管理员密码验证失败：非管理员用户，用户ID: {}, 角色: {}",
                    adminUserId, admin.getRole());
            throw new BizException(BizErrorCode.BAD_REQUEST, "仅管理员可执行此操作，请使用管理员账号");
        }

        String dbPwd = admin.getPassword();
        if (dbPwd == null || !adminPassword.trim().equals(dbPwd)) {
            log.warn("管理员密码验证失败：密码错误，管理员ID: {}", adminUserId);
            throw new BizException(BizErrorCode.ADMIN_PASSWORD_WRONG);
        }

        log.info("管理员密码验证成功，管理员ID: {}", adminUserId);
    }
}
