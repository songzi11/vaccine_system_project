package com.tjut.edu.vaccine_system.service;

import com.tjut.edu.vaccine_system.VaccineSystemApplication;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@SpringBootTest(classes = VaccineSystemApplication.class)
@Slf4j
public class DoctorScheduleGeneratorServiceTest {

    @Autowired
    private DoctorScheduleGeneratorService doctorScheduleGeneratorService;

    @Test
    public void testGenerateCurrentMonthSchedules() {
        // 生成当前月的排班
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        doctorScheduleGeneratorService.generateMonthlySchedules(currentMonth);
        log.info("生成{}排班完成", currentMonth);
    }

    @Test
    public void testGenerateNextMonthSchedules() {
        // 生成下个月的排班
        String nextMonth = LocalDate.now().plusMonths(1).format(DateTimeFormatter.ofPattern("yyyy-MM"));
        doctorScheduleGeneratorService.generateMonthlySchedules(nextMonth);
        log.info("生成{}排班完成", nextMonth);
    }

    @Test
    public void testGenerateTimeSlots() throws Exception {
        // 使用反射调用私有方法generateTimeSlots
        java.lang.reflect.Method method = DoctorScheduleGeneratorService.class.getDeclaredMethod("generateTimeSlots");
        method.setAccessible(true);

        java.util.List<String> timeSlots = (java.util.List<String>) method.invoke(doctorScheduleGeneratorService);

        // 验证生成的时间槽数量是否正确
        // 上午8点到12点：4小时 × 4个15分钟时段 = 16个时段
        // 下午14点到17点：3小时 × 4个15分钟时段 = 12个时段
        // 总计：16 + 12 = 28个时段
        assert timeSlots.size() == 28 : "时间槽数量应该为28个，实际为" + timeSlots.size();

        // 验证第一个时段是否为08:00-08:15
        assert "08:00-08:15".equals(timeSlots.get(0)) : "第一个时段应该是08:00-08:15，实际为" + timeSlots.get(0);

        // 验证最后一个时段是否为16:45-17:00
        assert "16:45-17:00".equals(timeSlots.get(timeSlots.size() - 1)) : "最后一个时段应该是16:45-17:00，实际为" + timeSlots.get(timeSlots.size() - 1);

        // 验证是否不包含中午12点到14点的时段
        for (String slot : timeSlots) {
            assert !slot.startsWith("12:") && !slot.startsWith("13:") : "不应该包含中午12点到14点的时段，发现：" + slot;
        }

        log.info("时间槽生成测试通过，共生成{}个时段", timeSlots.size());
        for (String slot : timeSlots) {
            log.info("时段: {}", slot);
        }
    }
}