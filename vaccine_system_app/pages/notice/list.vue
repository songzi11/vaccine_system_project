<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">公告</text>
			<uni-load-more v-if="loading" status="loading" />
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">
				<uni-icons type="notification" size="60" color="#ccc"></uni-icons>
				<text>暂无公告</text>
			</view>
			<view v-else class="notice-list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="notice-item"
					:class="[
						item.publisherRole === 'DOCTOR' ? 'notice-doctor' : 'notice-admin',
						item.noticeStyle === 'WARNING' ? 'notice-warning' : '',
						item.noticeStyle === 'FROZEN' ? 'notice-frozen' : ''
					]"
					@click="goDetail(item)"
				>
					<view class="notice-head">
						<text class="notice-title">{{ item.title || item.noticeTitle || '无标题' }}</text>
						<text class="notice-tag" :class="item.noticeStyle === 'WARNING' ? 'tag-warning' : (item.noticeStyle === 'FROZEN' ? 'tag-frozen' : (item.publisherRole === 'DOCTOR' ? 'tag-doctor' : 'tag-admin'))">{{ item.noticeStyle === 'WARNING' ? '爽约警告' : (item.noticeStyle === 'FROZEN' ? '冻结通知' : (item.publisherRole === 'DOCTOR' ? '医生发布' : '管理员发布')) }}</text>
					</view>
					<text class="notice-time">{{ item.publishTime || item.createTime || '' }}</text>
					<text class="notice-summary" v-if="item.summary || item.content">{{ (item.summary || item.content || '').slice(0, 60) }}{{ (item.summary || item.content || '').length > 60 ? '...' : '' }}</text>
				</view>
			</view>
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
						url: '/api/notice/list',
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
				const content = item.content || item.summary || '暂无内容'
				uni.showModal({
					title: item.title || item.noticeTitle || '公告',
					content: content.length > 200 ? content.slice(0, 200) + '...' : content,
					showCancel: false
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
	.notice-list {
		padding: 20rpx;
	}
	.notice-item {
		border-radius: 16rpx;
		padding: 28rpx;
		margin-bottom: 20rpx;
		box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
		&.notice-admin { background: #e8f4ff; border-left: 6rpx solid #007AFF; }
		&.notice-doctor { background: #e8f8f0; border-left: 6rpx solid #34C759; }
		&.notice-warning { background: #fff5f5; border: 2rpx solid #ff4d4f; border-left: 8rpx solid #ff4d4f; }
		&.notice-frozen { background: #fff2e8; border: 2rpx solid #fa8c16; border-left: 8rpx solid #fa8c16; }
		.notice-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8rpx; }
		.notice-title {
			flex: 1;
			font-size: 30rpx;
			font-weight: 500;
			color: #333;
		}
		.notice-tag { font-size: 22rpx; padding: 4rpx 12rpx; border-radius: 8rpx; }
		.tag-admin { background: #007AFF; color: #fff; }
		.tag-doctor { background: #34C759; color: #fff; }
		.tag-warning { background: #ff4d4f; color: #fff; }
		.tag-frozen { background: #fa8c16; color: #fff; }
		.notice-time {
			display: block;
			font-size: 24rpx;
			color: #999;
			margin-bottom: 8rpx;
		}
		.notice-summary {
			display: block;
			font-size: 26rpx;
			color: #666;
			line-height: 1.5;
		}
	}
</style>
