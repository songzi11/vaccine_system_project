/*
 Navicat Premium Data Transfer

 Source Server         : localatabase
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : vaccine_system

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 27/03/2026 15:31:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for adverse_reaction
-- ----------------------------
DROP TABLE IF EXISTS `adverse_reaction`;
CREATE TABLE `adverse_reaction`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `record_id` bigint NOT NULL COMMENT '接种记录ID',
  `reporter_id` bigint NULL DEFAULT NULL COMMENT '上报人（家长）用户ID',
  `symptoms` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '症状描述',
  `severity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '严重程度：MILD/MODERATE/SEVERE',
  `report_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上报时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_record_id`(`record_id` ASC) USING BTREE,
  INDEX `idx_reporter_id`(`reporter_id` ASC) USING BTREE,
  INDEX `idx_report_time`(`report_time` ASC) USING BTREE,
  CONSTRAINT `fk_ar_record` FOREIGN KEY (`record_id`) REFERENCES `vaccination_record` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_ar_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '不良反应上报表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of adverse_reaction
-- ----------------------------
INSERT INTO `adverse_reaction` VALUES (1, 1, 4, '接种处轻微红肿', 'MILD', '2025-02-17 14:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (2, 2, 4, '无', 'MILD', '2025-02-18 15:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (3, 3, 5, '无', 'MILD', '2025-02-20 16:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (4, 4, 5, '低热 37.5℃', 'MILD', '2025-02-21 18:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (5, 5, 5, '无', 'MILD', '2025-02-22 17:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (6, 6, 5, '无', 'MILD', '2025-02-24 19:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (7, 7, 4, '无', 'MILD', '2025-01-10 20:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (8, 8, 4, '乏力半天', 'MILD', '2025-01-15 21:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (9, 9, 4, '无', 'MILD', '2025-01-20 22:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `adverse_reaction` VALUES (10, 10, 5, '发热 38℃ 持续一天', 'MODERATE', '2025-01-26 10:00:00', '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '家长/居民用户ID',
  `child_id` bigint NULL DEFAULT NULL COMMENT '儿童档案ID',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `batch_id` bigint NULL DEFAULT NULL COMMENT 'FEFO 分配的批次ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `doctor_schedule_id` bigint NULL DEFAULT NULL COMMENT '排班ID（预约时必选）',
  `appointment_date` date NOT NULL COMMENT '预约日期',
  `time_slot` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '时段',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1已预约 6已签到 7预检通过 9预检未通过 10留观中 2已完成 3已取消 4已过期',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '分配医生ID',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `observe_start_time` datetime NULL DEFAULT NULL COMMENT '留观开始时间（完成接种时写入）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_child_id`(`child_id` ASC) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_appointment_date`(`appointment_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id` ASC) USING BTREE,
  INDEX `idx_doctor_schedule_id`(`doctor_schedule_id` ASC) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  CONSTRAINT `fk_appointment_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batch` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_child` FOREIGN KEY (`child_id`) REFERENCES `child_profile` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_doctor_schedule` FOREIGN KEY (`doctor_schedule_id`) REFERENCES `doctor_schedule` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_appointment_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预约单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of appointment
-- ----------------------------
INSERT INTO `appointment` VALUES (1, 4, 1, 1, NULL, 1, NULL, '2026-02-11', '08:00-09:00', 2, 2, '第一针', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (2, 4, 2, 6, NULL, 1, NULL, '2026-02-11', '08:00-09:00', 2, 2, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (3, 4, NULL, 3, NULL, 1, NULL, '2025-02-17', '08:00-09:00', 2, 2, '第二针', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (4, 4, NULL, 4, NULL, 1, NULL, '2025-02-18', '10:00-11:00', 2, 2, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (5, 4, NULL, 8, NULL, 1, NULL, '2025-02-19', '08:00-09:00', 3, NULL, '改期', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (6, 5, 6, 2, NULL, 1, NULL, '2025-02-20', '09:00-10:00', 2, 2, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (7, 5, 7, 7, NULL, 2, NULL, '2025-02-21', '08:00-09:00', 2, 3, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (8, 5, 8, 1, NULL, 2, NULL, '2025-02-22', '10:00-11:00', 2, 3, '第一针', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (9, 5, 9, 5, NULL, 2, NULL, '2025-02-23', '08:00-09:00', 4, NULL, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (10, 5, 10, 9, NULL, 2, NULL, '2025-02-24', '09:00-10:00', 2, 3, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `appointment` VALUES (11, 4, NULL, 1, NULL, 1, NULL, '2026-02-11', '08:00-09:00', 4, 2, NULL, NULL, '2026-02-11 23:39:28', '2026-02-11 23:39:28');
INSERT INTO `appointment` VALUES (12, 4, NULL, 1, NULL, 1, NULL, '2026-02-12', '08:00-09:00', 2, 6, NULL, NULL, '2026-02-12 07:57:14', '2026-02-12 07:57:14');
INSERT INTO `appointment` VALUES (13, 4, 2, 1, NULL, 1, NULL, '2026-03-12', '08:00-09:00', 3, 2, NULL, NULL, '2026-02-12 08:28:15', '2026-02-12 08:28:15');
INSERT INTO `appointment` VALUES (14, 4, 1, 5, NULL, 1, NULL, '2026-04-30', '08:00-09:00', 3, NULL, NULL, NULL, '2026-02-12 19:19:42', '2026-02-12 19:19:42');
INSERT INTO `appointment` VALUES (15, 4, 1, 3, NULL, 1, NULL, '2026-02-24', '08:00-09:00', 2, 7, NULL, NULL, '2026-02-24 09:58:27', '2026-02-24 09:58:27');
INSERT INTO `appointment` VALUES (16, 4, 1, 6, NULL, 1, NULL, '2026-02-26', '08:00-09:00', 3, 2, NULL, NULL, '2026-02-24 17:25:24', '2026-02-24 17:25:24');
INSERT INTO `appointment` VALUES (17, 4, 1, 2, NULL, 1, 134, '2026-02-25', '08:00-08:15', 3, 2, NULL, '2026-02-25 15:34:43', '2026-02-25 15:10:58', '2026-02-25 15:10:58');
INSERT INTO `appointment` VALUES (18, 4, 1, 2, 3, 1, NULL, '2026-03-27', '08:00-08:15', 3, 2, NULL, NULL, '2026-03-26 15:59:23', '2026-03-26 15:59:23');
INSERT INTO `appointment` VALUES (19, 4, 2, 2, 3, 1, NULL, '2026-03-26', '15:45-16:00', 3, 2, NULL, '2026-03-26 16:02:28', '2026-03-26 16:01:57', '2026-03-26 16:01:57');
INSERT INTO `appointment` VALUES (20, 4, 1, 2, 3, 1, NULL, '2026-03-26', '08:00-08:15', 4, 2, NULL, NULL, '2026-03-26 16:21:09', '2026-03-26 16:21:09');
INSERT INTO `appointment` VALUES (21, 4, 1, 2, 3, 1, NULL, '2026-03-27', '09:45-10:00', 1, 2, NULL, NULL, '2026-03-26 16:41:45', '2026-03-26 16:41:45');
INSERT INTO `appointment` VALUES (22, 5, 6, 2, 3, 1, NULL, '2026-03-27', '10:00-10:15', 3, 2, NULL, NULL, '2026-03-26 16:42:21', '2026-03-26 16:42:21');
INSERT INTO `appointment` VALUES (23, 4, 2, 2, 3, 1, NULL, '2026-03-27', '08:00-08:15', 10, 2, NULL, '2026-03-27 12:19:02', '2026-03-26 16:48:50', '2026-03-26 16:48:50');
INSERT INTO `appointment` VALUES (24, 5, 7, 2, 3, 2, NULL, '2026-03-27', '08:15-08:30', 10, 2, NULL, '2026-03-27 12:35:14', '2026-03-26 22:31:08', '2026-03-26 22:31:08');

-- ----------------------------
-- Table structure for campaign_push_log
-- ----------------------------
DROP TABLE IF EXISTS `campaign_push_log`;
CREATE TABLE `campaign_push_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `vaccine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗名称',
  `site_id` bigint NULL DEFAULT NULL COMMENT '接种点ID',
  `target_user_id` bigint NOT NULL COMMENT '目标家长用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '推送内容',
  `push_channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'WECHAT' COMMENT '推送渠道',
  `push_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '推送时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_target_user_id`(`target_user_id` ASC) USING BTREE,
  INDEX `idx_push_time`(`push_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '宣传推送记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of campaign_push_log
-- ----------------------------
INSERT INTO `campaign_push_log` VALUES (1, 6, '流感疫苗', 1, 4, '流感高发季来临，建议为宝宝预约流感疫苗，南开区社区卫生服务中心可接种。', 'WECHAT', '2025-02-02 10:30:00', '2026-02-11 23:03:22');
INSERT INTO `campaign_push_log` VALUES (2, 6, '流感疫苗', 2, 5, '流感疫苗到货，南开区妇幼保健院接种点开放预约，请及时为儿童接种。', 'WECHAT', '2025-02-02 11:00:00', '2026-02-11 23:03:22');
INSERT INTO `campaign_push_log` VALUES (3, 8, '手足口疫苗', 1, 4, 'EV71手足口疫苗可预防重症手足口病，建议6月龄以上儿童接种。', 'APP', '2025-02-04 09:00:00', '2026-02-11 23:03:22');
INSERT INTO `campaign_push_log` VALUES (4, 7, '水痘疫苗', 2, 5, '水痘疫苗两针程序可长期保护，第二针与第一针间隔3个月以上。', 'WECHAT', '2025-02-05 14:00:00', '2026-02-11 23:03:22');
INSERT INTO `campaign_push_log` VALUES (5, 9, '肺炎球菌疫苗', 1, 4, '13价肺炎疫苗适合2月龄起接种，可有效预防肺炎球菌感染。', 'WECHAT', '2025-02-06 10:00:00', '2026-02-11 23:03:22');
INSERT INTO `campaign_push_log` VALUES (6, 10, '轮状病毒疫苗', 2, 5, '轮状病毒疫苗口服接种，预防婴幼儿腹泻，请关注接种时间。', 'APP', '2025-02-07 09:30:00', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for child_profile
-- ----------------------------
DROP TABLE IF EXISTS `child_profile`;
CREATE TABLE `child_profile`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint NOT NULL COMMENT '家长用户ID',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '儿童姓名',
  `birth_date` date NOT NULL COMMENT '出生日期',
  `gender` tinyint NOT NULL COMMENT '性别：0-未知，1-男，2-女',
  `contraindication_allergy` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '禁忌症/过敏史',
  `vaccination_card_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '接种卡号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_birth_date`(`birth_date` ASC) USING BTREE,
  INDEX `idx_vaccination_card_no`(`vaccination_card_no` ASC) USING BTREE,
  CONSTRAINT `fk_child_parent` FOREIGN KEY (`parent_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '儿童档案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of child_profile
-- ----------------------------
INSERT INTO `child_profile` VALUES (1, 4, '李小宝', '2023-05-10', 1, NULL, 'TJNK20230001', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `child_profile` VALUES (2, 4, '李二宝', '2024-01-20', 2, '鸡蛋过敏', 'TJNK20240002', '2026-02-11 23:03:22', '2026-02-24 17:55:58');
INSERT INTO `child_profile` VALUES (6, 5, '赵小明', '2023-02-14', 1, NULL, 'TJNK20230006', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `child_profile` VALUES (7, 5, '赵小红', '2023-07-20', 2, NULL, 'TJNK20230007', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `child_profile` VALUES (8, 5, '赵小刚', '2024-05-01', 1, '青霉素过敏', 'TJNK20240008', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `child_profile` VALUES (9, 5, '赵小丽', '2022-12-25', 2, NULL, 'TJNK20220009', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `child_profile` VALUES (10, 5, '赵小强', '2023-09-10', 1, NULL, 'TJNK20230010', '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for doctor_dispatch
-- ----------------------------
DROP TABLE IF EXISTS `doctor_dispatch`;
CREATE TABLE `doctor_dispatch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `doctor_id` bigint NOT NULL COMMENT '医生用户ID',
  `from_site_id` bigint NOT NULL COMMENT '调出接种点ID',
  `to_site_id` bigint NOT NULL COMMENT '调入接种点ID',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-待审批，1-同意，2-拒绝',
  `apply_time` datetime NULL DEFAULT NULL COMMENT '申请时间',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id` ASC) USING BTREE,
  INDEX `idx_from_site_id`(`from_site_id` ASC) USING BTREE,
  INDEX `idx_to_site_id`(`to_site_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_dispatch_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_dispatch_from_site` FOREIGN KEY (`from_site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_dispatch_to_site` FOREIGN KEY (`to_site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生调遣申请表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of doctor_dispatch
-- ----------------------------
INSERT INTO `doctor_dispatch` VALUES (1, 2, 1, 2, 1, '2025-01-15 09:00:00', '2025-01-15 14:00:00');
INSERT INTO `doctor_dispatch` VALUES (2, 2, 2, 3, 2, '2025-02-01 10:00:00', '2026-02-11 23:23:14');
INSERT INTO `doctor_dispatch` VALUES (6, 2, 2, 1, 1, '2026-02-11 23:22:41', '2026-02-11 23:23:10');
INSERT INTO `doctor_dispatch` VALUES (7, 6, 1, 3, 0, '2026-02-12 00:11:52', NULL);
INSERT INTO `doctor_dispatch` VALUES (8, 6, 1, 3, 1, '2026-02-12 08:30:57', '2026-02-12 08:31:40');
INSERT INTO `doctor_dispatch` VALUES (9, 7, 1, 2, 1, '2026-02-24 09:33:32', '2026-02-24 17:57:37');
INSERT INTO `doctor_dispatch` VALUES (10, 7, 1, 2, 1, '2026-02-24 10:19:51', '2026-02-24 17:57:37');
INSERT INTO `doctor_dispatch` VALUES (11, 7, 1, 2, 1, '2026-02-24 10:20:38', '2026-02-24 17:57:36');
INSERT INTO `doctor_dispatch` VALUES (12, 7, 1, 2, 1, '2026-02-24 10:20:43', '2026-02-24 17:57:35');
INSERT INTO `doctor_dispatch` VALUES (13, 2, 2, 1, 1, '2026-02-24 10:33:56', '2026-02-24 10:34:43');
INSERT INTO `doctor_dispatch` VALUES (14, 7, 4, 1, 1, '2026-02-24 10:34:01', '2026-02-24 17:57:39');
INSERT INTO `doctor_dispatch` VALUES (15, 2, 2, 1, 1, '2026-02-24 10:34:08', '2026-02-24 10:34:45');
INSERT INTO `doctor_dispatch` VALUES (16, 7, 4, 1, 1, '2026-02-24 11:30:12', '2026-02-24 17:57:33');
INSERT INTO `doctor_dispatch` VALUES (17, 2, 2, 1, 1, '2026-02-24 11:30:55', '2026-02-24 11:31:22');
INSERT INTO `doctor_dispatch` VALUES (18, 7, 4, 1, 1, '2026-02-24 15:57:46', '2026-02-24 17:57:33');
INSERT INTO `doctor_dispatch` VALUES (19, 2, 2, 1, 1, '2026-02-24 15:57:50', '2026-02-24 17:11:17');
INSERT INTO `doctor_dispatch` VALUES (20, 7, 4, 1, 1, '2026-02-24 17:50:56', '2026-02-24 17:57:32');
INSERT INTO `doctor_dispatch` VALUES (21, 7, 1, 4, 0, '2026-02-25 15:36:39', NULL);
INSERT INTO `doctor_dispatch` VALUES (22, 7, 1, 3, 0, '2026-02-25 15:36:50', NULL);
INSERT INTO `doctor_dispatch` VALUES (23, 7, 1, 4, 0, '2026-02-25 16:29:14', NULL);
INSERT INTO `doctor_dispatch` VALUES (24, 2, 2, 1, 1, '2026-02-25 16:29:26', '2026-03-27 12:37:03');
INSERT INTO `doctor_dispatch` VALUES (25, 7, 3, 2, 1, '2026-03-26 15:57:23', '2026-03-26 16:01:16');
INSERT INTO `doctor_dispatch` VALUES (32, 3, 2, 2, 0, '2026-03-27 12:13:55', NULL);
INSERT INTO `doctor_dispatch` VALUES (33, 6, 1, 1, 0, '2026-03-27 12:14:04', NULL);
INSERT INTO `doctor_dispatch` VALUES (34, 2, 3, 3, 1, '2026-03-27 12:14:13', '2026-03-27 12:37:01');
INSERT INTO `doctor_dispatch` VALUES (35, 7, 4, 4, 0, '2026-03-27 12:37:56', NULL);
INSERT INTO `doctor_dispatch` VALUES (36, 7, 4, 3, 0, '2026-03-27 12:38:04', NULL);

-- ----------------------------
-- Table structure for doctor_schedule
-- ----------------------------
DROP TABLE IF EXISTS `doctor_schedule`;
CREATE TABLE `doctor_schedule`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `doctor_id` bigint NOT NULL COMMENT '医生用户ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `schedule_date` date NOT NULL COMMENT '排班日期',
  `time_slot` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '时段，如 08:00-09:00',
  `max_capacity` int NOT NULL DEFAULT 0 COMMENT '该时段最大预约数',
  `current_count` int NOT NULL DEFAULT 0 COMMENT '当前已预约数',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_schedule_date`(`schedule_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_site_date_slot`(`site_id` ASC, `schedule_date` ASC, `time_slot` ASC) USING BTREE,
  CONSTRAINT `fk_ds_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_ds_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15366 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生排班表（排班先行）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of doctor_schedule
-- ----------------------------
INSERT INTO `doctor_schedule` VALUES (121, 6, 1, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (122, 2, 1, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (123, 6, 2, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (124, 2, 2, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (125, 6, 4, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (126, 2, 4, '2026-02-27', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (127, 6, 1, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (128, 2, 1, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (129, 6, 2, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (130, 2, 2, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (131, 6, 4, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (132, 2, 4, '2026-02-26', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (133, 6, 1, '2026-02-25', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (134, 2, 1, '2026-02-25', '08:00-08:15', 5, 1, 1, '2026-02-25 10:44:49', '2026-02-25 15:10:57');
INSERT INTO `doctor_schedule` VALUES (135, 6, 2, '2026-02-25', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (136, 2, 2, '2026-02-25', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (137, 6, 4, '2026-02-25', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (138, 2, 4, '2026-02-25', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (139, 6, 1, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (140, 2, 1, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (141, 6, 2, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (142, 2, 2, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (143, 6, 4, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (144, 2, 4, '2026-02-24', '08:00-08:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (265, 6, 1, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (266, 2, 1, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (267, 6, 2, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (268, 2, 2, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (269, 6, 4, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (270, 2, 4, '2026-02-27', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (271, 6, 1, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (272, 2, 1, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (273, 6, 2, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (274, 2, 2, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (275, 6, 4, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (276, 2, 4, '2026-02-26', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (277, 6, 1, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (278, 2, 1, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (279, 6, 2, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (280, 2, 2, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (281, 6, 4, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (282, 2, 4, '2026-02-25', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (283, 6, 1, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (284, 2, 1, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (285, 6, 2, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (286, 2, 2, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (287, 6, 4, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (288, 2, 4, '2026-02-24', '08:15-08:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (409, 6, 1, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (410, 2, 1, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (411, 6, 2, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (412, 2, 2, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (413, 6, 4, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (414, 2, 4, '2026-02-27', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (415, 6, 1, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (416, 2, 1, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (417, 6, 2, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (418, 2, 2, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (419, 6, 4, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (420, 2, 4, '2026-02-26', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (421, 6, 1, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (422, 2, 1, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (423, 6, 2, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (424, 2, 2, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (425, 6, 4, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (426, 2, 4, '2026-02-25', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (427, 6, 1, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (428, 2, 1, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (429, 6, 2, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (430, 2, 2, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (431, 6, 4, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (432, 2, 4, '2026-02-24', '08:30-08:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (553, 6, 1, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (554, 2, 1, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (555, 6, 2, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (556, 2, 2, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (557, 6, 4, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (558, 2, 4, '2026-02-27', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (559, 6, 1, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (560, 2, 1, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (561, 6, 2, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (562, 2, 2, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (563, 6, 4, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (564, 2, 4, '2026-02-26', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (565, 6, 1, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (566, 2, 1, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (567, 6, 2, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (568, 2, 2, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (569, 6, 4, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (570, 2, 4, '2026-02-25', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (571, 6, 1, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (572, 2, 1, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (573, 6, 2, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (574, 2, 2, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (575, 6, 4, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (576, 2, 4, '2026-02-24', '08:45-09:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (697, 6, 1, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (698, 2, 1, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (699, 6, 2, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (700, 2, 2, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (701, 6, 4, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (702, 2, 4, '2026-02-27', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (703, 6, 1, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (704, 2, 1, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (705, 6, 2, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (706, 2, 2, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (707, 6, 4, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (708, 2, 4, '2026-02-26', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (709, 6, 1, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (710, 2, 1, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (711, 6, 2, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (712, 2, 2, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (713, 6, 4, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (714, 2, 4, '2026-02-25', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (715, 6, 1, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (716, 2, 1, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (717, 6, 2, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (718, 2, 2, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (719, 6, 4, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (720, 2, 4, '2026-02-24', '09:00-09:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (841, 6, 1, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (842, 2, 1, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (843, 6, 2, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (844, 2, 2, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (845, 6, 4, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (846, 2, 4, '2026-02-27', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (847, 6, 1, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (848, 2, 1, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (849, 6, 2, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (850, 2, 2, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (851, 6, 4, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (852, 2, 4, '2026-02-26', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (853, 6, 1, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (854, 2, 1, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (855, 6, 2, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (856, 2, 2, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (857, 6, 4, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (858, 2, 4, '2026-02-25', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (859, 6, 1, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (860, 2, 1, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (861, 6, 2, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (862, 2, 2, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (863, 6, 4, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (864, 2, 4, '2026-02-24', '09:15-09:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (985, 6, 1, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (986, 2, 1, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (987, 6, 2, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (988, 2, 2, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (989, 6, 4, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (990, 2, 4, '2026-02-27', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (991, 6, 1, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (992, 2, 1, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (993, 6, 2, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (994, 2, 2, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (995, 6, 4, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (996, 2, 4, '2026-02-26', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (997, 6, 1, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (998, 2, 1, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (999, 6, 2, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1000, 2, 2, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1001, 6, 4, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1002, 2, 4, '2026-02-25', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1003, 6, 1, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1004, 2, 1, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1005, 6, 2, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1006, 2, 2, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1007, 6, 4, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1008, 2, 4, '2026-02-24', '09:30-09:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1129, 6, 1, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1130, 2, 1, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1131, 6, 2, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1132, 2, 2, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1133, 6, 4, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1134, 2, 4, '2026-02-27', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1135, 6, 1, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1136, 2, 1, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1137, 6, 2, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1138, 2, 2, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1139, 6, 4, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1140, 2, 4, '2026-02-26', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1141, 6, 1, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1142, 2, 1, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1143, 6, 2, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1144, 2, 2, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1145, 6, 4, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1146, 2, 4, '2026-02-25', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1147, 6, 1, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1148, 2, 1, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1149, 6, 2, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1150, 2, 2, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1151, 6, 4, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1152, 2, 4, '2026-02-24', '09:45-10:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1273, 6, 1, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1274, 2, 1, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1275, 6, 2, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1276, 2, 2, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1277, 6, 4, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1278, 2, 4, '2026-02-27', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1279, 6, 1, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1280, 2, 1, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1281, 6, 2, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1282, 2, 2, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1283, 6, 4, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1284, 2, 4, '2026-02-26', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1285, 6, 1, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1286, 2, 1, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1287, 6, 2, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1288, 2, 2, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1289, 6, 4, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1290, 2, 4, '2026-02-25', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1291, 6, 1, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1292, 2, 1, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1293, 6, 2, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1294, 2, 2, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1295, 6, 4, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1296, 2, 4, '2026-02-24', '10:00-10:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1417, 6, 1, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1418, 2, 1, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1419, 6, 2, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1420, 2, 2, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1421, 6, 4, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1422, 2, 4, '2026-02-27', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1423, 6, 1, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1424, 2, 1, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1425, 6, 2, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1426, 2, 2, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1427, 6, 4, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1428, 2, 4, '2026-02-26', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1429, 6, 1, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1430, 2, 1, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1431, 6, 2, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1432, 2, 2, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1433, 6, 4, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1434, 2, 4, '2026-02-25', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1435, 6, 1, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1436, 2, 1, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1437, 6, 2, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1438, 2, 2, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1439, 6, 4, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1440, 2, 4, '2026-02-24', '10:15-10:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1561, 6, 1, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1562, 2, 1, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1563, 6, 2, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1564, 2, 2, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1565, 6, 4, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1566, 2, 4, '2026-02-27', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1567, 6, 1, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1568, 2, 1, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1569, 6, 2, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1570, 2, 2, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1571, 6, 4, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1572, 2, 4, '2026-02-26', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1573, 6, 1, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1574, 2, 1, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1575, 6, 2, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1576, 2, 2, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1577, 6, 4, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1578, 2, 4, '2026-02-25', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1579, 6, 1, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1580, 2, 1, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1581, 6, 2, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1582, 2, 2, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1583, 6, 4, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1584, 2, 4, '2026-02-24', '10:30-10:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1705, 6, 1, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1706, 2, 1, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1707, 6, 2, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1708, 2, 2, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1709, 6, 4, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1710, 2, 4, '2026-02-27', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1711, 6, 1, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1712, 2, 1, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1713, 6, 2, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1714, 2, 2, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1715, 6, 4, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1716, 2, 4, '2026-02-26', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1717, 6, 1, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1718, 2, 1, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1719, 6, 2, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1720, 2, 2, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1721, 6, 4, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1722, 2, 4, '2026-02-25', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1723, 6, 1, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1724, 2, 1, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1725, 6, 2, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1726, 2, 2, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1727, 6, 4, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1728, 2, 4, '2026-02-24', '10:45-11:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1849, 6, 1, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1850, 2, 1, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1851, 6, 2, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1852, 2, 2, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1853, 6, 4, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1854, 2, 4, '2026-02-27', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1855, 6, 1, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1856, 2, 1, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1857, 6, 2, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1858, 2, 2, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1859, 6, 4, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1860, 2, 4, '2026-02-26', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1861, 6, 1, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1862, 2, 1, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1863, 6, 2, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1864, 2, 2, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1865, 6, 4, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1866, 2, 4, '2026-02-25', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1867, 6, 1, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1868, 2, 1, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1869, 6, 2, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1870, 2, 2, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1871, 6, 4, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1872, 2, 4, '2026-02-24', '11:00-11:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1993, 6, 1, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1994, 2, 1, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1995, 6, 2, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1996, 2, 2, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1997, 6, 4, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1998, 2, 4, '2026-02-27', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (1999, 6, 1, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2000, 2, 1, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2001, 6, 2, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2002, 2, 2, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2003, 6, 4, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2004, 2, 4, '2026-02-26', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2005, 6, 1, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2006, 2, 1, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2007, 6, 2, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2008, 2, 2, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2009, 6, 4, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2010, 2, 4, '2026-02-25', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2011, 6, 1, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2012, 2, 1, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2013, 6, 2, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2014, 2, 2, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2015, 6, 4, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2016, 2, 4, '2026-02-24', '11:15-11:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2137, 6, 1, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2138, 2, 1, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2139, 6, 2, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2140, 2, 2, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2141, 6, 4, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2142, 2, 4, '2026-02-27', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2143, 6, 1, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2144, 2, 1, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2145, 6, 2, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2146, 2, 2, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2147, 6, 4, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2148, 2, 4, '2026-02-26', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2149, 6, 1, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2150, 2, 1, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2151, 6, 2, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2152, 2, 2, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2153, 6, 4, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2154, 2, 4, '2026-02-25', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2155, 6, 1, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2156, 2, 1, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2157, 6, 2, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2158, 2, 2, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2159, 6, 4, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2160, 2, 4, '2026-02-24', '11:30-11:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2281, 6, 1, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2282, 2, 1, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2283, 6, 2, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2284, 2, 2, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2285, 6, 4, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2286, 2, 4, '2026-02-27', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2287, 6, 1, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2288, 2, 1, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2289, 6, 2, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2290, 2, 2, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2291, 6, 4, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2292, 2, 4, '2026-02-26', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2293, 6, 1, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2294, 2, 1, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2295, 6, 2, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2296, 2, 2, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2297, 6, 4, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2298, 2, 4, '2026-02-25', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2299, 6, 1, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2300, 2, 1, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2301, 6, 2, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2302, 2, 2, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2303, 6, 4, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2304, 2, 4, '2026-02-24', '11:45-12:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2425, 6, 1, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2426, 2, 1, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2427, 6, 2, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2428, 2, 2, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2429, 6, 4, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2430, 2, 4, '2026-02-27', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2431, 6, 1, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2432, 2, 1, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2433, 6, 2, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2434, 2, 2, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2435, 6, 4, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2436, 2, 4, '2026-02-26', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2437, 6, 1, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2438, 2, 1, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2439, 6, 2, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2440, 2, 2, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2441, 6, 4, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2442, 2, 4, '2026-02-25', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2443, 6, 1, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2444, 2, 1, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2445, 6, 2, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2446, 2, 2, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2447, 6, 4, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2448, 2, 4, '2026-02-24', '12:00-12:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2569, 6, 1, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2570, 2, 1, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2571, 6, 2, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2572, 2, 2, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2573, 6, 4, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2574, 2, 4, '2026-02-27', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2575, 6, 1, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2576, 2, 1, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2577, 6, 2, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2578, 2, 2, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2579, 6, 4, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2580, 2, 4, '2026-02-26', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2581, 6, 1, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2582, 2, 1, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2583, 6, 2, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2584, 2, 2, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2585, 6, 4, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2586, 2, 4, '2026-02-25', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2587, 6, 1, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2588, 2, 1, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2589, 6, 2, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2590, 2, 2, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2591, 6, 4, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2592, 2, 4, '2026-02-24', '12:15-12:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2713, 6, 1, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2714, 2, 1, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2715, 6, 2, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2716, 2, 2, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2717, 6, 4, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2718, 2, 4, '2026-02-27', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2719, 6, 1, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2720, 2, 1, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2721, 6, 2, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2722, 2, 2, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2723, 6, 4, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2724, 2, 4, '2026-02-26', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2725, 6, 1, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2726, 2, 1, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2727, 6, 2, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2728, 2, 2, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2729, 6, 4, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2730, 2, 4, '2026-02-25', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2731, 6, 1, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2732, 2, 1, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2733, 6, 2, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2734, 2, 2, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2735, 6, 4, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2736, 2, 4, '2026-02-24', '12:30-12:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2857, 6, 1, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2858, 2, 1, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2859, 6, 2, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2860, 2, 2, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2861, 6, 4, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2862, 2, 4, '2026-02-27', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2863, 6, 1, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2864, 2, 1, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2865, 6, 2, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2866, 2, 2, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2867, 6, 4, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2868, 2, 4, '2026-02-26', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2869, 6, 1, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2870, 2, 1, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2871, 6, 2, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2872, 2, 2, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2873, 6, 4, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2874, 2, 4, '2026-02-25', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2875, 6, 1, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2876, 2, 1, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2877, 6, 2, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2878, 2, 2, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2879, 6, 4, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (2880, 2, 4, '2026-02-24', '12:45-13:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3001, 6, 1, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3002, 2, 1, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3003, 6, 2, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3004, 2, 2, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3005, 6, 4, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3006, 2, 4, '2026-02-27', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3007, 6, 1, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3008, 2, 1, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3009, 6, 2, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3010, 2, 2, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3011, 6, 4, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3012, 2, 4, '2026-02-26', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3013, 6, 1, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3014, 2, 1, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3015, 6, 2, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3016, 2, 2, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3017, 6, 4, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3018, 2, 4, '2026-02-25', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3019, 6, 1, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3020, 2, 1, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3021, 6, 2, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3022, 2, 2, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3023, 6, 4, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3024, 2, 4, '2026-02-24', '13:00-13:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3145, 6, 1, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3146, 2, 1, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3147, 6, 2, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3148, 2, 2, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3149, 6, 4, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3150, 2, 4, '2026-02-27', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3151, 6, 1, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3152, 2, 1, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3153, 6, 2, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3154, 2, 2, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3155, 6, 4, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3156, 2, 4, '2026-02-26', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3157, 6, 1, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3158, 2, 1, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3159, 6, 2, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3160, 2, 2, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3161, 6, 4, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3162, 2, 4, '2026-02-25', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3163, 6, 1, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3164, 2, 1, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3165, 6, 2, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3166, 2, 2, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3167, 6, 4, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3168, 2, 4, '2026-02-24', '13:15-13:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3289, 6, 1, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3290, 2, 1, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3291, 6, 2, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3292, 2, 2, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3293, 6, 4, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3294, 2, 4, '2026-02-27', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3295, 6, 1, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3296, 2, 1, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3297, 6, 2, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3298, 2, 2, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3299, 6, 4, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3300, 2, 4, '2026-02-26', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3301, 6, 1, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3302, 2, 1, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3303, 6, 2, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3304, 2, 2, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3305, 6, 4, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3306, 2, 4, '2026-02-25', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3307, 6, 1, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3308, 2, 1, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3309, 6, 2, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3310, 2, 2, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3311, 6, 4, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3312, 2, 4, '2026-02-24', '13:30-13:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3433, 6, 1, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3434, 2, 1, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3435, 6, 2, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3436, 2, 2, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3437, 6, 4, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3438, 2, 4, '2026-02-27', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3439, 6, 1, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3440, 2, 1, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3441, 6, 2, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3442, 2, 2, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3443, 6, 4, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3444, 2, 4, '2026-02-26', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3445, 6, 1, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3446, 2, 1, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3447, 6, 2, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3448, 2, 2, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3449, 6, 4, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3450, 2, 4, '2026-02-25', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3451, 6, 1, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3452, 2, 1, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3453, 6, 2, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3454, 2, 2, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3455, 6, 4, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3456, 2, 4, '2026-02-24', '13:45-14:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3577, 6, 1, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3578, 2, 1, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3579, 6, 2, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3580, 2, 2, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3581, 6, 4, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3582, 2, 4, '2026-02-27', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3583, 6, 1, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3584, 2, 1, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3585, 6, 2, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3586, 2, 2, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3587, 6, 4, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3588, 2, 4, '2026-02-26', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3589, 6, 1, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3590, 2, 1, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3591, 6, 2, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3592, 2, 2, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3593, 6, 4, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3594, 2, 4, '2026-02-25', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3595, 6, 1, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3596, 2, 1, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3597, 6, 2, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3598, 2, 2, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3599, 6, 4, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3600, 2, 4, '2026-02-24', '14:00-14:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3721, 6, 1, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3722, 2, 1, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3723, 6, 2, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3724, 2, 2, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3725, 6, 4, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3726, 2, 4, '2026-02-27', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3727, 6, 1, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3728, 2, 1, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3729, 6, 2, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3730, 2, 2, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3731, 6, 4, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3732, 2, 4, '2026-02-26', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3733, 6, 1, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3734, 2, 1, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3735, 6, 2, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3736, 2, 2, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3737, 6, 4, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3738, 2, 4, '2026-02-25', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3739, 6, 1, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3740, 2, 1, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3741, 6, 2, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3742, 2, 2, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3743, 6, 4, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3744, 2, 4, '2026-02-24', '14:15-14:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3865, 6, 1, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3866, 2, 1, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3867, 6, 2, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3868, 2, 2, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3869, 6, 4, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3870, 2, 4, '2026-02-27', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3871, 6, 1, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3872, 2, 1, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3873, 6, 2, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3874, 2, 2, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3875, 6, 4, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3876, 2, 4, '2026-02-26', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3877, 6, 1, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3878, 2, 1, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3879, 6, 2, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3880, 2, 2, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3881, 6, 4, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3882, 2, 4, '2026-02-25', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3883, 6, 1, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3884, 2, 1, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3885, 6, 2, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3886, 2, 2, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3887, 6, 4, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (3888, 2, 4, '2026-02-24', '14:30-14:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4009, 6, 1, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4010, 2, 1, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4011, 6, 2, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4012, 2, 2, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4013, 6, 4, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4014, 2, 4, '2026-02-27', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4015, 6, 1, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4016, 2, 1, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4017, 6, 2, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4018, 2, 2, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4019, 6, 4, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4020, 2, 4, '2026-02-26', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4021, 6, 1, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4022, 2, 1, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4023, 6, 2, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4024, 2, 2, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4025, 6, 4, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4026, 2, 4, '2026-02-25', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4027, 6, 1, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4028, 2, 1, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4029, 6, 2, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4030, 2, 2, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4031, 6, 4, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4032, 2, 4, '2026-02-24', '14:45-15:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4153, 6, 1, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4154, 2, 1, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4155, 6, 2, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4156, 2, 2, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4157, 6, 4, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4158, 2, 4, '2026-02-27', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4159, 6, 1, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4160, 2, 1, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4161, 6, 2, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4162, 2, 2, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4163, 6, 4, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4164, 2, 4, '2026-02-26', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4165, 6, 1, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4166, 2, 1, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4167, 6, 2, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4168, 2, 2, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4169, 6, 4, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4170, 2, 4, '2026-02-25', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4171, 6, 1, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4172, 2, 1, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4173, 6, 2, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4174, 2, 2, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4175, 6, 4, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4176, 2, 4, '2026-02-24', '15:00-15:15', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4297, 6, 1, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4298, 2, 1, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4299, 6, 2, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4300, 2, 2, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4301, 6, 4, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4302, 2, 4, '2026-02-27', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4303, 6, 1, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4304, 2, 1, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4305, 6, 2, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4306, 2, 2, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4307, 6, 4, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4308, 2, 4, '2026-02-26', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4309, 6, 1, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4310, 2, 1, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4311, 6, 2, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4312, 2, 2, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4313, 6, 4, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4314, 2, 4, '2026-02-25', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4315, 6, 1, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4316, 2, 1, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4317, 6, 2, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4318, 2, 2, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4319, 6, 4, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4320, 2, 4, '2026-02-24', '15:15-15:30', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4441, 6, 1, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4442, 2, 1, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4443, 6, 2, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4444, 2, 2, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4445, 6, 4, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4446, 2, 4, '2026-02-27', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4447, 6, 1, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4448, 2, 1, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4449, 6, 2, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4450, 2, 2, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4451, 6, 4, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4452, 2, 4, '2026-02-26', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4453, 6, 1, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4454, 2, 1, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4455, 6, 2, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4456, 2, 2, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4457, 6, 4, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4458, 2, 4, '2026-02-25', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4459, 6, 1, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4460, 2, 1, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4461, 6, 2, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4462, 2, 2, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4463, 6, 4, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4464, 2, 4, '2026-02-24', '15:30-15:45', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4585, 6, 1, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4586, 2, 1, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4587, 6, 2, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4588, 2, 2, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4589, 6, 4, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4590, 2, 4, '2026-02-27', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4591, 6, 1, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4592, 2, 1, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4593, 6, 2, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4594, 2, 2, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4595, 6, 4, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4596, 2, 4, '2026-02-26', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4597, 6, 1, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4598, 2, 1, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4599, 6, 2, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4600, 2, 2, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4601, 6, 4, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4602, 2, 4, '2026-02-25', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4603, 6, 1, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4604, 2, 1, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4605, 6, 2, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4606, 2, 2, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4607, 6, 4, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (4608, 2, 4, '2026-02-24', '15:45-16:00', 5, 0, 1, '2026-02-25 10:44:49', '2026-02-25 10:44:49');
INSERT INTO `doctor_schedule` VALUES (8254, 3, 1, '2026-03-03', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8255, 3, 1, '2026-03-03', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8256, 3, 1, '2026-03-03', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8257, 3, 1, '2026-03-03', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8258, 3, 1, '2026-03-03', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8259, 3, 1, '2026-03-03', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8260, 3, 1, '2026-03-03', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8261, 3, 1, '2026-03-03', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8262, 3, 1, '2026-03-03', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8263, 3, 1, '2026-03-03', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8264, 3, 1, '2026-03-03', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8265, 3, 1, '2026-03-03', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8266, 3, 1, '2026-03-03', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8267, 3, 1, '2026-03-03', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8268, 3, 1, '2026-03-03', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8269, 3, 1, '2026-03-03', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8270, 3, 1, '2026-03-03', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8271, 3, 1, '2026-03-03', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8272, 3, 1, '2026-03-03', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8273, 3, 1, '2026-03-03', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8274, 3, 1, '2026-03-03', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8275, 3, 1, '2026-03-03', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8276, 3, 1, '2026-03-03', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8277, 3, 1, '2026-03-03', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8278, 3, 1, '2026-03-03', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8279, 3, 1, '2026-03-03', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8280, 3, 1, '2026-03-03', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8281, 3, 1, '2026-03-03', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8310, 2, 1, '2026-03-03', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8311, 2, 1, '2026-03-03', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8312, 2, 1, '2026-03-03', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8313, 2, 1, '2026-03-03', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8314, 2, 1, '2026-03-03', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8315, 2, 1, '2026-03-03', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8316, 2, 1, '2026-03-03', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8317, 2, 1, '2026-03-03', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8318, 2, 1, '2026-03-03', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8319, 2, 1, '2026-03-03', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8320, 2, 1, '2026-03-03', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8321, 2, 1, '2026-03-03', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8322, 2, 1, '2026-03-03', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8323, 2, 1, '2026-03-03', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8324, 2, 1, '2026-03-03', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8325, 2, 1, '2026-03-03', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8326, 2, 1, '2026-03-03', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8327, 2, 1, '2026-03-03', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8328, 2, 1, '2026-03-03', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8329, 2, 1, '2026-03-03', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8330, 2, 1, '2026-03-03', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8331, 2, 1, '2026-03-03', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8332, 2, 1, '2026-03-03', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8333, 2, 1, '2026-03-03', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8334, 2, 1, '2026-03-03', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8335, 2, 1, '2026-03-03', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8336, 2, 1, '2026-03-03', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8337, 2, 1, '2026-03-03', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:15', '2026-03-27 10:51:15');
INSERT INTO `doctor_schedule` VALUES (8478, 3, 1, '2026-03-06', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8479, 3, 1, '2026-03-06', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8480, 3, 1, '2026-03-06', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8481, 3, 1, '2026-03-06', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8482, 3, 1, '2026-03-06', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8483, 3, 1, '2026-03-06', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8484, 3, 1, '2026-03-06', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8485, 3, 1, '2026-03-06', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8486, 3, 1, '2026-03-06', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8487, 3, 1, '2026-03-06', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8488, 3, 1, '2026-03-06', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8489, 3, 1, '2026-03-06', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8490, 3, 1, '2026-03-06', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8491, 3, 1, '2026-03-06', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8492, 3, 1, '2026-03-06', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8493, 3, 1, '2026-03-06', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8494, 3, 1, '2026-03-06', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8495, 3, 1, '2026-03-06', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8496, 3, 1, '2026-03-06', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8497, 3, 1, '2026-03-06', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8498, 3, 1, '2026-03-06', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8499, 3, 1, '2026-03-06', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8500, 3, 1, '2026-03-06', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8501, 3, 1, '2026-03-06', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8502, 3, 1, '2026-03-06', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8503, 3, 1, '2026-03-06', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8504, 3, 1, '2026-03-06', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8505, 3, 1, '2026-03-06', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8534, 7, 1, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8535, 7, 1, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8536, 7, 1, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8537, 7, 1, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8538, 7, 1, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8539, 7, 1, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8540, 7, 1, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8541, 7, 1, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8542, 7, 1, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8543, 7, 1, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8544, 7, 1, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8545, 7, 1, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8546, 7, 1, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8547, 7, 1, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8548, 7, 1, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8549, 7, 1, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8550, 7, 1, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8551, 7, 1, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8552, 7, 1, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8553, 7, 1, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8554, 7, 1, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8555, 7, 1, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8556, 7, 1, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8557, 7, 1, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8558, 7, 1, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8559, 7, 1, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8560, 7, 1, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8561, 7, 1, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8590, 7, 1, '2026-03-10', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8591, 7, 1, '2026-03-10', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8592, 7, 1, '2026-03-10', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8593, 7, 1, '2026-03-10', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8594, 7, 1, '2026-03-10', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8595, 7, 1, '2026-03-10', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8596, 7, 1, '2026-03-10', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8597, 7, 1, '2026-03-10', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8598, 7, 1, '2026-03-10', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8599, 7, 1, '2026-03-10', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8600, 7, 1, '2026-03-10', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8601, 7, 1, '2026-03-10', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8602, 7, 1, '2026-03-10', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8603, 7, 1, '2026-03-10', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8604, 7, 1, '2026-03-10', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8605, 7, 1, '2026-03-10', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8606, 7, 1, '2026-03-10', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8607, 7, 1, '2026-03-10', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8608, 7, 1, '2026-03-10', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8609, 7, 1, '2026-03-10', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8610, 7, 1, '2026-03-10', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8611, 7, 1, '2026-03-10', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8612, 7, 1, '2026-03-10', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8613, 7, 1, '2026-03-10', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8614, 7, 1, '2026-03-10', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8615, 7, 1, '2026-03-10', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8616, 7, 1, '2026-03-10', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8617, 7, 1, '2026-03-10', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8674, 2, 1, '2026-03-11', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8675, 2, 1, '2026-03-11', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8676, 2, 1, '2026-03-11', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8677, 2, 1, '2026-03-11', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8678, 2, 1, '2026-03-11', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8679, 2, 1, '2026-03-11', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8680, 2, 1, '2026-03-11', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8681, 2, 1, '2026-03-11', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8682, 2, 1, '2026-03-11', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8683, 2, 1, '2026-03-11', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8684, 2, 1, '2026-03-11', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8685, 2, 1, '2026-03-11', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8686, 2, 1, '2026-03-11', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8687, 2, 1, '2026-03-11', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8688, 2, 1, '2026-03-11', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8689, 2, 1, '2026-03-11', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8690, 2, 1, '2026-03-11', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8691, 2, 1, '2026-03-11', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8692, 2, 1, '2026-03-11', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8693, 2, 1, '2026-03-11', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8694, 2, 1, '2026-03-11', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8695, 2, 1, '2026-03-11', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8696, 2, 1, '2026-03-11', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8697, 2, 1, '2026-03-11', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8698, 2, 1, '2026-03-11', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8699, 2, 1, '2026-03-11', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8700, 2, 1, '2026-03-11', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8701, 2, 1, '2026-03-11', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8758, 7, 1, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8759, 7, 1, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8760, 7, 1, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8761, 7, 1, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8762, 7, 1, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8763, 7, 1, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8764, 7, 1, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8765, 7, 1, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8766, 7, 1, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8767, 7, 1, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8768, 7, 1, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8769, 7, 1, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8770, 7, 1, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8771, 7, 1, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8772, 7, 1, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8773, 7, 1, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8774, 7, 1, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8775, 7, 1, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8776, 7, 1, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8777, 7, 1, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8778, 7, 1, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8779, 7, 1, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8780, 7, 1, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8781, 7, 1, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8782, 7, 1, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8783, 7, 1, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8784, 7, 1, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8785, 7, 1, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8814, 2, 1, '2026-03-13', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8815, 2, 1, '2026-03-13', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8816, 2, 1, '2026-03-13', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8817, 2, 1, '2026-03-13', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8818, 2, 1, '2026-03-13', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8819, 2, 1, '2026-03-13', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8820, 2, 1, '2026-03-13', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8821, 2, 1, '2026-03-13', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8822, 2, 1, '2026-03-13', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8823, 2, 1, '2026-03-13', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8824, 2, 1, '2026-03-13', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8825, 2, 1, '2026-03-13', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8826, 2, 1, '2026-03-13', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8827, 2, 1, '2026-03-13', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8828, 2, 1, '2026-03-13', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8829, 2, 1, '2026-03-13', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8830, 2, 1, '2026-03-13', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8831, 2, 1, '2026-03-13', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8832, 2, 1, '2026-03-13', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8833, 2, 1, '2026-03-13', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8834, 2, 1, '2026-03-13', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8835, 2, 1, '2026-03-13', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8836, 2, 1, '2026-03-13', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8837, 2, 1, '2026-03-13', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8838, 2, 1, '2026-03-13', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:16', '2026-03-27 10:51:16');
INSERT INTO `doctor_schedule` VALUES (8839, 2, 1, '2026-03-13', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8840, 2, 1, '2026-03-13', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8841, 2, 1, '2026-03-13', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8926, 6, 1, '2026-03-17', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8927, 6, 1, '2026-03-17', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8928, 6, 1, '2026-03-17', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8929, 6, 1, '2026-03-17', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8930, 6, 1, '2026-03-17', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8931, 6, 1, '2026-03-17', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8932, 6, 1, '2026-03-17', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8933, 6, 1, '2026-03-17', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8934, 6, 1, '2026-03-17', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8935, 6, 1, '2026-03-17', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8936, 6, 1, '2026-03-17', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8937, 6, 1, '2026-03-17', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8938, 6, 1, '2026-03-17', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8939, 6, 1, '2026-03-17', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8940, 6, 1, '2026-03-17', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8941, 6, 1, '2026-03-17', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8942, 6, 1, '2026-03-17', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8943, 6, 1, '2026-03-17', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8944, 6, 1, '2026-03-17', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8945, 6, 1, '2026-03-17', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8946, 6, 1, '2026-03-17', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8947, 6, 1, '2026-03-17', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8948, 6, 1, '2026-03-17', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8949, 6, 1, '2026-03-17', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8950, 6, 1, '2026-03-17', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8951, 6, 1, '2026-03-17', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8952, 6, 1, '2026-03-17', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8953, 6, 1, '2026-03-17', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8982, 7, 1, '2026-03-17', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8983, 7, 1, '2026-03-17', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8984, 7, 1, '2026-03-17', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8985, 7, 1, '2026-03-17', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8986, 7, 1, '2026-03-17', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8987, 7, 1, '2026-03-17', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8988, 7, 1, '2026-03-17', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8989, 7, 1, '2026-03-17', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8990, 7, 1, '2026-03-17', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8991, 7, 1, '2026-03-17', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8992, 7, 1, '2026-03-17', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8993, 7, 1, '2026-03-17', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8994, 7, 1, '2026-03-17', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8995, 7, 1, '2026-03-17', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8996, 7, 1, '2026-03-17', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8997, 7, 1, '2026-03-17', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8998, 7, 1, '2026-03-17', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (8999, 7, 1, '2026-03-17', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9000, 7, 1, '2026-03-17', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9001, 7, 1, '2026-03-17', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9002, 7, 1, '2026-03-17', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9003, 7, 1, '2026-03-17', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9004, 7, 1, '2026-03-17', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9005, 7, 1, '2026-03-17', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9006, 7, 1, '2026-03-17', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9007, 7, 1, '2026-03-17', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9008, 7, 1, '2026-03-17', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9009, 7, 1, '2026-03-17', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9010, 3, 1, '2026-03-18', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9011, 3, 1, '2026-03-18', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9012, 3, 1, '2026-03-18', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9013, 3, 1, '2026-03-18', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9014, 3, 1, '2026-03-18', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9015, 3, 1, '2026-03-18', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9016, 3, 1, '2026-03-18', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9017, 3, 1, '2026-03-18', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9018, 3, 1, '2026-03-18', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9019, 3, 1, '2026-03-18', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9020, 3, 1, '2026-03-18', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9021, 3, 1, '2026-03-18', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9022, 3, 1, '2026-03-18', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9023, 3, 1, '2026-03-18', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9024, 3, 1, '2026-03-18', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9025, 3, 1, '2026-03-18', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9026, 3, 1, '2026-03-18', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9027, 3, 1, '2026-03-18', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9028, 3, 1, '2026-03-18', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9029, 3, 1, '2026-03-18', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9030, 3, 1, '2026-03-18', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9031, 3, 1, '2026-03-18', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9032, 3, 1, '2026-03-18', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9033, 3, 1, '2026-03-18', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9034, 3, 1, '2026-03-18', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9035, 3, 1, '2026-03-18', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9036, 3, 1, '2026-03-18', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9037, 3, 1, '2026-03-18', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9150, 7, 1, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9151, 7, 1, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9152, 7, 1, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9153, 7, 1, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9154, 7, 1, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9155, 7, 1, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9156, 7, 1, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9157, 7, 1, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9158, 7, 1, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9159, 7, 1, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9160, 7, 1, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9161, 7, 1, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9162, 7, 1, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9163, 7, 1, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9164, 7, 1, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9165, 7, 1, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9166, 7, 1, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9167, 7, 1, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9168, 7, 1, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9169, 7, 1, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9170, 7, 1, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9171, 7, 1, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9172, 7, 1, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9173, 7, 1, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9174, 7, 1, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9175, 7, 1, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9176, 7, 1, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9177, 7, 1, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9206, 3, 1, '2026-03-23', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9207, 3, 1, '2026-03-23', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9208, 3, 1, '2026-03-23', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9209, 3, 1, '2026-03-23', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9210, 3, 1, '2026-03-23', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9211, 3, 1, '2026-03-23', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9212, 3, 1, '2026-03-23', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9213, 3, 1, '2026-03-23', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9214, 3, 1, '2026-03-23', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9215, 3, 1, '2026-03-23', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9216, 3, 1, '2026-03-23', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9217, 3, 1, '2026-03-23', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9218, 3, 1, '2026-03-23', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9219, 3, 1, '2026-03-23', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9220, 3, 1, '2026-03-23', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9221, 3, 1, '2026-03-23', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9222, 3, 1, '2026-03-23', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9223, 3, 1, '2026-03-23', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9224, 3, 1, '2026-03-23', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9225, 3, 1, '2026-03-23', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9226, 3, 1, '2026-03-23', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9227, 3, 1, '2026-03-23', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9228, 3, 1, '2026-03-23', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9229, 3, 1, '2026-03-23', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9230, 3, 1, '2026-03-23', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9231, 3, 1, '2026-03-23', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9232, 3, 1, '2026-03-23', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:17', '2026-03-27 10:51:17');
INSERT INTO `doctor_schedule` VALUES (9233, 3, 1, '2026-03-23', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9234, 2, 1, '2026-03-23', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9235, 2, 1, '2026-03-23', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9236, 2, 1, '2026-03-23', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9237, 2, 1, '2026-03-23', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9238, 2, 1, '2026-03-23', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9239, 2, 1, '2026-03-23', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9240, 2, 1, '2026-03-23', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9241, 2, 1, '2026-03-23', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9242, 2, 1, '2026-03-23', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9243, 2, 1, '2026-03-23', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9244, 2, 1, '2026-03-23', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9245, 2, 1, '2026-03-23', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9246, 2, 1, '2026-03-23', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9247, 2, 1, '2026-03-23', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9248, 2, 1, '2026-03-23', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9249, 2, 1, '2026-03-23', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9250, 2, 1, '2026-03-23', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9251, 2, 1, '2026-03-23', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9252, 2, 1, '2026-03-23', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9253, 2, 1, '2026-03-23', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9254, 2, 1, '2026-03-23', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9255, 2, 1, '2026-03-23', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9256, 2, 1, '2026-03-23', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9257, 2, 1, '2026-03-23', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9258, 2, 1, '2026-03-23', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9259, 2, 1, '2026-03-23', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9260, 2, 1, '2026-03-23', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9261, 2, 1, '2026-03-23', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9458, 7, 1, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9459, 7, 1, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9460, 7, 1, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9461, 7, 1, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9462, 7, 1, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9463, 7, 1, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9464, 7, 1, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9465, 7, 1, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9466, 7, 1, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9467, 7, 1, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9468, 7, 1, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9469, 7, 1, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9470, 7, 1, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9471, 7, 1, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9472, 7, 1, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9473, 7, 1, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9474, 7, 1, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9475, 7, 1, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9476, 7, 1, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9477, 7, 1, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9478, 7, 1, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9479, 7, 1, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9480, 7, 1, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9481, 7, 1, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9482, 7, 1, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9483, 7, 1, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9484, 7, 1, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9485, 7, 1, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9570, 3, 1, '2026-03-30', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9571, 3, 1, '2026-03-30', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9572, 3, 1, '2026-03-30', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9573, 3, 1, '2026-03-30', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9574, 3, 1, '2026-03-30', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9575, 3, 1, '2026-03-30', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9576, 3, 1, '2026-03-30', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9577, 3, 1, '2026-03-30', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9578, 3, 1, '2026-03-30', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9579, 3, 1, '2026-03-30', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9580, 3, 1, '2026-03-30', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9581, 3, 1, '2026-03-30', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9582, 3, 1, '2026-03-30', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9583, 3, 1, '2026-03-30', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9584, 3, 1, '2026-03-30', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9585, 3, 1, '2026-03-30', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9586, 3, 1, '2026-03-30', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9587, 3, 1, '2026-03-30', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9588, 3, 1, '2026-03-30', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9589, 3, 1, '2026-03-30', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9590, 3, 1, '2026-03-30', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9591, 3, 1, '2026-03-30', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9592, 3, 1, '2026-03-30', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9593, 3, 1, '2026-03-30', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9594, 3, 1, '2026-03-30', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9595, 3, 1, '2026-03-30', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9596, 3, 1, '2026-03-30', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9597, 3, 1, '2026-03-30', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9626, 3, 1, '2026-03-31', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9627, 3, 1, '2026-03-31', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9628, 3, 1, '2026-03-31', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9629, 3, 1, '2026-03-31', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9630, 3, 1, '2026-03-31', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9631, 3, 1, '2026-03-31', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9632, 3, 1, '2026-03-31', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9633, 3, 1, '2026-03-31', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9634, 3, 1, '2026-03-31', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9635, 3, 1, '2026-03-31', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9636, 3, 1, '2026-03-31', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9637, 3, 1, '2026-03-31', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9638, 3, 1, '2026-03-31', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9639, 3, 1, '2026-03-31', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9640, 3, 1, '2026-03-31', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9641, 3, 1, '2026-03-31', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9642, 3, 1, '2026-03-31', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9643, 3, 1, '2026-03-31', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9644, 3, 1, '2026-03-31', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9645, 3, 1, '2026-03-31', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9646, 3, 1, '2026-03-31', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9647, 3, 1, '2026-03-31', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9648, 3, 1, '2026-03-31', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9649, 3, 1, '2026-03-31', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9650, 3, 1, '2026-03-31', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9651, 3, 1, '2026-03-31', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9652, 3, 1, '2026-03-31', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9653, 3, 1, '2026-03-31', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:18', '2026-03-27 10:51:18');
INSERT INTO `doctor_schedule` VALUES (9794, 3, 2, '2026-03-03', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9795, 3, 2, '2026-03-03', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9796, 3, 2, '2026-03-03', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9797, 3, 2, '2026-03-03', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9798, 3, 2, '2026-03-03', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9799, 3, 2, '2026-03-03', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9800, 3, 2, '2026-03-03', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9801, 3, 2, '2026-03-03', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9802, 3, 2, '2026-03-03', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9803, 3, 2, '2026-03-03', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9804, 3, 2, '2026-03-03', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9805, 3, 2, '2026-03-03', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9806, 3, 2, '2026-03-03', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9807, 3, 2, '2026-03-03', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9808, 3, 2, '2026-03-03', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9809, 3, 2, '2026-03-03', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9810, 3, 2, '2026-03-03', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9811, 3, 2, '2026-03-03', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9812, 3, 2, '2026-03-03', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9813, 3, 2, '2026-03-03', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9814, 3, 2, '2026-03-03', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9815, 3, 2, '2026-03-03', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9816, 3, 2, '2026-03-03', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9817, 3, 2, '2026-03-03', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9818, 3, 2, '2026-03-03', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9819, 3, 2, '2026-03-03', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9820, 3, 2, '2026-03-03', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9821, 3, 2, '2026-03-03', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9822, 7, 2, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9823, 7, 2, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9824, 7, 2, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9825, 7, 2, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9826, 7, 2, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9827, 7, 2, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9828, 7, 2, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9829, 7, 2, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9830, 7, 2, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9831, 7, 2, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9832, 7, 2, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9833, 7, 2, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9834, 7, 2, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9835, 7, 2, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9836, 7, 2, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9837, 7, 2, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9838, 7, 2, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9839, 7, 2, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9840, 7, 2, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9841, 7, 2, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9842, 7, 2, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9843, 7, 2, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9844, 7, 2, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9845, 7, 2, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9846, 7, 2, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9847, 7, 2, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9848, 7, 2, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9849, 7, 2, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9850, 2, 2, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9851, 2, 2, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9852, 2, 2, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9853, 2, 2, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9854, 2, 2, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9855, 2, 2, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9856, 2, 2, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9857, 2, 2, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9858, 2, 2, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9859, 2, 2, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9860, 2, 2, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9861, 2, 2, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9862, 2, 2, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9863, 2, 2, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9864, 2, 2, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9865, 2, 2, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9866, 2, 2, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9867, 2, 2, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9868, 2, 2, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9869, 2, 2, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9870, 2, 2, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9871, 2, 2, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9872, 2, 2, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9873, 2, 2, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9874, 2, 2, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9875, 2, 2, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9876, 2, 2, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9877, 2, 2, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9878, 3, 2, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9879, 3, 2, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9880, 3, 2, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9881, 3, 2, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9882, 3, 2, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9883, 3, 2, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9884, 3, 2, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9885, 3, 2, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9886, 3, 2, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9887, 3, 2, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9888, 3, 2, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9889, 3, 2, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9890, 3, 2, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9891, 3, 2, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9892, 3, 2, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9893, 3, 2, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9894, 3, 2, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9895, 3, 2, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9896, 3, 2, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9897, 3, 2, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9898, 3, 2, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9899, 3, 2, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9900, 3, 2, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9901, 3, 2, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9902, 3, 2, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9903, 3, 2, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9904, 3, 2, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (9905, 3, 2, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10046, 6, 2, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10047, 6, 2, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10048, 6, 2, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10049, 6, 2, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10050, 6, 2, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10051, 6, 2, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10052, 6, 2, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10053, 6, 2, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10054, 6, 2, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10055, 6, 2, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10056, 6, 2, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10057, 6, 2, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10058, 6, 2, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10059, 6, 2, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10060, 6, 2, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10061, 6, 2, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10062, 6, 2, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10063, 6, 2, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10064, 6, 2, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10065, 6, 2, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10066, 6, 2, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10067, 6, 2, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10068, 6, 2, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10069, 6, 2, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10070, 6, 2, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10071, 6, 2, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10072, 6, 2, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10073, 6, 2, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:19', '2026-03-27 10:51:19');
INSERT INTO `doctor_schedule` VALUES (10074, 2, 2, '2026-03-10', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10075, 2, 2, '2026-03-10', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10076, 2, 2, '2026-03-10', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10077, 2, 2, '2026-03-10', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10078, 2, 2, '2026-03-10', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10079, 2, 2, '2026-03-10', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10080, 2, 2, '2026-03-10', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10081, 2, 2, '2026-03-10', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10082, 2, 2, '2026-03-10', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10083, 2, 2, '2026-03-10', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10084, 2, 2, '2026-03-10', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10085, 2, 2, '2026-03-10', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10086, 2, 2, '2026-03-10', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10087, 2, 2, '2026-03-10', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10088, 2, 2, '2026-03-10', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10089, 2, 2, '2026-03-10', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10090, 2, 2, '2026-03-10', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10091, 2, 2, '2026-03-10', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10092, 2, 2, '2026-03-10', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10093, 2, 2, '2026-03-10', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10094, 2, 2, '2026-03-10', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10095, 2, 2, '2026-03-10', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10096, 2, 2, '2026-03-10', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10097, 2, 2, '2026-03-10', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10098, 2, 2, '2026-03-10', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10099, 2, 2, '2026-03-10', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10100, 2, 2, '2026-03-10', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10101, 2, 2, '2026-03-10', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10158, 6, 2, '2026-03-11', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10159, 6, 2, '2026-03-11', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10160, 6, 2, '2026-03-11', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10161, 6, 2, '2026-03-11', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10162, 6, 2, '2026-03-11', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10163, 6, 2, '2026-03-11', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10164, 6, 2, '2026-03-11', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10165, 6, 2, '2026-03-11', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10166, 6, 2, '2026-03-11', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10167, 6, 2, '2026-03-11', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10168, 6, 2, '2026-03-11', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10169, 6, 2, '2026-03-11', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10170, 6, 2, '2026-03-11', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10171, 6, 2, '2026-03-11', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10172, 6, 2, '2026-03-11', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10173, 6, 2, '2026-03-11', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10174, 6, 2, '2026-03-11', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10175, 6, 2, '2026-03-11', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10176, 6, 2, '2026-03-11', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10177, 6, 2, '2026-03-11', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10178, 6, 2, '2026-03-11', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10179, 6, 2, '2026-03-11', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10180, 6, 2, '2026-03-11', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10181, 6, 2, '2026-03-11', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10182, 6, 2, '2026-03-11', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10183, 6, 2, '2026-03-11', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10184, 6, 2, '2026-03-11', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10185, 6, 2, '2026-03-11', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10186, 3, 2, '2026-03-11', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10187, 3, 2, '2026-03-11', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10188, 3, 2, '2026-03-11', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10189, 3, 2, '2026-03-11', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10190, 3, 2, '2026-03-11', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10191, 3, 2, '2026-03-11', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10192, 3, 2, '2026-03-11', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10193, 3, 2, '2026-03-11', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10194, 3, 2, '2026-03-11', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10195, 3, 2, '2026-03-11', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10196, 3, 2, '2026-03-11', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10197, 3, 2, '2026-03-11', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10198, 3, 2, '2026-03-11', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10199, 3, 2, '2026-03-11', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10200, 3, 2, '2026-03-11', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10201, 3, 2, '2026-03-11', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10202, 3, 2, '2026-03-11', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10203, 3, 2, '2026-03-11', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10204, 3, 2, '2026-03-11', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10205, 3, 2, '2026-03-11', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10206, 3, 2, '2026-03-11', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10207, 3, 2, '2026-03-11', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10208, 3, 2, '2026-03-11', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10209, 3, 2, '2026-03-11', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10210, 3, 2, '2026-03-11', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10211, 3, 2, '2026-03-11', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10212, 3, 2, '2026-03-11', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10213, 3, 2, '2026-03-11', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10298, 2, 2, '2026-03-13', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10299, 2, 2, '2026-03-13', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10300, 2, 2, '2026-03-13', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10301, 2, 2, '2026-03-13', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10302, 2, 2, '2026-03-13', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10303, 2, 2, '2026-03-13', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10304, 2, 2, '2026-03-13', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10305, 2, 2, '2026-03-13', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10306, 2, 2, '2026-03-13', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10307, 2, 2, '2026-03-13', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10308, 2, 2, '2026-03-13', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10309, 2, 2, '2026-03-13', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10310, 2, 2, '2026-03-13', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10311, 2, 2, '2026-03-13', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10312, 2, 2, '2026-03-13', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10313, 2, 2, '2026-03-13', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10314, 2, 2, '2026-03-13', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10315, 2, 2, '2026-03-13', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10316, 2, 2, '2026-03-13', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10317, 2, 2, '2026-03-13', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10318, 2, 2, '2026-03-13', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10319, 2, 2, '2026-03-13', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10320, 2, 2, '2026-03-13', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10321, 2, 2, '2026-03-13', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10322, 2, 2, '2026-03-13', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10323, 2, 2, '2026-03-13', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10324, 2, 2, '2026-03-13', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10325, 2, 2, '2026-03-13', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10382, 2, 2, '2026-03-16', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10383, 2, 2, '2026-03-16', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10384, 2, 2, '2026-03-16', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10385, 2, 2, '2026-03-16', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10386, 2, 2, '2026-03-16', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10387, 2, 2, '2026-03-16', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10388, 2, 2, '2026-03-16', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10389, 2, 2, '2026-03-16', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10390, 2, 2, '2026-03-16', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10391, 2, 2, '2026-03-16', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10392, 2, 2, '2026-03-16', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10393, 2, 2, '2026-03-16', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10394, 2, 2, '2026-03-16', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10395, 2, 2, '2026-03-16', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10396, 2, 2, '2026-03-16', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10397, 2, 2, '2026-03-16', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10398, 2, 2, '2026-03-16', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10399, 2, 2, '2026-03-16', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10400, 2, 2, '2026-03-16', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10401, 2, 2, '2026-03-16', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10402, 2, 2, '2026-03-16', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10403, 2, 2, '2026-03-16', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10404, 2, 2, '2026-03-16', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10405, 2, 2, '2026-03-16', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10406, 2, 2, '2026-03-16', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10407, 2, 2, '2026-03-16', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10408, 2, 2, '2026-03-16', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10409, 2, 2, '2026-03-16', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10438, 6, 2, '2026-03-17', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10439, 6, 2, '2026-03-17', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10440, 6, 2, '2026-03-17', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10441, 6, 2, '2026-03-17', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10442, 6, 2, '2026-03-17', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10443, 6, 2, '2026-03-17', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10444, 6, 2, '2026-03-17', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:20', '2026-03-27 10:51:20');
INSERT INTO `doctor_schedule` VALUES (10445, 6, 2, '2026-03-17', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10446, 6, 2, '2026-03-17', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10447, 6, 2, '2026-03-17', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10448, 6, 2, '2026-03-17', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10449, 6, 2, '2026-03-17', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10450, 6, 2, '2026-03-17', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10451, 6, 2, '2026-03-17', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10452, 6, 2, '2026-03-17', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10453, 6, 2, '2026-03-17', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10454, 6, 2, '2026-03-17', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10455, 6, 2, '2026-03-17', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10456, 6, 2, '2026-03-17', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10457, 6, 2, '2026-03-17', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10458, 6, 2, '2026-03-17', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10459, 6, 2, '2026-03-17', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10460, 6, 2, '2026-03-17', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10461, 6, 2, '2026-03-17', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10462, 6, 2, '2026-03-17', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10463, 6, 2, '2026-03-17', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10464, 6, 2, '2026-03-17', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10465, 6, 2, '2026-03-17', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10494, 3, 2, '2026-03-18', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10495, 3, 2, '2026-03-18', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10496, 3, 2, '2026-03-18', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10497, 3, 2, '2026-03-18', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10498, 3, 2, '2026-03-18', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10499, 3, 2, '2026-03-18', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10500, 3, 2, '2026-03-18', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10501, 3, 2, '2026-03-18', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10502, 3, 2, '2026-03-18', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10503, 3, 2, '2026-03-18', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10504, 3, 2, '2026-03-18', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10505, 3, 2, '2026-03-18', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10506, 3, 2, '2026-03-18', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10507, 3, 2, '2026-03-18', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10508, 3, 2, '2026-03-18', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10509, 3, 2, '2026-03-18', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10510, 3, 2, '2026-03-18', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10511, 3, 2, '2026-03-18', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10512, 3, 2, '2026-03-18', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10513, 3, 2, '2026-03-18', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10514, 3, 2, '2026-03-18', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10515, 3, 2, '2026-03-18', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10516, 3, 2, '2026-03-18', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10517, 3, 2, '2026-03-18', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10518, 3, 2, '2026-03-18', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10519, 3, 2, '2026-03-18', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10520, 3, 2, '2026-03-18', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10521, 3, 2, '2026-03-18', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10550, 3, 2, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10551, 3, 2, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10552, 3, 2, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10553, 3, 2, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10554, 3, 2, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10555, 3, 2, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10556, 3, 2, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10557, 3, 2, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10558, 3, 2, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10559, 3, 2, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10560, 3, 2, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10561, 3, 2, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10562, 3, 2, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10563, 3, 2, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10564, 3, 2, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10565, 3, 2, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10566, 3, 2, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10567, 3, 2, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10568, 3, 2, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10569, 3, 2, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10570, 3, 2, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10571, 3, 2, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10572, 3, 2, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10573, 3, 2, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10574, 3, 2, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10575, 3, 2, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10576, 3, 2, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10577, 3, 2, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10578, 7, 2, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10579, 7, 2, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10580, 7, 2, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10581, 7, 2, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10582, 7, 2, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10583, 7, 2, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10584, 7, 2, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10585, 7, 2, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10586, 7, 2, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10587, 7, 2, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10588, 7, 2, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10589, 7, 2, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10590, 7, 2, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10591, 7, 2, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10592, 7, 2, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10593, 7, 2, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10594, 7, 2, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10595, 7, 2, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10596, 7, 2, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10597, 7, 2, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10598, 7, 2, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10599, 7, 2, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10600, 7, 2, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10601, 7, 2, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10602, 7, 2, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10603, 7, 2, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10604, 7, 2, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10605, 7, 2, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10606, 2, 2, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10607, 2, 2, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10608, 2, 2, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10609, 2, 2, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10610, 2, 2, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10611, 2, 2, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10612, 2, 2, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10613, 2, 2, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10614, 2, 2, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10615, 2, 2, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10616, 2, 2, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10617, 2, 2, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10618, 2, 2, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10619, 2, 2, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10620, 2, 2, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10621, 2, 2, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10622, 2, 2, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10623, 2, 2, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10624, 2, 2, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10625, 2, 2, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10626, 2, 2, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10627, 2, 2, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10628, 2, 2, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10629, 2, 2, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10630, 2, 2, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10631, 2, 2, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10632, 2, 2, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10633, 2, 2, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10634, 7, 2, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10635, 7, 2, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10636, 7, 2, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10637, 7, 2, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10638, 7, 2, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10639, 7, 2, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10640, 7, 2, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10641, 7, 2, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10642, 7, 2, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10643, 7, 2, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10644, 7, 2, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10645, 7, 2, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10646, 7, 2, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10647, 7, 2, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10648, 7, 2, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10649, 7, 2, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10650, 7, 2, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10651, 7, 2, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10652, 7, 2, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10653, 7, 2, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10654, 7, 2, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10655, 7, 2, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10656, 7, 2, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10657, 7, 2, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10658, 7, 2, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10659, 7, 2, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10660, 7, 2, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10661, 7, 2, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10662, 3, 2, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10663, 3, 2, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10664, 3, 2, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10665, 3, 2, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10666, 3, 2, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10667, 3, 2, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10668, 3, 2, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10669, 3, 2, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10670, 3, 2, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10671, 3, 2, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10672, 3, 2, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10673, 3, 2, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10674, 3, 2, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10675, 3, 2, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10676, 3, 2, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10677, 3, 2, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10678, 3, 2, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10679, 3, 2, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10680, 3, 2, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10681, 3, 2, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10682, 3, 2, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10683, 3, 2, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10684, 3, 2, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10685, 3, 2, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10686, 3, 2, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10687, 3, 2, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10688, 3, 2, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10689, 3, 2, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10690, 6, 2, '2026-03-23', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10691, 6, 2, '2026-03-23', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10692, 6, 2, '2026-03-23', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10693, 6, 2, '2026-03-23', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10694, 6, 2, '2026-03-23', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10695, 6, 2, '2026-03-23', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10696, 6, 2, '2026-03-23', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10697, 6, 2, '2026-03-23', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10698, 6, 2, '2026-03-23', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10699, 6, 2, '2026-03-23', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10700, 6, 2, '2026-03-23', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10701, 6, 2, '2026-03-23', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10702, 6, 2, '2026-03-23', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10703, 6, 2, '2026-03-23', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10704, 6, 2, '2026-03-23', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10705, 6, 2, '2026-03-23', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10706, 6, 2, '2026-03-23', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10707, 6, 2, '2026-03-23', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10708, 6, 2, '2026-03-23', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10709, 6, 2, '2026-03-23', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10710, 6, 2, '2026-03-23', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10711, 6, 2, '2026-03-23', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10712, 6, 2, '2026-03-23', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10713, 6, 2, '2026-03-23', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10714, 6, 2, '2026-03-23', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10715, 6, 2, '2026-03-23', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10716, 6, 2, '2026-03-23', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10717, 6, 2, '2026-03-23', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10718, 3, 2, '2026-03-23', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10719, 3, 2, '2026-03-23', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10720, 3, 2, '2026-03-23', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10721, 3, 2, '2026-03-23', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10722, 3, 2, '2026-03-23', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10723, 3, 2, '2026-03-23', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10724, 3, 2, '2026-03-23', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10725, 3, 2, '2026-03-23', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10726, 3, 2, '2026-03-23', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10727, 3, 2, '2026-03-23', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10728, 3, 2, '2026-03-23', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10729, 3, 2, '2026-03-23', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10730, 3, 2, '2026-03-23', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10731, 3, 2, '2026-03-23', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10732, 3, 2, '2026-03-23', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10733, 3, 2, '2026-03-23', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10734, 3, 2, '2026-03-23', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10735, 3, 2, '2026-03-23', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10736, 3, 2, '2026-03-23', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10737, 3, 2, '2026-03-23', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10738, 3, 2, '2026-03-23', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10739, 3, 2, '2026-03-23', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10740, 3, 2, '2026-03-23', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10741, 3, 2, '2026-03-23', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10742, 3, 2, '2026-03-23', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10743, 3, 2, '2026-03-23', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10744, 3, 2, '2026-03-23', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10745, 3, 2, '2026-03-23', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10802, 7, 2, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10803, 7, 2, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10804, 7, 2, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10805, 7, 2, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10806, 7, 2, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10807, 7, 2, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10808, 7, 2, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10809, 7, 2, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10810, 7, 2, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10811, 7, 2, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10812, 7, 2, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10813, 7, 2, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10814, 7, 2, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10815, 7, 2, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10816, 7, 2, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10817, 7, 2, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10818, 7, 2, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10819, 7, 2, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10820, 7, 2, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10821, 7, 2, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10822, 7, 2, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10823, 7, 2, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10824, 7, 2, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10825, 7, 2, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10826, 7, 2, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10827, 7, 2, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10828, 7, 2, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10829, 7, 2, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10830, 6, 2, '2026-03-25', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10831, 6, 2, '2026-03-25', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10832, 6, 2, '2026-03-25', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10833, 6, 2, '2026-03-25', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10834, 6, 2, '2026-03-25', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10835, 6, 2, '2026-03-25', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10836, 6, 2, '2026-03-25', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10837, 6, 2, '2026-03-25', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10838, 6, 2, '2026-03-25', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10839, 6, 2, '2026-03-25', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10840, 6, 2, '2026-03-25', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10841, 6, 2, '2026-03-25', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:21', '2026-03-27 10:51:21');
INSERT INTO `doctor_schedule` VALUES (10842, 6, 2, '2026-03-25', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10843, 6, 2, '2026-03-25', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10844, 6, 2, '2026-03-25', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10845, 6, 2, '2026-03-25', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10846, 6, 2, '2026-03-25', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10847, 6, 2, '2026-03-25', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10848, 6, 2, '2026-03-25', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10849, 6, 2, '2026-03-25', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10850, 6, 2, '2026-03-25', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10851, 6, 2, '2026-03-25', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10852, 6, 2, '2026-03-25', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10853, 6, 2, '2026-03-25', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10854, 6, 2, '2026-03-25', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10855, 6, 2, '2026-03-25', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10856, 6, 2, '2026-03-25', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10857, 6, 2, '2026-03-25', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10858, 7, 2, '2026-03-25', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10859, 7, 2, '2026-03-25', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10860, 7, 2, '2026-03-25', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10861, 7, 2, '2026-03-25', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10862, 7, 2, '2026-03-25', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10863, 7, 2, '2026-03-25', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10864, 7, 2, '2026-03-25', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10865, 7, 2, '2026-03-25', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10866, 7, 2, '2026-03-25', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10867, 7, 2, '2026-03-25', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10868, 7, 2, '2026-03-25', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10869, 7, 2, '2026-03-25', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10870, 7, 2, '2026-03-25', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10871, 7, 2, '2026-03-25', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10872, 7, 2, '2026-03-25', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10873, 7, 2, '2026-03-25', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10874, 7, 2, '2026-03-25', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10875, 7, 2, '2026-03-25', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10876, 7, 2, '2026-03-25', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10877, 7, 2, '2026-03-25', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10878, 7, 2, '2026-03-25', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10879, 7, 2, '2026-03-25', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10880, 7, 2, '2026-03-25', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10881, 7, 2, '2026-03-25', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10882, 7, 2, '2026-03-25', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10883, 7, 2, '2026-03-25', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10884, 7, 2, '2026-03-25', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (10885, 7, 2, '2026-03-25', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11054, 2, 2, '2026-03-30', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11055, 2, 2, '2026-03-30', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11056, 2, 2, '2026-03-30', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11057, 2, 2, '2026-03-30', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11058, 2, 2, '2026-03-30', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11059, 2, 2, '2026-03-30', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11060, 2, 2, '2026-03-30', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11061, 2, 2, '2026-03-30', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11062, 2, 2, '2026-03-30', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11063, 2, 2, '2026-03-30', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11064, 2, 2, '2026-03-30', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11065, 2, 2, '2026-03-30', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11066, 2, 2, '2026-03-30', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11067, 2, 2, '2026-03-30', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11068, 2, 2, '2026-03-30', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11069, 2, 2, '2026-03-30', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11070, 2, 2, '2026-03-30', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11071, 2, 2, '2026-03-30', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11072, 2, 2, '2026-03-30', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11073, 2, 2, '2026-03-30', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11074, 2, 2, '2026-03-30', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11075, 2, 2, '2026-03-30', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11076, 2, 2, '2026-03-30', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11077, 2, 2, '2026-03-30', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11078, 2, 2, '2026-03-30', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11079, 2, 2, '2026-03-30', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11080, 2, 2, '2026-03-30', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11081, 2, 2, '2026-03-30', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11138, 6, 2, '2026-03-31', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11139, 6, 2, '2026-03-31', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11140, 6, 2, '2026-03-31', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11141, 6, 2, '2026-03-31', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11142, 6, 2, '2026-03-31', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11143, 6, 2, '2026-03-31', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11144, 6, 2, '2026-03-31', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11145, 6, 2, '2026-03-31', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11146, 6, 2, '2026-03-31', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11147, 6, 2, '2026-03-31', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11148, 6, 2, '2026-03-31', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11149, 6, 2, '2026-03-31', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11150, 6, 2, '2026-03-31', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11151, 6, 2, '2026-03-31', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11152, 6, 2, '2026-03-31', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11153, 6, 2, '2026-03-31', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11154, 6, 2, '2026-03-31', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11155, 6, 2, '2026-03-31', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11156, 6, 2, '2026-03-31', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11157, 6, 2, '2026-03-31', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11158, 6, 2, '2026-03-31', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11159, 6, 2, '2026-03-31', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11160, 6, 2, '2026-03-31', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11161, 6, 2, '2026-03-31', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11162, 6, 2, '2026-03-31', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11163, 6, 2, '2026-03-31', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11164, 6, 2, '2026-03-31', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11165, 6, 2, '2026-03-31', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11194, 7, 3, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11195, 7, 3, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11196, 7, 3, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11197, 7, 3, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11198, 7, 3, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11199, 7, 3, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11200, 7, 3, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11201, 7, 3, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11202, 7, 3, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11203, 7, 3, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11204, 7, 3, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11205, 7, 3, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11206, 7, 3, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11207, 7, 3, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11208, 7, 3, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11209, 7, 3, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11210, 7, 3, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11211, 7, 3, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11212, 7, 3, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11213, 7, 3, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11214, 7, 3, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11215, 7, 3, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11216, 7, 3, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11217, 7, 3, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11218, 7, 3, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11219, 7, 3, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11220, 7, 3, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11221, 7, 3, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11222, 3, 3, '2026-03-03', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11223, 3, 3, '2026-03-03', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11224, 3, 3, '2026-03-03', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11225, 3, 3, '2026-03-03', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11226, 3, 3, '2026-03-03', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11227, 3, 3, '2026-03-03', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11228, 3, 3, '2026-03-03', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:22', '2026-03-27 10:51:22');
INSERT INTO `doctor_schedule` VALUES (11229, 3, 3, '2026-03-03', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11230, 3, 3, '2026-03-03', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11231, 3, 3, '2026-03-03', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11232, 3, 3, '2026-03-03', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11233, 3, 3, '2026-03-03', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11234, 3, 3, '2026-03-03', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11235, 3, 3, '2026-03-03', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11236, 3, 3, '2026-03-03', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11237, 3, 3, '2026-03-03', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11238, 3, 3, '2026-03-03', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11239, 3, 3, '2026-03-03', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11240, 3, 3, '2026-03-03', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11241, 3, 3, '2026-03-03', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11242, 3, 3, '2026-03-03', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11243, 3, 3, '2026-03-03', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11244, 3, 3, '2026-03-03', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11245, 3, 3, '2026-03-03', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11246, 3, 3, '2026-03-03', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11247, 3, 3, '2026-03-03', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11248, 3, 3, '2026-03-03', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11249, 3, 3, '2026-03-03', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11418, 7, 3, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11419, 7, 3, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11420, 7, 3, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11421, 7, 3, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11422, 7, 3, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11423, 7, 3, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11424, 7, 3, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11425, 7, 3, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11426, 7, 3, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11427, 7, 3, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11428, 7, 3, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11429, 7, 3, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11430, 7, 3, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11431, 7, 3, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11432, 7, 3, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11433, 7, 3, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11434, 7, 3, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11435, 7, 3, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11436, 7, 3, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11437, 7, 3, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11438, 7, 3, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11439, 7, 3, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11440, 7, 3, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11441, 7, 3, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11442, 7, 3, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11443, 7, 3, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11444, 7, 3, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11445, 7, 3, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11502, 2, 3, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11503, 2, 3, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11504, 2, 3, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11505, 2, 3, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11506, 2, 3, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11507, 2, 3, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11508, 2, 3, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11509, 2, 3, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11510, 2, 3, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11511, 2, 3, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11512, 2, 3, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11513, 2, 3, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11514, 2, 3, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11515, 2, 3, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11516, 2, 3, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11517, 2, 3, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11518, 2, 3, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11519, 2, 3, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11520, 2, 3, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11521, 2, 3, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11522, 2, 3, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11523, 2, 3, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11524, 2, 3, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11525, 2, 3, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11526, 2, 3, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11527, 2, 3, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11528, 2, 3, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11529, 2, 3, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11530, 3, 3, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11531, 3, 3, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11532, 3, 3, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11533, 3, 3, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11534, 3, 3, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11535, 3, 3, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11536, 3, 3, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11537, 3, 3, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11538, 3, 3, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11539, 3, 3, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11540, 3, 3, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11541, 3, 3, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11542, 3, 3, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11543, 3, 3, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11544, 3, 3, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11545, 3, 3, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11546, 3, 3, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11547, 3, 3, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11548, 3, 3, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11549, 3, 3, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11550, 3, 3, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11551, 3, 3, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11552, 3, 3, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11553, 3, 3, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11554, 3, 3, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11555, 3, 3, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11556, 3, 3, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11557, 3, 3, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11614, 7, 3, '2026-03-10', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11615, 7, 3, '2026-03-10', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11616, 7, 3, '2026-03-10', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11617, 7, 3, '2026-03-10', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11618, 7, 3, '2026-03-10', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:23', '2026-03-27 10:51:23');
INSERT INTO `doctor_schedule` VALUES (11619, 7, 3, '2026-03-10', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11620, 7, 3, '2026-03-10', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11621, 7, 3, '2026-03-10', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11622, 7, 3, '2026-03-10', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11623, 7, 3, '2026-03-10', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11624, 7, 3, '2026-03-10', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11625, 7, 3, '2026-03-10', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11626, 7, 3, '2026-03-10', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11627, 7, 3, '2026-03-10', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11628, 7, 3, '2026-03-10', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11629, 7, 3, '2026-03-10', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11630, 7, 3, '2026-03-10', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11631, 7, 3, '2026-03-10', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11632, 7, 3, '2026-03-10', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11633, 7, 3, '2026-03-10', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11634, 7, 3, '2026-03-10', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11635, 7, 3, '2026-03-10', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11636, 7, 3, '2026-03-10', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11637, 7, 3, '2026-03-10', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11638, 7, 3, '2026-03-10', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11639, 7, 3, '2026-03-10', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11640, 7, 3, '2026-03-10', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11641, 7, 3, '2026-03-10', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11838, 2, 3, '2026-03-16', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11839, 2, 3, '2026-03-16', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11840, 2, 3, '2026-03-16', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11841, 2, 3, '2026-03-16', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11842, 2, 3, '2026-03-16', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11843, 2, 3, '2026-03-16', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11844, 2, 3, '2026-03-16', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11845, 2, 3, '2026-03-16', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11846, 2, 3, '2026-03-16', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11847, 2, 3, '2026-03-16', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11848, 2, 3, '2026-03-16', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11849, 2, 3, '2026-03-16', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11850, 2, 3, '2026-03-16', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11851, 2, 3, '2026-03-16', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11852, 2, 3, '2026-03-16', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11853, 2, 3, '2026-03-16', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11854, 2, 3, '2026-03-16', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11855, 2, 3, '2026-03-16', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11856, 2, 3, '2026-03-16', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11857, 2, 3, '2026-03-16', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11858, 2, 3, '2026-03-16', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11859, 2, 3, '2026-03-16', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11860, 2, 3, '2026-03-16', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11861, 2, 3, '2026-03-16', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11862, 2, 3, '2026-03-16', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11863, 2, 3, '2026-03-16', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11864, 2, 3, '2026-03-16', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11865, 2, 3, '2026-03-16', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11922, 3, 3, '2026-03-17', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11923, 3, 3, '2026-03-17', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11924, 3, 3, '2026-03-17', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11925, 3, 3, '2026-03-17', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11926, 3, 3, '2026-03-17', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11927, 3, 3, '2026-03-17', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11928, 3, 3, '2026-03-17', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11929, 3, 3, '2026-03-17', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11930, 3, 3, '2026-03-17', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11931, 3, 3, '2026-03-17', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11932, 3, 3, '2026-03-17', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11933, 3, 3, '2026-03-17', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11934, 3, 3, '2026-03-17', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11935, 3, 3, '2026-03-17', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11936, 3, 3, '2026-03-17', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11937, 3, 3, '2026-03-17', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11938, 3, 3, '2026-03-17', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11939, 3, 3, '2026-03-17', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11940, 3, 3, '2026-03-17', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11941, 3, 3, '2026-03-17', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11942, 3, 3, '2026-03-17', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11943, 3, 3, '2026-03-17', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11944, 3, 3, '2026-03-17', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11945, 3, 3, '2026-03-17', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11946, 3, 3, '2026-03-17', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11947, 3, 3, '2026-03-17', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11948, 3, 3, '2026-03-17', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11949, 3, 3, '2026-03-17', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11978, 7, 3, '2026-03-18', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11979, 7, 3, '2026-03-18', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11980, 7, 3, '2026-03-18', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11981, 7, 3, '2026-03-18', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11982, 7, 3, '2026-03-18', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11983, 7, 3, '2026-03-18', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11984, 7, 3, '2026-03-18', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11985, 7, 3, '2026-03-18', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11986, 7, 3, '2026-03-18', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11987, 7, 3, '2026-03-18', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11988, 7, 3, '2026-03-18', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11989, 7, 3, '2026-03-18', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11990, 7, 3, '2026-03-18', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11991, 7, 3, '2026-03-18', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11992, 7, 3, '2026-03-18', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11993, 7, 3, '2026-03-18', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11994, 7, 3, '2026-03-18', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11995, 7, 3, '2026-03-18', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11996, 7, 3, '2026-03-18', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11997, 7, 3, '2026-03-18', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11998, 7, 3, '2026-03-18', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (11999, 7, 3, '2026-03-18', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12000, 7, 3, '2026-03-18', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12001, 7, 3, '2026-03-18', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12002, 7, 3, '2026-03-18', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12003, 7, 3, '2026-03-18', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12004, 7, 3, '2026-03-18', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12005, 7, 3, '2026-03-18', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:24', '2026-03-27 10:51:24');
INSERT INTO `doctor_schedule` VALUES (12034, 6, 3, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12035, 6, 3, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12036, 6, 3, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12037, 6, 3, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12038, 6, 3, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12039, 6, 3, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12040, 6, 3, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12041, 6, 3, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12042, 6, 3, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12043, 6, 3, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12044, 6, 3, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12045, 6, 3, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12046, 6, 3, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12047, 6, 3, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12048, 6, 3, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12049, 6, 3, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12050, 6, 3, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12051, 6, 3, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12052, 6, 3, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12053, 6, 3, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12054, 6, 3, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12055, 6, 3, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12056, 6, 3, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12057, 6, 3, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12058, 6, 3, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12059, 6, 3, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12060, 6, 3, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12061, 6, 3, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12062, 7, 3, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12063, 7, 3, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12064, 7, 3, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12065, 7, 3, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12066, 7, 3, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12067, 7, 3, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12068, 7, 3, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12069, 7, 3, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12070, 7, 3, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12071, 7, 3, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12072, 7, 3, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12073, 7, 3, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12074, 7, 3, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12075, 7, 3, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12076, 7, 3, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12077, 7, 3, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12078, 7, 3, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12079, 7, 3, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12080, 7, 3, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12081, 7, 3, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12082, 7, 3, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12083, 7, 3, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12084, 7, 3, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12085, 7, 3, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12086, 7, 3, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12087, 7, 3, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12088, 7, 3, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12089, 7, 3, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12090, 3, 3, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12091, 3, 3, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12092, 3, 3, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12093, 3, 3, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12094, 3, 3, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12095, 3, 3, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12096, 3, 3, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12097, 3, 3, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12098, 3, 3, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12099, 3, 3, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12100, 3, 3, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12101, 3, 3, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12102, 3, 3, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12103, 3, 3, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12104, 3, 3, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12105, 3, 3, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12106, 3, 3, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12107, 3, 3, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12108, 3, 3, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12109, 3, 3, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12110, 3, 3, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12111, 3, 3, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12112, 3, 3, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12113, 3, 3, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12114, 3, 3, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12115, 3, 3, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12116, 3, 3, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12117, 3, 3, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12146, 7, 3, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12147, 7, 3, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12148, 7, 3, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12149, 7, 3, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12150, 7, 3, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12151, 7, 3, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12152, 7, 3, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12153, 7, 3, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12154, 7, 3, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12155, 7, 3, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12156, 7, 3, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12157, 7, 3, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12158, 7, 3, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12159, 7, 3, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12160, 7, 3, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12161, 7, 3, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12162, 7, 3, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12163, 7, 3, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12164, 7, 3, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12165, 7, 3, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12166, 7, 3, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12167, 7, 3, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12168, 7, 3, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12169, 7, 3, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12170, 7, 3, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12171, 7, 3, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12172, 7, 3, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12173, 7, 3, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12202, 2, 3, '2026-03-23', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12203, 2, 3, '2026-03-23', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12204, 2, 3, '2026-03-23', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12205, 2, 3, '2026-03-23', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12206, 2, 3, '2026-03-23', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12207, 2, 3, '2026-03-23', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12208, 2, 3, '2026-03-23', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12209, 2, 3, '2026-03-23', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12210, 2, 3, '2026-03-23', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12211, 2, 3, '2026-03-23', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12212, 2, 3, '2026-03-23', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12213, 2, 3, '2026-03-23', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12214, 2, 3, '2026-03-23', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12215, 2, 3, '2026-03-23', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12216, 2, 3, '2026-03-23', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12217, 2, 3, '2026-03-23', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12218, 2, 3, '2026-03-23', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12219, 2, 3, '2026-03-23', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12220, 2, 3, '2026-03-23', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12221, 2, 3, '2026-03-23', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12222, 2, 3, '2026-03-23', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12223, 2, 3, '2026-03-23', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12224, 2, 3, '2026-03-23', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12225, 2, 3, '2026-03-23', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12226, 2, 3, '2026-03-23', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12227, 2, 3, '2026-03-23', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12228, 2, 3, '2026-03-23', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12229, 2, 3, '2026-03-23', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12286, 3, 3, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12287, 3, 3, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12288, 3, 3, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12289, 3, 3, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12290, 3, 3, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12291, 3, 3, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12292, 3, 3, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12293, 3, 3, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12294, 3, 3, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12295, 3, 3, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12296, 3, 3, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12297, 3, 3, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12298, 3, 3, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12299, 3, 3, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12300, 3, 3, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12301, 3, 3, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12302, 3, 3, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12303, 3, 3, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12304, 3, 3, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12305, 3, 3, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12306, 3, 3, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12307, 3, 3, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12308, 3, 3, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12309, 3, 3, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12310, 3, 3, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12311, 3, 3, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12312, 3, 3, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12313, 3, 3, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12314, 7, 3, '2026-03-25', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12315, 7, 3, '2026-03-25', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12316, 7, 3, '2026-03-25', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12317, 7, 3, '2026-03-25', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12318, 7, 3, '2026-03-25', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12319, 7, 3, '2026-03-25', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12320, 7, 3, '2026-03-25', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12321, 7, 3, '2026-03-25', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12322, 7, 3, '2026-03-25', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12323, 7, 3, '2026-03-25', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12324, 7, 3, '2026-03-25', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12325, 7, 3, '2026-03-25', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12326, 7, 3, '2026-03-25', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12327, 7, 3, '2026-03-25', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12328, 7, 3, '2026-03-25', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12329, 7, 3, '2026-03-25', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12330, 7, 3, '2026-03-25', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12331, 7, 3, '2026-03-25', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12332, 7, 3, '2026-03-25', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12333, 7, 3, '2026-03-25', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12334, 7, 3, '2026-03-25', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12335, 7, 3, '2026-03-25', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12336, 7, 3, '2026-03-25', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12337, 7, 3, '2026-03-25', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12338, 7, 3, '2026-03-25', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12339, 7, 3, '2026-03-25', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12340, 7, 3, '2026-03-25', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12341, 7, 3, '2026-03-25', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12398, 6, 3, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12399, 6, 3, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12400, 6, 3, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12401, 6, 3, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12402, 6, 3, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12403, 6, 3, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12404, 6, 3, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12405, 6, 3, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12406, 6, 3, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12407, 6, 3, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12408, 6, 3, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12409, 6, 3, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12410, 6, 3, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12411, 6, 3, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12412, 6, 3, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12413, 6, 3, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12414, 6, 3, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12415, 6, 3, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:25', '2026-03-27 10:51:25');
INSERT INTO `doctor_schedule` VALUES (12416, 6, 3, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12417, 6, 3, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12418, 6, 3, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12419, 6, 3, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12420, 6, 3, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12421, 6, 3, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12422, 6, 3, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12423, 6, 3, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12424, 6, 3, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12425, 6, 3, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12426, 7, 3, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12427, 7, 3, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12428, 7, 3, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12429, 7, 3, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12430, 7, 3, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12431, 7, 3, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12432, 7, 3, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12433, 7, 3, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12434, 7, 3, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12435, 7, 3, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12436, 7, 3, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12437, 7, 3, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12438, 7, 3, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12439, 7, 3, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12440, 7, 3, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12441, 7, 3, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12442, 7, 3, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12443, 7, 3, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12444, 7, 3, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12445, 7, 3, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12446, 7, 3, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12447, 7, 3, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12448, 7, 3, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12449, 7, 3, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12450, 7, 3, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12451, 7, 3, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12452, 7, 3, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12453, 7, 3, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12482, 2, 3, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12483, 2, 3, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12484, 2, 3, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12485, 2, 3, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12486, 2, 3, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12487, 2, 3, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12488, 2, 3, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12489, 2, 3, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12490, 2, 3, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12491, 2, 3, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12492, 2, 3, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12493, 2, 3, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12494, 2, 3, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12495, 2, 3, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12496, 2, 3, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12497, 2, 3, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (12498, 3, 3, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12499, 3, 3, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12500, 3, 3, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12501, 3, 3, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12502, 3, 3, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12503, 3, 3, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12504, 3, 3, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12505, 3, 3, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12506, 3, 3, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12507, 3, 3, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12508, 3, 3, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12509, 3, 3, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12622, 6, 3, '2026-03-31', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12623, 6, 3, '2026-03-31', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12624, 6, 3, '2026-03-31', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12625, 6, 3, '2026-03-31', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12626, 6, 3, '2026-03-31', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12627, 6, 3, '2026-03-31', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12628, 6, 3, '2026-03-31', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12629, 6, 3, '2026-03-31', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12630, 6, 3, '2026-03-31', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12631, 6, 3, '2026-03-31', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12632, 6, 3, '2026-03-31', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12633, 6, 3, '2026-03-31', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12634, 6, 3, '2026-03-31', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12635, 6, 3, '2026-03-31', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12636, 6, 3, '2026-03-31', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12637, 6, 3, '2026-03-31', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12638, 6, 3, '2026-03-31', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12639, 6, 3, '2026-03-31', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12640, 6, 3, '2026-03-31', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12641, 6, 3, '2026-03-31', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12642, 6, 3, '2026-03-31', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12643, 6, 3, '2026-03-31', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12644, 6, 3, '2026-03-31', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12645, 6, 3, '2026-03-31', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12646, 6, 3, '2026-03-31', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12647, 6, 3, '2026-03-31', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12648, 6, 3, '2026-03-31', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12649, 6, 3, '2026-03-31', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12678, 6, 4, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12679, 6, 4, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12680, 6, 4, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12681, 6, 4, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12682, 6, 4, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12683, 6, 4, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12684, 6, 4, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12685, 6, 4, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12686, 6, 4, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12687, 6, 4, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12688, 6, 4, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12689, 6, 4, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12690, 6, 4, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12691, 6, 4, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12692, 6, 4, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12693, 6, 4, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12694, 6, 4, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12695, 6, 4, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12696, 6, 4, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12697, 6, 4, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12698, 6, 4, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12699, 6, 4, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12700, 6, 4, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12701, 6, 4, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12702, 6, 4, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12703, 6, 4, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12704, 6, 4, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12705, 6, 4, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12762, 3, 4, '2026-03-03', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12763, 3, 4, '2026-03-03', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12764, 3, 4, '2026-03-03', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12765, 3, 4, '2026-03-03', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12766, 3, 4, '2026-03-03', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12767, 3, 4, '2026-03-03', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12768, 3, 4, '2026-03-03', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12769, 3, 4, '2026-03-03', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12770, 3, 4, '2026-03-03', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12771, 3, 4, '2026-03-03', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12772, 3, 4, '2026-03-03', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12773, 3, 4, '2026-03-03', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12774, 3, 4, '2026-03-03', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12775, 3, 4, '2026-03-03', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12776, 3, 4, '2026-03-03', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12777, 3, 4, '2026-03-03', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12778, 3, 4, '2026-03-03', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12779, 3, 4, '2026-03-03', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12780, 3, 4, '2026-03-03', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12781, 3, 4, '2026-03-03', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12782, 3, 4, '2026-03-03', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12783, 3, 4, '2026-03-03', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12784, 3, 4, '2026-03-03', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12785, 3, 4, '2026-03-03', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12786, 3, 4, '2026-03-03', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12787, 3, 4, '2026-03-03', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12788, 3, 4, '2026-03-03', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12789, 3, 4, '2026-03-03', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:26', '2026-03-27 10:51:26');
INSERT INTO `doctor_schedule` VALUES (12846, 6, 4, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12847, 6, 4, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12848, 6, 4, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12849, 6, 4, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12850, 6, 4, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12851, 6, 4, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12852, 6, 4, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12853, 6, 4, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12854, 6, 4, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12855, 6, 4, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12856, 6, 4, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12857, 6, 4, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12858, 6, 4, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12859, 6, 4, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12860, 6, 4, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12861, 6, 4, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12862, 6, 4, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12863, 6, 4, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12864, 6, 4, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12865, 6, 4, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12866, 6, 4, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12867, 6, 4, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12868, 6, 4, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12869, 6, 4, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12870, 6, 4, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12871, 6, 4, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12872, 6, 4, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12873, 6, 4, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12902, 3, 4, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12903, 3, 4, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12904, 3, 4, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12905, 3, 4, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12906, 3, 4, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12907, 3, 4, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12908, 3, 4, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12909, 3, 4, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12910, 3, 4, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12911, 3, 4, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12912, 3, 4, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12913, 3, 4, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12914, 3, 4, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12915, 3, 4, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12916, 3, 4, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12917, 3, 4, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12918, 3, 4, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12919, 3, 4, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12920, 3, 4, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12921, 3, 4, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12922, 3, 4, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12923, 3, 4, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12924, 3, 4, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12925, 3, 4, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12926, 3, 4, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12927, 3, 4, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12928, 3, 4, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12929, 3, 4, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12986, 6, 4, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12987, 6, 4, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12988, 6, 4, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12989, 6, 4, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12990, 6, 4, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12991, 6, 4, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12992, 6, 4, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12993, 6, 4, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12994, 6, 4, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12995, 6, 4, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12996, 6, 4, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12997, 6, 4, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12998, 6, 4, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (12999, 6, 4, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13000, 6, 4, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13001, 6, 4, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13002, 6, 4, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13003, 6, 4, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13004, 6, 4, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13005, 6, 4, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13006, 6, 4, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13007, 6, 4, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13008, 6, 4, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13009, 6, 4, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13010, 6, 4, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13011, 6, 4, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13012, 6, 4, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13013, 6, 4, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13014, 7, 4, '2026-03-09', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13015, 7, 4, '2026-03-09', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13016, 7, 4, '2026-03-09', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13017, 7, 4, '2026-03-09', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13018, 7, 4, '2026-03-09', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13019, 7, 4, '2026-03-09', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13020, 7, 4, '2026-03-09', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13021, 7, 4, '2026-03-09', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13022, 7, 4, '2026-03-09', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13023, 7, 4, '2026-03-09', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13024, 7, 4, '2026-03-09', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13025, 7, 4, '2026-03-09', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13026, 7, 4, '2026-03-09', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13027, 7, 4, '2026-03-09', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13028, 7, 4, '2026-03-09', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13029, 7, 4, '2026-03-09', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13030, 7, 4, '2026-03-09', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13031, 7, 4, '2026-03-09', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13032, 7, 4, '2026-03-09', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13033, 7, 4, '2026-03-09', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13034, 7, 4, '2026-03-09', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13035, 7, 4, '2026-03-09', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13036, 7, 4, '2026-03-09', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13037, 7, 4, '2026-03-09', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13038, 7, 4, '2026-03-09', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13039, 7, 4, '2026-03-09', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13040, 7, 4, '2026-03-09', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13041, 7, 4, '2026-03-09', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13042, 7, 4, '2026-03-10', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13043, 7, 4, '2026-03-10', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13044, 7, 4, '2026-03-10', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13045, 7, 4, '2026-03-10', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13046, 7, 4, '2026-03-10', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13047, 7, 4, '2026-03-10', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13048, 7, 4, '2026-03-10', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13049, 7, 4, '2026-03-10', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13050, 7, 4, '2026-03-10', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13051, 7, 4, '2026-03-10', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13052, 7, 4, '2026-03-10', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13053, 7, 4, '2026-03-10', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13054, 7, 4, '2026-03-10', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13055, 7, 4, '2026-03-10', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13056, 7, 4, '2026-03-10', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13057, 7, 4, '2026-03-10', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13058, 7, 4, '2026-03-10', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13059, 7, 4, '2026-03-10', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13060, 7, 4, '2026-03-10', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13061, 7, 4, '2026-03-10', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13062, 7, 4, '2026-03-10', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13063, 7, 4, '2026-03-10', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13064, 7, 4, '2026-03-10', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13065, 7, 4, '2026-03-10', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13066, 7, 4, '2026-03-10', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13067, 7, 4, '2026-03-10', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13068, 7, 4, '2026-03-10', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13069, 7, 4, '2026-03-10', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:27', '2026-03-27 10:51:27');
INSERT INTO `doctor_schedule` VALUES (13238, 3, 4, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13239, 3, 4, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13240, 3, 4, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13241, 3, 4, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13242, 3, 4, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13243, 3, 4, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13244, 3, 4, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13245, 3, 4, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13246, 3, 4, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13247, 3, 4, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13248, 3, 4, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13249, 3, 4, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13250, 3, 4, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13251, 3, 4, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13252, 3, 4, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13253, 3, 4, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13254, 3, 4, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13255, 3, 4, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13256, 3, 4, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13257, 3, 4, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13258, 3, 4, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13259, 3, 4, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13260, 3, 4, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13261, 3, 4, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13262, 3, 4, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13263, 3, 4, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13264, 3, 4, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13265, 3, 4, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13266, 3, 4, '2026-03-13', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13267, 3, 4, '2026-03-13', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13268, 3, 4, '2026-03-13', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13269, 3, 4, '2026-03-13', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13270, 3, 4, '2026-03-13', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13271, 3, 4, '2026-03-13', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13272, 3, 4, '2026-03-13', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13273, 3, 4, '2026-03-13', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13274, 3, 4, '2026-03-13', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13275, 3, 4, '2026-03-13', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13276, 3, 4, '2026-03-13', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13277, 3, 4, '2026-03-13', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13278, 3, 4, '2026-03-13', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13279, 3, 4, '2026-03-13', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13280, 3, 4, '2026-03-13', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13281, 3, 4, '2026-03-13', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13282, 3, 4, '2026-03-13', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13283, 3, 4, '2026-03-13', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13284, 3, 4, '2026-03-13', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13285, 3, 4, '2026-03-13', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13286, 3, 4, '2026-03-13', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13287, 3, 4, '2026-03-13', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13288, 3, 4, '2026-03-13', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13289, 3, 4, '2026-03-13', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13290, 3, 4, '2026-03-13', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13291, 3, 4, '2026-03-13', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13292, 3, 4, '2026-03-13', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13293, 3, 4, '2026-03-13', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13322, 6, 4, '2026-03-16', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13323, 6, 4, '2026-03-16', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13324, 6, 4, '2026-03-16', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13325, 6, 4, '2026-03-16', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13326, 6, 4, '2026-03-16', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13327, 6, 4, '2026-03-16', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13328, 6, 4, '2026-03-16', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13329, 6, 4, '2026-03-16', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13330, 6, 4, '2026-03-16', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13331, 6, 4, '2026-03-16', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13332, 6, 4, '2026-03-16', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13333, 6, 4, '2026-03-16', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13334, 6, 4, '2026-03-16', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13335, 6, 4, '2026-03-16', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13336, 6, 4, '2026-03-16', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13337, 6, 4, '2026-03-16', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13338, 6, 4, '2026-03-16', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13339, 6, 4, '2026-03-16', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13340, 6, 4, '2026-03-16', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13341, 6, 4, '2026-03-16', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13342, 6, 4, '2026-03-16', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13343, 6, 4, '2026-03-16', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13344, 6, 4, '2026-03-16', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13345, 6, 4, '2026-03-16', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13346, 6, 4, '2026-03-16', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13347, 6, 4, '2026-03-16', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13348, 6, 4, '2026-03-16', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13349, 6, 4, '2026-03-16', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13378, 7, 4, '2026-03-17', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13379, 7, 4, '2026-03-17', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13380, 7, 4, '2026-03-17', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13381, 7, 4, '2026-03-17', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13382, 7, 4, '2026-03-17', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13383, 7, 4, '2026-03-17', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13384, 7, 4, '2026-03-17', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13385, 7, 4, '2026-03-17', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13386, 7, 4, '2026-03-17', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13387, 7, 4, '2026-03-17', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13388, 7, 4, '2026-03-17', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13389, 7, 4, '2026-03-17', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13390, 7, 4, '2026-03-17', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13391, 7, 4, '2026-03-17', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13392, 7, 4, '2026-03-17', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13393, 7, 4, '2026-03-17', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13394, 7, 4, '2026-03-17', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13395, 7, 4, '2026-03-17', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13396, 7, 4, '2026-03-17', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13397, 7, 4, '2026-03-17', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13398, 7, 4, '2026-03-17', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13399, 7, 4, '2026-03-17', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13400, 7, 4, '2026-03-17', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13401, 7, 4, '2026-03-17', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13402, 7, 4, '2026-03-17', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13403, 7, 4, '2026-03-17', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13404, 7, 4, '2026-03-17', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13405, 7, 4, '2026-03-17', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13602, 7, 4, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13603, 7, 4, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13604, 7, 4, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13605, 7, 4, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13606, 7, 4, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13607, 7, 4, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13608, 7, 4, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13609, 7, 4, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13610, 7, 4, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13611, 7, 4, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13612, 7, 4, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:28', '2026-03-27 10:51:28');
INSERT INTO `doctor_schedule` VALUES (13613, 7, 4, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13614, 7, 4, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13615, 7, 4, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13616, 7, 4, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13617, 7, 4, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13618, 7, 4, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13619, 7, 4, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13620, 7, 4, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13621, 7, 4, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13622, 7, 4, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13623, 7, 4, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13624, 7, 4, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13625, 7, 4, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13626, 7, 4, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13627, 7, 4, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13628, 7, 4, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13629, 7, 4, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13630, 6, 4, '2026-03-20', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13631, 6, 4, '2026-03-20', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13632, 6, 4, '2026-03-20', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13633, 6, 4, '2026-03-20', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13634, 6, 4, '2026-03-20', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13635, 6, 4, '2026-03-20', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13636, 6, 4, '2026-03-20', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13637, 6, 4, '2026-03-20', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13638, 6, 4, '2026-03-20', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13639, 6, 4, '2026-03-20', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13640, 6, 4, '2026-03-20', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13641, 6, 4, '2026-03-20', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13642, 6, 4, '2026-03-20', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13643, 6, 4, '2026-03-20', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13644, 6, 4, '2026-03-20', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13645, 6, 4, '2026-03-20', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13646, 6, 4, '2026-03-20', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13647, 6, 4, '2026-03-20', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13648, 6, 4, '2026-03-20', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13649, 6, 4, '2026-03-20', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13650, 6, 4, '2026-03-20', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13651, 6, 4, '2026-03-20', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13652, 6, 4, '2026-03-20', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13653, 6, 4, '2026-03-20', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13654, 6, 4, '2026-03-20', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13655, 6, 4, '2026-03-20', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13656, 6, 4, '2026-03-20', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13657, 6, 4, '2026-03-20', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13714, 3, 4, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13715, 3, 4, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13716, 3, 4, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13717, 3, 4, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13718, 3, 4, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13719, 3, 4, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13720, 3, 4, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13721, 3, 4, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13722, 3, 4, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13723, 3, 4, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13724, 3, 4, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13725, 3, 4, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13726, 3, 4, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13727, 3, 4, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13728, 3, 4, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13729, 3, 4, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13730, 3, 4, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13731, 3, 4, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13732, 3, 4, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13733, 3, 4, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13734, 3, 4, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13735, 3, 4, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13736, 3, 4, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13737, 3, 4, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13738, 3, 4, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13739, 3, 4, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13740, 3, 4, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13741, 3, 4, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13854, 3, 4, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13855, 3, 4, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13856, 3, 4, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13857, 3, 4, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13858, 3, 4, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13859, 3, 4, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13860, 3, 4, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13861, 3, 4, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13862, 3, 4, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13863, 3, 4, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13864, 3, 4, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13865, 3, 4, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13866, 3, 4, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13867, 3, 4, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13868, 3, 4, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13869, 3, 4, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13870, 3, 4, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13871, 3, 4, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13872, 3, 4, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13873, 3, 4, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13874, 3, 4, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13875, 3, 4, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13876, 3, 4, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13877, 3, 4, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13878, 3, 4, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13879, 3, 4, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13880, 3, 4, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13881, 3, 4, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13966, 2, 4, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13967, 2, 4, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13968, 2, 4, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13969, 2, 4, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13970, 2, 4, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13971, 2, 4, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13972, 2, 4, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13973, 2, 4, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13974, 2, 4, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13975, 2, 4, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13976, 2, 4, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13977, 2, 4, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13978, 2, 4, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13979, 2, 4, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13980, 2, 4, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13981, 2, 4, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 12:43:02');
INSERT INTO `doctor_schedule` VALUES (13982, 3, 4, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13983, 3, 4, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13984, 3, 4, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13985, 3, 4, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13986, 3, 4, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13987, 3, 4, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13988, 3, 4, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13989, 3, 4, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13990, 3, 4, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13991, 3, 4, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13992, 3, 4, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (13993, 3, 4, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14022, 2, 4, '2026-03-30', '08:00-08:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14023, 2, 4, '2026-03-30', '08:15-08:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14024, 2, 4, '2026-03-30', '08:30-08:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14025, 2, 4, '2026-03-30', '08:45-09:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14026, 2, 4, '2026-03-30', '09:00-09:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14027, 2, 4, '2026-03-30', '09:15-09:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14028, 2, 4, '2026-03-30', '09:30-09:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14029, 2, 4, '2026-03-30', '09:45-10:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14030, 2, 4, '2026-03-30', '10:00-10:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14031, 2, 4, '2026-03-30', '10:15-10:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14032, 2, 4, '2026-03-30', '10:30-10:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14033, 2, 4, '2026-03-30', '10:45-11:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14034, 2, 4, '2026-03-30', '11:00-11:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14035, 2, 4, '2026-03-30', '11:15-11:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14036, 2, 4, '2026-03-30', '11:30-11:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14037, 2, 4, '2026-03-30', '11:45-12:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14038, 2, 4, '2026-03-30', '14:00-14:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14039, 2, 4, '2026-03-30', '14:15-14:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14040, 2, 4, '2026-03-30', '14:30-14:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14041, 2, 4, '2026-03-30', '14:45-15:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14042, 2, 4, '2026-03-30', '15:00-15:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14043, 2, 4, '2026-03-30', '15:15-15:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14044, 2, 4, '2026-03-30', '15:30-15:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14045, 2, 4, '2026-03-30', '15:45-16:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14046, 2, 4, '2026-03-30', '16:00-16:15', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14047, 2, 4, '2026-03-30', '16:15-16:30', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14048, 2, 4, '2026-03-30', '16:30-16:45', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14049, 2, 4, '2026-03-30', '16:45-17:00', 10, 0, 1, '2026-03-27 10:51:29', '2026-03-27 10:51:29');
INSERT INTO `doctor_schedule` VALUES (14106, 2, 4, '2026-03-31', '08:00-08:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14107, 2, 4, '2026-03-31', '08:15-08:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14108, 2, 4, '2026-03-31', '08:30-08:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14109, 2, 4, '2026-03-31', '08:45-09:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14110, 2, 4, '2026-03-31', '09:00-09:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14111, 2, 4, '2026-03-31', '09:15-09:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14112, 2, 4, '2026-03-31', '09:30-09:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14113, 2, 4, '2026-03-31', '09:45-10:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14114, 2, 4, '2026-03-31', '10:00-10:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14115, 2, 4, '2026-03-31', '10:15-10:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14116, 2, 4, '2026-03-31', '10:30-10:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14117, 2, 4, '2026-03-31', '10:45-11:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14118, 2, 4, '2026-03-31', '11:00-11:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14119, 2, 4, '2026-03-31', '11:15-11:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14120, 2, 4, '2026-03-31', '11:30-11:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14121, 2, 4, '2026-03-31', '11:45-12:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14122, 2, 4, '2026-03-31', '14:00-14:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14123, 2, 4, '2026-03-31', '14:15-14:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14124, 2, 4, '2026-03-31', '14:30-14:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14125, 2, 4, '2026-03-31', '14:45-15:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14126, 2, 4, '2026-03-31', '15:00-15:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14127, 2, 4, '2026-03-31', '15:15-15:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14128, 2, 4, '2026-03-31', '15:30-15:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14129, 2, 4, '2026-03-31', '15:45-16:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14130, 2, 4, '2026-03-31', '16:00-16:15', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14131, 2, 4, '2026-03-31', '16:15-16:30', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14132, 2, 4, '2026-03-31', '16:30-16:45', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14133, 2, 4, '2026-03-31', '16:45-17:00', 15, 0, 1, '2026-03-27 10:51:30', '2026-03-27 10:51:30');
INSERT INTO `doctor_schedule` VALUES (14134, 2, 1, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14135, 2, 1, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14136, 2, 1, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14137, 2, 1, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14138, 2, 1, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14139, 2, 1, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14140, 2, 1, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14141, 2, 1, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14142, 2, 1, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14143, 2, 1, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14144, 2, 1, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14145, 2, 1, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14146, 2, 1, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14147, 2, 1, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14148, 2, 1, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14149, 2, 1, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14150, 2, 1, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14151, 2, 1, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14152, 2, 1, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14153, 2, 1, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14154, 2, 1, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14155, 2, 1, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14156, 2, 1, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14157, 2, 1, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14158, 2, 1, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14159, 2, 1, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14160, 2, 1, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14161, 2, 1, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14162, 3, 1, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14163, 3, 1, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14164, 3, 1, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14165, 3, 1, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14166, 3, 1, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14167, 3, 1, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14168, 3, 1, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14169, 3, 1, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14170, 3, 1, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14171, 3, 1, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14172, 3, 1, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14173, 3, 1, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14174, 3, 1, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14175, 3, 1, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14176, 3, 1, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14177, 3, 1, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14178, 3, 1, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14179, 3, 1, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14180, 3, 1, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14181, 3, 1, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14182, 3, 1, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14183, 3, 1, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14184, 3, 1, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14185, 3, 1, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14186, 3, 1, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14187, 3, 1, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14188, 3, 1, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14189, 3, 1, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14190, 7, 1, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14191, 7, 1, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14192, 7, 1, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14193, 7, 1, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14194, 7, 1, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14195, 7, 1, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14196, 7, 1, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14197, 7, 1, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14198, 7, 1, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14199, 7, 1, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14200, 7, 1, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14201, 7, 1, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14202, 7, 1, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14203, 7, 1, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14204, 7, 1, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14205, 7, 1, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14206, 7, 1, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14207, 7, 1, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14208, 7, 1, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14209, 7, 1, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14210, 7, 1, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14211, 7, 1, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14212, 7, 1, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14213, 7, 1, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14214, 7, 1, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14215, 7, 1, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14216, 7, 1, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14217, 7, 1, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14218, 2, 1, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14219, 2, 1, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14220, 2, 1, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14221, 2, 1, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14222, 2, 1, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14223, 2, 1, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14224, 2, 1, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14225, 2, 1, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14226, 2, 1, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14227, 2, 1, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14228, 2, 1, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14229, 2, 1, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14230, 2, 1, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14231, 2, 1, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14232, 2, 1, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14233, 2, 1, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14234, 2, 1, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14235, 2, 1, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14236, 2, 1, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14237, 2, 1, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14238, 2, 1, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14239, 2, 1, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14240, 2, 1, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14241, 2, 1, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14242, 2, 1, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14243, 2, 1, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14244, 2, 1, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14245, 2, 1, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14246, 7, 1, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14247, 7, 1, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14248, 7, 1, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14249, 7, 1, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14250, 7, 1, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14251, 7, 1, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14252, 7, 1, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14253, 7, 1, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14254, 7, 1, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14255, 7, 1, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14256, 7, 1, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14257, 7, 1, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14258, 7, 1, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14259, 7, 1, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14260, 7, 1, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14261, 7, 1, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14262, 7, 1, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14263, 7, 1, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14264, 7, 1, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14265, 7, 1, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14266, 7, 1, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14267, 7, 1, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14268, 7, 1, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14269, 7, 1, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14270, 7, 1, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14271, 7, 1, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14272, 7, 1, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14273, 7, 1, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14274, 6, 1, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14275, 6, 1, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14276, 6, 1, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14277, 6, 1, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14278, 6, 1, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14279, 6, 1, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14280, 6, 1, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14281, 6, 1, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14282, 6, 1, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14283, 6, 1, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14284, 6, 1, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14285, 6, 1, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14286, 6, 1, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14287, 6, 1, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14288, 6, 1, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14289, 6, 1, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:06', '2026-03-27 12:18:06');
INSERT INTO `doctor_schedule` VALUES (14290, 6, 1, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14291, 6, 1, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14292, 6, 1, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14293, 6, 1, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14294, 6, 1, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14295, 6, 1, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14296, 6, 1, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14297, 6, 1, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14298, 6, 1, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14299, 6, 1, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14300, 6, 1, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14301, 6, 1, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14302, 3, 1, '2026-03-05', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14303, 3, 1, '2026-03-05', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14304, 3, 1, '2026-03-05', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14305, 3, 1, '2026-03-05', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14306, 3, 1, '2026-03-05', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14307, 3, 1, '2026-03-05', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14308, 3, 1, '2026-03-05', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14309, 3, 1, '2026-03-05', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14310, 3, 1, '2026-03-05', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14311, 3, 1, '2026-03-05', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14312, 3, 1, '2026-03-05', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14313, 3, 1, '2026-03-05', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14314, 3, 1, '2026-03-05', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14315, 3, 1, '2026-03-05', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14316, 3, 1, '2026-03-05', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14317, 3, 1, '2026-03-05', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14318, 3, 1, '2026-03-05', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14319, 3, 1, '2026-03-05', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14320, 3, 1, '2026-03-05', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14321, 3, 1, '2026-03-05', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14322, 3, 1, '2026-03-05', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14323, 3, 1, '2026-03-05', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14324, 3, 1, '2026-03-05', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14325, 3, 1, '2026-03-05', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14326, 3, 1, '2026-03-05', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14327, 3, 1, '2026-03-05', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14328, 3, 1, '2026-03-05', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14329, 3, 1, '2026-03-05', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14330, 6, 1, '2026-03-16', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14331, 6, 1, '2026-03-16', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14332, 6, 1, '2026-03-16', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14333, 6, 1, '2026-03-16', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14334, 6, 1, '2026-03-16', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14335, 6, 1, '2026-03-16', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14336, 6, 1, '2026-03-16', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14337, 6, 1, '2026-03-16', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14338, 6, 1, '2026-03-16', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14339, 6, 1, '2026-03-16', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14340, 6, 1, '2026-03-16', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14341, 6, 1, '2026-03-16', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14342, 6, 1, '2026-03-16', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14343, 6, 1, '2026-03-16', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14344, 6, 1, '2026-03-16', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14345, 6, 1, '2026-03-16', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14346, 6, 1, '2026-03-16', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14347, 6, 1, '2026-03-16', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14348, 6, 1, '2026-03-16', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14349, 6, 1, '2026-03-16', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14350, 6, 1, '2026-03-16', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14351, 6, 1, '2026-03-16', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14352, 6, 1, '2026-03-16', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14353, 6, 1, '2026-03-16', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14354, 6, 1, '2026-03-16', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14355, 6, 1, '2026-03-16', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14356, 6, 1, '2026-03-16', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14357, 6, 1, '2026-03-16', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14358, 3, 1, '2026-03-16', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14359, 3, 1, '2026-03-16', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14360, 3, 1, '2026-03-16', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14361, 3, 1, '2026-03-16', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14362, 3, 1, '2026-03-16', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14363, 3, 1, '2026-03-16', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14364, 3, 1, '2026-03-16', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14365, 3, 1, '2026-03-16', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14366, 3, 1, '2026-03-16', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14367, 3, 1, '2026-03-16', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14368, 3, 1, '2026-03-16', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14369, 3, 1, '2026-03-16', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14370, 3, 1, '2026-03-16', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14371, 3, 1, '2026-03-16', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14372, 3, 1, '2026-03-16', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14373, 3, 1, '2026-03-16', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14374, 3, 1, '2026-03-16', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14375, 3, 1, '2026-03-16', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14376, 3, 1, '2026-03-16', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14377, 3, 1, '2026-03-16', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14378, 3, 1, '2026-03-16', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14379, 3, 1, '2026-03-16', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14380, 3, 1, '2026-03-16', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14381, 3, 1, '2026-03-16', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14382, 3, 1, '2026-03-16', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14383, 3, 1, '2026-03-16', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14384, 3, 1, '2026-03-16', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14385, 3, 1, '2026-03-16', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14386, 3, 1, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14387, 3, 1, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14388, 3, 1, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14389, 3, 1, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14390, 3, 1, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14391, 3, 1, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14392, 3, 1, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14393, 3, 1, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14394, 3, 1, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14395, 3, 1, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14396, 3, 1, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14397, 3, 1, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14398, 3, 1, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14399, 3, 1, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14400, 3, 1, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14401, 3, 1, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14402, 3, 1, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14403, 3, 1, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14404, 3, 1, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14405, 3, 1, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14406, 3, 1, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14407, 3, 1, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14408, 3, 1, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14409, 3, 1, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14410, 3, 1, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14411, 3, 1, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14412, 3, 1, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14413, 3, 1, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14414, 6, 1, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14415, 6, 1, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14416, 6, 1, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14417, 6, 1, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14418, 6, 1, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14419, 6, 1, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14420, 6, 1, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14421, 6, 1, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14422, 6, 1, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14423, 6, 1, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14424, 6, 1, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14425, 6, 1, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14426, 6, 1, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14427, 6, 1, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14428, 6, 1, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14429, 6, 1, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14430, 6, 1, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14431, 6, 1, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14432, 6, 1, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14433, 6, 1, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14434, 6, 1, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14435, 6, 1, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14436, 6, 1, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14437, 6, 1, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14438, 6, 1, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14439, 6, 1, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14440, 6, 1, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14441, 6, 1, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14442, 7, 1, '2026-03-19', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14443, 7, 1, '2026-03-19', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14444, 7, 1, '2026-03-19', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14445, 7, 1, '2026-03-19', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14446, 7, 1, '2026-03-19', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14447, 7, 1, '2026-03-19', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14448, 7, 1, '2026-03-19', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14449, 7, 1, '2026-03-19', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14450, 7, 1, '2026-03-19', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14451, 7, 1, '2026-03-19', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14452, 7, 1, '2026-03-19', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14453, 7, 1, '2026-03-19', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14454, 7, 1, '2026-03-19', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14455, 7, 1, '2026-03-19', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14456, 7, 1, '2026-03-19', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14457, 7, 1, '2026-03-19', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14458, 7, 1, '2026-03-19', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14459, 7, 1, '2026-03-19', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14460, 7, 1, '2026-03-19', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14461, 7, 1, '2026-03-19', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14462, 7, 1, '2026-03-19', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14463, 7, 1, '2026-03-19', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14464, 7, 1, '2026-03-19', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14465, 7, 1, '2026-03-19', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14466, 7, 1, '2026-03-19', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14467, 7, 1, '2026-03-19', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14468, 7, 1, '2026-03-19', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14469, 7, 1, '2026-03-19', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14470, 6, 1, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14471, 6, 1, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14472, 6, 1, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14473, 6, 1, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14474, 6, 1, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14475, 6, 1, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14476, 6, 1, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14477, 6, 1, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14478, 6, 1, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14479, 6, 1, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14480, 6, 1, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14481, 6, 1, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14482, 6, 1, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14483, 6, 1, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14484, 6, 1, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14485, 6, 1, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14486, 6, 1, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14487, 6, 1, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14488, 6, 1, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14489, 6, 1, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14490, 6, 1, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14491, 6, 1, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14492, 6, 1, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14493, 6, 1, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14494, 6, 1, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14495, 6, 1, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14496, 6, 1, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14497, 6, 1, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14498, 2, 1, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14499, 2, 1, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14500, 2, 1, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14501, 2, 1, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14502, 2, 1, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14503, 2, 1, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14504, 2, 1, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14505, 2, 1, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14506, 2, 1, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14507, 2, 1, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14508, 2, 1, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14509, 2, 1, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14510, 2, 1, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14511, 2, 1, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14512, 2, 1, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14513, 2, 1, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14514, 2, 1, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14515, 2, 1, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14516, 2, 1, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14517, 2, 1, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14518, 2, 1, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14519, 2, 1, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14520, 2, 1, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14521, 2, 1, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14522, 2, 1, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14523, 2, 1, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14524, 2, 1, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14525, 2, 1, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14526, 7, 1, '2026-03-24', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14527, 7, 1, '2026-03-24', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14528, 7, 1, '2026-03-24', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14529, 7, 1, '2026-03-24', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14530, 7, 1, '2026-03-24', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14531, 7, 1, '2026-03-24', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14532, 7, 1, '2026-03-24', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14533, 7, 1, '2026-03-24', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14534, 7, 1, '2026-03-24', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14535, 7, 1, '2026-03-24', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14536, 7, 1, '2026-03-24', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14537, 7, 1, '2026-03-24', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14538, 7, 1, '2026-03-24', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14539, 7, 1, '2026-03-24', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14540, 7, 1, '2026-03-24', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14541, 7, 1, '2026-03-24', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14542, 7, 1, '2026-03-24', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14543, 7, 1, '2026-03-24', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14544, 7, 1, '2026-03-24', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14545, 7, 1, '2026-03-24', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14546, 7, 1, '2026-03-24', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14547, 7, 1, '2026-03-24', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14548, 7, 1, '2026-03-24', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14549, 7, 1, '2026-03-24', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14550, 7, 1, '2026-03-24', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14551, 7, 1, '2026-03-24', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14552, 7, 1, '2026-03-24', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14553, 7, 1, '2026-03-24', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14554, 2, 1, '2026-03-25', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14555, 2, 1, '2026-03-25', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14556, 2, 1, '2026-03-25', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14557, 2, 1, '2026-03-25', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14558, 2, 1, '2026-03-25', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14559, 2, 1, '2026-03-25', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14560, 2, 1, '2026-03-25', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14561, 2, 1, '2026-03-25', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14562, 2, 1, '2026-03-25', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14563, 2, 1, '2026-03-25', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14564, 2, 1, '2026-03-25', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14565, 2, 1, '2026-03-25', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14566, 2, 1, '2026-03-25', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14567, 2, 1, '2026-03-25', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14568, 2, 1, '2026-03-25', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14569, 2, 1, '2026-03-25', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14570, 2, 1, '2026-03-25', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14571, 2, 1, '2026-03-25', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14572, 2, 1, '2026-03-25', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14573, 2, 1, '2026-03-25', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14574, 2, 1, '2026-03-25', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14575, 2, 1, '2026-03-25', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14576, 2, 1, '2026-03-25', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14577, 2, 1, '2026-03-25', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14578, 2, 1, '2026-03-25', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14579, 2, 1, '2026-03-25', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14580, 2, 1, '2026-03-25', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14581, 2, 1, '2026-03-25', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14582, 7, 1, '2026-03-25', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14583, 7, 1, '2026-03-25', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14584, 7, 1, '2026-03-25', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14585, 7, 1, '2026-03-25', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14586, 7, 1, '2026-03-25', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14587, 7, 1, '2026-03-25', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14588, 7, 1, '2026-03-25', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14589, 7, 1, '2026-03-25', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14590, 7, 1, '2026-03-25', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14591, 7, 1, '2026-03-25', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14592, 7, 1, '2026-03-25', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14593, 7, 1, '2026-03-25', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14594, 7, 1, '2026-03-25', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14595, 7, 1, '2026-03-25', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14596, 7, 1, '2026-03-25', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14597, 7, 1, '2026-03-25', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14598, 7, 1, '2026-03-25', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14599, 7, 1, '2026-03-25', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14600, 7, 1, '2026-03-25', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14601, 7, 1, '2026-03-25', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14602, 7, 1, '2026-03-25', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14603, 7, 1, '2026-03-25', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14604, 7, 1, '2026-03-25', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14605, 7, 1, '2026-03-25', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14606, 7, 1, '2026-03-25', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14607, 7, 1, '2026-03-25', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14608, 7, 1, '2026-03-25', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14609, 7, 1, '2026-03-25', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14610, 6, 1, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14611, 6, 1, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14612, 6, 1, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14613, 6, 1, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14614, 6, 1, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14615, 6, 1, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14616, 6, 1, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14617, 6, 1, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14618, 6, 1, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14619, 6, 1, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14620, 6, 1, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14621, 6, 1, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14622, 6, 1, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14623, 6, 1, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14624, 6, 1, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14625, 6, 1, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14626, 6, 1, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14627, 6, 1, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14628, 6, 1, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14629, 6, 1, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14630, 6, 1, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14631, 6, 1, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14632, 6, 1, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14633, 6, 1, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14634, 6, 1, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14635, 6, 1, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14636, 6, 1, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14637, 6, 1, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14638, 7, 1, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14639, 7, 1, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14640, 7, 1, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14641, 7, 1, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14642, 7, 1, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14643, 7, 1, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14644, 7, 1, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14645, 7, 1, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14646, 7, 1, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14647, 7, 1, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14648, 7, 1, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14649, 7, 1, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14650, 7, 1, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14651, 7, 1, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14652, 7, 1, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14653, 7, 1, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14654, 7, 1, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14655, 7, 1, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14656, 7, 1, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14657, 7, 1, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14658, 7, 1, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14659, 7, 1, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14660, 7, 1, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14661, 7, 1, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14662, 7, 1, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14663, 7, 1, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14664, 7, 1, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14665, 7, 1, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14666, 3, 2, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14667, 3, 2, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14668, 3, 2, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14669, 3, 2, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14670, 3, 2, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14671, 3, 2, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14672, 3, 2, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14673, 3, 2, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14674, 3, 2, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14675, 3, 2, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14676, 3, 2, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14677, 3, 2, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14678, 3, 2, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14679, 3, 2, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14680, 3, 2, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14681, 3, 2, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14682, 3, 2, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14683, 3, 2, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14684, 3, 2, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14685, 3, 2, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14686, 3, 2, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14687, 3, 2, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14688, 3, 2, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14689, 3, 2, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14690, 3, 2, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14691, 3, 2, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14692, 3, 2, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14693, 3, 2, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14694, 6, 2, '2026-03-02', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14695, 6, 2, '2026-03-02', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14696, 6, 2, '2026-03-02', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14697, 6, 2, '2026-03-02', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14698, 6, 2, '2026-03-02', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14699, 6, 2, '2026-03-02', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14700, 6, 2, '2026-03-02', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14701, 6, 2, '2026-03-02', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14702, 6, 2, '2026-03-02', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14703, 6, 2, '2026-03-02', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14704, 6, 2, '2026-03-02', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14705, 6, 2, '2026-03-02', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14706, 6, 2, '2026-03-02', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14707, 6, 2, '2026-03-02', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14708, 6, 2, '2026-03-02', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14709, 6, 2, '2026-03-02', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14710, 6, 2, '2026-03-02', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14711, 6, 2, '2026-03-02', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14712, 6, 2, '2026-03-02', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14713, 6, 2, '2026-03-02', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14714, 6, 2, '2026-03-02', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14715, 6, 2, '2026-03-02', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14716, 6, 2, '2026-03-02', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14717, 6, 2, '2026-03-02', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14718, 6, 2, '2026-03-02', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14719, 6, 2, '2026-03-02', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14720, 6, 2, '2026-03-02', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14721, 6, 2, '2026-03-02', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14722, 6, 2, '2026-03-06', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14723, 6, 2, '2026-03-06', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14724, 6, 2, '2026-03-06', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14725, 6, 2, '2026-03-06', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14726, 6, 2, '2026-03-06', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14727, 6, 2, '2026-03-06', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14728, 6, 2, '2026-03-06', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14729, 6, 2, '2026-03-06', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14730, 6, 2, '2026-03-06', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14731, 6, 2, '2026-03-06', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14732, 6, 2, '2026-03-06', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14733, 6, 2, '2026-03-06', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14734, 6, 2, '2026-03-06', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14735, 6, 2, '2026-03-06', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14736, 6, 2, '2026-03-06', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14737, 6, 2, '2026-03-06', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14738, 6, 2, '2026-03-06', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14739, 6, 2, '2026-03-06', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14740, 6, 2, '2026-03-06', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14741, 6, 2, '2026-03-06', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14742, 6, 2, '2026-03-06', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14743, 6, 2, '2026-03-06', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14744, 6, 2, '2026-03-06', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14745, 6, 2, '2026-03-06', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14746, 6, 2, '2026-03-06', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14747, 6, 2, '2026-03-06', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14748, 6, 2, '2026-03-06', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14749, 6, 2, '2026-03-06', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14750, 2, 2, '2026-03-06', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14751, 2, 2, '2026-03-06', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14752, 2, 2, '2026-03-06', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14753, 2, 2, '2026-03-06', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14754, 2, 2, '2026-03-06', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14755, 2, 2, '2026-03-06', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14756, 2, 2, '2026-03-06', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14757, 2, 2, '2026-03-06', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14758, 2, 2, '2026-03-06', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14759, 2, 2, '2026-03-06', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14760, 2, 2, '2026-03-06', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14761, 2, 2, '2026-03-06', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14762, 2, 2, '2026-03-06', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14763, 2, 2, '2026-03-06', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14764, 2, 2, '2026-03-06', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14765, 2, 2, '2026-03-06', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14766, 2, 2, '2026-03-06', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14767, 2, 2, '2026-03-06', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14768, 2, 2, '2026-03-06', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14769, 2, 2, '2026-03-06', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14770, 2, 2, '2026-03-06', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14771, 2, 2, '2026-03-06', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14772, 2, 2, '2026-03-06', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14773, 2, 2, '2026-03-06', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14774, 2, 2, '2026-03-06', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14775, 2, 2, '2026-03-06', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14776, 2, 2, '2026-03-06', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14777, 2, 2, '2026-03-06', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14778, 6, 2, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14779, 6, 2, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14780, 6, 2, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14781, 6, 2, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14782, 6, 2, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14783, 6, 2, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14784, 6, 2, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14785, 6, 2, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14786, 6, 2, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14787, 6, 2, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14788, 6, 2, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14789, 6, 2, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14790, 6, 2, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14791, 6, 2, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14792, 6, 2, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14793, 6, 2, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14794, 6, 2, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14795, 6, 2, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14796, 6, 2, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14797, 6, 2, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14798, 6, 2, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14799, 6, 2, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14800, 6, 2, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14801, 6, 2, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14802, 6, 2, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14803, 6, 2, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14804, 6, 2, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14805, 6, 2, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14806, 2, 2, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14807, 2, 2, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14808, 2, 2, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14809, 2, 2, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14810, 2, 2, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14811, 2, 2, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14812, 2, 2, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14813, 2, 2, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14814, 2, 2, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14815, 2, 2, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14816, 2, 2, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14817, 2, 2, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14818, 2, 2, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14819, 2, 2, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14820, 2, 2, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14821, 2, 2, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14822, 2, 2, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14823, 2, 2, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14824, 2, 2, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14825, 2, 2, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14826, 2, 2, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14827, 2, 2, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14828, 2, 2, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14829, 2, 2, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14830, 2, 2, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14831, 2, 2, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14832, 2, 2, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14833, 2, 2, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14834, 7, 2, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14835, 7, 2, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14836, 7, 2, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14837, 7, 2, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14838, 7, 2, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14839, 7, 2, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14840, 7, 2, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14841, 7, 2, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14842, 7, 2, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14843, 7, 2, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14844, 7, 2, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14845, 7, 2, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14846, 7, 2, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14847, 7, 2, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14848, 7, 2, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14849, 7, 2, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14850, 7, 2, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14851, 7, 2, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14852, 7, 2, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14853, 7, 2, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14854, 7, 2, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14855, 7, 2, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14856, 7, 2, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14857, 7, 2, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14858, 7, 2, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14859, 7, 2, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14860, 7, 2, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14861, 7, 2, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14862, 3, 2, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14863, 3, 2, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14864, 3, 2, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14865, 3, 2, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14866, 3, 2, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14867, 3, 2, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14868, 3, 2, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14869, 3, 2, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14870, 3, 2, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14871, 3, 2, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14872, 3, 2, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14873, 3, 2, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14874, 3, 2, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14875, 3, 2, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14876, 3, 2, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14877, 3, 2, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14878, 3, 2, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14879, 3, 2, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14880, 3, 2, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14881, 3, 2, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14882, 3, 2, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14883, 3, 2, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14884, 3, 2, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14885, 3, 2, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14886, 3, 2, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14887, 3, 2, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14888, 3, 2, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14889, 3, 2, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14890, 6, 2, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14891, 6, 2, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14892, 6, 2, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14893, 6, 2, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14894, 6, 2, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14895, 6, 2, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14896, 6, 2, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14897, 6, 2, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14898, 6, 2, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14899, 6, 2, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14900, 6, 2, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14901, 6, 2, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14902, 6, 2, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14903, 6, 2, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14904, 6, 2, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14905, 6, 2, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14906, 6, 2, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14907, 6, 2, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14908, 6, 2, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14909, 6, 2, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14910, 6, 2, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14911, 6, 2, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14912, 6, 2, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14913, 6, 2, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14914, 6, 2, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14915, 6, 2, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14916, 6, 2, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14917, 6, 2, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14918, 2, 2, '2026-03-26', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14919, 2, 2, '2026-03-26', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14920, 2, 2, '2026-03-26', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14921, 2, 2, '2026-03-26', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14922, 2, 2, '2026-03-26', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14923, 2, 2, '2026-03-26', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14924, 2, 2, '2026-03-26', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14925, 2, 2, '2026-03-26', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14926, 2, 2, '2026-03-26', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14927, 2, 2, '2026-03-26', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14928, 2, 2, '2026-03-26', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14929, 2, 2, '2026-03-26', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14930, 2, 2, '2026-03-26', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14931, 2, 2, '2026-03-26', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14932, 2, 2, '2026-03-26', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14933, 2, 2, '2026-03-26', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14934, 2, 2, '2026-03-26', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14935, 2, 2, '2026-03-26', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14936, 2, 2, '2026-03-26', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14937, 2, 2, '2026-03-26', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14938, 2, 2, '2026-03-26', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14939, 2, 2, '2026-03-26', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14940, 2, 2, '2026-03-26', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14941, 2, 2, '2026-03-26', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14942, 2, 2, '2026-03-26', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14943, 2, 2, '2026-03-26', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14944, 2, 2, '2026-03-26', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14945, 2, 2, '2026-03-26', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14946, 6, 2, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14947, 6, 2, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14948, 6, 2, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14949, 6, 2, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14950, 6, 2, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14951, 6, 2, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14952, 6, 2, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14953, 6, 2, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14954, 6, 2, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14955, 6, 2, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14956, 6, 2, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14957, 6, 2, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14958, 6, 2, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14959, 6, 2, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14960, 6, 2, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14961, 6, 2, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14962, 6, 2, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14963, 6, 2, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14964, 6, 2, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14965, 6, 2, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14966, 6, 2, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14967, 6, 2, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14968, 6, 2, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14969, 6, 2, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14970, 6, 2, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14971, 6, 2, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14972, 6, 2, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14973, 6, 2, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14974, 7, 2, '2026-03-27', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14975, 7, 2, '2026-03-27', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14976, 7, 2, '2026-03-27', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14977, 7, 2, '2026-03-27', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14978, 7, 2, '2026-03-27', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14979, 7, 2, '2026-03-27', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14980, 7, 2, '2026-03-27', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14981, 7, 2, '2026-03-27', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14982, 7, 2, '2026-03-27', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14983, 7, 2, '2026-03-27', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14984, 7, 2, '2026-03-27', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14985, 7, 2, '2026-03-27', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14986, 7, 2, '2026-03-27', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14987, 7, 2, '2026-03-27', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14988, 7, 2, '2026-03-27', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14989, 7, 2, '2026-03-27', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14990, 7, 2, '2026-03-27', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14991, 7, 2, '2026-03-27', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14992, 7, 2, '2026-03-27', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14993, 7, 2, '2026-03-27', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14994, 7, 2, '2026-03-27', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14995, 7, 2, '2026-03-27', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14996, 7, 2, '2026-03-27', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14997, 7, 2, '2026-03-27', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14998, 7, 2, '2026-03-27', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (14999, 7, 2, '2026-03-27', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (15000, 7, 2, '2026-03-27', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (15001, 7, 2, '2026-03-27', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:07', '2026-03-27 12:18:07');
INSERT INTO `doctor_schedule` VALUES (15002, 2, 3, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15003, 2, 3, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15004, 2, 3, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15005, 2, 3, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15006, 2, 3, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15007, 2, 3, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15008, 2, 3, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15009, 2, 3, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15010, 2, 3, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15011, 2, 3, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15012, 2, 3, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15013, 2, 3, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15014, 2, 3, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15015, 2, 3, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15016, 2, 3, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15017, 2, 3, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15018, 2, 3, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15019, 2, 3, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15020, 2, 3, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15021, 2, 3, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15022, 2, 3, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15023, 2, 3, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15024, 2, 3, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15025, 2, 3, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15026, 2, 3, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15027, 2, 3, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15028, 2, 3, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15029, 2, 3, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15030, 7, 3, '2026-03-04', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15031, 7, 3, '2026-03-04', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15032, 7, 3, '2026-03-04', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15033, 7, 3, '2026-03-04', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15034, 7, 3, '2026-03-04', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15035, 7, 3, '2026-03-04', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15036, 7, 3, '2026-03-04', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15037, 7, 3, '2026-03-04', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15038, 7, 3, '2026-03-04', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15039, 7, 3, '2026-03-04', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15040, 7, 3, '2026-03-04', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15041, 7, 3, '2026-03-04', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15042, 7, 3, '2026-03-04', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15043, 7, 3, '2026-03-04', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15044, 7, 3, '2026-03-04', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15045, 7, 3, '2026-03-04', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15046, 7, 3, '2026-03-04', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15047, 7, 3, '2026-03-04', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15048, 7, 3, '2026-03-04', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15049, 7, 3, '2026-03-04', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15050, 7, 3, '2026-03-04', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15051, 7, 3, '2026-03-04', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15052, 7, 3, '2026-03-04', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15053, 7, 3, '2026-03-04', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15054, 7, 3, '2026-03-04', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15055, 7, 3, '2026-03-04', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15056, 7, 3, '2026-03-04', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15057, 7, 3, '2026-03-04', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15058, 3, 3, '2026-03-06', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15059, 3, 3, '2026-03-06', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15060, 3, 3, '2026-03-06', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15061, 3, 3, '2026-03-06', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15062, 3, 3, '2026-03-06', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15063, 3, 3, '2026-03-06', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15064, 3, 3, '2026-03-06', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15065, 3, 3, '2026-03-06', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15066, 3, 3, '2026-03-06', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15067, 3, 3, '2026-03-06', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15068, 3, 3, '2026-03-06', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15069, 3, 3, '2026-03-06', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15070, 3, 3, '2026-03-06', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15071, 3, 3, '2026-03-06', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15072, 3, 3, '2026-03-06', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15073, 3, 3, '2026-03-06', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15074, 3, 3, '2026-03-06', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15075, 3, 3, '2026-03-06', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15076, 3, 3, '2026-03-06', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15077, 3, 3, '2026-03-06', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15078, 3, 3, '2026-03-06', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15079, 3, 3, '2026-03-06', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15080, 3, 3, '2026-03-06', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15081, 3, 3, '2026-03-06', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15082, 3, 3, '2026-03-06', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15083, 3, 3, '2026-03-06', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15084, 3, 3, '2026-03-06', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15085, 3, 3, '2026-03-06', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15086, 2, 3, '2026-03-06', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15087, 2, 3, '2026-03-06', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15088, 2, 3, '2026-03-06', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15089, 2, 3, '2026-03-06', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15090, 2, 3, '2026-03-06', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15091, 2, 3, '2026-03-06', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15092, 2, 3, '2026-03-06', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15093, 2, 3, '2026-03-06', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15094, 2, 3, '2026-03-06', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15095, 2, 3, '2026-03-06', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15096, 2, 3, '2026-03-06', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15097, 2, 3, '2026-03-06', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15098, 2, 3, '2026-03-06', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15099, 2, 3, '2026-03-06', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15100, 2, 3, '2026-03-06', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15101, 2, 3, '2026-03-06', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15102, 2, 3, '2026-03-06', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15103, 2, 3, '2026-03-06', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15104, 2, 3, '2026-03-06', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15105, 2, 3, '2026-03-06', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15106, 2, 3, '2026-03-06', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15107, 2, 3, '2026-03-06', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15108, 2, 3, '2026-03-06', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15109, 2, 3, '2026-03-06', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15110, 2, 3, '2026-03-06', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15111, 2, 3, '2026-03-06', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15112, 2, 3, '2026-03-06', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15113, 2, 3, '2026-03-06', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15114, 3, 3, '2026-03-11', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15115, 3, 3, '2026-03-11', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15116, 3, 3, '2026-03-11', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15117, 3, 3, '2026-03-11', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15118, 3, 3, '2026-03-11', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15119, 3, 3, '2026-03-11', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15120, 3, 3, '2026-03-11', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15121, 3, 3, '2026-03-11', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15122, 3, 3, '2026-03-11', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15123, 3, 3, '2026-03-11', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15124, 3, 3, '2026-03-11', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15125, 3, 3, '2026-03-11', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15126, 3, 3, '2026-03-11', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15127, 3, 3, '2026-03-11', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15128, 3, 3, '2026-03-11', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15129, 3, 3, '2026-03-11', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15130, 3, 3, '2026-03-11', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15131, 3, 3, '2026-03-11', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15132, 3, 3, '2026-03-11', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15133, 3, 3, '2026-03-11', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15134, 3, 3, '2026-03-11', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15135, 3, 3, '2026-03-11', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15136, 3, 3, '2026-03-11', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15137, 3, 3, '2026-03-11', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15138, 3, 3, '2026-03-11', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15139, 3, 3, '2026-03-11', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15140, 3, 3, '2026-03-11', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15141, 3, 3, '2026-03-11', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15142, 6, 3, '2026-03-11', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15143, 6, 3, '2026-03-11', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15144, 6, 3, '2026-03-11', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15145, 6, 3, '2026-03-11', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15146, 6, 3, '2026-03-11', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15147, 6, 3, '2026-03-11', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15148, 6, 3, '2026-03-11', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15149, 6, 3, '2026-03-11', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15150, 6, 3, '2026-03-11', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15151, 6, 3, '2026-03-11', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15152, 6, 3, '2026-03-11', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15153, 6, 3, '2026-03-11', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15154, 6, 3, '2026-03-11', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15155, 6, 3, '2026-03-11', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15156, 6, 3, '2026-03-11', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15157, 6, 3, '2026-03-11', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15158, 6, 3, '2026-03-11', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15159, 6, 3, '2026-03-11', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15160, 6, 3, '2026-03-11', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15161, 6, 3, '2026-03-11', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15162, 6, 3, '2026-03-11', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15163, 6, 3, '2026-03-11', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15164, 6, 3, '2026-03-11', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15165, 6, 3, '2026-03-11', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15166, 6, 3, '2026-03-11', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15167, 6, 3, '2026-03-11', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15168, 6, 3, '2026-03-11', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15169, 6, 3, '2026-03-11', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15170, 7, 3, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15171, 7, 3, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15172, 7, 3, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15173, 7, 3, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15174, 7, 3, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15175, 7, 3, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15176, 7, 3, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15177, 7, 3, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15178, 7, 3, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15179, 7, 3, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15180, 7, 3, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15181, 7, 3, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15182, 7, 3, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15183, 7, 3, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15184, 7, 3, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15185, 7, 3, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15186, 7, 3, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15187, 7, 3, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15188, 7, 3, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15189, 7, 3, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15190, 7, 3, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15191, 7, 3, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15192, 7, 3, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15193, 7, 3, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15194, 7, 3, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15195, 7, 3, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15196, 7, 3, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15197, 7, 3, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15198, 6, 3, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15199, 6, 3, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15200, 6, 3, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15201, 6, 3, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15202, 6, 3, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15203, 6, 3, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15204, 6, 3, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15205, 6, 3, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15206, 6, 3, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15207, 6, 3, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15208, 6, 3, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15209, 6, 3, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15210, 6, 3, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15211, 6, 3, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15212, 6, 3, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15213, 6, 3, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15214, 6, 3, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15215, 6, 3, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15216, 6, 3, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15217, 6, 3, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15218, 6, 3, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15219, 6, 3, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15220, 6, 3, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15221, 6, 3, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15222, 6, 3, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15223, 6, 3, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15224, 6, 3, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15225, 6, 3, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15226, 2, 3, '2026-03-12', '08:00-08:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15227, 2, 3, '2026-03-12', '08:15-08:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15228, 2, 3, '2026-03-12', '08:30-08:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15229, 2, 3, '2026-03-12', '08:45-09:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15230, 2, 3, '2026-03-12', '09:00-09:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15231, 2, 3, '2026-03-12', '09:15-09:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15232, 2, 3, '2026-03-12', '09:30-09:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15233, 2, 3, '2026-03-12', '09:45-10:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15234, 2, 3, '2026-03-12', '10:00-10:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15235, 2, 3, '2026-03-12', '10:15-10:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15236, 2, 3, '2026-03-12', '10:30-10:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15237, 2, 3, '2026-03-12', '10:45-11:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15238, 2, 3, '2026-03-12', '11:00-11:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15239, 2, 3, '2026-03-12', '11:15-11:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15240, 2, 3, '2026-03-12', '11:30-11:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15241, 2, 3, '2026-03-12', '11:45-12:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15242, 2, 3, '2026-03-12', '14:00-14:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15243, 2, 3, '2026-03-12', '14:15-14:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15244, 2, 3, '2026-03-12', '14:30-14:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15245, 2, 3, '2026-03-12', '14:45-15:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15246, 2, 3, '2026-03-12', '15:00-15:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15247, 2, 3, '2026-03-12', '15:15-15:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15248, 2, 3, '2026-03-12', '15:30-15:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15249, 2, 3, '2026-03-12', '15:45-16:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15250, 2, 3, '2026-03-12', '16:00-16:15', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15251, 2, 3, '2026-03-12', '16:15-16:30', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15252, 2, 3, '2026-03-12', '16:30-16:45', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15253, 2, 3, '2026-03-12', '16:45-17:00', 15, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15254, 3, 3, '2026-03-13', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15255, 3, 3, '2026-03-13', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15256, 3, 3, '2026-03-13', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15257, 3, 3, '2026-03-13', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15258, 3, 3, '2026-03-13', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15259, 3, 3, '2026-03-13', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15260, 3, 3, '2026-03-13', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15261, 3, 3, '2026-03-13', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15262, 3, 3, '2026-03-13', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15263, 3, 3, '2026-03-13', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15264, 3, 3, '2026-03-13', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15265, 3, 3, '2026-03-13', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15266, 3, 3, '2026-03-13', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15267, 3, 3, '2026-03-13', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15268, 3, 3, '2026-03-13', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15269, 3, 3, '2026-03-13', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15270, 3, 3, '2026-03-13', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15271, 3, 3, '2026-03-13', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15272, 3, 3, '2026-03-13', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15273, 3, 3, '2026-03-13', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15274, 3, 3, '2026-03-13', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15275, 3, 3, '2026-03-13', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15276, 3, 3, '2026-03-13', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15277, 3, 3, '2026-03-13', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15278, 3, 3, '2026-03-13', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15279, 3, 3, '2026-03-13', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15280, 3, 3, '2026-03-13', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15281, 3, 3, '2026-03-13', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15282, 6, 3, '2026-03-13', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15283, 6, 3, '2026-03-13', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15284, 6, 3, '2026-03-13', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15285, 6, 3, '2026-03-13', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15286, 6, 3, '2026-03-13', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15287, 6, 3, '2026-03-13', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15288, 6, 3, '2026-03-13', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15289, 6, 3, '2026-03-13', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15290, 6, 3, '2026-03-13', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15291, 6, 3, '2026-03-13', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15292, 6, 3, '2026-03-13', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15293, 6, 3, '2026-03-13', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15294, 6, 3, '2026-03-13', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15295, 6, 3, '2026-03-13', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15296, 6, 3, '2026-03-13', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15297, 6, 3, '2026-03-13', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15298, 6, 3, '2026-03-13', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15299, 6, 3, '2026-03-13', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15300, 6, 3, '2026-03-13', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15301, 6, 3, '2026-03-13', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15302, 6, 3, '2026-03-13', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15303, 6, 3, '2026-03-13', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15304, 6, 3, '2026-03-13', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15305, 6, 3, '2026-03-13', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15306, 6, 3, '2026-03-13', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15307, 6, 3, '2026-03-13', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15308, 6, 3, '2026-03-13', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15309, 6, 3, '2026-03-13', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15310, 3, 3, '2026-03-30', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15311, 3, 3, '2026-03-30', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15312, 3, 3, '2026-03-30', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15313, 3, 3, '2026-03-30', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15314, 3, 3, '2026-03-30', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15315, 3, 3, '2026-03-30', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15316, 3, 3, '2026-03-30', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15317, 3, 3, '2026-03-30', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15318, 3, 3, '2026-03-30', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15319, 3, 3, '2026-03-30', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15320, 3, 3, '2026-03-30', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15321, 3, 3, '2026-03-30', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15322, 3, 3, '2026-03-30', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15323, 3, 3, '2026-03-30', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15324, 3, 3, '2026-03-30', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15325, 3, 3, '2026-03-30', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15326, 3, 3, '2026-03-30', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15327, 3, 3, '2026-03-30', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15328, 3, 3, '2026-03-30', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15329, 3, 3, '2026-03-30', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15330, 3, 3, '2026-03-30', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15331, 3, 3, '2026-03-30', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15332, 3, 3, '2026-03-30', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15333, 3, 3, '2026-03-30', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15334, 3, 3, '2026-03-30', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15335, 3, 3, '2026-03-30', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15336, 3, 3, '2026-03-30', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15337, 3, 3, '2026-03-30', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15338, 6, 3, '2026-03-30', '08:00-08:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15339, 6, 3, '2026-03-30', '08:15-08:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15340, 6, 3, '2026-03-30', '08:30-08:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15341, 6, 3, '2026-03-30', '08:45-09:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15342, 6, 3, '2026-03-30', '09:00-09:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15343, 6, 3, '2026-03-30', '09:15-09:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15344, 6, 3, '2026-03-30', '09:30-09:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15345, 6, 3, '2026-03-30', '09:45-10:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15346, 6, 3, '2026-03-30', '10:00-10:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15347, 6, 3, '2026-03-30', '10:15-10:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15348, 6, 3, '2026-03-30', '10:30-10:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15349, 6, 3, '2026-03-30', '10:45-11:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15350, 6, 3, '2026-03-30', '11:00-11:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15351, 6, 3, '2026-03-30', '11:15-11:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15352, 6, 3, '2026-03-30', '11:30-11:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15353, 6, 3, '2026-03-30', '11:45-12:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15354, 6, 3, '2026-03-30', '14:00-14:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15355, 6, 3, '2026-03-30', '14:15-14:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15356, 6, 3, '2026-03-30', '14:30-14:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15357, 6, 3, '2026-03-30', '14:45-15:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15358, 6, 3, '2026-03-30', '15:00-15:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15359, 6, 3, '2026-03-30', '15:15-15:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15360, 6, 3, '2026-03-30', '15:30-15:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15361, 6, 3, '2026-03-30', '15:45-16:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15362, 6, 3, '2026-03-30', '16:00-16:15', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15363, 6, 3, '2026-03-30', '16:15-16:30', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15364, 6, 3, '2026-03-30', '16:30-16:45', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');
INSERT INTO `doctor_schedule` VALUES (15365, 6, 3, '2026-03-30', '16:45-17:00', 10, 0, 1, '2026-03-27 12:18:08', '2026-03-27 12:18:08');

-- ----------------------------
-- Table structure for doctor_site
-- ----------------------------
DROP TABLE IF EXISTS `doctor_site`;
CREATE TABLE `doctor_site`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '医生用户ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_doctor_site`(`user_id` ASC, `site_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  CONSTRAINT `fk_doctor_site_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_doctor_site_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生-接种点关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of doctor_site
-- ----------------------------
INSERT INTO `doctor_site` VALUES (1, 2, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `doctor_site` VALUES (2, 2, 2, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `doctor_site` VALUES (3, 2, 3, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `doctor_site` VALUES (4, 2, 4, '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '正文内容',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NORMAL' COMMENT '类型：NORMAL/IMPORTANT/SYSTEM',
  `publisher_id` bigint NULL DEFAULT NULL COMMENT '发布人ID',
  `publisher_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ADMIN' COMMENT '发布者角色：ADMIN-管理员，DOCTOR-医生',
  `audit_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'PENDING/APPROVED/REJECTED',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '未通过原因',
  `is_top` tinyint NOT NULL DEFAULT 0 COMMENT '是否置顶：0-否，1-是',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-草稿/下架，1-发布',
  `publish_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `target_user_id` bigint NULL DEFAULT NULL COMMENT '定向用户ID：非空时仅该用户可见',
  `notice_style` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NORMAL' COMMENT '展示样式：NORMAL/WARNING/FROZEN',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_is_top`(`is_top` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_publish_time`(`publish_time` ASC) USING BTREE,
  INDEX `fk_notice_publisher`(`publisher_id` ASC) USING BTREE,
  CONSTRAINT `fk_notice_publisher` FOREIGN KEY (`publisher_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, '2025年2月接种安排通知', '本月每周一至周五上午开放接种，请家长提前在系统预约，携带接种证与儿童到场。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2026-02-24 17:13:01', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (2, '流感疫苗接种提醒', '当前为流感高发季，建议6月龄以上儿童及时接种流感疫苗。', 'IMPORTANT', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-02 10:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (3, '一类疫苗缺货说明', '卡介苗近期到货，请需接种的家长关注预约开放时间。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-03 11:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (4, '留观须知', '接种后请在留观区观察30分钟，无异常后方可离开。', 'SYSTEM', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-04 09:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (5, '春节假期接种点开放时间', '除夕至初三休息，初四起正常开放。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-05 10:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (6, '儿童接种证补办流程', '遗失接种证可携带户口本到接种点补办。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-06 11:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (7, '鸡蛋过敏儿童接种须知', '鸡蛋过敏者部分疫苗需谨慎，请提前告知医生。', 'IMPORTANT', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-07 09:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (8, '不良反应上报渠道', '接种后如有不适可通过本系统上报或到接种点登记。', 'SYSTEM', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-08 10:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (9, '三月疫苗库存预告', '三月将到货百白破、麻腮风等疫苗，请关注预约。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-09 11:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (10, '接种点联系方式汇总', '各接种点地址与电话已更新，详见系统内接种点列表。', 'NORMAL', 1, 'ADMIN', NULL, NULL, 0, 1, '2025-02-10 09:00:00', NULL, 'NORMAL', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `notice` VALUES (11, '好奥i设计及', '12121211', 'NORMAL', 2, 'DOCTOR', 'APPROVED', NULL, 0, 0, '2026-02-12 19:18:47', NULL, 'NORMAL', '2026-02-12 19:18:22', '2026-02-12 19:18:22');
INSERT INTO `notice` VALUES (12, '123', '123', 'NORMAL', NULL, 'ADMIN', 'APPROVED', NULL, 0, 0, '2026-02-24 16:02:00', NULL, 'NORMAL', '2026-02-24 16:02:00', '2026-02-24 16:02:00');
INSERT INTO `notice` VALUES (13, 'nih你好', '测试一i', 'NORMAL', 2, 'DOCTOR', 'APPROVED', NULL, 0, 1, '2026-02-24 17:12:51', NULL, 'NORMAL', '2026-02-24 17:12:03', '2026-02-24 17:12:03');
INSERT INTO `notice` VALUES (14, '12122121fdfdf', 'yuutuy', 'NORMAL', NULL, 'ADMIN', 'APPROVED', NULL, 0, 1, '2026-02-24 17:13:20', NULL, 'NORMAL', '2026-02-24 17:13:20', '2026-02-24 17:13:20');
INSERT INTO `notice` VALUES (15, '1212adsad', 'ghmvh', 'NORMAL', 2, 'DOCTOR', 'REJECTED', '妮妮ininii', 0, 0, NULL, NULL, 'NORMAL', '2026-02-24 17:28:57', '2026-02-24 17:28:57');
INSERT INTO `notice` VALUES (16, '预约爽约警告', '您于2026-03-26的预约未按时核销，记爽约一次。请按时履约，累计爽约将影响预约资格。', 'SYSTEM', NULL, 'ADMIN', 'APPROVED', NULL, 0, 1, '2026-03-26 16:30:00', 4, 'WARNING', '2026-03-26 16:30:00', '2026-03-26 16:30:00');
INSERT INTO `notice` VALUES (17, '121212', '12121', 'NORMAL', 2, 'DOCTOR', 'PENDING', NULL, 0, 0, NULL, NULL, 'NORMAL', '2026-03-27 12:36:12', '2026-03-27 12:36:12');

-- ----------------------------
-- Table structure for notice_feedback
-- ----------------------------
DROP TABLE IF EXISTS `notice_feedback`;
CREATE TABLE `notice_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `user_id` bigint NOT NULL COMMENT '提交人（医生）ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '意见内容',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notice_id`(`notice_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_feedback_notice` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '公告意见表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice_feedback
-- ----------------------------
INSERT INTO `notice_feedback` VALUES (1, 10, 2, '测试测试', '2026-02-24 17:12:17');
INSERT INTO `notice_feedback` VALUES (2, 10, 2, 'bhjgjhjg', '2026-02-24 17:29:04');
INSERT INTO `notice_feedback` VALUES (3, 8, 2, 'gjhgjgjh', '2026-02-24 17:29:07');
INSERT INTO `notice_feedback` VALUES (4, 13, 2, '1212121', '2026-03-27 12:36:29');

-- ----------------------------
-- Table structure for pre_check_record
-- ----------------------------
DROP TABLE IF EXISTS `pre_check_record`;
CREATE TABLE `pre_check_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `appointment_id` bigint NOT NULL COMMENT '预约ID（唯一）',
  `temperature` decimal(4, 1) NULL DEFAULT NULL COMMENT '体温(℃)，如 36.5',
  `body_condition` tinyint NULL DEFAULT NULL COMMENT '身体状况：0-正常，1-异常',
  `body_condition_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '身体状况异常时的具体描述',
  `recent_medication` tinyint NULL DEFAULT NULL COMMENT '近期用药：0-否，1-是',
  `medication_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用药具体情况描述',
  `contraindication_check` tinyint NULL DEFAULT NULL COMMENT '禁忌症核对：0-不通过，1-通过',
  `parent_signature` tinyint NULL DEFAULT NULL COMMENT '家长签字确认：0-否，1-是',
  `source` tinyint NULL DEFAULT NULL COMMENT '填写方：1-医生填写，2-家长填写',
  `conclusion` tinyint NULL DEFAULT NULL COMMENT '预检结论：0-未通过，1-通过',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-待填写，1-已填写待确认，2-已完成',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注/不通过原因',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '预检医生ID（发起预检的医生）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '家长/医生提交时间',
  `timeout_status` tinyint NOT NULL DEFAULT 0 COMMENT '超时状态：0-未超时，1-已超时',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_appointment_id`(`appointment_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_timeout_status`(`timeout_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预检记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of pre_check_record
-- ----------------------------
INSERT INTO `pre_check_record` VALUES (1, 1, 36.5, 0, NULL, 0, NULL, 1, 1, 1, 1, 2, NULL, 2, '2026-03-23 20:12:28', '2026-03-23 20:12:28', 0);
INSERT INTO `pre_check_record` VALUES (2, 2, 36.8, 0, NULL, 0, NULL, 1, 1, 1, 1, 2, NULL, 2, '2026-03-23 20:12:28', '2026-03-23 20:12:28', 0);

-- ----------------------------
-- Table structure for pre_check_reminder_log
-- ----------------------------
DROP TABLE IF EXISTS `pre_check_reminder_log`;
CREATE TABLE `pre_check_reminder_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `appointment_id` bigint NOT NULL COMMENT '预约ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `child_id` bigint NOT NULL COMMENT '儿童ID',
  `reminder_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '提醒类型(FIRST/SECOND/FINAL)',
  `push_channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '推送渠道(APP/SMS/WECHAT)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '提醒内容',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态(0-待发送,1-发送成功,2-发送失败)',
  `push_time` datetime NULL DEFAULT NULL COMMENT '推送时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_appointment_id`(`appointment_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_child_id`(`child_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_push_time`(`push_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预检提醒推送日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of pre_check_reminder_log
-- ----------------------------
INSERT INTO `pre_check_reminder_log` VALUES (1, 1, 4, 1, 'SCHEDULE_72H', 'WECHAT', '您的疫苗预约即将到期，请及时完成预检', 1, '2026-03-23 20:11:56', '2026-03-23 20:11:56');
INSERT INTO `pre_check_reminder_log` VALUES (2, 2, 5, 2, 'SCHEDULE_72H', 'APP', '您的疫苗预约即将到期，请及时完成预检', 1, '2026-03-23 20:11:56', '2026-03-23 20:11:56');

-- ----------------------------
-- Table structure for precheck_timeout_log
-- ----------------------------
DROP TABLE IF EXISTS `precheck_timeout_log`;
CREATE TABLE `precheck_timeout_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `appointment_id` bigint NOT NULL COMMENT '预约ID',
  `pre_check_record_id` bigint NOT NULL COMMENT '预检记录ID',
  `timeout_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '超时时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_appointment_id`(`appointment_id` ASC) USING BTREE,
  INDEX `idx_pre_check_record_id`(`pre_check_record_id` ASC) USING BTREE,
  INDEX `idx_timeout_time`(`timeout_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预检超时日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of precheck_timeout_log
-- ----------------------------
INSERT INTO `precheck_timeout_log` VALUES (1, 1, 1, '2026-03-24 08:00:00', '2026-03-23 20:12:12');
INSERT INTO `precheck_timeout_log` VALUES (2, 2, 2, '2026-03-24 09:00:00', '2026-03-23 20:12:12');

-- ----------------------------
-- Table structure for record
-- ----------------------------
DROP TABLE IF EXISTS `record`;
CREATE TABLE `record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NULL DEFAULT NULL COMMENT '预约ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '家长ID',
  `child_id` bigint NULL DEFAULT NULL COMMENT '宝宝ID',
  `vaccine_id` bigint NULL DEFAULT NULL COMMENT '疫苗ID',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '医生ID',
  `site_id` bigint NULL DEFAULT NULL COMMENT '接种点ID',
  `vaccinate_time` datetime NULL DEFAULT NULL COMMENT '接种时间',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态：已接种/异常/取消',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_child_id`(`child_id` ASC) USING BTREE,
  INDEX `idx_vaccinate_time`(`vaccinate_time` ASC) USING BTREE,
  INDEX `idx_is_deleted`(`is_deleted` ASC) USING BTREE,
  INDEX `fk_record_vaccine_r`(`vaccine_id` ASC) USING BTREE,
  INDEX `fk_record_doctor_r`(`doctor_id` ASC) USING BTREE,
  INDEX `fk_record_site_r`(`site_id` ASC) USING BTREE,
  CONSTRAINT `fk_record_child_r` FOREIGN KEY (`child_id`) REFERENCES `child_profile` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_doctor_r` FOREIGN KEY (`doctor_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_order` FOREIGN KEY (`order_id`) REFERENCES `appointment` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_site_r` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_user_r` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_vaccine_r` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '简易接种记录表（统计与医生完成接种）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of record
-- ----------------------------
INSERT INTO `record` VALUES (1, 3, 4, NULL, 3, 2, 1, '2025-02-17 08:20:00', '已接种', '脊灰第二针', '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (2, 4, 4, NULL, 4, 2, 1, '2025-02-18 10:15:00', '已接种', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (3, 6, 5, 6, 2, 2, 1, '2025-02-20 09:10:00', '已接种', '卡介苗', '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (4, 7, 5, 7, 7, 3, 2, '2025-02-21 08:25:00', '已接种', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (5, 8, 5, 8, 1, 3, 2, '2025-02-22 10:05:00', '已接种', '乙肝第一针', '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (6, 10, 5, 10, 9, 3, 2, '2025-02-24 09:30:00', '已接种', NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (7, NULL, 4, 1, 1, 2, 1, '2025-01-10 09:00:00', '已接种', '补录', '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);
INSERT INTO `record` VALUES (8, NULL, 5, 9, 5, 3, 2, '2025-01-25 09:00:00', '异常', '轻微发热已观察', '2026-02-11 23:03:22', '2026-02-11 23:03:22', 0);

-- ----------------------------
-- Table structure for site_vaccine_stock
-- ----------------------------
DROP TABLE IF EXISTS `site_vaccine_stock`;
CREATE TABLE `site_vaccine_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `batch_id` bigint NOT NULL COMMENT '疫苗批次ID',
  `available_stock` int NOT NULL DEFAULT 0 COMMENT '可用库存（可被预约锁定）',
  `locked_stock` int NOT NULL DEFAULT 0 COMMENT '预约锁定库存（已预约未核销）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_site_batch`(`site_id` ASC, `batch_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  CONSTRAINT `fk_svs_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batch` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_svs_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '接种点库存（按批次，与总仓调拨联动）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of site_vaccine_stock
-- ----------------------------
INSERT INTO `site_vaccine_stock` VALUES (1, 1, 3, 0, 2, '2026-03-26 15:58:18', '2026-03-27 12:19:01');
INSERT INTO `site_vaccine_stock` VALUES (2, 1, 4, 0, 0, '2026-03-26 15:58:18', '2026-03-27 11:38:03');
INSERT INTO `site_vaccine_stock` VALUES (3, 1, 5, 0, 0, '2026-03-26 15:58:18', '2026-03-27 11:38:03');
INSERT INTO `site_vaccine_stock` VALUES (4, 1, 7, 0, 0, '2026-03-26 15:58:18', '2026-03-27 11:38:03');
INSERT INTO `site_vaccine_stock` VALUES (5, 1, 8, 0, 0, '2026-03-26 15:58:18', '2026-03-27 11:38:03');
INSERT INTO `site_vaccine_stock` VALUES (6, 2, 3, 0, 0, '2026-03-26 16:53:23', '2026-03-27 12:35:14');
INSERT INTO `site_vaccine_stock` VALUES (7, 2, 4, 0, 0, '2026-03-26 16:53:23', '2026-03-27 11:37:52');
INSERT INTO `site_vaccine_stock` VALUES (8, 2, 5, 0, 0, '2026-03-26 16:53:23', '2026-03-27 11:37:52');
INSERT INTO `site_vaccine_stock` VALUES (9, 2, 7, 0, 0, '2026-03-26 16:53:23', '2026-03-27 11:37:52');
INSERT INTO `site_vaccine_stock` VALUES (10, 2, 8, 0, 0, '2026-03-26 16:53:23', '2026-03-27 11:37:52');
INSERT INTO `site_vaccine_stock` VALUES (11, 2, 9, 0, 0, '2026-03-26 16:53:23', '2026-03-27 11:37:52');
INSERT INTO `site_vaccine_stock` VALUES (12, 1, 1, 30, 0, '2026-03-27 12:14:57', '2026-03-27 12:25:59');

-- ----------------------------
-- Table structure for stock_alert_log
-- ----------------------------
DROP TABLE IF EXISTS `stock_alert_log`;
CREATE TABLE `stock_alert_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `alert_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'LOW_STOCK-批次剩余率低，EXPIRY-效期临近',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `vaccine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗名称（冗余）',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `inventory_id` bigint NOT NULL COMMENT '批次库存ID',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '入库数量',
  `used_quantity` int NOT NULL DEFAULT 0 COMMENT '已使用数量',
  `remaining_ratio` decimal(5, 2) NULL DEFAULT NULL COMMENT '剩余率（如 8.50 表示 8.5%）',
  `expiry_date` date NULL DEFAULT NULL COMMENT '有效期至',
  `synced_to_supplier` tinyint NOT NULL DEFAULT 0 COMMENT '是否已同步供应商：0-否，1-是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_alert_type`(`alert_type` ASC) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_inventory_id`(`inventory_id` ASC) USING BTREE,
  INDEX `idx_synced`(`synced_to_supplier` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '库存/效期预警与补货提醒记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of stock_alert_log
-- ----------------------------
INSERT INTO `stock_alert_log` VALUES (1, 'LOW_STOCK', 5, '麻腮风疫苗', 1, 5, 'MMR202501001', 70, 65, 7.14, '2026-02-01', 1, '2025-02-01 10:00:00');
INSERT INTO `stock_alert_log` VALUES (2, 'LOW_STOCK', 9, '肺炎球菌疫苗', 2, 9, 'PCV202502001', 40, 36, 10.00, '2026-08-01', 1, '2025-02-03 11:00:00');
INSERT INTO `stock_alert_log` VALUES (3, 'EXPIRY', 6, '流感疫苗', 2, 6, 'FLU202502001', 60, 10, 83.33, '2025-08-01', 1, '2025-02-05 09:00:00');
INSERT INTO `stock_alert_log` VALUES (4, 'EXPIRY', 2, '卡介苗', 1, 2, 'BCG202501001', 80, 5, 93.75, '2026-03-01', 1, '2025-02-07 14:00:00');
INSERT INTO `stock_alert_log` VALUES (5, 'LOW_STOCK', 4, '百白破疫苗', 1, 4, 'DPT202501001', 90, 82, 8.89, '2026-04-01', 1, '2025-02-09 08:00:00');
INSERT INTO `stock_alert_log` VALUES (6, 'EXPIRY', 2, '卡介苗', 1, 2, 'BCG202501001', 80, 0, 100.00, '2026-03-01', 1, '2026-02-12 08:00:00');

-- ----------------------------
-- Table structure for stock_transfer_log
-- ----------------------------
DROP TABLE IF EXISTS `stock_transfer_log`;
CREATE TABLE `stock_transfer_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `from_type` tinyint NOT NULL COMMENT '调出方类型：0-总仓 1-接种点',
  `from_id` bigint NULL DEFAULT NULL COMMENT '调出方ID（总仓时为NULL，接种点时为 site_id）',
  `to_type` tinyint NOT NULL COMMENT '调入方类型：0-总仓 1-接种点',
  `to_id` bigint NULL DEFAULT NULL COMMENT '调入方ID（总仓时为NULL，接种点时为 site_id）',
  `quantity` int NOT NULL COMMENT '调拨数量',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人用户ID',
  `transfer_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调拨时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  INDEX `idx_from`(`from_type` ASC, `from_id` ASC) USING BTREE,
  INDEX `idx_to`(`to_type` ASC, `to_id` ASC) USING BTREE,
  INDEX `idx_transfer_time`(`transfer_time` ASC) USING BTREE,
  CONSTRAINT `fk_stl_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batch` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '库存调拨日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of stock_transfer_log
-- ----------------------------
INSERT INTO `stock_transfer_log` VALUES (1, 3, 0, NULL, 1, 1, 10, NULL, '2026-03-26 15:58:18');
INSERT INTO `stock_transfer_log` VALUES (2, 4, 0, NULL, 1, 1, 10, NULL, '2026-03-26 15:58:18');
INSERT INTO `stock_transfer_log` VALUES (3, 5, 0, NULL, 1, 1, 10, NULL, '2026-03-26 15:58:18');
INSERT INTO `stock_transfer_log` VALUES (4, 7, 0, NULL, 1, 1, 10, NULL, '2026-03-26 15:58:18');
INSERT INTO `stock_transfer_log` VALUES (5, 8, 0, NULL, 1, 1, 10, NULL, '2026-03-26 15:58:18');
INSERT INTO `stock_transfer_log` VALUES (6, 3, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (7, 4, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (8, 5, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (9, 7, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (10, 8, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (11, 9, 0, NULL, 1, 2, 10, NULL, '2026-03-26 16:53:24');
INSERT INTO `stock_transfer_log` VALUES (12, 3, 1, 2, 0, NULL, 9, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (13, 4, 1, 2, 0, NULL, 10, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (14, 5, 1, 2, 0, NULL, 10, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (15, 7, 1, 2, 0, NULL, 10, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (16, 8, 1, 2, 0, NULL, 10, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (17, 9, 1, 2, 0, NULL, 10, NULL, '2026-03-27 11:37:53');
INSERT INTO `stock_transfer_log` VALUES (18, 3, 1, 1, 0, NULL, 6, NULL, '2026-03-27 11:38:04');
INSERT INTO `stock_transfer_log` VALUES (19, 4, 1, 1, 0, NULL, 10, NULL, '2026-03-27 11:38:04');
INSERT INTO `stock_transfer_log` VALUES (20, 5, 1, 1, 0, NULL, 10, NULL, '2026-03-27 11:38:04');
INSERT INTO `stock_transfer_log` VALUES (21, 7, 1, 1, 0, NULL, 10, NULL, '2026-03-27 11:38:04');
INSERT INTO `stock_transfer_log` VALUES (22, 8, 1, 1, 0, NULL, 10, NULL, '2026-03-27 11:38:04');
INSERT INTO `stock_transfer_log` VALUES (23, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (24, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (25, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (26, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (27, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (28, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:14:58');
INSERT INTO `stock_transfer_log` VALUES (29, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:15:10');
INSERT INTO `stock_transfer_log` VALUES (30, 1, 0, NULL, 1, 1, 10, NULL, '2026-03-27 12:24:34');
INSERT INTO `stock_transfer_log` VALUES (31, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:24:34');
INSERT INTO `stock_transfer_log` VALUES (32, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:24:34');
INSERT INTO `stock_transfer_log` VALUES (33, 1, 0, NULL, 1, 1, 1, NULL, '2026-03-27 12:24:34');
INSERT INTO `stock_transfer_log` VALUES (34, 1, 0, NULL, 1, 1, 10, NULL, '2026-03-27 12:26:00');

-- ----------------------------
-- Table structure for supplier_sync_log
-- ----------------------------
DROP TABLE IF EXISTS `supplier_sync_log`;
CREATE TABLE `supplier_sync_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `stock_alert_log_id` bigint NOT NULL COMMENT '关联 stock_alert_log.id',
  `supplier_endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商接口地址',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求体（JSON）',
  `response_code` int NULL DEFAULT NULL COMMENT 'HTTP 状态码',
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '响应体',
  `sync_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_stock_alert_log_id`(`stock_alert_log_id` ASC) USING BTREE,
  INDEX `idx_sync_time`(`sync_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '供应商同步记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of supplier_sync_log
-- ----------------------------
INSERT INTO `supplier_sync_log` VALUES (1, 1, 'https://api.supplier.example.com/alert', '{\"vaccine\":\"麻腮风疫苗\",\"batch\":\"MMR202501001\",\"remaining_ratio\":7.14}', 200, '{\"code\":0,\"msg\":\"已记录补货需求\"}', '2025-02-01 10:05:00');
INSERT INTO `supplier_sync_log` VALUES (2, 2, 'https://api.supplier.example.com/alert', '{\"vaccine\":\"肺炎球菌疫苗\",\"batch\":\"PCV202502001\",\"remaining_ratio\":10}', 200, '{\"code\":0,\"msg\":\"已记录补货需求\"}', '2025-02-03 11:10:00');
INSERT INTO `supplier_sync_log` VALUES (3, 5, 'https://api.supplier.example.com/alert', '{\"vaccine\":\"百白破疫苗\",\"batch\":\"DPT202501001\",\"remaining_ratio\":8.89}', 200, '{\"code\":0,\"msg\":\"已记录补货需求\"}', '2025-02-09 08:15:00');
INSERT INTO `supplier_sync_log` VALUES (4, 3, '', '{\"alertId\":3}', 0, 'supplier URL not configured, log only', '2026-02-12 08:00:00');
INSERT INTO `supplier_sync_log` VALUES (5, 4, '', '{\"alertId\":4}', 0, 'supplier URL not configured, log only', '2026-02-12 08:00:00');
INSERT INTO `supplier_sync_log` VALUES (6, 6, '', '{\"alertId\":6}', 0, 'supplier URL not configured, log only', '2026-02-12 08:00:00');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（明文存储）',
  `real_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色：ADMIN-管理员，DOCTOR-医生，RESIDENT-居民/家长',
  `gender` tinyint NULL DEFAULT NULL COMMENT '性别：0-未知，1-男，2-女',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '身份证号',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '常住地址',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-正常，1-已禁用，2-已注销（不可恢复）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `reservation_ban_until` datetime NULL DEFAULT NULL COMMENT '预约禁约截止时间：爽约超3次当日逾期未核销则30日内不可预约',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_id_card`(`id_card` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_last_login_time`(`last_login_time` ASC) USING BTREE,
  INDEX `idx_is_deleted`(`is_deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '123456', '系统管理员', 'ADMIN', 1, '13800000001', NULL, '天津市南开区', NULL, 0, '2026-02-11 23:03:22', '2026-03-27 12:37:15', '2026-03-27 12:37:16', NULL, 0);
INSERT INTO `sys_user` VALUES (2, 'doctor01', '123456', '张医生', 'DOCTOR', 2, '13800000002', NULL, '天津市南开区', NULL, 0, '2026-02-11 23:03:22', '2026-03-27 12:34:33', '2026-03-27 12:34:33', NULL, 0);
INSERT INTO `sys_user` VALUES (3, 'doctor02', '123456', '马医生', 'DOCTOR', 1, '13800000003', NULL, '天津市南开区', NULL, 0, '2026-02-11 23:03:22', '2026-03-27 10:43:34', NULL, NULL, 0);
INSERT INTO `sys_user` VALUES (4, 'parent01', '123456', '李家长', 'RESIDENT', 1, '13800000004', NULL, '天津市南开区某某小区', NULL, 0, '2026-02-11 23:03:22', '2026-03-27 12:31:44', '2026-03-27 12:31:45', NULL, 0);
INSERT INTO `sys_user` VALUES (5, 'parent02', '123456', '赵家长', 'RESIDENT', 2, '13800000005', NULL, '天津市南开区某某街道', NULL, 0, '2026-02-11 23:03:22', '2026-03-27 12:19:26', '2026-03-27 12:19:27', NULL, 0);
INSERT INTO `sys_user` VALUES (6, 'doctor03', '123456', '刘医生', 'DOCTOR', NULL, NULL, NULL, NULL, NULL, 0, '2026-02-12 00:10:21', '2026-03-27 10:43:34', '2026-02-12 08:31:25', NULL, 0);
INSERT INTO `sys_user` VALUES (7, 'doctor04', '123456', '王医生', 'DOCTOR', NULL, '123', NULL, '123', NULL, 0, '2026-02-12 07:55:23', '2026-03-26 16:00:46', '2026-03-26 16:00:47', NULL, 0);

-- ----------------------------
-- Table structure for user_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `user_notice_read`;
CREATE TABLE `user_notice_read`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `read_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_notice`(`user_id` ASC, `notice_id` ASC) USING BTREE,
  INDEX `idx_notice_id`(`notice_id` ASC) USING BTREE,
  CONSTRAINT `fk_read_notice` FOREIGN KEY (`notice_id`) REFERENCES `notice` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_read_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户公告已读表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_notice_read
-- ----------------------------
INSERT INTO `user_notice_read` VALUES (1, 1, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (2, 1, 2, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (3, 2, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (4, 2, 3, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (5, 3, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (6, 3, 4, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (7, 4, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (8, 4, 2, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (9, 4, 5, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `user_notice_read` VALUES (10, 5, 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for vaccination_record
-- ----------------------------
DROP TABLE IF EXISTS `vaccination_record`;
CREATE TABLE `vaccination_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `child_id` bigint NULL DEFAULT NULL COMMENT '接种儿童档案ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '家长/居民ID',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `appointment_id` bigint NULL DEFAULT NULL COMMENT '关联预约ID',
  `inventory_id` bigint NULL DEFAULT NULL COMMENT '使用的库存批次ID',
  `batch_id` bigint NULL DEFAULT NULL COMMENT '接种使用批次ID',
  `vaccine_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗编号，核销时自动生成，不可修改',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗批号',
  `dose_number` int NOT NULL DEFAULT 1 COMMENT '第几针/剂次',
  `vaccination_date` datetime NOT NULL COMMENT '实际接种时间',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '接种医生ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `injection_site` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '接种部位',
  `observation_ok` tinyint NULL DEFAULT NULL COMMENT '留观无异常：0-否，1-是',
  `reaction` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '不良反应简要记录',
  `next_dose_date` date NULL DEFAULT NULL COMMENT '下次接种日期',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_vaccine_code`(`vaccine_code` ASC) USING BTREE,
  INDEX `idx_child_id`(`child_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_appointment_id`(`appointment_id` ASC) USING BTREE,
  INDEX `idx_inventory_id`(`inventory_id` ASC) USING BTREE,
  INDEX `idx_vaccination_date`(`vaccination_date` ASC) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  CONSTRAINT `fk_record_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointment` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batch` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_child` FOREIGN KEY (`child_id`) REFERENCES `child_profile` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `vaccine_inventory` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_record_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '接种记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccination_record
-- ----------------------------
INSERT INTO `vaccination_record` VALUES (1, NULL, 4, 3, 3, 3, NULL, NULL, 'PV202501001', 2, '2025-02-17 08:20:00', 2, 1, '左上臂', 1, NULL, '2025-03-17', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (2, NULL, 4, 4, 4, 4, NULL, NULL, 'DPT202501001', 1, '2025-02-18 10:15:00', 2, 1, '左上臂', 1, NULL, '2025-03-18', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (3, 6, 5, 2, 6, 2, NULL, NULL, 'BCG202501001', 1, '2025-02-20 09:10:00', 2, 1, '左上臂', 1, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (4, 7, 5, 7, 7, 7, NULL, NULL, 'VAR202502001', 1, '2025-02-21 08:25:00', 3, 2, '左上臂', 1, NULL, '2025-05-21', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (5, 8, 5, 1, 8, 1, NULL, NULL, 'HBV202501001', 1, '2025-02-22 10:05:00', 3, 2, '左上臂', 1, NULL, '2025-03-24', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (6, 10, 5, 9, 10, 9, NULL, NULL, 'PCV202502001', 1, '2025-02-24 09:30:00', 3, 2, '左上臂', 1, NULL, '2025-04-25', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (7, 1, 4, 1, NULL, 1, NULL, NULL, 'HBV202501001', 1, '2025-01-10 09:00:00', 2, 1, '左上臂', 1, NULL, '2025-02-09', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (8, 2, 4, 6, NULL, 6, NULL, NULL, 'FLU202502001', 1, '2025-01-15 10:00:00', 2, 2, '左上臂', 1, NULL, NULL, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (9, NULL, 4, 3, NULL, 3, NULL, NULL, 'PV202501001', 1, '2025-01-20 08:30:00', 2, 1, '左上臂', 1, NULL, '2025-02-17', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (10, 9, 5, 5, NULL, 5, NULL, NULL, 'MMR202501001', 1, '2025-01-25 09:00:00', 3, 2, '左上臂', 1, '轻微发热', '2026-01-25', '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_record` VALUES (11, 1, 4, 1, 1, NULL, NULL, NULL, '12121', 1, '2026-02-11 23:27:40', 2, 1, '12121', 1, NULL, '2026-03-13', '2026-02-11 23:27:39', '2026-02-11 23:27:39');
INSERT INTO `vaccination_record` VALUES (12, 2, 4, 6, 2, NULL, NULL, NULL, '1212', 1, '2026-02-11 23:52:24', 2, 1, '1212', 1, '121', NULL, '2026-02-11 23:52:23', '2026-02-11 23:52:23');
INSERT INTO `vaccination_record` VALUES (13, NULL, 4, 1, 12, NULL, NULL, NULL, '123456', 1, '2026-02-12 07:59:37', 6, 1, '1234', 1, NULL, '2026-03-14', '2026-02-12 07:59:36', '2026-02-12 07:59:36');
INSERT INTO `vaccination_record` VALUES (14, 1, 4, 3, 15, NULL, NULL, NULL, '12345', 1, '2026-02-24 10:01:30', 7, 1, '123', 1, '123', '2026-03-24', '2026-02-24 10:01:30', '2026-02-24 10:01:30');
INSERT INTO `vaccination_record` VALUES (15, 1, 4, 2, 17, NULL, NULL, NULL, '12212', 1, '2026-02-25 15:34:43', 2, 1, '12121', 1, '12121212', NULL, '2026-02-25 15:34:42', '2026-02-25 15:34:42');
INSERT INTO `vaccination_record` VALUES (16, 2, 4, 2, 19, NULL, 3, 'V2-20260326-502001-0001', 'BCG202502001', 1, '2026-03-26 16:02:28', 2, 1, '1212', 1, NULL, NULL, '2026-03-26 16:02:27', '2026-03-26 16:02:27');
INSERT INTO `vaccination_record` VALUES (17, 2, 4, 2, 23, NULL, 3, 'V2-20260327-502001-0001', 'BCG202502001', 1, '2026-03-27 12:19:02', 2, 1, '12121', 1, '1212', NULL, '2026-03-27 12:19:01', '2026-03-27 12:19:01');
INSERT INTO `vaccination_record` VALUES (18, 7, 5, 2, 24, NULL, 3, 'V2-20260327-502001-0002', 'BCG202502001', 1, '2026-03-27 12:35:14', 2, 2, '1221', 1, NULL, NULL, '2026-03-27 12:35:14', '2026-03-27 12:35:14');

-- ----------------------------
-- Table structure for vaccination_reminder_log
-- ----------------------------
DROP TABLE IF EXISTS `vaccination_reminder_log`;
CREATE TABLE `vaccination_reminder_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `child_id` bigint NOT NULL COMMENT '儿童档案ID',
  `user_id` bigint NOT NULL COMMENT '家长用户ID',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `vaccine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗名称',
  `dose_number` int NOT NULL COMMENT '待接种剂次',
  `remind_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SCHEDULE_72H' COMMENT 'SCHEDULE_72H-提前72小时预约提醒',
  `appointment_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预约链接',
  `push_channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'WECHAT' COMMENT 'WECHAT/APP/SMS',
  `push_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '推送时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_child_id`(`child_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_push_time`(`push_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能提醒推送记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccination_reminder_log
-- ----------------------------
INSERT INTO `vaccination_reminder_log` VALUES (1, 1, 4, 1, '乙肝疫苗', 2, 'SCHEDULE_72H', '/appointment?vaccine=1', 'WECHAT', '2025-02-12 09:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (2, 2, 4, 6, '流感疫苗', 1, 'SCHEDULE_72H', '/appointment?vaccine=6', 'APP', '2025-02-13 10:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (3, 1, 4, 3, '脊灰疫苗', 2, 'SCHEDULE_72H', '/appointment?vaccine=3', 'WECHAT', '2025-02-14 08:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (4, 6, 5, 2, '卡介苗', 1, 'SCHEDULE_72H', '/appointment?vaccine=2', 'WECHAT', '2025-02-17 09:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (5, 7, 5, 7, '水痘疫苗', 1, 'SCHEDULE_72H', '/appointment?vaccine=7', 'SMS', '2025-02-18 10:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (6, 8, 5, 1, '乙肝疫苗', 1, 'SCHEDULE_72H', '/appointment?vaccine=1', 'WECHAT', '2025-02-19 08:00:00', '2026-02-11 23:03:22');
INSERT INTO `vaccination_reminder_log` VALUES (7, 10, 5, 9, '肺炎球菌疫苗', 1, 'SCHEDULE_72H', '/appointment?vaccine=9', 'APP', '2025-02-21 09:00:00', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for vaccination_site
-- ----------------------------
DROP TABLE IF EXISTS `vaccination_site`;
CREATE TABLE `vaccination_site`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `site_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接种点名称',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地址',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `work_time` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `current_doctor_id` bigint NULL DEFAULT NULL COMMENT '当前驻场医生用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_current_doctor_id`(`current_doctor_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '接种点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccination_site
-- ----------------------------
INSERT INTO `vaccination_site` VALUES (1, '南开区社区卫生服务中心', '天津市南开区XX路100号', '022-12345678', '周一至周五 8:00-11:30 14:00-17:00', 1, NULL, 6, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_site` VALUES (2, '南开区妇幼保健院接种点', '天津市南开区YY大道200号', '022-87654321', '周一至周六 8:00-11:00', 1, NULL, 3, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_site` VALUES (3, '南开区第一接种点', '天津市南开区AA街1号', '022-11111111', '周一至周五 8:00-11:00', 0, NULL, 7, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccination_site` VALUES (4, '南开区第二接种点', '天津市南开区BB街2号', '022-22222222', '周一至周五 8:00-11:00', 1, NULL, 7, '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for vaccine
-- ----------------------------
DROP TABLE IF EXISTS `vaccine`;
CREATE TABLE `vaccine`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vaccine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '疫苗名称',
  `short_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗简称，用于疫苗编号生成，如 DTP、HBV',
  `category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CLASS_II' COMMENT '类别：CLASS_I-一类，CLASS_II-二类',
  `manufacturer` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产厂家',
  `vaccine_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '疫苗类型',
  `total_doses` int NOT NULL DEFAULT 1 COMMENT '总剂次',
  `interval_days` int NULL DEFAULT NULL COMMENT '剂次间隔天数',
  `applicable_age_months` int NULL DEFAULT NULL COMMENT '适用起始月龄',
  `dosage_desc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '剂型/规格说明',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '疫苗说明、注意事项',
  `adverse_reaction_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '不良反应说明',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-下架，1-上架',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_vaccine_name`(`vaccine_name` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_short_code`(`short_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '疫苗信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine
-- ----------------------------
INSERT INTO `vaccine` VALUES (1, '乙肝疫苗', NULL, 'CLASS_I', '北京生物', '重组酵母', 3, 30, 0, '0.5ml/支', '预防乙型肝炎。', '偶见发热、局部红肿，一般可自行缓解。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (2, '卡介苗', NULL, 'CLASS_I', '上海生物', '减毒活疫苗', 1, NULL, 0, '0.1ml/支', '预防结核病。', '局部红肿、化脓属正常反应。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (3, '脊灰疫苗', NULL, 'CLASS_I', '北京生物', '灭活疫苗', 4, 28, 2, '0.5ml/支', '预防脊髓灰质炎。', '少数发热、食欲减退。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (4, '百白破疫苗', NULL, 'CLASS_I', '武汉生物', '联合疫苗', 4, 28, 3, '0.5ml/支', '预防百日咳、白喉、破伤风。', '局部红肿、发热较常见。', 1, '2026-02-11 23:03:22', '2026-02-24 15:57:10');
INSERT INTO `vaccine` VALUES (5, '麻腮风疫苗', NULL, 'CLASS_I', '北京生物', '减毒活疫苗', 2, 365, 8, '0.5ml/支', '预防麻疹、流行性腮腺炎、风疹。', '少数发热、皮疹。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (6, '流感疫苗', NULL, 'CLASS_II', '华兰生物', '灭活疫苗', 1, NULL, 6, '0.5ml/支', '预防流行性感冒。', '少数发热、乏力，鸡蛋过敏者禁用。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (7, '水痘疫苗', NULL, 'CLASS_II', '长春百克', '减毒活疫苗', 2, 90, 12, '0.5ml/支', '预防水痘。', '偶见发热、局部红肿。', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (8, '手足口疫苗', NULL, 'CLASS_II', '北京科兴', '灭活疫苗', 2, 28, 6, '0.5ml/支', '预防EV71引起的手足口病。', '少数发热、局部反应。', 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (9, '肺炎球菌疫苗', NULL, 'CLASS_II', '辉瑞', '多糖结合疫苗', 4, 60, 2, '0.5ml/支', '预防肺炎球菌感染。', '发热、局部红肿较常见。', 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine` VALUES (10, '轮状病毒疫苗', NULL, 'CLASS_II', '兰州生物', '减毒活疫苗', 3, 28, 2, '1.5ml/支', '预防轮状病毒肠炎。', '偶见发热、腹泻。', 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for vaccine_batch
-- ----------------------------
DROP TABLE IF EXISTS `vaccine_batch`;
CREATE TABLE `vaccine_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '批号',
  `production_date` date NULL DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date NOT NULL COMMENT '有效期至',
  `stock` int NOT NULL DEFAULT 0 COMMENT '可用库存',
  `warning_days` int NOT NULL DEFAULT 30 COMMENT '临期预警天数',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '0正常 1临期 2过期 3已销毁',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_expiry_date`(`expiry_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_fefo`(`vaccine_id` ASC, `stock` ASC, `expiry_date` ASC) USING BTREE,
  CONSTRAINT `fk_batch_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '疫苗批次表（FEFO 分配）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine_batch
-- ----------------------------
INSERT INTO `vaccine_batch` VALUES (1, 1, 'HBV202501001', '2025-01-10', '2027-01-10', 70, 30, 0, '2026-03-26 15:56:09', '2026-03-27 12:25:59');
INSERT INTO `vaccine_batch` VALUES (2, 1, 'HBV202506002', '2025-06-01', '2027-06-01', 80, 30, 0, '2026-03-26 15:56:09', '2026-03-26 15:56:09');
INSERT INTO `vaccine_batch` VALUES (3, 2, 'BCG202502001', '2025-02-15', '2026-08-15', 45, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:38:03');
INSERT INTO `vaccine_batch` VALUES (4, 3, 'IPV202503001', '2025-03-01', '2027-03-01', 120, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:38:03');
INSERT INTO `vaccine_batch` VALUES (5, 4, 'DTP202504001', '2025-04-10', '2027-04-10', 90, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:38:03');
INSERT INTO `vaccine_batch` VALUES (6, 4, 'DTP202508002', '2025-08-01', '2027-08-01', 60, 30, 0, '2026-03-26 15:56:09', '2026-03-26 15:56:09');
INSERT INTO `vaccine_batch` VALUES (7, 5, 'MMR202505001', '2025-05-20', '2027-05-20', 70, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:38:03');
INSERT INTO `vaccine_batch` VALUES (8, 6, 'FLU202509001', '2025-09-01', '2026-09-01', 200, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:38:03');
INSERT INTO `vaccine_batch` VALUES (9, 7, 'VAR202506001', '2025-06-15', '2027-06-15', 40, 30, 0, '2026-03-26 15:56:09', '2026-03-27 11:37:52');
INSERT INTO `vaccine_batch` VALUES (10, 10, 'ROT202507001', '2025-07-01', '2026-07-01', 85, 30, 0, '2026-03-26 15:56:09', '2026-03-26 15:56:09');
INSERT INTO `vaccine_batch` VALUES (11, 2, '卡介苗20260327001', '2026-03-27', '2026-09-22', 100, 30, 0, '2026-03-26 21:13:04', '2026-03-26 21:13:04');
INSERT INTO `vaccine_batch` VALUES (12, 4, '百白破20260312001', '2026-03-12', '2026-03-31', 200, 30, 0, '2026-03-27 12:27:14', '2026-03-27 12:27:14');
INSERT INTO `vaccine_batch` VALUES (13, 1, '乙肝疫20260327001', '2026-03-27', '2026-04-07', 100, 30, 0, '2026-03-27 12:44:33', '2026-03-27 12:44:33');

-- ----------------------------
-- Table structure for vaccine_batch_disposal
-- ----------------------------
DROP TABLE IF EXISTS `vaccine_batch_disposal`;
CREATE TABLE `vaccine_batch_disposal`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `disposal_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '销毁原因',
  `disposal_date` date NOT NULL COMMENT '销毁日期',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  INDEX `fk_disposal_operator`(`operator_id` ASC) USING BTREE,
  CONSTRAINT `fk_disposal_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batch` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_disposal_operator` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '批次销毁记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine_batch_disposal
-- ----------------------------

-- ----------------------------
-- Table structure for vaccine_inventory
-- ----------------------------
DROP TABLE IF EXISTS `vaccine_inventory`;
CREATE TABLE `vaccine_inventory`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '批次号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '入库数量',
  `used_quantity` int NOT NULL DEFAULT 0 COMMENT '已使用数量',
  `expiry_date` date NOT NULL COMMENT '有效期至',
  `storage_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '存放位置',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-停用，1-有效',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_batch_no`(`batch_no` ASC) USING BTREE,
  INDEX `idx_expiry_date`(`expiry_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_inventory_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_inventory_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '疫苗库存表（按批次）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine_inventory
-- ----------------------------
INSERT INTO `vaccine_inventory` VALUES (1, 1, 1, 'HBV202501001', 100, 0, '2026-06-01', 'A区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (2, 2, 1, 'BCG202501001', 80, 0, '2026-03-01', 'A区2号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (3, 3, 1, 'PV202501001', 120, 0, '2026-05-01', 'A区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (4, 4, 1, 'DPT202501001', 90, 0, '2026-04-01', 'A区2号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (5, 5, 1, 'MMR202501001', 70, 0, '2026-02-01', 'A区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (6, 6, 2, 'FLU202502001', 60, 0, '2025-08-01', 'B区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (7, 7, 2, 'VAR202502001', 50, 0, '2026-07-01', 'B区2号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (8, 8, 2, 'EV71202502001', 80, 0, '2026-06-01', 'B区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (9, 9, 2, 'PCV202502001', 40, 0, '2026-08-01', 'B区2号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_inventory` VALUES (10, 10, 2, 'ROT202502001', 55, 0, '2026-04-01', 'B区1号冰箱', 1, '2026-02-11 23:03:22', '2026-02-11 23:03:22');

-- ----------------------------
-- Table structure for vaccine_rule
-- ----------------------------
DROP TABLE IF EXISTS `vaccine_rule`;
CREATE TABLE `vaccine_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rule_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则代码',
  `rule_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则名称',
  `rule_group` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则组',
  `priority` int NULL DEFAULT 0 COMMENT '优先级',
  `enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `params` json NULL COMMENT '规则参数',
  `error_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误代码',
  `error_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误消息',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `rule_code`(`rule_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine_rule
-- ----------------------------
INSERT INTO `vaccine_rule` VALUES (1, 'AGE_LIMIT_DTP', '百白破疫苗年龄限制', 'AGE_LIMIT', 1, 1, '{\"maxAgeMonths\": 72, \"minAgeMonths\": 3}', 'AGE_OUT_OF_RANGE', '该疫苗适用于3个月至6岁儿童', '2024-01-01 00:00:00', '2024-01-01 00:00:00', 0);
INSERT INTO `vaccine_rule` VALUES (2, 'INTERVAL_HBV', '乙肝疫苗接种间隔', 'INTERVAL', 1, 1, '{\"minIntervalDays\": 28}', 'INTERVAL_TOO_SHORT', '乙肝疫苗两针之间至少间隔28天', '2024-01-01 00:00:00', '2024-01-01 00:00:00', 0);
INSERT INTO `vaccine_rule` VALUES (3, 'CONTRAINDICATION_FLU', '流感疫苗禁忌症检查', 'CONTRAINDICATION', 1, 1, '{\"allergies\": [\"鸡蛋\"]}', 'CONTRAINDICATION_DETECTED', '对鸡蛋过敏者禁止接种流感疫苗', '2024-01-01 00:00:00', '2024-01-01 00:00:00', 0);

-- ----------------------------
-- Table structure for vaccine_site_stock
-- ----------------------------
DROP TABLE IF EXISTS `vaccine_site_stock`;
CREATE TABLE `vaccine_site_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vaccine_id` bigint NOT NULL COMMENT '疫苗ID',
  `site_id` bigint NOT NULL COMMENT '接种点ID',
  `stock` int NOT NULL DEFAULT 0 COMMENT '当前可用库存',
  `warning_threshold` int NOT NULL DEFAULT 10 COMMENT '库存预警阈值',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_vaccine_site`(`vaccine_id` ASC, `site_id` ASC) USING BTREE,
  INDEX `idx_vaccine_id`(`vaccine_id` ASC) USING BTREE,
  INDEX `idx_site_id`(`site_id` ASC) USING BTREE,
  INDEX `idx_stock`(`stock` ASC) USING BTREE,
  CONSTRAINT `fk_stock_site` FOREIGN KEY (`site_id`) REFERENCES `vaccination_site` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_stock_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccine` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '疫苗按接种点库存（乐观锁）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of vaccine_site_stock
-- ----------------------------
INSERT INTO `vaccine_site_stock` VALUES (2, 2, 1, 31, 10, 0, '2026-02-11 23:03:22', '2026-02-25 15:34:42');
INSERT INTO `vaccine_site_stock` VALUES (3, 3, 1, 39, 10, 0, '2026-02-11 23:03:22', '2026-02-24 10:01:30');
INSERT INTO `vaccine_site_stock` VALUES (4, 4, 1, 35, 10, 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_site_stock` VALUES (5, 5, 1, 25, 10, 0, '2026-02-11 23:03:22', '2026-02-12 19:13:43');
INSERT INTO `vaccine_site_stock` VALUES (6, 6, 1, 60, 10, 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_site_stock` VALUES (7, 7, 1, 45, 10, 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_site_stock` VALUES (8, 8, 1, 50, 10, 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_site_stock` VALUES (9, 9, 1, 33, 10, 0, '2026-02-11 23:03:22', '2026-02-24 15:59:14');
INSERT INTO `vaccine_site_stock` VALUES (10, 10, 1, 40, 10, 0, '2026-02-11 23:03:22', '2026-02-11 23:03:22');
INSERT INTO `vaccine_site_stock` VALUES (11, 1, 4, 10, 10, 1, '2026-02-12 19:12:50', '2026-02-12 19:13:12');
INSERT INTO `vaccine_site_stock` VALUES (12, 4, 4, 10, 10, 0, '2026-02-12 19:12:59', '2026-02-12 19:12:59');
INSERT INTO `vaccine_site_stock` VALUES (13, 1, 1, 25, 10, 1, '2026-02-24 09:34:34', '2026-02-24 17:41:44');
INSERT INTO `vaccine_site_stock` VALUES (14, 1, 2, 10, 10, 0, '2026-02-24 11:06:31', '2026-02-24 11:06:31');
INSERT INTO `vaccine_site_stock` VALUES (15, 2, 2, 10, 10, 0, '2026-02-24 11:06:35', '2026-02-24 11:06:35');
INSERT INTO `vaccine_site_stock` VALUES (16, 7, 2, 10, 10, 0, '2026-02-24 11:06:38', '2026-02-24 11:06:38');
INSERT INTO `vaccine_site_stock` VALUES (17, 5, 2, 10, 10, 0, '2026-02-24 11:06:41', '2026-02-24 11:06:41');
INSERT INTO `vaccine_site_stock` VALUES (18, 9, 4, 21, 10, 0, '2026-02-24 15:59:37', '2026-02-24 15:59:44');

SET FOREIGN_KEY_CHECKS = 1;
