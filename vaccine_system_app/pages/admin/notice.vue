<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">公告管理</text>
			<text class="link" @click="showAdd = true">+ 发布公告</text>
		</view>
		<view class="tabs">
			<view class="tab" :class="{ active: tab === 'all' }" @click="tab = 'all'; refresh()">全部公告</view>
			<view class="tab" :class="{ active: tab === 'pending' }" @click="tab = 'pending'; refresh()">待审批</view>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="tab === 'pending' && pendingList.length === 0 && !pendingLoading" class="empty">暂无待审批的医生公告申请</view>
			<view v-else-if="tab === 'pending'" class="list">
				<view v-for="(item, index) in pendingList" :key="item.id || index" class="card card-pending">
					<text class="title">{{ item.title || '无标题' }}</text>
					<text class="meta">医生申请 · 申请时间：{{ item.createTime || '' }}</text>
					<text class="content-preview" v-if="item.content">{{ (item.content || '').slice(0, 80) }}{{ (item.content || '').length > 80 ? '...' : '' }}</text>
					<view class="actions">
						<button class="btn btn-approve" size="mini" type="primary" :loading="approvingId === item.id" @click="approve(item)">通过并发布</button>
						<button class="btn btn-reject" size="mini" :loading="rejectingId === item.id" @click="reject(item)">拒绝</button>
					</view>
				</view>
			</view>
			<view v-else-if="list.length === 0 && !loading" class="empty">暂无公告</view>
			<view v-else-if="tab === 'all'" class="list">
				<view v-for="(item, index) in list" :key="item.id || index" class="card" :class="{ 'card-offline': item.status === 0 }" @click="goDetail(item)">
					<view class="card-head">
						<text class="title">{{ item.title || '无标题' }}</text>
						<text v-if="item.isTop === 1" class="tag-top">置顶</text>
						<text v-if="item.status === 0" class="tag-offline">已下架</text>
					</view>
					<text class="meta">{{ item.publisherRole === 'DOCTOR' ? '医生发布' : '管理员发布' }} · {{ item.publishTime || item.createTime || '' }}</text>
					<view class="actions" @click.stop>
						<text v-if="item.isTop === 1" class="link" @click="setUntop(item)">取消置顶</text>
						<text v-else class="link" @click="setTop(item)">置顶</text>
						<text class="link" @click="showFeedback(item)">查看意见</text>
						<button v-if="item.status === 1" class="btn btn-offline" size="mini" :loading="offlineId === item.id" @click="setOffline(item)">下架</button>
						<button v-if="item.status === 0" class="btn btn-online" size="mini" type="primary" :loading="onlineId === item.id" @click="setOnline(item)">上架</button>
					</view>
				</view>
			</view>
			<uni-load-more v-if="(tab === 'all' ? list : pendingList).length > 0" :status="tab === 'all' ? loadStatus : 'noMore'" />
		</scroll-view>

		<!-- 发布公告弹窗 -->
		<view v-if="showAdd" class="modal-mask" @click="showAdd = false">
			<view class="modal modal-form" @click.stop>
				<text class="modal-title">发布公告</text>
				<view class="form-item">
					<text class="form-label">标题（必填）</text>
					<input v-model="form.title" placeholder="请输入公告标题" class="form-input" />
				</view>
				<view class="form-item">
					<text class="form-label">内容</text>
					<textarea v-model="form.content" placeholder="请输入公告内容" class="form-textarea" :maxlength="-1" />
				</view>
				<view class="form-item">
					<text class="form-label">类型（选填）</text>
					<input v-model="form.type" placeholder="如：通知、提醒" class="form-input" />
				</view>
				<view class="form-item row">
					<text class="form-label">置顶</text>
					<switch :checked="form.isTop === 1" @change="e => form.isTop = e.detail.value ? 1 : 0" color="#007AFF" />
				</view>
				<view class="modal-btns">
					<button class="btn btn-outline" @click="showAdd = false">取消</button>
					<button class="btn btn-primary" :loading="adding" @click="submitNotice">发布</button>
				</view>
			</view>
		</view>

		<!-- 驳回弹窗：填写管理员意见 -->
		<view v-if="rejectingItem" class="modal-mask" @click="rejectingItem = null">
			<view class="modal" @click.stop>
				<text class="modal-title">驳回公告申请</text>
				<text class="modal-desc">驳回后医生端将显示为未通过，并展示您填写的意见。医生可修改后重新申请。</text>
				<view class="form-item">
					<text class="form-label">驳回意见（必填）</text>
					<textarea v-model="rejectReason" placeholder="请输入驳回原因，将展示给医生" class="form-textarea" />
				</view>
				<view class="modal-btns">
					<button class="btn btn-outline" @click="rejectingItem = null">取消</button>
					<button class="btn btn-primary" :loading="rejectingId === rejectingItem.id" @click="confirmReject">确认驳回</button>
				</view>
			</view>
		</view>

		<!-- 医生意见列表弹窗 -->
		<view v-if="feedbackNotice" class="modal-mask" @click="feedbackNotice = null">
			<view class="modal modal-feedback" @click.stop>
				<text class="modal-title">「{{ feedbackNotice.title }}」— 医生意见</text>
				<scroll-view scroll-y class="feedback-scroll" v-if="feedbackList.length > 0">
					<view v-for="(fb, i) in feedbackList" :key="fb.id || i" class="feedback-item">
						<text class="feedback-content">{{ fb.content }}</text>
						<text class="feedback-meta">用户ID: {{ fb.userId }} · {{ fb.createTime || '' }}</text>
					</view>
				</scroll-view>
				<view v-else-if="feedbackLoading" class="feedback-empty">加载中...</view>
				<view v-else class="feedback-empty">暂无医生意见</view>
				<view class="modal-btns">
					<button class="btn btn-outline" @click="feedbackNotice = null">关闭</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
	import request, { parsePageResponse } from '@/common/request.js'

	export default {
		data() {
			return {
				tab: 'all',
				list: [],
				pendingList: [],
				loading: false,
				pendingLoading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20,
				approvingId: null,
				rejectingId: null,
				rejectingItem: null,
				rejectReason: '',
				offlineId: null,
				onlineId: null,
				topId: null,
				untopId: null,
				showAdd: false,
				adding: false,
				form: { title: '', content: '', type: '', isTop: 0 },
				feedbackNotice: null,
				feedbackList: [],
				feedbackLoading: false
			}
		},
		onLoad() {
			this.loadList()
			this.loadPending()
		},
		methods: {
			refresh() {
				if (this.tab === 'all') {
					this.page = 1
					this.loadList()
				} else {
					this.loadPending()
				}
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const res = await request({
						url: '/notice/list',
						method: 'GET',
						data: { current: this.page, size: this.pageSize }
					})
					const { list: rows } = parsePageResponse(res)
					if (this.page === 1) this.list = rows || []
					else this.list = (this.list || []).concat(rows || [])
					this.loadStatus = (rows && rows.length >= this.pageSize) ? 'more' : 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.loadStatus = 'more'
				} finally {
					this.loading = false
				}
			},
			async loadPending() {
				this.pendingLoading = true
				try {
					const res = await request({
						url: '/notice/pending',
						method: 'GET',
						data: { current: 1, size: 50 }
					})
					const data = res && res.data
					this.pendingList = (data && data.records) ? data.records : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.pendingList = []
				} finally {
					this.pendingLoading = false
				}
			},
			loadMore() {
				if (this.tab !== 'all' || this.loadStatus !== 'more' || this.loading) return
				this.page++
				this.loadList()
			},
			async approve(item) {
				this.approvingId = item.id
				try {
					await request({
						url: '/notice/' + item.id + '/approve',
						method: 'PUT'
					})
					uni.showToast({ title: '已通过并发布', icon: 'success' })
					this.pendingList = this.pendingList.filter(x => x.id !== item.id)
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.approvingId = null
				}
			},
			reject(item) {
				this.rejectingItem = item
				this.rejectReason = ''
			},
			async confirmReject() {
				const item = this.rejectingItem
				if (!item) return
				const reason = (this.rejectReason || '').trim()
				if (!reason) {
					uni.showToast({ title: '请填写驳回意见', icon: 'none' })
					return
				}
				this.rejectingId = item.id
				try {
					await request({
						url: '/notice/' + item.id + '/reject',
						method: 'PUT',
						data: { rejectReason: reason }
					})
					uni.showToast({ title: '已拒绝，医生可见驳回意见', icon: 'success' })
					this.rejectingItem = null
					this.rejectReason = ''
					this.pendingList = this.pendingList.filter(x => x.id !== item.id)
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.rejectingId = null
				}
			},
			goDetail(item) {
				uni.showModal({
					title: item.title || '公告',
					content: (item.content || '').slice(0, 300) + ((item.content || '').length > 300 ? '...' : ''),
					showCancel: false
				})
			},
			async setOffline(item) {
				this.offlineId = item.id
				try {
					await request({ url: '/notice/' + item.id + '/offline', method: 'PUT' })
					uni.showToast({ title: '已下架', icon: 'success' })
					item.status = 0
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.offlineId = null
				}
			},
			async setOnline(item) {
				this.onlineId = item.id
				try {
					await request({ url: '/notice/' + item.id + '/online', method: 'PUT' })
					uni.showToast({ title: '已上架', icon: 'success' })
					item.status = 1
					if (item.publishTime === null) item.publishTime = new Date().toISOString().slice(0, 19).replace('T', ' ')
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.onlineId = null
				}
			},
			async setTop(item) {
				this.topId = item.id
				try {
					await request({ url: '/notice/' + item.id + '/top', method: 'PUT' })
					uni.showToast({ title: '已置顶', icon: 'success' })
					item.isTop = 1
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.topId = null
				}
			},
			async setUntop(item) {
				this.untopId = item.id
				try {
					await request({ url: '/notice/' + item.id + '/untop', method: 'PUT' })
					uni.showToast({ title: '已取消置顶', icon: 'success' })
					item.isTop = 0
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.untopId = null
				}
			},
			showFeedback(item) {
				this.feedbackNotice = item
				this.feedbackList = []
				this.loadFeedback(item.id)
			},
			async loadFeedback(noticeId) {
				this.feedbackLoading = true
				try {
					const res = await request({
						url: '/notice/' + noticeId + '/feedback',
						method: 'GET'
					})
					const data = res && res.data
					this.feedbackList = Array.isArray(data) ? data : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载意见失败', icon: 'none' })
					this.feedbackList = []
				} finally {
					this.feedbackLoading = false
				}
			},
			async submitNotice() {
				const title = (this.form.title || '').trim()
				if (!title) {
					uni.showToast({ title: '请填写公告标题', icon: 'none' })
					return
				}
				this.adding = true
				try {
					await request({
						url: '/notice',
						method: 'POST',
						data: {
							title,
							content: (this.form.content || '').trim(),
							type: (this.form.type || '').trim() || undefined,
							isTop: this.form.isTop || 0,
							publisherRole: 'ADMIN'
						}
					})
					uni.showToast({ title: '发布成功', icon: 'success' })
					this.showAdd = false
					this.form = { title: '', content: '', type: '', isTop: 0 }
					this.page = 1
					this.loadList()
				} catch (e) {
					uni.showToast({ title: e.message || '发布失败', icon: 'none' })
				} finally {
					this.adding = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; align-items: center; justify-content: space-between; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.toolbar .link { font-size: 28rpx; color: #007AFF; }
	.modal-form .form-input { width: 100%; height: 72rpx; border: 1rpx solid #eee; border-radius: 8rpx; padding: 0 20rpx; font-size: 28rpx; box-sizing: border-box; }
	.form-item.row { display: flex; align-items: center; justify-content: space-between; }
	.tabs { display: flex; background: #fff; padding: 0 20rpx; border-bottom: 1rpx solid #eee; }
	.tab { flex: 1; text-align: center; padding: 24rpx; font-size: 28rpx; color: #666; }
	.tab.active { color: #007AFF; font-weight: 600; border-bottom: 4rpx solid #007AFF; }
	.scroll { flex: 1; height: 0; padding: 20rpx; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.list { padding-bottom: 40rpx; }
	.card {
		background: #fff;
		border-radius: 16rpx;
		padding: 28rpx;
		margin-bottom: 20rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
		.card-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8rpx; }
		.title { display: block; font-size: 30rpx; font-weight: 500; color: #333; flex: 1; }
		.tag-top { font-size: 22rpx; color: #ff9500; padding: 4rpx 12rpx; border: 1rpx solid #ff9500; border-radius: 8rpx; margin-left: 8rpx; }
		.tag-offline { font-size: 22rpx; color: #999; padding: 4rpx 12rpx; border: 1rpx solid #ccc; border-radius: 8rpx; margin-left: 12rpx; }
		.actions .link { font-size: 26rpx; color: #007AFF; margin-right: 16rpx; }
		.meta { display: block; font-size: 24rpx; color: #999; margin-bottom: 8rpx; }
		.content-preview { display: block; font-size: 26rpx; color: #666; margin-bottom: 16rpx; }
		&.card-offline {
			background: #f0f0f0;
			.title { color: #888; }
			.meta { color: #aaa; }
		}
		&.card-pending { border-left: 6rpx solid #ff9500; }
		.actions { display: flex; gap: 20rpx; margin-top: 16rpx; }
		.btn-approve { flex: 1; }
		.btn-reject { background: #f5f5f5; color: #666; }
		.btn-offline { background: #f5f5f5; color: #666; }
		.btn-online { flex: 1; }
	}
	.modal-mask { position: fixed; left: 0; right: 0; top: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 100; display: flex; align-items: center; justify-content: center; padding: 40rpx; }
	.modal { background: #fff; border-radius: 20rpx; padding: 32rpx; width: 100%; max-width: 600rpx; }
	.modal-title { font-size: 32rpx; font-weight: 600; display: block; margin-bottom: 16rpx; }
	.modal-desc { font-size: 24rpx; color: #666; display: block; margin-bottom: 24rpx; }
	.form-item { margin-bottom: 20rpx; }
	.form-label { font-size: 26rpx; color: #666; display: block; margin-bottom: 8rpx; }
	.form-textarea { width: 100%; min-height: 160rpx; border: 1rpx solid #eee; border-radius: 8rpx; padding: 20rpx; font-size: 28rpx; box-sizing: border-box; }
	.modal-btns { display: flex; gap: 20rpx; margin-top: 24rpx; }
	.modal-btns .btn { flex: 1; }
	.btn-outline { background: transparent; color: #007AFF; border: 1rpx solid #007AFF; }
	.btn-primary { background: #007AFF; color: #fff; }
	.modal-feedback { max-height: 80vh; display: flex; flex-direction: column; }
	.feedback-scroll { max-height: 400rpx; margin: 16rpx 0; }
	.feedback-item { padding: 20rpx; background: #f8f8f8; border-radius: 12rpx; margin-bottom: 16rpx; }
	.feedback-content { display: block; font-size: 28rpx; color: #333; margin-bottom: 8rpx; }
	.feedback-meta { font-size: 22rpx; color: #999; }
	.feedback-empty { padding: 40rpx; text-align: center; color: #999; font-size: 28rpx; }
</style>
