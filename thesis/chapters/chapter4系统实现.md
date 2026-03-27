# 第4章 系统实现

## 4.1 开发环境与配置

### 4.1.1 开发工具

本系统的开发过程中使用了以下开发工具和环境：

**后端开发环境**。JDK选择Java 17版本，充分利用其带来的新特性如records、模式匹配等。构建工具采用Apache Maven 3.9，负责项目依赖管理和构建。IDE选择IntelliJ IDEA 2024，提供完善的代码智能提示和调试功能。

**前端开发环境**。Node.js选择v18 LTS版本，作为UniApp开发的基础运行环境。包管理工具使用npm 10，负责管理前端依赖。IDE选择HBuilderX，这是DCloud官方推荐的UniApp开发工具，支持可视化预览和真机调试。

**数据库**。MySQL选择8.0版本，作为系统的持久化存储。MySQL 8支持窗口函数、CTE等高级特性，为业务查询提供更多优化空间。

### 4.1.2 环境配置

**后端配置文件**。Spring Boot的配置文件位于`src/main/resources/application.properties`，主要配置项包括数据库连接信息、服务器端口、日志级别等。数据库连接配置如下：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/vaccine_db?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
spring.datasource.username=root
spring.datasource.password=root
server.port=8080
```

**MyBatis-Plus配置**。在MyBatis-Plus配置类中开启了驼峰命名映射、逻辑删除、乐观锁等特性。逻辑删除字段通过注解`@TableLogic`标识，删除时自动将记录标记为已删除而非物理删除。乐观锁通过`@Version`注解实现，防止并发更新导致的数据不一致。

**跨域配置**。系统实现了CORS跨域资源共享配置，允许前端应用跨域访问后端API。跨域配置类`CorsConfig`通过实现`WebMvcConfigurer`接口，配置允许的来源、请求方法、请求头等信息。

### 4.1.3 项目结构

**后端项目结构**。后端项目采用标准的Maven多模块结构，主要目录包括：`config`包存放配置类；`controller`包存放控制器，处理HTTP请求；`service`包存放业务逻辑层；`mapper`包存放数据访问层；`model`包存放实体类、DTO、VO等；`common`包存放公共类如异常处理、响应封装等。

**前端项目结构**。前端项目为UniApp标准结构，主要目录包括：`pages`目录按角色分为admin（管理员）、doctor（医生）、user（居民）三个子目录；`components`目录存放可复用组件；`common`目录存放公共样式和工具函数；`store`目录存放Vuex状态管理；`static`目录存放静态资源。

## 4.2 后端关键实现

### 4.2.1 预约管理模块实现

预约管理模块是系统的核心模块，负责处理预约的创建、查询、状态更新等业务。预约创建服务方法`createOrderWithStockCheck`实现了完整的预约流程。

**预约创建流程**。居民选择接种点、疫苗、排班时段后，系统执行以下校验：检查用户角色是否为居民、检查是否存在进行中的预约、检查是否存在同天同疫苗重复预约、检查疫苗适用月龄、检查儿童禁忌症与疫苗说明是否冲突、检查疫苗间隔天数是否满足。校验通过后，调用FEFO算法锁定库存，创建预约记录并将状态设置为“已预约”（状态码1）。

预约创建的核心代码实现如下：

```java
@Override
@Transactional(rollbackFor = Exception.class)
public Appointment createOrderWithStockCheck(CreateAppointmentDTO dto) {
    // 参数校验：用户角色、预约排班有效性、接种点状态
    SysUser user = sysUserService.getById(userId);
    if (!"RESIDENT".equals(user.getRole())) {
        throw new BizException(BizErrorCode.ROLE_NOT_RESIDENT);
    }

    // 检查是否存在进行中的预约
    List<Appointment> pendingForChild = list(new LambdaQueryWrapper<Appointment>()
            .eq(Appointment::getChildId, childId)
            .in(Appointment::getStatus, AppointmentStatusEnum.BOOKED.getCode(),
                    AppointmentStatusEnum.CHECKED_IN.getCode(),
                    AppointmentStatusEnum.PRE_CHECK_PASS.getCode(),
                    AppointmentStatusEnum.OBSERVING.getCode()));
    if (!pendingForChild.isEmpty()) {
        throw new BizException(BizErrorCode.DUPLICATE_PENDING_APPOINTMENT);
    }

    // 检查可用库存，FEFO锁定
    int stock = siteVaccineStockService.getAvailableStock(vaccineId, siteId);
    if (stock <= 0) throw new BizException(BizErrorCode.STOCK_INSUFFICIENT);

    SiteVaccineStock fefoRow = siteVaccineStockService.getFefoStockRow(siteId, vaccineId);
    boolean locked = siteVaccineStockService.lockStock(fefoRow.getId());
    Long batchId = fefoRow.getBatchId();

    // 创建预约记录
    Appointment appointment = new Appointment();
    appointment.setUserId(userId);
    appointment.setChildId(childId);
    appointment.setVaccineId(vaccineId);
    appointment.setSiteId(siteId);
    appointment.setDoctorScheduleId(doctorScheduleId);
    appointment.setDoctorId(doctorId);
    appointment.setAppointmentDate(appointmentDate);
    appointment.setStatus(AppointmentStatusEnum.BOOKED.getCode());
    appointment.setBatchId(batchId);
    save(appointment);
    return getById(appointment.getId());
}
```

**预约状态管理**。系统实现了预约状态的全流程管理，包括签到、预检、接种、留观等状态的更新。签到服务通过`checkIn`方法实现，将预约状态更新为“已签到”（状态码6）；预检服务通过`preCheck`方法实现，预检通过更新为“预检通过”（状态码7），预检未通过更新为“预检未通过”（状态码9）。

**预约取消功能**。用户可取消处于“已预约”、“已签到”、“预检通过”、“预检未通过”、“留观中”状态的预约。取消时系统自动回滚已锁定的库存，释放排班名额。取消预约的核心代码如下：

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void cancelByUser(Long appointmentId, Long userId) {
    Appointment a = getById(appointmentId);
    if (!userId.equals(a.getUserId())) {
        throw new BizException(BizErrorCode.BAD_REQUEST, "只能取消本人的预约");
    }
    // 可取消状态：1已预约、6已签到、7预检通过、9预检未通过、10留观中
    boolean canCancel = status == AppointmentStatusEnum.BOOKED.getCode()
            || status == AppointmentStatusEnum.CHECKED_IN.getCode()
            || status == AppointmentStatusEnum.PRE_CHECK_PASS.getCode()
            || status == AppointmentStatusEnum.PRE_CHECK_FAIL.getCode()
            || status == AppointmentStatusEnum.OBSERVING.getCode();
    if (!canCancel) {
        throw new BizException(BizErrorCode.BAD_REQUEST, "当前状态不可取消");
    }
    // 取消时回滚接种点锁定库存
    if (a.getBatchId() != null && a.getSiteId() != null) {
        siteVaccineStockService.unlockStock(a.getSiteId(), a.getBatchId());
    }
    a.setStatus(AppointmentStatusEnum.CANCELLED.getCode());
    updateById(a);
}
```

