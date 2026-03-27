<template>
	<view class="page">
		<view class="toolbar"><text class="page-title">待接种（已排期）</text></view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无已排期待接种的预约</view>
			<view v-else class="card-list">
				<view v-for="(item, index) in list" :key="item.id || index" class="card">
					<view class="card-body">
						<text class="title">预约#{{ item.id }} · 疫苗ID {{ item.vaccineId }}</text>
						<text class="meta">日期：{{ item.appointmentDate }} {{ item.timeSlot || '' }}</text>
						<text class="meta">接种点ID：{{ item.siteId }} · 儿童ID：{{ item.childId }}</text>
					</view>
					<view class="card-actions">
						<button class="btn" type="primary" size="mini" @click="openVaccinate(item)">接种核销</button>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
		<!-- 核销弹窗 -->
		<uni-popup ref="popup" type="center">
			<view class="popup-content">
				<text class="popup-title">接种核销</text>
				<view class="form-item">
					<text class="label">接种部位</text>
					<uni-easyinput v-model="vaccinateForm.injectionSite" placeholder="如左上臂" :inputBorder="true" />
				</view>
				<view class="form-item">
					<text class="label">留观无异常</text>
					<picker mode="selector" :range="observationOptions" range-key="label" :value="observationIndex" @change="onObservationChange">
						<view class="picker-value">{{ observationOptions[observationIndex].label }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">不良反应记录</text>
					<textarea v-model="vaccinateForm.reaction" placeholder="选填" class="textarea" />
				</view>
				<view class="popup-actions">
					<button size="mini" @click="closePop">取消</button>
					<button size="mini" type="primary" :loading="submitting" @click="submitVaccinate">确认核销</button>
				</view>
			</view>
		</uni-popup>
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
				pageSize: 20,
				currentAppointment: null,
				vaccinateForm: { injectionSite: '', observationOk: 1, reaction: '' },
				observationOptions: [{ value: 0, label: '否' }, { value: 1, label: '是' }],
				observationIndex: 1,
				submitting: false
			}
		},
		onLoad() {
			this.loadList()
		},
		methods: {
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const uid = getUserId()
					const doctorId = uid ? Number(uid) : undefined
					const res = await request({
						url: '/api/doctor/appointments/scheduled',
						method: 'GET',
						data: { current: this.page, size: this.pageSize, doctorId }
					})
					const data = res && res.data
					const rows = (data && data.records) ? data.records : (Array.isArray(data) ? data : [])
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
			onObservationChange(e) {
				this.observationIndex = Number(e.detail.value)
				this.vaccinateForm.observationOk = this.observationOptions[this.observationIndex].value
			},
			openVaccinate(item) {
				this.currentAppointment = item
				this.vaccinateForm = { injectionSite: '', observationOk: 1, reaction: '' }
				this.observationIndex = 1
				this.$refs.popup.open()
			},
			closePop() {
				this.$refs.popup.close()
			},
			async submitVaccinate() {
				if (!this.currentAppointment || !this.currentAppointment.id) return
				this.submitting = true
				try {
					const operatorId = getUserId()
					await request({
						url: '/api/doctor/vaccinate',
						method: 'POST',
						data: {
							appointmentId: this.currentAppointment.id,
							operatorUserId: operatorId ? Number(operatorId) : undefined,
							doseNumber: 1,
							injectionSite: this.vaccinateForm.injectionSite || undefined,
							observationOk: this.vaccinateForm.observationOk,
							reaction: this.vaccinateForm.reaction || undefined
						}
					})
					uni.showToast({ title: '核销成功', icon: 'success' })
					this.closePop()
					this.page = 1
					this.loadList()
				} catch (e) {
					uni.showToast({ title: e.message || '核销失败', icon: 'none' })
				} finally {
					this.submitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.scroll { flex: 1; height: 0; }
	.card-list { padding: 20rpx; }
	.card {
		background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 20rpx;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
	}
	.title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 12rpx; }
	.meta { display: block; font-size: 26rpx; color: #666; margin-bottom: 6rpx; }
	.card-actions { margin-top: 24rpx; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.popup-content { background: #fff; border-radius: 16rpx; padding: 40rpx; min-width: 560rpx; }
	.popup-title { display: block; font-size: 34rpx; font-weight: 600; margin-bottom: 28rpx; }
	.form-item { margin-bottom: 24rpx; }
	.label { display: block; font-size: 26rpx; color: #666; margin-bottom: 8rpx; }
	.picker-value { padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 8rpx; font-size: 28rpx; }
	.textarea { width: 100%; min-height: 80rpx; padding: 16rpx; border: 1rpx solid #e5e5e5; border-radius: 8rpx; font-size: 28rpx; }
	.popup-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 32rpx; }
</style>
