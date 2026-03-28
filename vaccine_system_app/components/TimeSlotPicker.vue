<template>
	<view class="time-slot-picker">
		<view v-if="!siteId || !orderDate" class="picker-value hint">请先选择接种点和预约日期</view>
		<view v-else class="slot-wrap">
			<scroll-view scroll-x class="slot-scroll" :show-scrollbar="true">
				<view class="slot-list">
					<view
						v-for="slot in slots"
						:key="slot.id"
						class="slot-item"
						:class="{ booked: slot.booked, selected: selectedId === slot.id, expired: slot.expired }"
						@click="handleClick(slot)"
					>
						<text class="slot-time">{{ slot.timeSlot || '-' }}</text>
						<text class="slot-status">{{ slot.expired ? '已过期' : slot.booked ? '已约' : '可约' }}</text>
					</view>
				</view>
			</scroll-view>
			<view v-if="slots.length === 0 && !loading" class="slot-empty">该日期暂无排班</view>
			<view v-if="loading" class="slot-loading">加载排班中...</view>
		</view>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		props: {
			siteId: [Number, String],
			orderDate: String,
			dateRangeStart: String,
			dateRangeEnd: String
		},
		data() {
			return {
				slots: [],
				loading: false,
				selectedId: null
			}
		},
		watch: {
			siteId: {
				handler() {
					this.loadSlots()
				},
				immediate: true
			},
			orderDate() {
				this.loadSlots()
			}
		},
		methods: {
			isSlotExpired(slot) {
				if (!slot.scheduleDate || !slot.timeSlot) return false
				const now = new Date()
				const scheduleDate = new Date(slot.scheduleDate)
				if (scheduleDate < new Date(now.getFullYear(), now.getMonth(), now.getDate())) {
					return true
				}
				if (scheduleDate.getDate() === now.getDate() &&
					scheduleDate.getMonth() === now.getMonth() &&
					scheduleDate.getFullYear() === now.getFullYear()) {
					const timeMatch = slot.timeSlot.match(/^(\d{1,2}):(\d{2})/)
					if (timeMatch) {
						const slotHour = parseInt(timeMatch[1])
						const slotMinute = parseInt(timeMatch[2])
						const slotEndTime = new Date(scheduleDate)
						slotEndTime.setHours(slotHour, slotMinute, 0, 0)
						return now > slotEndTime
					}
				}
				return false
			},
			async loadSlots() {
				if (!this.siteId) {
					this.slots = []
					return
				}
				this.loading = true
				try {
					const from = this.dateRangeStart || this.orderDate
					const end = this.dateRangeEnd || this.orderDate
					const res = await request({
						url: '/api/appointment/schedules',
						method: 'GET',
						data: { siteId: this.siteId, fromDate: from, toDate: end }
					})
					const scheduleList = (res && res.data && Array.isArray(res.data)) ? res.data : []
					if (!this.orderDate) {
						this.slots = scheduleList.map(s => this.mapSlot(s))
					} else {
						const dateStr = String(this.orderDate).slice(0, 10)
						const filtered = scheduleList.filter(s => String(s.scheduleDate || '').slice(0, 10) === dateStr)
						this.slots = filtered.map(s => this.mapSlot(s))
					}
				} catch (_) {
					this.slots = []
				} finally {
					this.loading = false
				}
			},
			mapSlot(s) {
				return {
					id: s.id,
					timeSlot: s.timeSlot,
					booked: (s.currentCount != null && s.maxCapacity != null) && s.currentCount >= s.maxCapacity,
					expired: this.isSlotExpired(s),
					doctorId: s.doctorId,
					siteId: s.siteId,
					scheduleDate: s.scheduleDate
				}
			},
			handleClick(slot) {
				if (slot.expired) {
					uni.showToast({ title: '该时段已过期', icon: 'none' })
					return
				}
				if (slot.booked) {
					uni.showToast({ title: '该时段已约满', icon: 'none' })
					return
				}
				this.selectedId = slot.id
				this.$emit('select', slot)
			},
			setSelectedId(id) {
				this.selectedId = id
			}
		}
	}
</script>

<style lang="scss" scoped>
	.time-slot-picker { width: 100%; }
	.picker-value {
		padding: 24rpx;
		background: #f8f8f8;
		border-radius: 12rpx;
		font-size: 28rpx;
		color: #333;
	}
	.picker-value.hint { color: #999; }
	.slot-wrap { width: 100%; }
	.slot-scroll { white-space: nowrap; width: 100%; }
	.slot-list {
		display: inline-flex;
		flex-wrap: nowrap;
		gap: 20rpx;
		padding: 12rpx 0 24rpx;
		min-width: min-content;
	}
	.slot-item {
		flex-shrink: 0;
		min-width: 200rpx;
		padding: 24rpx 28rpx;
		background: #f0f9ff;
		border-radius: 12rpx;
		border: 2rpx solid #e0e0e0;
		display: inline-flex;
		align-items: center;
		justify-content: space-between;
		&.booked {
			background: #f5f5f5;
			color: #999;
			border-color: #eee;
		}
		&.expired {
			background: #f5f5f5;
			color: #999;
			border-color: #eee;
		}
		&.selected {
			border-color: #07c160;
			background: #e8f8f0;
		}
		.slot-time { font-size: 28rpx; color: #333; }
		.slot-status { font-size: 24rpx; color: #07c160; }
		&.booked .slot-status { color: #999; }
		&.expired .slot-status { color: #999; }
	}
	.slot-empty, .slot-loading {
		width: 100%;
		padding: 24rpx;
		text-align: center;
		color: #999;
		font-size: 26rpx;
	}
</style>