### 4.2.2 库存管理模块实现

库存管理模块负责疫苗库存的查询、锁定、扣减等操作。FEFO（First Expired First Out，先过期先出）库存分配策略是本系统的核心创新点。

**FEFO算法实现**。FEFO算法的核心逻辑在Mapper层的SQL语句中实现，通过`selectFefoBySiteAndVaccine`方法查询符合条件的批次。SQL查询逻辑为：从`site_vaccine_stock`表和`vaccine_batch`表关联查询，筛选条件包括接种点ID、疫苗ID、可用库存大于0、批次未过期（有效期大于当前日期）、批次状态有效，按批次有效期升序排列，取第一条记录。

FEFO查询的SQL实现如下：

```xml
<!-- FEFO：接种点+疫苗维度，取未过期且 available_stock>0 的批次，按 expiry_date 升序 -->
<select id="selectFefoBySiteAndVaccine" resultMap="BaseResultMap">
    SELECT s.id, s.site_id, s.batch_id, s.available_stock, s.locked_stock
    FROM site_vaccine_stock s
    INNER JOIN vaccine_batch b ON s.batch_id = b.id
    WHERE s.site_id = #{siteId}
      AND b.vaccine_id = #{vaccineId}
      AND s.available_stock > 0
      AND b.expiry_date > CURDATE()
      AND b.status IN (0, 1)
    ORDER BY b.expiry_date ASC
    LIMIT 1
</select>
```

**库存锁定机制**。预约创建时调用`lockStock`方法锁定库存，该方法执行原子操作：可用库存减1，锁定库存加1。锁定操作的SQL实现如下：

