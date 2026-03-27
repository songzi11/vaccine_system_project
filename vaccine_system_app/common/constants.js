/**
 * 与后端枚举一致的常量（预约状态等），便于前后端统一
 * 后端：AppointmentStatusEnum（1已预约 6已签到 7预检通过 9预检未通过 10留观中 2已完成 3已取消 4已过期）
 */

/** 预约状态 code -> 文案（与后端 AppointmentStatusEnum 一致） */
export const APPOINTMENT_STATUS = {
	1: '已预约',
	2: '已完成',
	3: '已取消',
	4: '已过期',
	6: '已签到',
	7: '预检通过',
	9: '预检未通过',
	10: '留观中'
}

/**
 * 取预约状态文案：优先用后端返回的 statusLabel，否则用 code 查表
 * @param {number} status - 状态码
 * @param {string} [statusLabel] - 后端返回的状态文案（可选）
 * @returns {string}
 */
export function getAppointmentStatusText(status, statusLabel) {
	if (statusLabel != null && statusLabel !== '') return statusLabel
	if (APPOINTMENT_STATUS[status] != null) return APPOINTMENT_STATUS[status]
	return status != null ? String(status) : ''
}

/** 可取消预约的状态码（1已预约 6已签到 7预检通过 9预检未通过 10留观中） */
export const APPOINTMENT_CAN_CANCEL = [1, 6, 7, 9, 10]

/** 待接种/进行中状态（用于 Tab 筛选） */
export const APPOINTMENT_PENDING = [1, 6, 7, 10]

/** 已结束状态（已完成、已过期） */
export const APPOINTMENT_ENDED = [2, 4]

/** 已取消/未通过状态 */
export const APPOINTMENT_CANCELLED = [3, 9]
