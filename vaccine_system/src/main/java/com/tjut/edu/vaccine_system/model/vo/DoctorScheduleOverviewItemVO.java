package com.tjut.edu.vaccine_system.model.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.List;

/**
 * 医生排班概览项VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorScheduleOverviewItemVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 医生ID */
    private Long doctorId;
    /** 医生姓名 */
    private String doctorName;
    /** 医生性别 1=男 2=女 */
    private Integer doctorGender;
    /** 医生电话 */
    private String doctorPhone;
    /** 接种点ID */
    private Long siteId;
    /** 接种点名称 */
    private String siteName;
    /** 上午时段数 */
    private Integer morningSlotCount;
    /** 下午时段数 */
    private Integer afternoonSlotCount;
    /** 今日预约数 */
    private Integer todayAppointmentCount;
    /** 状态 normal=全部启用, partial=部分禁用 */
    private String status;
    /** 该医生的所有排班记录（可选） */
    private List<DoctorScheduleSimpleVO> schedules;
}
