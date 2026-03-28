package com.tjut.edu.vaccine_system.constants;

import com.tjut.edu.vaccine_system.config.BusinessConfiguration;

/**
 * 业务常量类
 * 提供对业务配置的便捷访问
 * 注意：此类需要在Spring容器初始化后才能使用配置值
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
public final class BusinessConstants {

    private BusinessConstants() {
        throw new UnsupportedOperationException("常量类不允许实例化");
    }

    /**
     * 业务配置实例（延迟加载）
     */
    private static volatile BusinessConfiguration config;

    /**
     * 初始化配置实例
     * @param configuration 业务配置
     */
    public static synchronized void init(BusinessConfiguration configuration) {
        if (config == null) {
            config = configuration;
        }
    }

    /**
     * 获取配置实例
     * @return 业务配置
     */
    public static BusinessConfiguration getConfig() {
        if (config == null) {
            throw new IllegalStateException("BusinessConfiguration未初始化，请确保Spring容器已启动");
        }
        return config;
    }

    // ========== 分页配置 ==========

    /**
     * 默认分页大小
     */
    public static int getDefaultPageSize() {
        return getConfig().getPagination().getDefaultPageSize();
    }

    /**
     * 最大分页大小
     */
    public static int getMaxPageSize() {
        return getConfig().getPagination().getMaxPageSize();
    }

    // ========== 爽约配置 ==========

    /**
     * 爽约禁约天数
     */
    public static int getNoShowBanDays() {
        return getConfig().getNoShow().getBanDays();
    }

    /**
     * 当日爽约阈值（超过此数量将禁约）
     */
    public static int getDailyNoShowThreshold() {
        return getConfig().getNoShow().getDailyThreshold();
    }

    /**
     * 累计爽约阈值（达到此数量将推送冻结通知）
     */
    public static int getTotalNoShowThreshold() {
        return getConfig().getNoShow().getTotalThreshold();
    }

    // ========== 预约配置 ==========

    /**
     * 预约过期时段结束后的小时数
     */
    public static int getAppointmentExpireHours() {
        return getConfig().getAppointment().getExpireHours();
    }

    // ========== 预警配置 ==========

    /**
     * 默认预警天数
     */
    public static int getDefaultWarningDays() {
        return getConfig().getWarning().getDefaultDays();
    }

    // ========== 系统常量（非配置项） ==========

    /**
     * 默认请求超时时间（毫秒）
     */
    public static final int DEFAULT_TIMEOUT_MS = 20000;

    /**
     * 列表分割关键字正则表达式
     */
    public static final String SPLIT_KEYWORDS_PATTERN = "[,，\\s]+";
}
