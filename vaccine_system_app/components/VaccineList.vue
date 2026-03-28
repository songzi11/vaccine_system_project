<template>
	<view>
		<view class="search-bar">
			<input class="search-input" v-model="searchName" placeholder="疫苗名称" @confirm="handleSearch" />
			<picker mode="selector" :range="statusOptions" range-key="label" :value="statusIndex" @change="handleStatusChange">
				<view class="picker-wrap">{{ statusOptions[statusIndex].label }}</view>
			</picker>
			<button class="btn-search" size="mini" @click="handleSearch">查询</button>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="handleRefresh">
			<view v-if="list.length === 0 && !loading" class="empty">暂无疫苗</view>
			<view v-else class="list-wrap">
				<view class="list-item" v-for="(item, index) in list" :key="item.id || index">
					<view class="item-main" @click="handleEdit(item)">
						<text class="item-title">{{ item.vaccineName || '-' }}</text>
						<text class="item-note">{{ item.manufacturer || '' }} {{ item.category ? ' · ' + (item.category === 'CLASS_I' ? '一类' : '二类') : '' }} · 总仓剩余 {{ getWarehouseRemain(item.id) }}</text>
						<text class="item-status" :class="item.status === 1 ? 'status-up' : 'status-down'">{{ item.status === 1 ? '上架' : '下架' }}</text>
					</view>
					<view class="item-actions">
						<text class="act" @click.stop="handleActionMenu(item)">更多</text>
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
		props: {
			warehouseSummary: {
				type: Array,
				default: () => []
			}
		},
		data() {
			return {
				list: [],
				loading: false,
				refreshing: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20,
				searchName: '',
				statusIndex: 0,
				statusOptions: [
					{ value: null, label: '全部状态' },
					{ value: 1, label: '上架' },
					{ value: 0, label: '下架' }
				]
			}
		},
		methods: {
			handleStatusChange(e) {
				this.statusIndex = Number(e.detail.value)
				this.page = 1
				this.loadList()
			},
			handleSearch() {
				this.page = 1
				this.loadList()
			},
			handleRefresh() {
				this.refreshing = true
				this.page = 1
				this.loadList().then(() => {
					this.refreshing = false
				})
			},
			getWarehouseRemain(vaccineId) {
				if (vaccineId == null) return '-'
				const s = this.warehouseSummary.find(x => x.vaccineId === vaccineId || x.vaccineId === Number(vaccineId))
				return s && s.stock != null ? s.stock : '-'
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const params = {
						current: this.page,
						size: this.pageSize,
						vaccineName: this.searchName || undefined,
						status: this.statusOptions[this.statusIndex].value
					}
					const res = await request({
						url: '/admin/vaccine/page',
						method: 'GET',
						data: params
					})
					const { list: rows } = parsePageResponse(res)
					if (this.page === 1) this.list = rows || []
					else this.list = this.list.concat(rows || [])
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
			handleEdit(item) {
				if (!item || item.id == null) return
				uni.navigateTo({ url: '/pages/admin/vaccine-edit?id=' + item.id })
			},
			handleActionMenu(item) {
				this.$emit('action-menu', item)
			},
			async toggleStatus(item) {
				if (!item || item.id == null) return
				const newStatus = item.status === 1 ? 0 : 1
				const action = newStatus === 1 ? '上架' : '下架'
				try {
					await request({
						url: '/admin/vaccine/' + item.id + '/status',
						method: 'PUT',
						data: { status: newStatus }
					})
					uni.showToast({ title: '已' + action })
					item.status = newStatus
				} catch (e) {
					uni.showToast({ title: e.message || action + '失败', icon: 'none' })
				}
			},
			doDelete(item) {
				if (!item || item.id == null) return
				uni.showModal({
					title: '确认删除',
					content: '确定删除疫苗「' + (item.vaccineName || item.id) + '」吗？删除后相关库存与预约可能受影响。',
					success: async (res) => {
						if (!res.confirm) return
						try {
							await request({
								url: '/admin/vaccine/' + item.id,
								method: 'DELETE'
							})
							uni.showToast({ title: '已删除' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '删除失败', icon: 'none' })
						}
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.search-bar {
		background: #fff;
		padding: 16rpx 30rpx;
		display: flex;
		align-items: center;
		gap: 16rpx;
		border-bottom: 1rpx solid #eee;
		.search-input { flex: 1; height: 64rpx; padding: 0 20rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 28rpx; }
		.picker-wrap { min-width: 140rpx; padding: 16rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 26rpx; color: #333; }
		.btn-search { padding: 12rpx 24rpx; background: #007AFF; color: #fff; border-radius: 8rpx; font-size: 26rpx; border: none; }
	}
	.scroll { flex: 1; height: 0; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.list-wrap { padding: 20rpx; }
	.list-item {
		background: #fff;
		border-radius: 12rpx;
		margin-bottom: 20rpx;
		overflow: hidden;
		box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.06);
		.item-main { padding: 24rpx 30rpx; position: relative; }
		.item-title { font-size: 32rpx; font-weight: 600; color: #333; display: block; }
		.item-note { font-size: 26rpx; color: #666; margin-top: 8rpx; display: block; }
		.item-status { position: absolute; right: 30rpx; top: 24rpx; font-size: 24rpx; padding: 4rpx 12rpx; border-radius: 6rpx; }
		.status-up { background: #e8f5e9; color: #2e7d32; }
		.status-down { background: #ffebee; color: #c62828; }
		.item-actions { display: flex; border-top: 1rpx solid #eee; padding: 16rpx 30rpx; gap: 24rpx; }
		.act { font-size: 26rpx; color: #007AFF; }
	}
</style>
