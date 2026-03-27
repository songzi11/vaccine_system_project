<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">接种记录</text>
			<text class="sub">我的宝宝</text>
		</view>
		<scroll-view
			scroll-y
			class="scroll"
			refresher-enabled
			:refresher-triggered="refreshing"
			@refresherrefresh="onRefresh"
		>
			<view v-if="list.length === 0 && !loading" class="empty">
				<text class="empty-text">暂无接种记录</text>
				<text class="empty-hint">完成预约接种后将显示在此处</text>
			</view>
			<view v-else class="timeline">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="timeline-item"
				>
					<view class="dot" :class="dotClass(item.status)"></view>
					<view class="card">
						<view class="card-row title">{{ item.vaccineName || '接种记录' }}</view>
						<view class="card-row meta">
							<text class="label">接种时间：</text>
							<text>{{ formatTime(item.vaccinateTime) }}</text>
						</view>
						<view class="card-row meta" v-if="item.siteName">
							<text class="label">接种地点：</text>
							<text>{{ item.siteName }}</text>
						</view>
						<view class="card-row meta" v-if="item.doctorName">
							<text class="label">医生：</text>
							<text>{{ item.doctorName }}</text>
						</view>
						<view class="card-row meta" v-if="item.vaccineCode">
							<text class="label">疫苗编号：</text>
							<text>{{ item.vaccineCode }}</text>
						</view>
						<view class="card-row">
							<text class="status-tag" :class="statusClass(item.status)">{{ item.status || '已接种' }}</text>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script>
	import request, { getUserId } from '@/common/request.js'

	export default {
		data() {
			return {
				list: [],
				loading: false,
				refreshing: false
			}
		},
		onLoad() {
			this.loadList()
		},
		methods: {
			formatTime(d) {
				if (!d) return '-'
				const s = String(d)
				return s.replace('T', ' ').substring(0, 19)
			},
			dotClass(status) {
				if (status === '异常') return 'dot-abnormal'
				if (status === '取消') return 'dot-cancel'
				return 'dot-done'
			},
			statusClass(status) {
				if (status === '异常') return 'status-abnormal'
				if (status === '取消') return 'status-cancel'
				return 'status-done'
			},
			async loadList() {
				const userId = getUserId()
				if (!userId) {
					uni.showToast({ title: '请先登录', icon: 'none' })
					return
				}
				if (this.loading) return
				this.loading = true
				try {
					const res = await request({
						url: '/user/record/my',
						method: 'GET',
						data: { userId: Number(userId) }
					})
					const data = (res && res.data) != null ? res.data : res
					this.list = Array.isArray(data) ? data : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.list = []
				} finally {
					this.loading = false
					this.refreshing = false
				}
			},
			onRefresh() {
				this.refreshing = true
				this.loadList()
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
		background: #f5f5f5;
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
		.sub {
			font-size: 24rpx;
			color: #999;
			margin-left: 12rpx;
		}
	}
	.scroll {
		flex: 1;
		height: 0;
	}
	.empty {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 120rpx 40rpx;
		.empty-text {
			font-size: 30rpx;
			color: #999;
		}
		.empty-hint {
			font-size: 24rpx;
			color: #bbb;
			margin-top: 16rpx;
		}
	}
	.timeline {
		padding: 30rpx 30rpx 30rpx 56rpx;
	}
	.timeline-item {
		position: relative;
		padding-bottom: 32rpx;
	}
	.dot {
		position: absolute;
		left: -30rpx;
		top: 28rpx;
		width: 20rpx;
		height: 20rpx;
		border-radius: 50%;
	}
	.dot-done {
		background: #07c160;
	}
	.dot-abnormal {
		background: #ee0a24;
	}
	.dot-cancel {
		background: #999;
	}
	.card {
		background: #fff;
		border-radius: 16rpx;
		padding: 28rpx 30rpx;
		box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
	}
	.card-row {
		font-size: 28rpx;
		color: #333;
		margin-bottom: 12rpx;
		&:last-child {
			margin-bottom: 0;
		}
	}
	.card-row.title {
		font-size: 32rpx;
		font-weight: 600;
		color: #333;
		margin-bottom: 16rpx;
	}
	.card-row.meta .label {
		color: #666;
		margin-right: 8rpx;
	}
	.status-tag {
		display: inline-block;
		padding: 6rpx 20rpx;
		border-radius: 8rpx;
		font-size: 24rpx;
	}
	.status-done {
		background: #e8f8f0;
		color: #07c160;
	}
	.status-abnormal {
		background: #ffebeb;
		color: #ee0a24;
	}
	.status-cancel {
		background: #f0f0f0;
		color: #999;
	}
</style>
