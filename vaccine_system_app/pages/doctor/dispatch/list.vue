<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">调遣通知</text>
			<text class="page-desc">管理员指派驻场医生后推送的通知，请查看后点击「标记已读」</text>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无调遣通知</view>
			<view v-else class="dispatch-list">
				<view v-for="(item, index) in list" :key="item.id || index" class="card" :class="item.status === 1 ? 'status-read' : 'status-unread'">
					<view class="card-head">
						<text class="card-status">{{ item.statusDesc || '已推送' }}</text>
						<text class="card-time">{{ formatTime(item.applyTime) }}</text>
					</view>
					<view class="card-body">
						<text class="row">您已被指派为驻场医生</text>
						<text class="row">接种点：{{ item.toSiteName || '-' }}</text>
						<text class="row" v-if="item.fromSiteName">调出：{{ item.fromSiteName }}</text>
						<text class="row" v-if="item.status === 1 && item.approveTime">已读时间：{{ formatTime(item.approveTime) }}</text>
					</view>
					<view v-if="item.status === 0" class="card-actions">
						<button class="btn btn-read" size="mini" @click="markRead(item)">标记已读</button>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
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
				loadStatus: 'more'
			}
		},
		onLoad() {
			this.loadList()
		},
		onShow() {
			if (this.list.length > 0) this.loadList()
		},
		methods: {
			formatTime(t) {
				if (!t) return '-'
				const d = new Date(t)
				return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0') + ' ' +
					String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0')
			},
			async loadList() {
				const doctorId = getUserId()
				if (!doctorId) {
					uni.showToast({ title: '请先登录', icon: 'none' })
					return
				}
				this.loading = true
				try {
					const res = await request({
						url: '/doctor/dispatch/list',
						method: 'GET',
						data: { doctorId: Number(doctorId) }
					})
					this.list = (res && res.data) ? res.data : []
					this.loadStatus = 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.list = []
				} finally {
					this.loading = false
				}
			},
			loadMore() {},
			markRead(item) {
				const doctorId = getUserId()
				if (!doctorId) return
				request({
					url: '/doctor/dispatch/' + item.id + '/read?doctorId=' + Number(doctorId),
					method: 'POST'
				}).then(() => {
					uni.showToast({ title: '已标记已读', icon: 'success' })
					this.loadList()
				}).catch(err => uni.showToast({ title: err.message || '操作失败', icon: 'none' }))
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
	.dispatch-list { padding: 20rpx; }
	.card {
		background: #fff;
		border-radius: 16rpx;
		padding: 28rpx;
		margin-bottom: 24rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
		border-left: 6rpx solid #ff9500;
	}
	.card.status-read { border-left-color: #34c759; }
	.card.status-unread { border-left-color: #ff9500; }
	.card-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
	.card-status { font-size: 28rpx; font-weight: 600; color: #333; }
	.card-time { font-size: 24rpx; color: #999; }
	.card-body .row { display: block; font-size: 26rpx; color: #666; margin-top: 8rpx; }
	.card-actions { margin-top: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #eee; display: flex; justify-content: flex-end; }
	.btn-read { background: #007aff; color: #fff; }
</style>
