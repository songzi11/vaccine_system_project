package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.mapper.DoctorScheduleMapper;
import com.tjut.edu.vaccine_system.model.entity.DoctorSchedule;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.service.DoctorScheduleService;
import com.tjut.edu.vaccine_system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

/**
 * 医生排班 Service 实现
 * 分页查询保留在此，复杂业务逻辑委托给专职Service
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorScheduleServiceImpl extends ServiceImpl<DoctorScheduleMapper, DoctorSchedule> implements DoctorScheduleService {

    // 专职服务委托
    private final DoctorScheduleQueryService doctorScheduleQueryService;
    private final DoctorScheduleManagementService doctorScheduleManagementService;
    private final DoctorScheduleOverviewService doctorScheduleOverviewService;

    private final SysUserService sysUserService;

    @Override
    public List<DoctorSchedule> listAvailable(Long siteId, LocalDate fromDate, LocalDate toDate) {
        return doctorScheduleQueryService.listAvailable(siteId, fromDate, toDate);
    }

    @Override
    public List<DoctorSchedule> listBySiteAndDateRange(Long siteId, LocalDate fromDate, LocalDate toDate) {
        return doctorScheduleQueryService.listBySiteAndDateRange(siteId, fromDate, toDate);
    }

    @Override
    public IPage<DoctorSchedule> page(long current, long size, Long doctorId, Long siteId,
                                         LocalDate scheduleDate, Integer status) {
        log.debug("开始分页查询排班，doctorId: {}, siteId: {}, scheduleDate: {}, status: {}",
                 doctorId, siteId, scheduleDate, status);

        Page<DoctorSchedule> page = new Page<>(current, size);
        LambdaQueryWrapper<DoctorSchedule> w = new LambdaQueryWrapper<>();

        // 添加子查询，只查询状态正常的医生的排班
        if (doctorId != null) {
            w.eq(DoctorSchedule::getDoctorId, doctorId);
        } else {
            // 使用 RoleConstants 替换魔法值
            // 如果没有指定具体医生，则只查询状态正常的医生（status=0）的排班
            w.inSql(DoctorSchedule::getDoctorId,
                "SELECT id FROM sys_user WHERE role = '" + RoleConstants.DOCTOR + "' AND status = " + UserStatusEnum.NORMAL.getCode());
        }

        w.eq(siteId != null, DoctorSchedule::getSiteId, siteId)
                .eq(scheduleDate != null, DoctorSchedule::getScheduleDate, scheduleDate)
                .eq(status != null, DoctorSchedule::getStatus, status)
                .orderByDesc(DoctorSchedule::getScheduleDate)
                .orderByAsc(DoctorSchedule::getTimeSlot);

        IPage<DoctorSchedule> result = page(page, w);
        log.debug("分页查询排班完成，结果数量: {}", result.getRecords().size());
        return result;
    }

    @Override
    public boolean incrementCurrentCount(Long scheduleId) {
        return doctorScheduleManagementService.incrementCurrentCount(scheduleId);
    }

    @Override
    public boolean decrementCurrentCount(Long scheduleId) {
        return doctorScheduleManagementService.decrementCurrentCount(scheduleId);
    }

    @Override
    public TodayScheduleOverviewVO getTodayOverview(LocalDate date) {
        return doctorScheduleOverviewService.getTodayOverview(date);
    }

    @Override
    public int batchReplaceByPeriod(Long oldDoctorId, Long newDoctorId, LocalDate date, String periodType) {
        return doctorScheduleManagementService.batchReplaceByPeriod(oldDoctorId, newDoctorId, date, periodType);
    }
}
