<template>
	<view class="page">
		<view class="date-bar">{{ nowDate }}</view>
		<view class="toolbar">
			<text class="page-title">我的预约</text>
			<text class="link" @click="goAdd">+ 去预约</text>
		</view>
		<!-- 按宝宝筛选 -->
		<view class="filter-row">
			<text class="filter-label">宝宝：</text>
			<picker mode="selector" :range="childOptions" range-key="label" :value="childIndex" @change="onChildChange">
				<view class="picker-value">{{ childOptions[childIndex] ? childOptions[childIndex].label : '全部宝宝' }}</view>
			</picker>
		</view>
		<!-- 状态 Tab -->
		<view class="tabs">
			<view
				v-for="(tab, i) in tabs"
				:key="tab.value"
				class="tab"
				:class="{ active: statusType === tab.value }"
				@click="switchTab(tab.value)"
			>
				<text>{{ tab.label }}</text>
			</view>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无预约，点击右上角去预约</view>
			<view v-else class="order-list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="order-card"
					:class="isPending(item.status) ? 'card-pending' : 'card-done'"
				>
					<view class="card-main">
						<text class="item-title">{{ item.vaccineName || '疫苗#' + (item.vaccineId || '') }}</text>
						<text class="item-note" v-if="item.childName">宝宝：{{ item.childName }}</text>
						<text class="item-note">{{ (item.appointmentDate || '') + (item.timeSlot ? ' ' + item.timeSlot : '') }}</text>
						<text class="item-note" v-if="item.siteName">接种点：{{ item.siteName }}</text>
						<text class="item-note">状态：{{ statusText(item) }}</text>
					</view>
					<view class="card-right">
						<text class="status-tag" :class="statusTagClass(item.status)">{{ statusText(item) }}</text>
						<text v-if="canCancel(item.status)" class="link cancel-btn" @click.stop="cancelAppointment(item)">取消预约</text>
						<text v-if="isRejected(item.status)" class="link reapply" @click.stop="goReapply(item)">再次预约</text>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'
	import { getAppointmentStatusText, APPOINTMENT_CAN_CANCEL, APPOINTMENT_PENDING, APPOINTMENT_CANCELLED } from '@/common/constants.js'

	export default {
		data() {
			return {
				nowDate: '',
				dateTimer: null,
				tabs: [
					{ label: '全部', value: 'all' },
					{ label: '待接种', value: 'pending' },
					{ label: '已结束', value: 'ended' },
					{ label: '已取消', value: 'cancelled' }
				],
				statusType: 'all',
				childOptions: [{ id: '', label: '全部宝宝' }],
				childIndex: 0,
				childId: null,
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
			this.loadChildren()
			this.loadList()
		},
		onShow() {
			this.updateNowDate()
			if (!this.dateTimer) {
				this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			}
			if (this.list.length > 0 || this.childOptions.length > 1) {
				this.loadChildren()
				this.refreshList()
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
			isRejected(s) {
				return APPOINTMENT_CANCELLED.indexOf(s) !== -1
			},
			canCancel(s) {
				return APPOINTMENT_CAN_CANCEL.indexOf(s) !== -1
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
							this.refreshList()
						} catch (e) {
							uni.showToast({ title: e.message || '取消失败', icon: 'none' })
						}
					}
				})
			},
			statusTagClass(s) {
				if (s === 1 || s === 6 || s === 7 || s === 10) return 'tag-scheduled'
				if (s === 2) return 'tag-completed'
				if (s === 3 || s === 9) return 'tag-cancelled'
				if (s === 4) return 'tag-noshow'
				return ''
			},
			onChildChange(e) {
				const i = Number(e.detail.value)
				this.childIndex = i
				this.childId = this.childOptions[i] && this.childOptions[i].id ? this.childOptions[i].id : null
				this.refreshList()
			},
			switchTab(value) {
				this.statusType = value
				this.refreshList()
			},
			async loadChildren() {
				try {
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: 1, size: 100, parentId: getUserId() || undefined }
					})
					const { list: rows } = parsePageResponse(res)
					this.childOptions = [{ id: '', label: '全部宝宝' }]
					;(rows || []).forEach(c => {
						this.childOptions.push({ id: c.id, label: c.name || '宝宝#' + c.id })
					})
				} catch (_) {
					this.childOptions = [{ id: '', label: '全部宝宝' }]
				}
			},
			refreshList() {
				this.page = 1
				this.loadList()
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
						data: {
							current: this.page,
							size: this.pageSize,
							userId: userId || undefined,
							childId: this.childId || undefined,
							statusType: this.statusType === 'all' ? undefined : this.statusType
						}
					})
					const { list: rows } = parsePageResponse(res)
					if (this.page === 1) this.list = rows || []
					else this.list = (this.list || []).concat(rows || [])
					this.loadStatus = (rows && rows.length >= this.pageSize) ? 'more' : 'noMore'
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
			goAdd() {
				uni.navigateTo({ url: '/pages/order/add' })
			},
			goReapply(item) {
				const url = '/pages/order/add?childId=' + (item.childId || '') + '&vaccineId=' + (item.vaccineId || '')
				uni.navigateTo({ url })
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
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
		background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee;
		display: flex; justify-content: space-between; align-items: center;
	}
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.link { font-size: 28rpx; color: #007aff; }
	.filter-row {
		background: #fff; padding: 20rpx 30rpx; display: flex; align-items: center; border-bottom: 1rpx solid #eee;
		.filter-label { font-size: 28rpx; color: #666; margin-right: 16rpx; }
		.picker-value { font-size: 28rpx; color: #333; flex: 1; }
	}
	.tabs {
		display: flex; background: #fff; padding: 0 20rpx 16rpx; border-bottom: 1rpx solid #eee;
		.tab {
			flex: 1; text-align: center; padding: 16rpx; font-size: 26rpx; color: #666;
			&.active { color: #007aff; font-weight: 600; border-bottom: 4rpx solid #007aff; }
		}
	}
	.scroll { flex: 1; height: 0; }
	.order-list { padding: 20rpx; }
	.order-card {
		border-radius: 16rpx; padding: 24rpx 28rpx; margin-bottom: 20rpx;
		display: flex; align-items: center; justify-content: space-between;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
		&.card-pending { background: #fffbf0; border-left: 6rpx solid #ff9500; }
		&.card-done { background: #fff; border-left: 6rpx solid #34C759; }
	}
	.card-main { flex: 1; }
	.item-title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 8rpx; }
	.item-note { display: block; font-size: 24rpx; color: #999; }
	.card-right { margin-left: 20rpx; display: flex; flex-direction: column; align-items: flex-end; gap: 8rpx; }
	.status-tag { display: inline-block; padding: 6rpx 16rpx; border-radius: 20rpx; font-size: 22rpx; }
	.reapply { font-size: 24rpx; }
	.cancel-btn { font-size: 24rpx; color: #ee0a24; }
	.hint { color: #666; margin-right: 4rpx; }
	.tag-pending { background: #f0f0f0; color: #666; }
	.tag-doctor-approved { background: #fff3e0; color: #e65100; }
	.tag-scheduled { background: #e8f4ff; color: #007aff; }
	.tag-completed { background: #e8f8f0; color: #07c160; }
	.tag-cancelled { background: #fff0f0; color: #ee0a24; }
	.tag-noshow { background: #f5f5f5; color: #999; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
</style>