```xml
<!-- 预约锁定：available -1, locked +1 -->
<update id="lockStock">
    UPDATE site_vaccine_stock
    SET available_stock = available_stock - 1, locked_stock = locked_stock + 1, updated_at = NOW()
    WHERE id = #{id} AND available_stock > 0
</update>
```

**库存扣减机制**。预约完成接种后调用`deductOnVerify`方法扣减库存，该方法将锁定库存减1，表示该剂疫苗已完成接种。扣减操作的SQL实现如下：

```xml
<!-- 核销扣减：仅 locked -1（可用已在预约锁定时减过） -->
<update id="deductOnVerify">
    UPDATE site_vaccine_stock
    SET locked_stock = locked_stock - 1, updated_at = NOW()
    WHERE site_id = #{siteId} AND batch_id = #{batchId} AND locked_stock > 0
</update>
```

**库存解锁机制**。预约取消时调用`unlockStock`方法释放锁定库存，该方法执行反向操作：可用库存加1，锁定库存减1。解锁操作的SQL实现如下：

```xml
<!-- 取消预约回滚：available +1, locked -1 -->
<update id="unlockStock">
    UPDATE site_vaccine_stock
    SET available_stock = available_stock + 1, locked_stock = locked_stock - 1, updated_at = NOW()
    WHERE id = #{id} AND locked_stock > 0
</update>
```

**库存查询功能**。系统提供了多种库存查询接口，包括按接种点和疫苗查询可用库存汇总、按接种点查询所有批次库存详情、按接种点和疫苗查询FEFO批次等。这些查询接口为前端预约页面和后台管理页面提供数据支持。

### 4.2.3 预约核销模块实现

预约核销模块负责处理接种的具体操作，包括签到、预检、接种、留观等环节，最终生成接种记录。

**接种核销流程**。医生对预约进行核销时，系统执行以下操作：校验预约状态（仅允许已预约、已签到、预检通过状态的预约进行核销）；校验操作医生权限（仅允许该预约的排班医生或接种点驻场医生执行核销）；从预约关联的批次扣减锁定库存；更新预约状态为“留观中”；设置留观开始时间和留观时长（默认30分钟）；生成接种记录。

接种核销的核心代码实现如下：

```java
@Override
@Transactional(rollbackFor = Exception.class)
public VaccinationRecord createRecordByAppointment(CreateRecordDTO dto) {
    // 校验操作权限
    Appointment appointment = appointmentService.getById(dto.getAppointmentId());
    Integer status = appointment.getStatus();
    boolean canVaccinate = Integer.valueOf(AppointmentStatusEnum.BOOKED.getCode()).equals(status)
            || Integer.valueOf(AppointmentStatusEnum.CHECKED_IN.getCode()).equals(status)
            || Integer.valueOf(AppointmentStatusEnum.PRE_CHECK_PASS.getCode()).equals(status);
    if (!canVaccinate) {
        throw new BizException(BizErrorCode.BAD_REQUEST, "当前预约状态不可核销");
    }

    // 从预约时锁定的批次扣减库存
    Long batchId = appointment.getBatchId();
    boolean siteDeducted = siteVaccineStockService.deductOnVerify(appointment.getSiteId(), batchId);
    if (!siteDeducted) {
        throw new BizException(BizErrorCode.BAD_REQUEST, "库存扣减失败");
    }

    // 设置留观状态
    appointment.setStatus(AppointmentStatusEnum.OBSERVING.getCode());
    appointment.setObserveStartTime(LocalDateTime.now());
    appointment.setObserveDuration(30); // 默认30分钟
    appointmentService.updateById(appointment);

    // 计算下次接种日期
    LocalDate nextDoseDate = null;
    if (vaccine.getIntervalDays() != null && vaccine.getIntervalDays() > 0) {
        int totalDoses = vaccine.getTotalDoses() != null ? vaccine.getTotalDoses() : 1;
        if (doseNumber < totalDoses) {
            nextDoseDate = vaccinationTime.toLocalDate().plusDays(vaccine.getIntervalDays());
        }
    }

    // 生成接种记录
    VaccinationRecord record = VaccinationRecord.builder()
            .childId(appointment.getChildId())
            .userId(appointment.getUserId())
            .vaccineId(appointment.getVaccineId())
            .appointmentId(appointment.getId())
            .batchId(batchId)
            .vaccineCode(generateVaccineCode(vaccine, batch, vaccinationTime.toLocalDate()))
            .vaccinationDate(vaccinationTime)
            .doctorId(operatorId)
            .doseNumber(dto.getDoseNumber())
            .nextDoseDate(nextDoseDate)
            .build();
    save(record);
    return record;
}
```

