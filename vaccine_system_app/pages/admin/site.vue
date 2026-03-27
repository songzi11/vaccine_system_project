<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">接种点管理</text>
			<text class="page-desc">点击进入详情：维护库存、启用/禁用、驻场医生与调遣</text>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无接种点</view>
			<view v-else class="site-list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="site-card"
					@click="toDetail(item.id)"
				>
					<view class="card-main">
						<text class="card-name">{{ item.siteName || '-' }}</text>
						<text class="card-addr">{{ item.address || '-' }}</text>
						<view class="card-meta">
							<text class="meta-status" :class="item.status === 1 ? 'enabled' : 'disabled'">
								{{ item.status === 1 ? '启用' : '禁用' }}
							</text>
							<text class="meta-doctor" :class="{ empty: !item.currentDoctorName }">
								驻场：{{ item.currentDoctorName || '空' }}
							</text>
						</view>
					</view>
					<view class="card-arrow">
						<uni-icons type="right" size="20" color="#b0b0b0"></uni-icons>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
	</view>
</template>

<script>
	import request, { parsePageResponse } from '@/common/request.js'

	export default {
		data() {
			return {
				list: [],
				loading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20
			}
		},
		onLoad() {
			this.loadList()
		},
		onShow() {
			// 从详情返回时刷新列表（可能修改了启用状态等）
			if (this.list.length > 0) this.loadList()
		},
		methods: {
			toDetail(id) {
				if (!id) return
				uni.navigateTo({ url: '/pages/admin/site-detail?id=' + id })
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const res = await request({
						url: '/vaccination_site/page',
						method: 'GET',
						data: { current: this.page, size: this.pageSize }
					})
					const data = res && res.data
					const rows = (data && data.records) ? data.records : []
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
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f0f2f5; }
	.toolbar { background: #fff; padding: 28rpx 32rpx; border-bottom: 1rpx solid #eee; }
	.page-title { font-size: 38rpx; font-weight: 700; color: #1a1a1a; display: block; letter-spacing: 0.5rpx; }
	.page-desc { font-size: 26rpx; color: #8c8c8c; margin-top: 10rpx; display: block; line-height: 1.45; }
	.scroll { flex: 1; height: 0; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.site-list { padding: 24rpx; }
	.site-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 32rpx 28rpx;
		margin-bottom: 24rpx;
		display: flex;
		align-items: center;
		justify-content: space-between;
		box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.04);
		border: 1rpx solid rgba(0, 0, 0, 0.04);
		min-height: 200rpx;
	}
	.card-main { flex: 1; min-width: 0; margin-right: 16rpx; display: flex; flex-direction: column; justify-content: center; }
	.card-name { font-size: 34rpx; font-weight: 600; color: #1a1a1a; display: block; line-height: 1.4; }
	.card-addr {
		font-size: 26rpx; color: #666; margin-top: 10rpx; display: block; line-height: 1.5;
		min-height: 78rpx;
	}
	.card-meta { margin-top: 16rpx; display: flex; align-items: center; gap: 24rpx; flex-wrap: nowrap; min-height: 44rpx; }
	.meta-status {
		font-size: 24rpx; font-weight: 500;
		padding: 6rpx 16rpx; border-radius: 10rpx;
	}
	.meta-status.enabled { background: #52c41a; color: #fff; }
	.meta-status.disabled { background: #ff4d4f; color: #fff; }
	.meta-doctor { font-size: 26rpx; color: #555; }
	.meta-doctor.empty { color: #999; }
	.card-arrow { flex-shrink: 0; display: flex; align-items: center; }
</style>
