package com.tjut.edu.vaccine_system.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 业务配置类
 * 用于管理系统的业务参数配置
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@Data
@Component
@ConfigurationProperties(prefix = "vaccine.business")
public class BusinessConfiguration {

    /**
     * 分页配置
     */
    private Pagination pagination = new Pagination();

    /**
     * 爽约配置
     */
    private NoShow noShow = new NoShow();

    /**
     * 预约配置
     */
    private Appointment appointment = new Appointment();

    /**
     * 预警配置
     */
    private Warning warning = new Warning();

    /**
     * 分页配置
     */
    @Data
    public static class Pagination {
        /**
         * 默认分页大小
         */
        private int defaultPageSize = 20;

        /**
         * 最大分页大小
         */
        private int maxPageSize = 200;
    }

    /**
     * 爽约配置
     */
    @Data
    public static class NoShow {
        /**
         * 爽约禁约天数
         */
        private int banDays = 30;

        /**
         * 当日爽约阈值（超过此数量将禁约）
         */
        private int dailyThreshold = 4;

        /**
         * 累计爽约阈值（达到此数量将推送冻结通知）
         */
        private int totalThreshold = 3;
    }

    /**
     * 预约配置
     */
    @Data
    public static class Appointment {
        /**
         * 预约过期时段结束后的小时数
         */
        private int expireHours = 2;
    }

    /**
     * 预警配置
     */
    @Data
    public static class Warning {
        /**
         * 默认预警天数
         */
        private int defaultDays = 30;
    }
}