**疫苗编号生成**。系统为每剂接种的疫苗生成唯一编号，编号格式为“疫苗简称-接种日期(YYYYMMDD)-批号后6位-当天序号(4位)”。例如："HBV-20240317-123456-0001"。疫苗编号的生成实现了疫苗的全程可追溯。

**留观管理**。接种完成后系统自动启动留观计时，默认留观时长为30分钟。系统通过定时任务`completeObservationExpired`检查留观是否超时，超时后自动将预约状态更新为“已完成”。留观期间医生可标记留观是否异常，如有异常则记录到接种记录中。

## 4.3 前端关键实现

### 4.3.1 页面结构

前端页面按角色分为三个主要模块：居民端、医生端、管理员端。

**居民端页面**。居民端主要页面包括：首页（轮播图、通知公告、快捷入口）、宝宝档案管理（添加、编辑、查看儿童信息）、疫苗列表（按分类展示疫苗）、预约页面（选择接种点、疫苗、日期、时段）、我的预约（查看预约列表、取消预约）、接种记录（查看历史接种记录）。

**医生端页面**。医生端主要页面包括：今日任务（显示当天待接种的预约列表）、预约详情（查看预约详情、签到、预检）、接种核销（扫描疫苗、确认接种）、接种记录（查看历史接种记录）、我的排班（查看排班信息）。

**管理员端页面**。管理员端主要页面包括：仪表盘（统计大屏，展示关键指标）、用户管理（用户列表、角色管理）、疫苗管理（疫苗列表、添加编辑）、接种点管理（接种点列表、库存查看）、库存管理（入库、出库、调拨）、排班管理（医生排班）、公告管理（发布通知公告）、统计分析（接种趋势图表）。

### 4.3.2 核心组件实现

**预约表单组件**。居民端预约页面实现了一套完整的预约表单，包括接种点选择器、疫苗选择器、日历选择器、时段选择器。组件实现了日期联动逻辑：选择接种点后加载该点的可用疫苗列表；选择疫苗后加载该疫苗的可用排班日期；选择日期后加载该日期的可用时段。表单还实现了库存状态实时显示，让用户清楚了解各时段的预约余量。

**预约状态组件**。前端通过预约状态组件展示不同状态的预约卡片，使用不同的颜色和图标区分：已预约（蓝色）、已签到（绿色）、已完成（灰色）、已取消（红色）、已过期（橙色）。组件还实现了状态对应的操作按钮显示，如“签到”、“预检”、“接种”、“取消”等。

**库存可视化组件**。管理员端的库存管理页面实现了库存可视化展示，包括按疫苗汇总的库存列表、按批次的库存明细、库存预警提示（低于阈值的疫苗用红色高亮）。组件支持库存操作：入库、出库、调拨。

**统计图表组件**。管理员端的统计大屏集成了u-charts图表库，实现了多种统计图表：接种趋势折线图（展示近7天/30天的接种量）、时段热力图（展示各时段的预约量分布）、疫苗接种量饼图（展示各疫苗的接种占比）、接种点工作量柱状图（展示各接种点的工作量对比）。

### 4.3.3 多端适配说明

本系统前端采用UniApp框架开发，实现了“一次开发，多端运行”的目标。

**微信小程序适配**。系统支持在微信小程序中运行，所有页面和组件均通过了微信小程序兼容测试。微信特有的分享功能、扫一扫功能、模板消息推送功能均已集成到相应页面中。

**H5移动端适配**。系统同时支持H5移动端浏览器访问，采用了响应式布局设计，能够适配不同尺寸的手机屏幕。H5模式下可以使用微信登录、支付宝支付等第三方登录和支付功能。

**App端适配**。通过DCloud的uts语言能力，系统可以编译为原生App（Android/iOS）。App端提供了更好的用户体验，包括离线缓存、消息推送、原生动画等特性。

多端共享的核心业务逻辑通过Vuex状态管理实现，各端特有的功能通过条件编译`#ifdef`区分处理。API请求层统一封装了请求拦截器、响应拦截器、错误处理逻辑，确保各端的接口调用方式一致。