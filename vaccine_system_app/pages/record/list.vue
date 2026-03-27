<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">接种记录</text>
			<uni-load-more v-if="loading" status="loading" />
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">
				<uni-icons type="checkbox" size="60" color="#ccc"></uni-icons>
				<text>暂无接种记录</text>
			</view>
			<uni-list v-else>
				<uni-list-item
					v-for="(item, index) in list"
					:key="item.id || index"
					:title="item.vaccineName || item.vaccine || ('接种记录#' + (item.id || ''))"
					:note="(item.vaccinateTime || item.vaccinationDate || item.vaccineDate || item.recordDate || item.createTime || '') + (item.vaccineCode ? ' · ' + item.vaccineCode : '')"
					:rightText="item.vaccineCode || ''"
					showArrow
					@click="goDetail(item)"
				/>
			</uni-list>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

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
					const userId = getUserId()
					const res = await request({
						url: '/record/list',
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
				const content = [
					item.vaccineName && ('疫苗：' + item.vaccineName),
					(item.vaccinateTime || item.vaccinationDate || item.vaccineDate) && ('接种时间：' + (item.vaccinateTime || item.vaccinationDate || item.vaccineDate)),
					item.vaccineCode && ('疫苗编号：' + item.vaccineCode),
					item.siteName && ('接种点：' + item.siteName),
					item.doctorName && ('医生：' + item.doctorName)
				].filter(Boolean).join('\n') || '暂无详情'
				uni.showModal({ title: '接种记录', content })
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
