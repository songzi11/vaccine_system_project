package com.tjut.edu.vaccine_system.model.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * 医生排班简单VO（用于概览）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorScheduleSimpleVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long doctorId;
    private Long siteId;
    private LocalDate scheduleDate;
    private String timeSlot;
    private Integer maxCapacity;
    private Integer currentCount;
    private Integer status;
}
