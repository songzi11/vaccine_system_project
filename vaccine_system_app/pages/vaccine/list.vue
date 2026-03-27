<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">疫苗列表</text>
			<uni-load-more v-if="loading" status="loading" />
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">
				<uni-icons type="list" size="60" color="#ccc"></uni-icons>
				<text>暂无疫苗数据</text>
			</view>
			<uni-list v-else>
				<uni-list-item
					v-for="(item, index) in list"
					:key="item.id || index"
					:title="item.name || item.vaccineName || '未命名'"
					:note="item.description || item.remark || ''"
					:rightText="item.price != null ? '¥' + item.price : ''"
					showArrow
					@click="goDetail(item)"
				/>
			</uni-list>
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
		onPullDownRefresh() {
			this.page = 1
			this.loadList().then(() => uni.stopPullDownRefresh())
		},
		methods: {
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const res = await request({
						url: '/vaccine/list',
						method: 'GET',
						data: { current: this.page, size: this.pageSize, status: 1 }
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
				uni.navigateTo({
					url: '/pages/order/add?vaccineId=' + (item.id || item.vaccineId || '')
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
	.empty {
		padding: 120rpx;
		text-align: center;
		color: #999;
		font-size: 28rpx;
	}
</style>
