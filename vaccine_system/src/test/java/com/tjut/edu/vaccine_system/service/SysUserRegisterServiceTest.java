package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import com.tjut.edu.vaccine_system.common.exception.BizException;
import com.tjut.edu.vaccine_system.common.exception.BizErrorCode;
import com.tjut.edu.vaccine_system.entity.SysUser;
import com.tjut.edu.vaccine_system.mapper.SysUserMapper;
import com.tjut.edu.vaccine_system.service.impl.SysUserRegisterService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * 用户注册服务测试
 *
 * 测试内容：
 * 1. 正常注册用户
 * 2. 用户名已存在时抛出异常
 * 3. 用户名格式校验
 * 4. 密码格式校验
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class SysUserRegisterServiceTest {

    @Mock
    private SysUserMapper sysUserMapper;

    @InjectMocks
    private SysUserRegisterService sysUserRegisterService;

    /**
     * 测试正常注册居民用户
     */
    @Test
    public void testRegisterResidentSuccess() {
        // Given
        SysUser user = new SysUser();
        user.setUsername("newResident");
        user.setPassword("Password123");
        user.setRole("RESIDENT");
        user.setName("测试居民");

        when(sysUserMapper.selectOne(any())).thenReturn(null);
        when(sysUserMapper.insert(any(SysUser.class))).thenReturn(1);

        // When
        Long userId = sysUserRegisterService.registerUser(user);

        // Then
        assertNotNull(userId);
        assertNotNull(user.getPassword()); // 密码已加密
        assertNotEquals("Password123", user.getPassword()); // 密码不应是明文
        verify(sysUserMapper, times(1)).insert(any(SysUser.class));
        log.info("正常注册居民用户测试通过");
    }

    /**
     * 测试用户名已存在
     */
    @Test
    public void testRegisterUsernameTaken() {
        // Given
        SysUser existingUser = new SysUser();
        existingUser.setUsername("existingUser");

        SysUser newUser = new SysUser();
        newUser.setUsername("existingUser");
        newUser.setPassword("Password123");
        newUser.setRole("RESIDENT");

        when(sysUserMapper.selectOne(any())).thenReturn(existingUser);

        // When & Then
        BizException exception = assertThrows(BizException.class, () -> {
            sysUserRegisterService.registerUser(newUser);
        });

        assertEquals(BizErrorCode.USERNAME_TAKEN.getCode(), exception.getCode());
        log.info("用户名已存在异常测试通过");
    }
}
