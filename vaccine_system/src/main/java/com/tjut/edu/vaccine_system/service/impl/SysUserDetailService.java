package com.tjut.edu.vaccine_system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.tjut.edu.vaccine_system.constants.RoleConstants;
import com.tjut.edu.vaccine_system.model.entity.Appointment;
import com.tjut.edu.vaccine_system.model.entity.ChildProfile;
import com.tjut.edu.vaccine_system.model.entity.Record;
import com.tjut.edu.vaccine_system.model.entity.SysUser;
import com.tjut.edu.vaccine_system.model.enums.AppointmentStatusEnum;
import com.tjut.edu.vaccine_system.model.enums.UserStatusEnum;
import com.tjut.edu.vaccine_system.model.vo.*;
import com.tjut.edu.vaccine_system.service.AppointmentService;
import com.tjut.edu.vaccine_system.service.ChildProfileService;
import com.tjut.edu.vaccine_system.service.RecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户详情查询服务
 * 负责用户详情的复杂关联数据查询和转换
 *
 * @author vaccine-system
 * @since 2026-03-27
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysUserDetailService {

    private final ChildProfileService childProfileService;
    @Lazy
    private final AppointmentService appointmentService;
    @Lazy
    private final RecordService recordService;

    /**
     * 获取用户详情
     * 包含关联的儿童、预约、接种记录等数据
     * 根据用户角色加载不同的关联信息
     *
     * @param userId 用户ID
     * @return 用户详情VO
     */
    public UserDetailVO getUserDetail(Long userId) {
        log.info("开始查询用户详情，用户ID: {}", userId);

        SysUser user = recordService.getSysUserById(userId);
        if (user == null) {
            log.warn("查询用户详情失败：用户不存在，用户ID: {}", userId);
            return null;
        }

        UserDetailVO vo = UserDetailVO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .realName(user.getRealName())
                .role(user.getRole())
                .gender(user.getGender())
                .phone(user.getPhone())
                .idCard(user.getIdCard())
                .address(user.getAddress())
                .avatar(user.getAvatar())
                .status(user.getStatus())
                .statusLabel(UserStatusEnum.fromCode(user.getStatus()) != null
                        ? UserStatusEnum.fromCode(user.getStatus()).getDesc() : "")
                .createTime(user.getCreateTime())
                .lastLoginTime(user.getLastLoginTime())
                .updateTime(user.getUpdateTime())
                .build();

        String role = user.getRole() != null ? user.getRole().toUpperCase() : "";

        // 使用 RoleConstants 替换魔法值
        if (RoleConstants.isResident(role) || "USER".equals(role)) {
            // 居民用户：加载儿童、预约、接种记录
            List<ChildProfile> children = childProfileService.list(
                    new LambdaQueryWrapper<ChildProfile>().eq(ChildProfile::getParentId, userId));
            vo.setChildList(children.stream().map(this::toChildSimpleVO).collect(Collectors.toList()));

            IPage<Appointment> appPage = appointmentService.pageAppointments(
                    1, 100, userId, null, null, null, null, null);
            vo.setAppointmentList(appPage.getRecords().stream()
                    .map(this::toAppointmentSimpleVO).collect(Collectors.toList()));

            List<Record> records = recordService.listByUserId(userId);
            vo.setRecordList(records.stream().map(this::toRecordSimpleVO).collect(Collectors.toList()));

            log.info("用户详情查询完成（居民），用户ID: {}, 儿童数: {}, 预约数: {}, 记录数: {}",
                    userId, children.size(), appPage.getRecords().size(), records.size());
        }

        // 使用 RoleConstants 替换魔法值
        if (RoleConstants.isDoctor(role)) {
            // 医生用户：加载预约列表和统计信息
            List<Appointment> byDoctor = appointmentService.listByDoctorId(userId);
            vo.setScheduleList(byDoctor.stream()
                    .map(this::toAppointmentSimpleVO).collect(Collectors.toList()));
            vo.setTodayAppointmentCount(appointmentService.countTodayByDoctorId(userId));
            vo.setHistoryRecordCount(recordService.countByDoctorId(userId));

            log.info("用户详情查询完成（医生），用户ID: {}, 预约数: {}, 今日预约数: {}, 历史记录数: {}",
                    userId, byDoctor.size(), vo.getTodayAppointmentCount(), vo.getHistoryRecordCount());
        }

        return vo;
    }

    /**
     * 转换儿童档案为简单VO
     */
    private ChildProfileSimpleVO toChildSimpleVO(ChildProfile c) {
        return ChildProfileSimpleVO.builder()
                .id(c.getId())
                .parentId(c.getParentId())
                .name(c.getName())
                .birthDate(c.getBirthDate())
                .gender(c.getGender())
                .contraindicationAllergy(c.getContraindicationAllAllergy())
                .vaccinationCardNo(c.getVaccinationCardNo())
                .createTime(c.getCreateTime())
                .updateTime(c.getUpdateTime())
                .build();
    }

    /**
     * 转换预约为简单VO
     */
    private AppointmentSimpleVO toAppointmentSimpleVO(Appointment a) {
        AppointmentStatusEnum statusEnum = AppointmentStatusEnum.fromCode(a.getStatus());
        return AppointmentSimpleVO.builder()
                .id(a.getId())
                .userId(a.getUserId())
                .childId(a.getChildId())
                .vaccineId(a.getVaccineId())
                .siteId(a.getSiteId())
                .appointmentDate(a.getAppointmentDate())
                .timeSlot(a.getTimeSlot())
                .status(a.getStatus())
                .statusLabel(statusEnum != null ? statusEnum.getDesc() : String.valueOf(a.getStatus()))
                .doctorId(a.getDoctorId())
                .remark(a.getRemark())
                .createTime(a.getCreateTime())
                .updateTime(a.getUpdateTime())
                .build();
    }

    /**
     * 转换接种记录为简单VO
     */
    private RecordSimpleVO toRecordSimpleVO(Record r) {
        return RecordSimpleVO.builder()
                .id(r.getId())
                .orderId(r.getOrderId())
                .userId(r.getUserId())
                .childId(r.getChildId())
                .vaccineId(r.getVaccineId())
                .doctorId(r.getDoctorId())
                .siteId(r.getSiteId())
                .vaccinateTime(r.getVaccinateTime())
                .status(r.getStatus())
                .remark(r.getRemark())
                .createTime(r.getCreateTime())
                .build();
    }
}
