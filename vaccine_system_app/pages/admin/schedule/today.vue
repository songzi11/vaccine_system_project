<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">今日排班</text>
			<text class="btn-refresh" @click="loadData">🔄</text>
		</view>
		<view class="date-header">
			<text class="date-text">{{ overview.date }} {{ overview.dayOfWeek }}</text>
		</view>
		<scroll-view scroll-y class="scroll">
			<view v-if="overview.doctors.length === 0 && !loading" class="empty">
				<text>今日暂无排班</text>
				<text>可前往排班管理页面添加排班</text>
			</view>
			<view v-else class="card-list">
				<view v-for="(doctor, index) in overview.doctors" :key="index" class="doctor-card">
					<view class="card-header">
						<text class="doctor-name">{{ doctor.doctorName }}</text>
						<text class="status-badge" :class="doctor.status">{{ doctor.status === 'normal' ? '在岗' : '部分禁用' }}</text>
					</view>
					<view class="card-body">
						<text class="info-row">📞 {{ doctor.doctorPhone }}</text>
						<text class="info-row">🏥 {{ doctor.siteName }}</text>
						<text class="info-row">🕐 上午：{{ doctor.morningSlotCount }}  下午：{{ doctor.afternoonSlotCount }}</text>
						<text class="info-row">👥 今日预约：{{ doctor.todayAppointmentCount }}人</text>
					</view>
					<view class="card-actions">
						<button class="action-btn btn-morning" @click="openReplaceDialog(doctor, 'morning')">上午换班</button>
						<button class="action-btn btn-afternoon" @click="openReplaceDialog(doctor, 'afternoon')">下午换班</button>
						<button class="action-btn btn-all" @click="openReplaceDialog(doctor, 'all')">全天</button>
					</view>
				</view>
			</view>
		</scroll-view>

		<!-- 换班弹窗 -->
		<uni-popup ref="replacePopup" type="center">
			<view class="replace-popup">
				<text class="popup-title">选择顶班医生</text>
				<scroll-view scroll-y class="doctor-scroll">
					<view v-if="availableDoctors.length === 0" class="empty-doctors">
						<text>暂无可用医生</text>
					</view>
					<view v-else>
						<view
							v-for="(doc, idx) in availableDoctors"
							:key="idx"
							class="doctor-option"
							:class="{ 'selected': selectedDoctorId === doc.id }"
							@click="selectDoctor(doc)"
						>
							<text class="option-name">{{ doc.realName }} ({{ doc.gender === 1 ? '男' : '女' }})</text>
							<text class="option-site">✅ {{ getDoctorSiteName(doc.id) }}</text>
							<text class="option-phone">📞 {{ doc.phone }}</text>
						</view>
					</view>
				</scroll-view>
				<view class="popup-actions">
					<button size="mini" @click="closeReplacePopup">取消</button>
					<button size="mini" type="primary" :loading="replacing" @click="confirmReplace">确定更换</button>
				</view>
			</view>
		</uni-popup>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		data() {
			const today = new Date()
			const y = today.getFullYear()
			const m = String(today.getMonth() + 1).padStart(2, '0')
			const d = String(today.getDate()).padStart(2, '0')
			return {
				loading: false,
				replacing: false,
				overview: {
					date: `${y}-${m}-${d}`,
					dayOfWeek: '',
					doctors: []
				},
				availableDoctors: [],
				selectedDoctorId: null,
				replaceInfo: {
					oldDoctorId: null,
					periodType: null
				},
				siteMap: {},
				doctorSiteMap: {}
			}
		},
		async onLoad() {
			await this.loadSites()
			await this.loadData()
		},
		methods: {
			async loadSites() {
				try {
					const res = await request({ url: '/admin/site/list', method: 'GET', data: { current: 1, size: 100 } })
					const { list } = res?.data || {}
					if (Array.isArray(list)) {
						list.forEach(site => {
							this.siteMap[site.id] = site.siteName
						})
					}
				} catch (e) {
					console.error('加载接种点失败', e)
				}
			},
			async loadData() {
				if (this.loading) return
				this.loading = true
				try {
					const res = await request({ url: '/api/admin/doctor-schedule/today-overview', method: 'GET' })
					if (res?.code === 200 && res?.data) {
						this.overview = {
							date: res.data.date || this.overview.date,
							dayOfWeek: res.data.dayOfWeek || '',
							doctors: res.data.doctors || []
						}
					}
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				} finally {
					this.loading = false
				}
			},
			async loadDoctors() {
				try {
					const res = await request({ url: '/api/admin/appointment/doctors', method: 'GET' })
					const doctors = res?.data || []
					// 排除当前正在被替换的医生
					this.availableDoctors = doctors.filter(doc => doc.id !== this.replaceInfo.oldDoctorId)
					// 加载医生的接种点信息
					await this.loadDoctorsSiteInfo()
				} catch (e) {
					console.error('加载医生列表失败', e)
					this.availableDoctors = []
				}
			},
			async loadDoctorsSiteInfo() {
				this.doctorSiteMap = {}
				const today = new Date().toISOString().split('T')[0]
				for (const doc of this.availableDoctors) {
					try {
						const res = await request({
							url: '/api/admin/doctor-schedule/page',
							method: 'GET',
							data: { current: 1, size: 1, doctorId: doc.id, scheduleDate: today }
						})
						const schedules = res?.data?.records || []
						if (schedules.length > 0) {
							const siteId = schedules[0].siteId
							this.doctorSiteMap[doc.id] = this.siteMap[siteId] || '未知接种点'
						} else {
							this.doctorSiteMap[doc.id] = '今日无排班'
						}
					} catch (e) {
						this.doctorSiteMap[doc.id] = '未知接种点'
					}
				}
			},
			getDoctorSiteName(doctorId) {
				return this.doctorSiteMap[doctorId] || '未知接种点'
			},
			openReplaceDialog(doctor, periodType) {
				this.replaceInfo = {
					oldDoctorId: doctor.doctorId,
					periodType: periodType
				}
				this.selectedDoctorId = null
				this.loadDoctors().then(() => {
					this.$refs.replacePopup.open()
				})
			},
			closeReplacePopup() {
				this.$refs.replacePopup.close()
				this.selectedDoctorId = null
			},
			selectDoctor(doc) {
				this.selectedDoctorId = doc.id
			},
			async confirmReplace() {
				if (!this.selectedDoctorId) {
					uni.showToast({ title: '请选择顶班医生', icon: 'none' })
					return
				}
				this.replacing = true
				try {
					const res = await request({
						url: '/api/admin/doctor-schedule/batch-replace',
						method: 'POST',
						data: {
							oldDoctorId: this.replaceInfo.oldDoctorId,
							newDoctorId: this.selectedDoctorId,
							date: this.overview.date,
							periodType: this.replaceInfo.periodType
						}
					})
					if (res?.code === 200) {
						const replacedCount = res?.data?.replacedCount || 0
						uni.showToast({ title: `已替换${replacedCount}个时段`, icon: 'success' })
						this.closeReplacePopup()
						this.loadData()
					} else {
						uni.showToast({ title: res?.message || '替换失败', icon: 'none' })
					}
				} catch (e) {
					uni.showToast({ title: e.message || '替换失败', icon: 'none' })
				} finally {
					this.replacing = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; justify-content: space-between; align-items: center; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.btn-refresh { font-size: 36rpx; }
	.date-header { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #eee; }
	.date-text { font-size: 32rpx; font-weight: 500; color: #007aff; }
	.scroll { flex: 1; height: 0; }
	.card-list { padding: 20rpx; }
	.doctor-card {
		background: #fff; border-radius: 16rpx; padding: 28rpx;
		margin-bottom: 20rpx; box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
	}
	.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20rpx; }
	.doctor-name { font-size: 34rpx; font-weight: 600; color: #333; }
	.status-badge { padding: 8rpx 16rpx; border-radius: 20rpx; font-size: 24rpx; }
	.status-badge.normal { background: #67c23a; color: #fff; }
	.status-badge.partial { background: #e6a23c; color: #fff; }
	.card-body { margin-bottom: 24rpx; }
	.info-row { display: block; font-size: 28rpx; color: #666; margin-bottom: 10rpx; line-height: 1.5; }
	.card-actions { display: flex; gap: 16rpx; }
	.action-btn { flex: 1; font-size: 26rpx; height: 70rpx; line-height: 70rpx; border-radius: 8rpx; border: none; }
	.btn-morning { background: #e1f3ff; color: #007aff; }
	.btn-afternoon { background: #fff4e1; color: #e6a23c; }
	.btn-all { background: #f0f8ff; color: #67c23a; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; display: flex; flex-direction: column; gap: 16rpx; }
	.replace-popup { background: #fff; border-radius: 16rpx; width: 600rpx; max-height: 800rpx; display: flex; flex-direction: column; }
	.popup-title { font-size: 34rpx; font-weight: 600; padding: 30rpx; border-bottom: 1rpx solid #eee; }
	.doctor-scroll { flex: 1; max-height: 500rpx; }
	.doctor-option {
		padding: 24rpx 30rpx; border-bottom: 1rpx solid #f5f5f5;
	}
	.doctor-option.selected { background: #f0f8ff; }
	.option-name { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 8rpx; }
	.option-site { display: block; font-size: 26rpx; color: #666; margin-bottom: 6rpx; }
	.option-phone { display: block; font-size: 26rpx; color: #999; }
	.empty-doctors { padding: 80rpx; text-align: center; color: #999; font-size: 28rpx; }
	.popup-actions { padding: 24rpx; border-top: 1rpx solid #eee; display: flex; gap: 24rpx; justify-content: flex-end; }
</style>
