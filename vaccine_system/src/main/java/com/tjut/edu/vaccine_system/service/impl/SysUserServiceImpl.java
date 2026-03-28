package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.model.dto.RegisterDTO;
import com.tjut.edu.vaccine_system.model.vo.UserListVO;
import com.tjut.edu.vaccine_system.model.vo.UserDetailVO;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 系统用户 Service 实现
 * 登录、查询等基础操作保留在此，复杂业务逻辑委托给专职Service
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    // 专职服务委托
    private final SysUserRegisterService sysUserRegisterService;
    private final SysUserManagementService sysUserManagementService;
    private final SysUserDetailService sysUserDetailService;

    @Override
    public Optional<SysUser> login(String username, String password) {
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            return Optional.empty();
        }
        SysUser user = getOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username.trim()));
        if (user == null) {
            return Optional.empty();
        }
        UserStatusEnum statusEnum = UserStatusEnum.fromCode(user.getStatus());
        if (statusEnum == null || !statusEnum.canLogin()) {
            return Optional.empty();
        }
        String raw = password.trim();
        String dbPwd = user.getPassword();
        if (dbPwd == null || !raw.equals(dbPwd)) {
            return Optional.empty();
        }
        // 更新最后登录时间
        update(new LambdaUpdateWrapper<SysUser>()
                .eq(SysUser::getId, user.getId())
                .set(SysUser::getLastLoginTime, LocalDateTime.now()));
        user.setLastLoginTime(LocalDateTime.now());
        log.info("用户登录成功，用户ID: {}, 用户名: {}", user.getId(), user.getUsername());
        return Optional.of(user);
    }

    @Override
    public boolean isUsernameValid(String username) {
        if (!StringUtils.hasText(username)) {
            return false;
        }
        SysUser user = getOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username.trim()));
        if (user == null) {
            return false;
        }
        UserStatusEnum statusEnum = UserStatusEnum.fromCode(user.getStatus());
        return statusEnum != null && statusEnum.canLogin();
    }

    @Override
    public SysUser register(RegisterDTO dto) {
        log.info("开始用户注册，用户名: {}", dto.getUsername());
        SysUser result = sysUserRegisterService.register(dto);
        log.info("用户注册成功，用户ID: {}", result.getId());
        return result;
    }

    @Override
    public UserListVO getUserListVO(Long id) {
        SysUser u = getById(id);
        return u == null ? null : toUserListVO(u);
    }

    @Override
    public IPage<UserListVO> pageUserVOs(long current, long size, String username, String role, Integer status) {
        Page<SysUser> page = new Page<>(current, size);
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(username), SysUser::getUsername, username)
                .eq(StringUtils.hasText(role), SysUser::getRole, role)
                .eq(status != null, SysUser::getStatus, status)
                .ne(SysUser::getStatus, UserStatusEnum.DEACTIVATED.getCode())
                .orderByDesc(SysUser::getCreateTime);
        IPage<SysUser> result = page(page, wrapper);
        List<UserListVO> voList = result.getRecords().stream()
                .map(this::toUserListVO)
                .collect(Collectors.toList());
        Page<UserListVO> voPage = new Page<>(result.getCurrent(), result.getSize(), result.getTotal());
        voPage.setRecords(voList);
        return voPage;
    }

    private UserListVO toUserListVO(SysUser u) {
        UserStatusEnum statusEnum = UserStatusEnum.fromCode(u.getStatus());
        return UserListVO.builder()
                .id(u.getId())
                .username(u.getUsername())
                .realName(u.getRealName())
                .role(u.getRole())
                .gender(u.getGender())
                .phone(u.getPhone())
                .idCard(u.getIdCard())
                .address(u.getAddress())
                .avatar(u.getAvatar())
                .status(u.getStatus())
                .statusLabel(statusEnum != null ? statusEnum.getDesc() : String.valueOf(u.getStatus()))
                .createTime(u.getCreateTime())
                .lastLoginTime(u.getLastLoginTime())
                .updateTime(u.getUpdateTime())
                .build();
    }

    @Override
    public UserDetailVO getUserDetail(Long userId) {
        log.info("开始查询用户详情，用户ID: {}", userId);
        UserDetailVO result = sysUserDetailService.getUserDetail(userId);
        log.info("用户详情查询完成，用户ID: {}", userId);
        return result;
    }

    @Override
    public void verifyAdminPassword(Long adminUserId, String adminPassword) {
        log.info("验证管理员密码，管理员ID: {}", adminUserId);
        sysUserRegisterService.verifyAdminPassword(adminUserId, adminPassword);
        log.info("管理员密码验证成功，管理员ID: {}", adminUserId);
    }

    @Override
    public void deactivateUser(Long targetUserId, Long adminUserId, String adminPassword) {
        log.info("开始注销用户，目标用户ID: {}, 操作管理员ID: {}", targetUserId, adminUserId);
        sysUserManagementService.deactivateUser(targetUserId, adminUserId, adminPassword);
        log.info("用户注销成功，用户ID: {}", targetUserId);
    }

    @Override
    public void disableUser(Long userId) {
        log.info("开始禁用用户，用户ID: {}", userId);
        sysUserManagementService.disableUser(userId);
        log.info("用户禁用成功，用户ID: {}", userId);
    }

    @Override
    public void enableUser(Long userId) {
        log.info("开始启用用户，用户ID: {}", userId);
        sysUserManagementService.enableUser(userId);
        log.info("用户启用成功，用户ID: {}", userId);
    }

    @Override
    public void saveOrUpdateUser(SysUser user) {
        log.info("开始保存/更新用户，用户ID: {}", user.getId());
        sysUserManagementService.saveOrUpdateUser(user);
        log.info("用户保存/更新成功，用户ID: {}", user.getId());
    }

    @Override
    public List<SysUser> listNormalDoctors() {
        log.debug("开始查询正常医生列表");
        LambdaQueryWrapper<SysUser> query = new LambdaQueryWrapper<>();
        // 使用 RoleConstants 替换魔法值
        query.eq(SysUser::getRole, RoleConstants.DOCTOR)
                .eq(SysUser::getStatus, UserStatusEnum.NORMAL.getCode());
        List<SysUser> result = list(query);
        log.debug("查询到正常医生数量: {}", result.size());
        return result;
    }
}
