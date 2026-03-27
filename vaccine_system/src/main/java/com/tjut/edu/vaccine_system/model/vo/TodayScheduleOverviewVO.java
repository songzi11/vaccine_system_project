package com.tjut.edu.vaccine_system.model.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.List;

/**
 * 今日排班概览响应对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TodayScheduleOverviewVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 日期 */
    private LocalDate date;
    /** 星期 */
    private String dayOfWeek;
    /** 医生列表 */
    private List<DoctorScheduleOverviewItemVO> doctors;
}
