package com.tjut.edu.vaccine_system.constants;

/**
 * 角色常量类
 * 定义系统中所有角色相关的常量，避免魔法值
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
public final class RoleConstants {

    private RoleConstants() {
        throw new UnsupportedOperationException("常量类不允许实例化");
    }

    /**
     * 居民角色
     */
    public static final String RESIDENT = "RESIDENT";

    /**
     * 医生角色
     */
    public static final String DOCTOR = "DOCTOR";

    /**
     * 管理员角色
     */
    public static final String ADMIN = "ADMIN";

    /**
     * 判断是否为居民角色
     */
    public static boolean isResident(String role) {
        return RESIDENT.equals(role);
    }

    /**
     * 判断是否为医生角色
     */
    public static boolean isDoctor(String role) {
        return DOCTOR.equals(role);
    }

    /**
     * 判断是否为管理员角色
     */
    public static boolean isAdmin(String role) {
        return ADMIN.equals(role);
    }
}
