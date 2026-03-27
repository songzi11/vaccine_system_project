<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">接种点信息</text>
			<text class="page-desc">可查询各接种点疫苗库存、地点、启用情况与驻场医生</text>
		</view>
		<scroll-view scroll-y class="scroll">
			<view v-if="list.length === 0 && !loading" class="empty">暂无启用接种点</view>
			<view v-else class="site-list">
				<view v-for="(item, index) in list" :key="item.id || index" class="site-card">
					<view class="card-head">
						<text class="card-name">{{ item.siteName || '-' }}</text>
						<text class="card-status" :class="item.status === 1 ? 'enabled' : 'disabled'">
							{{ item.statusDesc || (item.status === 1 ? '启用' : '禁用') }}
						</text>
					</view>
					<view class="card-body">
						<view class="row" v-if="item.address">
							<uni-icons type="location" size="16" color="#999"></uni-icons>
							<text class="row-text">{{ item.address }}</text>
						</view>
						<view class="row" v-if="item.contactPhone">
							<uni-icons type="phone" size="16" color="#999"></uni-icons>
							<text class="row-text">{{ item.contactPhone }}</text>
						</view>
						<view class="row" v-if="item.workTime">
							<uni-icons type="calendar" size="16" color="#999"></uni-icons>
							<text class="row-text">{{ item.workTime }}</text>
						</view>
						<view class="row">
							<text class="label">驻场医生：</text>
							<text class="row-text">{{ item.currentDoctorName || '空' }}</text>
						</view>
					</view>
					<view class="card-stock" v-if="item.stockList && item.stockList.length > 0">
						<text class="stock-title">疫苗库存</text>
						<view class="stock-tags">
							<text v-for="s in item.stockList" :key="s.id" class="stock-tag">
								{{ s.vaccineName }}：{{ s.quantity }}支
							</text>
						</view>
					</view>
					<view class="card-stock empty" v-else>
						<text class="stock-title">疫苗库存</text>
						<text class="stock-empty">暂无库存记录</text>
					</view>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		data() {
			return {
				list: [],
				loading: false
			}
		},
		onLoad() {
			this.loadList()
		},
		methods: {
			async loadList() {
				this.loading = true
				try {
					const res = await request({
						url: '/user/site/listWithStock',
						method: 'GET'
					})
					this.list = (res && res.data) ? res.data : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.list = []
				} finally {
					this.loading = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; display: block; }
	.page-desc { font-size: 24rpx; color: #999; margin-top: 8rpx; display: block; }
	.scroll { flex: 1; height: 0; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.site-list { padding: 20rpx; }
	.site-card {
		background: #fff;
		border-radius: 16rpx;
		padding: 28rpx;
		margin-bottom: 24rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
	}
	.card-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16rpx; }
	.card-name { font-size: 32rpx; font-weight: 600; color: #333; flex: 1; }
	.card-status { font-size: 24rpx; padding: 4rpx 12rpx; border-radius: 8rpx; }
	.card-status.enabled { background: #e8f5e9; color: #2e7d32; }
	.card-status.disabled { background: #ffebee; color: #c62828; }
	.card-body .row { display: flex; align-items: center; margin-top: 10rpx; font-size: 26rpx; color: #666; }
	.row .label { color: #999; margin-right: 8rpx; }
	.row-text { flex: 1; }
	.card-stock { margin-top: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #eee; }
	.stock-title { font-size: 26rpx; color: #999; display: block; margin-bottom: 12rpx; }
	.stock-tags { display: flex; flex-wrap: wrap; gap: 12rpx; }
	.stock-tag { font-size: 24rpx; background: #f0f0f0; padding: 8rpx 14rpx; border-radius: 8rpx; color: #333; }
	.stock-empty { font-size: 24rpx; color: #999; }
</style>
