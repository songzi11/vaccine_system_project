<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">统计大屏</text>
			<text class="refresh" @click="load">刷新</text>
		</view>
		<scroll-view scroll-y class="scroll" v-if="loaded">
			<!-- 汇总卡片（已移除疫苗库存相关展示） -->
			<view class="summary-row">
				<view class="summary-card">
					<text class="summary-value">{{ dashboard.todayVaccination }}</text>
					<text class="summary-label">今日接种</text>
				</view>
				<view class="summary-card">
					<text class="summary-value">{{ trend7Total }}</text>
					<text class="summary-label">7日合计</text>
				</view>
				<view class="summary-card" :class="{ warn: (dashboard.lowStock || []).length > 0 }">
					<text class="summary-value">{{ (dashboard.lowStock || []).length }}</text>
					<text class="summary-label">低库存项</text>
				</view>
			</view>
			<!-- 近7日接种趋势图 -->
			<view class="card card-trend">
				<text class="card-title">近 7 天接种趋势</text>
				<view class="trend-chart" v-if="(dashboard.trend7Days || []).length">
					<view class="trend-item" v-for="(t, i) in dashboard.trend7Days" :key="i">
						<text class="trend-date">{{ t.date }}</text>
						<view class="trend-bar-wrap">
							<view class="trend-bar" :style="{ width: barWidth(t) + '%' }"></view>
						</view>
						<text class="trend-count">{{ t.count }}</text>
					</view>
				</view>
				<view v-else class="empty-state">
					<text class="empty-text">暂无趋势数据</text>
				</view>
			</view>
			<!-- 低库存预警 -->
			<view class="card card-warn" v-if="(dashboard.lowStock || []).length">
				<text class="card-title">低库存预警</text>
				<view class="warn-list">
					<view class="warn-item" v-for="(w, i) in dashboard.lowStock" :key="i">
						<text>{{ w.vaccineName }} - {{ w.siteName }}：{{ w.stock }}</text>
					</view>
				</view>
			</view>
		</scroll-view>
		<view v-else class="loading-wrap">
			<uni-load-more status="loading" />
		</view>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		data() {
			return {
				dashboard: {
					todayVaccination: 0,
					trend7Days: [],
					lowStock: []
				},
				loaded: false
			}
		},
		onLoad() {
			this.load()
		},
		onPullDownRefresh() {
			this.load().then(() => uni.stopPullDownRefresh())
		},
		computed: {
			maxTrendCount() {
				const arr = this.dashboard.trend7Days || []
				if (!arr.length) return 1
				return Math.max(1, ...arr.map(t => Number(t.count) || 0))
			},
			trend7Total() {
				const arr = this.dashboard.trend7Days || []
				return arr.reduce((sum, t) => sum + (Number(t.count) || 0), 0)
			}
		},
		methods: {
			async load() {
				try {
					const res = await request({
						url: '/api/stats/dashboard',
						method: 'GET',
						data: { lowStockThreshold: 5 },
						loading: true
					})
					if (res && res.data) {
						this.dashboard = res.data
					}
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				} finally {
					this.loaded = true
				}
			},
			barWidth(t) {
				const max = this.maxTrendCount
				const n = Number(t.count) || 0
				return max ? Math.min(100, (n / max) * 100) : 0
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		min-height: 100vh;
		background: #f0f2f5;
		display: flex;
		flex-direction: column;
	}
	.toolbar {
		background: #fff;
		padding: 24rpx 30rpx;
		display: flex;
		align-items: center;
		justify-content: space-between;
		border-bottom: 1rpx solid #eee;
		.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
		.refresh { font-size: 28rpx; color: #007aff; }
	}
	.scroll { flex: 1; height: 0; padding: 24rpx; }
	.loading-wrap { flex: 1; display: flex; align-items: center; justify-content: center; }
	.summary-row {
		display: flex;
		flex-wrap: wrap;
		gap: 20rpx;
		margin-bottom: 24rpx;
	}
	.summary-card {
		flex: 1;
		min-width: calc(50% - 10rpx);
		background: #fff;
		border-radius: 16rpx;
		padding: 24rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
		display: flex;
		flex-direction: column;
		align-items: center;
		.summary-value { font-size: 44rpx; font-weight: bold; color: #007aff; }
		.summary-label { font-size: 24rpx; color: #999; margin-top: 8rpx; }
		&.warn .summary-value { color: #ee0a24; }
	}
	.card {
		background: #fff;
		border-radius: 20rpx;
		padding: 28rpx;
		margin-bottom: 24rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
		.card-title {
			display: block;
			font-size: 30rpx;
			font-weight: 500;
			color: #333;
			margin-bottom: 20rpx;
		}
		.card-value {
			font-size: 56rpx;
			font-weight: bold;
			color: #007aff;
		}
		.no-data { font-size: 26rpx; color: #999; }
	}
	.card-trend .card-title { margin-bottom: 16rpx; }
	.empty-state {
		padding: 48rpx 0;
		text-align: center;
		.empty-text { font-size: 26rpx; color: #999; }
	}
	.card-warn { border-left: 6rpx solid #ee0a24; }
	.trend-chart { margin-top: 8rpx; }
	.trend-chart .trend-item {
		display: flex;
		align-items: center;
		margin-bottom: 16rpx;
		font-size: 24rpx;
		.trend-date { width: 140rpx; color: #666; }
		.trend-bar-wrap {
			flex: 1;
			height: 32rpx;
			background: #f0f0f0;
			border-radius: 8rpx;
			overflow: hidden;
			margin: 0 16rpx;
		}
		.trend-bar {
			height: 100%;
			background: linear-gradient(90deg, #007aff, #5ac8fa);
			border-radius: 8rpx;
			transition: width 0.3s;
		}
		.trend-count { width: 60rpx; text-align: right; color: #333; font-weight: 500; }
	}
	.warn-list { margin-top: 8rpx; }
	.warn-item {
		padding: 12rpx 0;
		font-size: 26rpx;
		color: #ee0a24;
	}
</style>
