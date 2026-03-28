package com.tjut.edu.vaccine_system.config;

import com.tjut.edu.vaccine_system.constants.BusinessConstants;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * 业务配置初始化器
 * 在应用启动完成后初始化BusinessConstants
 *
 * @author vaccine-system
 * @since 2026-03-28
 */
@Component
public class BusinessConfigInitializer {

    private final BusinessConfiguration configuration;

    public BusinessConfigInitializer(BusinessConfiguration configuration) {
        this.configuration = configuration;
    }

    /**
     * 应用启动完成后初始化
     */
    @EventListener(ApplicationReadyEvent.class)
    public void init() {
        BusinessConstants.init(configuration);
    }
}
