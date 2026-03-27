<template>
	<view class="page">
		<view class="date-bar">{{ nowDate }}</view>
		<view class="toolbar">
			<text class="page-title">我的预约</text>
			<uni-load-more v-if="loading" status="loading" />
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">
				<uni-icons type="calendar" size="60" color="#ccc"></uni-icons>
				<text>暂无预约记录</text>
			</view>
			<view v-else class="order-list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="order-card"
					:class="isPending(item.status) ? 'card-pending' : 'card-done'"
					@click="goDetail(item)"
				>
					<view class="card-main">
						<text class="item-title">{{ item.vaccineName || item.vaccine || ('预约#' + (item.id || '')) }}</text>
						<text class="item-note">{{ (item.appointmentDate || item.orderDate || '') + (item.timeSlot || item.orderTime ? ' ' + (item.timeSlot || item.orderTime) : '') }}</text>
					</view>
					<view class="card-right">
						<text class="status-tag" :class="statusTagClass(item.status)">{{ statusText(item) }}</text>
						<text v-if="canCancel(item.status)" class="link cancel-btn" @click.stop="cancelAppointment(item)">取消预约</text>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'
	import { getAppointmentStatusText, APPOINTMENT_PENDING, APPOINTMENT_CAN_CANCEL } from '@/common/constants.js'

	export default {
		data() {
			return {
				nowDate: '',
				dateTimer: null,
				list: [],
				loading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20
			}
		},
		created() {
			this.updateNowDate()
		},
		onLoad() {
			this.updateNowDate()
			this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			this.loadList()
		},
		onShow() {
			this.updateNowDate()
			if (!this.dateTimer) {
				this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			}
		},
		onHide() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
			}
		},
		onUnload() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
			}
		},
		onPullDownRefresh() {
			this.page = 1
			this.loadList().then(() => uni.stopPullDownRefresh())
		},
		methods: {
			updateNowDate() {
				const d = new Date()
				const y = d.getFullYear()
				const m = String(d.getMonth() + 1).padStart(2, '0')
				const day = String(d.getDate()).padStart(2, '0')
				const h = String(d.getHours()).padStart(2, '0')
				const min = String(d.getMinutes()).padStart(2, '0')
				const s = String(d.getSeconds()).padStart(2, '0')
				const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
				this.nowDate = `${y}年${m}月${day}日 周${week} ${h}:${min}:${s}`
			},
			statusText(item) {
				const s = typeof item === 'object' && item != null ? item.status : item
				const label = typeof item === 'object' && item != null ? item.statusLabel : undefined
				return getAppointmentStatusText(s, label)
			},
			isPending(s) {
				return APPOINTMENT_PENDING.indexOf(s) !== -1
			},
			canCancel(s) {
				return APPOINTMENT_CAN_CANCEL.indexOf(s) !== -1
			},
			statusTagClass(s) {
				if (s === 1 || s === 6 || s === 7 || s === 10) return 'tag-scheduled'
				if (s === 2) return 'tag-completed'
				if (s === 3 || s === 9) return 'tag-cancelled'
				if (s === 4) return 'tag-noshow'
				return ''
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const userId = getUserId()
					const res = await request({
						url: '/order/list',
						method: 'GET',
						data: { current: this.page, size: this.pageSize, userId: userId || undefined }
					})
					const { list: rows } = parsePageResponse(res)
					if (this.page === 1) this.list = rows
					else this.list = this.list.concat(rows)
					this.loadStatus = (rows.length >= this.pageSize) ? 'more' : 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.loadStatus = 'more'
				} finally {
					this.loading = false
				}
			},
			loadMore() {
				if (this.loadStatus !== 'more' || this.loading) return
				this.page++
				this.loadList()
			},
			goDetail(item) {
				const date = item.appointmentDate || item.orderDate || ''
				const time = item.timeSlot || item.orderTime || ''
				uni.showModal({
					title: item.vaccineName || '预约详情',
					content: '日期：' + date + '\n时段：' + time + '\n状态：' + this.statusText(item)
				})
			},
			async cancelAppointment(item) {
				uni.showModal({
					title: '确认取消',
					content: '确定要取消该预约吗？',
					success: async (res) => {
						if (!res.confirm) return
						try {
							const userId = getUserId()
							const url = '/order/' + item.id + '/cancel' + (userId ? '?userId=' + encodeURIComponent(userId) : '')
							await request({ url, method: 'POST' })
							uni.showToast({ title: '已取消', icon: 'success' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '取消失败', icon: 'none' })
						}
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		height: 100vh;
		display: flex;
		flex-direction: column;
		background: #f5f5f5;
	}
	.date-bar {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		background-color: #667eea;
		color: #fff;
		text-align: center;
		padding: 20rpx 24rpx;
		font-size: 28rpx;
		font-weight: 500;
		min-height: 40rpx;
		flex-shrink: 0;
	}
	.toolbar {
		background: #fff;
		padding: 24rpx 30rpx;
		border-bottom: 1rpx solid #eee;
		.page-title {
			font-size: 36rpx;
			font-weight: bold;
			color: #333;
		}
	}
	.scroll {
		flex: 1;
		height: 0;
	}
	.order-list { padding: 20rpx; }
	.order-card {
		border-radius: 16rpx;
		padding: 24rpx 28rpx;
		margin-bottom: 20rpx;
		display: flex;
		align-items: center;
		justify-content: space-between;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
		border-left: 6rpx solid #ff9500;
		&.card-pending { background: #fffbf0; border-left-color: #ff9500; }
		&.card-done { background: #fff; border-left-color: #34C759; }
	}
	.card-main { flex: 1; }
	.card-right { margin-left: 20rpx; display: flex; flex-direction: column; align-items: flex-end; gap: 8rpx; }
	.item-title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 8rpx; }
	.item-note { font-size: 24rpx; color: #999; }
	.status-tag {
		display: inline-block;
		padding: 6rpx 16rpx;
		border-radius: 20rpx;
		font-size: 22rpx;
	}
	.link { font-size: 26rpx; color: #ee0a24; margin-top: 8rpx; }
	.tag-scheduled { background: #e8f4ff; color: #007aff; }
	.tag-completed { background: #e8f8f0; color: #07c160; }
	.tag-cancelled { background: #fff0f0; color: #ee0a24; }
	.tag-noshow { background: #f5f5f5; color: #999; }
	.empty {
		padding: 120rpx;
		text-align: center;
		color: #999;
		font-size: 28rpx;
	}
</style>
