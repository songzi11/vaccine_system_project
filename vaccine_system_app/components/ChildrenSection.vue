<template>
	<view>
		<!-- 绑定儿童卡片（宫格展示，显示姓名、月龄） -->
		<view class="section">
			<text class="section-title">我的宝宝</text>
			<view v-if="loading" class="loading-row">
				<uni-load-more status="loading" />
			</view>
			<view v-else-if="children.length === 0" class="empty-card" @click="handleAddChild">
				<text class="empty-text">暂未添加儿童档案</text>
				<text class="empty-hint">点击前往「宝宝档案」添加</text>
			</view>
			<view v-else class="children-grid">
				<view
					v-for="(c, i) in children"
					:key="c.id || i"
					class="child-card"
					@click="handleChildClick(c)"
				>
					<view class="child-avatar">{{ (c.name || '宝宝').charAt(0) }}</view>
					<text class="child-name">{{ c.name || '宝宝' }}</text>
					<text class="child-age">{{ ageMonths(c) }}月龄</text>
				</view>
			</view>
		</view>

		<!-- 智能提醒栏：根据后端数据高亮显示"宝宝下周该打XXX第N针了" -->
		<view v-if="reminderText" class="reminder-bar">
			<uni-icons type="notification" size="20" color="#ff9500"></uni-icons>
			<text class="reminder-text">{{ reminderText }}</text>
			<text class="reminder-link" @click="handleGoToReservation">去预约</text>
		</view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

	export default {
		props: {
			vaccineMap: {
				type: Object,
				default: () => ({})
			}
		},
		data() {
			return {
				children: [],
				loading: false,
				recordsWithNext: []
			}
		},
		mounted() {
			this.loadChildren()
			this.loadReminderData()
		},
		computed: {
			reminderText() {
				if (!this.recordsWithNext.length || !this.vaccineMap) return ''
				const today = new Date()
				today.setHours(0, 0, 0, 0)
				const in7 = new Date(today)
				in7.setDate(in7.getDate() + 7)
				for (const r of this.recordsWithNext) {
					if (!r.nextDoseDate) continue
					const d = new Date(r.nextDoseDate)
					d.setHours(0, 0, 0, 0)
					if (d >= today && d <= in7) {
						const name = this.vaccineMap[r.vaccineId] || ('疫苗#' + r.vaccineId)
						const doseNum = r.currentDose ? r.currentDose + 1 : 1
						return '宝宝下周该打' + name + '第' + doseNum + '针了'
					}
				}
				return ''
			}
		},
		methods: {
			async loadChildren() {
				this.loading = true
				try {
					const userId = getUserId()
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: 1, size: 50, parentId: userId }
					})
					const { list } = parsePageResponse(res)
					this.children = list || []
				} catch (e) {
					uni.showToast({ title: e.message || '加载儿童列表失败', icon: 'none' })
					this.children = []
				} finally {
					this.loading = false
				}
			},
			async loadReminderData() {
				try {
					const userId = getUserId()
					const res = await request({
						url: '/user/record/list',
						method: 'GET',
						data: { current: 1, size: 100, userId: userId, withNext: true }
					})
					const { list: records } = parsePageResponse(res)
					if (!records || !records.length) {
						this.recordsWithNext = []
						this.$emit('update:vaccineMap', {})
						return
					}
					const withNext = records.filter(r => r.nextDoseDate)
					this.recordsWithNext = withNext
					const vaccineIds = [...new Set(withNext.map(r => r.vaccineId).filter(Boolean))]
					if (!vaccineIds.length) return
					const vaccineRes = await request({
						url: '/vaccine/list',
						method: 'GET',
						data: { current: 1, size: 999 }
					})
					const { list: vaccines } = parsePageResponse(vaccineRes)
					const map = {}
					;(vaccines || []).forEach(v => {
						if (v.id != null) map[v.id] = v.vaccineName || v.name || ('疫苗' + v.id)
					})
					this.$emit('update:vaccineMap', map)
				} catch (e) {
					console.error('加载提醒数据失败', e)
					this.recordsWithNext = []
				}
			},
			ageMonths(c) {
				if (!c.birthDate) return '-'
				const birth = new Date(c.birthDate)
				const now = new Date()
				let m = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth())
				if (now.getDate() < birth.getDate()) m--
				return m < 0 ? 0 : m
			},
			handleAddChild() {
				uni.navigateTo({ url: '/pages/user/child/add' })
			},
			handleChildClick(child) {
				uni.navigateTo({ url: '/pages/order/add?childId=' + (child.id || '') })
			},
			handleGoToReservation() {
				uni.navigateTo({ url: '/pages/order/add' })
			}
		}
	}
</script>

<style lang="scss" scoped>
	.section {
		background: #fff;
		margin-bottom: 24rpx;
		border-radius: 20rpx;
		padding: 30rpx;
	}
	.section-title {
		font-size: 32rpx;
		font-weight: 600;
		color: #333;
		margin-bottom: 24rpx;
		display: block;
	}
	.loading-row {
		padding: 40rpx 0;
	}
	.empty-card {
		text-align: center;
		padding: 60rpx 30rpx;
		.empty-text {
			display: block;
			font-size: 28rpx;
			color: #666;
			margin-bottom: 12rpx;
		}
		.empty-hint {
			display: block;
			font-size: 24rpx;
			color: #999;
		}
	}
	.children-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200rpx, 1fr));
		gap: 24rpx;
	}
	.child-card {
		background: #f8f9fa;
		border-radius: 16rpx;
		padding: 32rpx 24rpx;
;
		text-align: center;
		transition: transform 0.2s;
		&:active { transform: scale(0.95); }
		.child-avatar {
			width: 88rpx;
			height: 88rpx;
			background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
			border-radius: 50%;
			display: flex;
			align-items: center;
			justify-content: center;
			font-size: 36rpx;
			font-weight: 600;
			color: #fff;
			margin: 0 auto 16rpx;
		}
		.child-name {
			display: block;
			font-size: 28rpx;
			font-weight: 600;
			color: #333;
			margin-bottom: 8rpx;
		}
		.child-age {
			display: block;
			font-size: 24rpx;
			color: #999;
		}
	}
	.reminder-bar {
		background: #fff3cd;
		border-left: 8rpx solid #ff9500;
		padding: 20rpx 24rpx;
		margin: 24rpx 0;
		border-radius: 12rpx;
		display: flex;
		align-items: center;
		gap: 16rpx;
		.reminder-text {
			flex: 1;
			font-size: 26rpx;
			color: #856404;
		}
		.reminder-link {
			font-size: 26rpx;
			color: #007AFF;
			font-weight: 500;
			flex-shrink: 0;
		}
	}
</style>
