<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">公告</text>
			<text class="link" @click="showSubmit = true">+ 提交新公告</text>
		</view>
		<view class="tabs">
			<view class="tab" :class="{ active: tab === 'my' }" @click="tab = 'my'; loadMy()">我的申请</view>
			<view class="tab" :class="{ active: tab === 'view' }" @click="tab = 'view'; loadPublished()">已发布公告</view>
		</view>
		<scroll-view scroll-y class="scroll">
			<view v-if="tab === 'my'">
				<view v-if="myList.length === 0 && !myLoading" class="empty">暂无申请记录</view>
				<view v-else class="list">
					<view v-for="(item, i) in myList" :key="item.id || i" class="card" :class="auditClass(item.auditStatus)">
						<text class="title">{{ item.title || '无标题' }}</text>
						<text class="meta">状态：{{ auditText(item.auditStatus) }}</text>
						<text class="meta" v-if="item.rejectReason">管理员意见：{{ item.rejectReason }}</text>
						<text class="time">{{ item.createTime || '' }}</text>
						<view class="actions" v-if="item.auditStatus === 'PENDING' || item.auditStatus === 'REJECTED'">
							<text v-if="item.auditStatus === 'PENDING'" class="link" @click="withdraw(item)">撤回</text>
							<text v-if="item.auditStatus === 'REJECTED'" class="link" @click="reapply(item)">修改后重新申请</text>
						</view>
					</view>
				</view>
			</view>
			<view v-else>
				<view v-if="pubList.length === 0 && !pubLoading" class="empty">暂无已发布公告</view>
				<view v-else class="list">
					<view v-for="(item, i) in pubList" :key="item.id || i" class="card" @click="openFeedback(item)">
						<text class="title">{{ item.title || '无标题' }}</text>
						<text class="meta">{{ item.publisherRole === 'DOCTOR' ? '医生发布' : '管理员发布' }} · {{ item.publishTime || '' }}</text>
						<text class="link feedback-link">提交意见给管理员</text>
					</view>
				</view>
			</view>
		</scroll-view>

		<!-- 提交新公告 -->
		<view v-if="showSubmit" class="modal-mask" @click="showSubmit = false">
			<view class="modal" @click.stop>
				<text class="modal-title">提交新公告申请</text>
				<view class="form-item">
					<text class="label">标题</text>
					<input v-model="submitForm.title" placeholder="请输入标题" class="input" />
				</view>
				<view class="form-item">
					<text class="label">内容</text>
					<textarea v-model="submitForm.content" placeholder="请输入内容" class="textarea" />
				</view>
				<view class="modal-actions">
					<button size="mini" @click="showSubmit = false">取消</button>
					<button size="mini" type="primary" :loading="submitting" @click="submitNotice">提交</button>
				</view>
			</view>
		</view>

		<!-- 意见反馈 -->
		<view v-if="feedbackNotice" class="modal-mask" @click="feedbackNotice = null">
			<view class="modal" @click.stop>
				<text class="modal-title">对「{{ feedbackNotice.title }}」提交意见</text>
				<textarea v-model="feedbackContent" placeholder="输入意见内容，提交给管理员" class="textarea" />
				<view class="modal-actions">
					<button size="mini" @click="feedbackNotice = null">取消</button>
					<button size="mini" type="primary" :loading="feedbackSubmitting" @click="submitFeedback">提交</button>
				</view>
			</view>
		</view>

		<!-- 修改后重新申请 -->
		<view v-if="reapplyItem" class="modal-mask" @click="reapplyItem = null">
			<view class="modal" @click.stop>
				<text class="modal-title">修改后重新申请</text>
				<view class="form-item">
					<text class="label">标题</text>
					<input v-model="reapplyForm.title" placeholder="请输入标题" class="input" />
				</view>
				<view class="form-item">
					<text class="label">内容</text>
					<textarea v-model="reapplyForm.content" placeholder="请输入内容" class="textarea" />
				</view>
				<view class="modal-actions">
					<button size="mini" @click="reapplyItem = null">取消</button>
					<button size="mini" type="primary" :loading="reapplySubmitting" @click="confirmReapply">提交</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
	import request, { getUserId } from '@/common/request.js'

	export default {
		data() {
			return {
				tab: 'my',
				myList: [],
				pubList: [],
				myLoading: false,
				pubLoading: false,
				showSubmit: false,
				submitForm: { title: '', content: '' },
				submitting: false,
				feedbackNotice: null,
				feedbackContent: '',
				feedbackSubmitting: false,
				reapplyItem: null,
				reapplyForm: { title: '', content: '' },
				reapplySubmitting: false
			}
		},
		onLoad() {
			this.loadMy()
		},
		methods: {
			auditText(s) {
				const m = { PENDING: '待审批', APPROVED: '已通过', REJECTED: '未通过' }
				return m[s] || s || ''
			},
			auditClass(s) {
				if (s === 'PENDING') return 'card-pending'
				if (s === 'APPROVED') return 'card-approved'
				if (s === 'REJECTED') return 'card-rejected'
				return ''
			},
			async loadMy() {
				this.myLoading = true
				try {
					const res = await request({
						url: '/api/doctor/notice/my',
						method: 'GET',
						data: { doctorId: getUserId() }
					})
					this.myList = (res && res.data) ? res.data : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.myList = []
				} finally {
					this.myLoading = false
				}
			},
			async loadPublished() {
				this.pubLoading = true
				try {
					const res = await request({
						url: '/api/notice/list',
						method: 'GET',
						data: { current: 1, size: 50 }
					})
					const data = res && res.data
					this.pubList = (data && data.records) ? data.records : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.pubList = []
				} finally {
					this.pubLoading = false
				}
			},
			async submitNotice() {
				if (!this.submitForm.title || !this.submitForm.title.trim()) {
					uni.showToast({ title: '请输入标题', icon: 'none' })
					return
				}
				const doctorId = getUserId()
				this.submitting = true
				try {
					await request({
						url: '/api/doctor/notice/submit?doctorId=' + (doctorId || ''),
						method: 'POST',
						data: { title: this.submitForm.title.trim(), content: this.submitForm.content || '' }
					})
					uni.showToast({ title: '提交成功，等待管理员审批', icon: 'success' })
					this.showSubmit = false
					this.submitForm = { title: '', content: '' }
					this.loadMy()
				} catch (e) {
					uni.showToast({ title: e.message || '提交失败', icon: 'none' })
				} finally {
					this.submitting = false
				}
			},
			async withdraw(item) {
				uni.showModal({
					title: '确认撤回',
					content: '撤回后该申请将删除，确定撤回？',
					success: async (res) => {
						if (res.confirm) {
							try {
								const doctorId = getUserId()
								await request({
									url: '/api/doctor/notice/' + item.id + '/withdraw?doctorId=' + (doctorId || ''),
									method: 'DELETE'
								})
								uni.showToast({ title: '已撤回', icon: 'success' })
								this.loadMy()
							} catch (e) {
								uni.showToast({ title: e.message || '操作失败', icon: 'none' })
							}
						}
					}
				})
			},
			reapply(item) {
				this.reapplyItem = item
				this.reapplyForm = { title: item.title || '', content: item.content || '' }
			},
			async confirmReapply() {
				if (!this.reapplyItem) return
				const doctorId = getUserId()
				this.reapplySubmitting = true
				try {
					await request({
						url: '/api/doctor/notice/' + this.reapplyItem.id + '/reapply?doctorId=' + (doctorId || ''),
						method: 'PUT',
						data: { title: this.reapplyForm.title, content: this.reapplyForm.content }
					})
					uni.showToast({ title: '已重新提交审批', icon: 'success' })
					this.reapplyItem = null
					this.loadMy()
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.reapplySubmitting = false
				}
			},
			openFeedback(item) {
				this.feedbackNotice = item
				this.feedbackContent = ''
			},
			async submitFeedback() {
				if (!this.feedbackNotice || !this.feedbackContent || !this.feedbackContent.trim()) {
					uni.showToast({ title: '请输入意见内容', icon: 'none' })
					return
				}
				this.feedbackSubmitting = true
				try {
					await request({
						url: '/api/doctor/notice/feedback',
						method: 'POST',
						data: {
							noticeId: this.feedbackNotice.id,
							userId: getUserId(),
							content: this.feedbackContent.trim()
						}
					})
					uni.showToast({ title: '提交成功', icon: 'success' })
					this.feedbackNotice = null
				} catch (e) {
					uni.showToast({ title: e.message || '提交失败', icon: 'none' })
				} finally {
					this.feedbackSubmitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; justify-content: space-between; align-items: center; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.link { font-size: 28rpx; color: #007AFF; }
	.tabs { display: flex; background: #fff; }
	.tab { flex: 1; text-align: center; padding: 24rpx; font-size: 28rpx; color: #666; }
	.tab.active { color: #007AFF; font-weight: 600; border-bottom: 4rpx solid #007AFF; }
	.scroll { flex: 1; height: 0; padding: 20rpx; }
	.empty { padding: 80rpx; text-align: center; color: #999; font-size: 28rpx; }
	.list { padding-bottom: 40rpx; }
	.card {
		background: #fff;
		border-radius: 16rpx;
		padding: 28rpx;
		margin-bottom: 20rpx;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
		.title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 8rpx; }
		.meta, .time { display: block; font-size: 24rpx; color: #999; margin-bottom: 4rpx; }
		.actions { margin-top: 16rpx; }
		.feedback-link { font-size: 26rpx; }
		&.card-pending { border-left: 6rpx solid #ff9500; }
		&.card-approved { border-left: 6rpx solid #34C759; }
		&.card-rejected { border-left: 6rpx solid #ee0a24; }
	}
	.modal-mask { position: fixed; left: 0; right: 0; top: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 100; display: flex; align-items: center; justify-content: center; padding: 40rpx; }
	.modal { background: #fff; border-radius: 20rpx; padding: 32rpx; width: 100%; max-width: 600rpx; }
	.modal-title { display: block; font-size: 32rpx; font-weight: 600; margin-bottom: 24rpx; }
	.form-item { margin-bottom: 20rpx; }
	.label { display: block; font-size: 26rpx; color: #666; margin-bottom: 8rpx; }
	.input { border: 1rpx solid #eee; border-radius: 8rpx; padding: 20rpx; font-size: 28rpx; }
	.textarea { width: 100%; min-height: 160rpx; border: 1rpx solid #eee; border-radius: 8rpx; padding: 20rpx; font-size: 28rpx; box-sizing: border-box; }
	.modal-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 32rpx; }
</style>
