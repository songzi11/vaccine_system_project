<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">医生排班管理</text>
			<view class="toolbar-buttons">
				<text class="btn-auto-generate" @click="autoGenerateSchedules">一键排班</text>
				<text class="btn-add" @click="openAdd">+ 新增排班</text>
			</view>
		</view>
		<view class="filter-row">
			<picker mode="date" :value="filterDate" @change="onFilterDateChange">
				<view class="filter-item filter-date">{{ filterDate ? '查看日期：' + filterDate : '选择日期' }}</view>
			</picker>
			<picker mode="selector" :range="doctorOptions" range-key="realName" :value="filterDoctorIndex" @change="onFilterDoctorChange">
				<view class="filter-item">{{ (doctorOptions[filterDoctorIndex] && doctorOptions[filterDoctorIndex].realName) || '全部医生' }}</view>
			</picker>
			<picker mode="selector" :range="siteOptions" range-key="siteName" :value="filterSiteIndex" @change="onFilterSiteChange">
				<view class="filter-item">{{ (siteOptions[filterSiteIndex] && siteOptions[filterSiteIndex].siteName) || '全部接种点' }}</view>
			</picker>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">该日期暂无排班，可点击右上角新增</view>
			<view v-else class="card-list">
				<view v-if="morningList.length > 0" class="period-section">
					<text class="period-title">上午</text>
					<view v-for="(item, index) in morningList" :key="'am-' + (item.id || index)" class="card">
						<view class="card-body">
							<text class="title">{{ getDoctorName(item.doctorId) }} · {{ getSiteName(item.siteId) }} · {{ item.timeSlot }}</text>
							<text class="meta">容量：{{ item.currentCount || 0 }}/1 · {{ item.status === 1 ? '启用' : '禁用' }}</text>
							<text v-if="item.doctorStatus !== 0 && item.doctorStatus != null" class="meta meta-warn">医生已注销/禁用，不可操作</text>
						</view>
						<view class="card-actions" v-if="item.doctorStatus === 0">
							<button class="btn" type="default" size="mini" @click="openEdit(item)">编辑</button>
							<button class="btn btn-danger" size="mini" @click="doDelete(item)">删除</button>
						</view>
					</view>
				</view>
				<view v-if="afternoonList.length > 0" class="period-section">
					<text class="period-title">下午</text>
					<view v-for="(item, index) in afternoonList" :key="'pm-' + (item.id || index)" class="card">
						<view class="card-body">
							<text class="title">{{ getDoctorName(item.doctorId) }} · {{ getSiteName(item.siteId) }} · {{ item.timeSlot }}</text>
							<text class="meta">容量：{{ item.currentCount || 0 }}/1 · {{ item.status === 1 ? '启用' : '禁用' }}</text>
							<text v-if="item.doctorStatus !== 0 && item.doctorStatus != null" class="meta meta-warn">医生已注销/禁用，不可操作</text>
						</view>
						<view class="card-actions" v-if="item.doctorStatus === 0">
							<button class="btn" type="default" size="mini" @click="openEdit(item)">编辑</button>
							<button class="btn btn-danger" size="mini" @click="doDelete(item)">删除</button>
						</view>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
		<!-- 新增/编辑弹窗 -->
		<uni-popup ref="popup" type="center">
			<view class="popup-content">
				<text class="popup-title">{{ editingId ? '编辑排班' : '新增排班' }}</text>
				<view class="form-item">
					<text class="label">医生</text>
					<picker mode="selector" :range="doctorOptions" range-key="realName" :value="formDoctorIndex" @change="onFormDoctorChange">
						<view class="picker-value">{{ (doctorOptions[formDoctorIndex] && doctorOptions[formDoctorIndex].realName) || '请选择医生' }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">接种点</text>
					<picker mode="selector" :range="siteOptions" range-key="siteName" :value="formSiteIndex" @change="onFormSiteChange">
						<view class="picker-value">{{ (siteOptions[formSiteIndex] && siteOptions[formSiteIndex].siteName) || '请选择接种点' }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">日期</text>
					<picker mode="date" :value="form.scheduleDate" :start="scheduleDateStart" @change="onFormDateChange">
						<view class="picker-value">{{ form.scheduleDate || '请选择日期' }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">时段（每15分钟）</text>
					<picker mode="selector" :range="timeSlots" :value="formTimeSlotIndex" @change="onFormTimeSlotChange">
						<view class="picker-value">{{ timeSlots[formTimeSlotIndex] || '请选择' }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">最大预约数</text>
					<input class="input" type="number" v-model.number="form.maxCapacity" placeholder="1" />
				</view>
				<view class="popup-actions">
					<button size="mini" @click="closePop">取消</button>
					<button size="mini" type="primary" :loading="submitting" @click="submitForm">确定</button>
				</view>
			</view>
		</uni-popup>
	</view>
</template>

<script>
	import request, { parsePageResponse } from '@/common/request.js'

	// 每天8点到17点，每15分钟一个时段，中午12点到14点休息
	const TIME_SLOTS = [
		'08:00-08:15', '08:15-08:30', '08:30-08:45', '08:45-09:00', '09:00-09:15', '09:15-09:30', '09:30-09:45', '09:45-10:00',
		'10:00-10:15', '10:15-10:30', '10:30-10:45', '10:45-11:00', '11:00-11:15', '11:15-11:30', '11:30-11:45', '11:45-12:00',
		'14:00-14:15', '14:15-14:30', '14:30-14:45', '14:45-15:00', '15:00-15:15', '15:15-15:30', '15:30-15:45', '15:45-16:00',
		'16:00-16:15', '16:15-16:30', '16:30-16:45', '16:45-17:00'
	]

	export default {
		data() {
			const today = new Date()
			const y = today.getFullYear()
			const m = today.getMonth() + 1
			const d = today.getDate()
			const startStr = y + '-' + (m < 10 ? '0' + m : m) + '-' + (d < 10 ? '0' + d : d)
			return {
				list: [],
				loading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20,
				doctorOptions: [{ id: '', realName: '全部医生' }],
				siteOptions: [{ id: '', siteName: '全部接种点' }],
				filterDoctorIndex: 0,
				filterSiteIndex: 0,
				filterDate: startStr,
				timeSlots: TIME_SLOTS,
				editingId: null,
				form: { doctorId: null, siteId: null, scheduleDate: '', timeSlot: TIME_SLOTS[0], maxCapacity: 5, status: 1 },
				formDoctorIndex: 0,
				formSiteIndex: 0,
				formTimeSlotIndex: 0,
				scheduleDateStart: startStr,
				submitting: false
			}
		},
		computed: {
			// 上午：时段 08:00-12:00（slot 开头小时 < 12）；下午：14:00-17:00
			morningList() {
				return this.list.filter(item => {
					const slot = (item.timeSlot || '').trim()
					if (!slot) return false
					// 解析时间段的开始小时
					const startTime = slot.split('-')[0]
					const hour = startTime ? parseInt(startTime.slice(0, 2), 10) : 0
					return hour >= 8 && hour < 12
				})
			},
			afternoonList() {
				return this.list.filter(item => {
					const slot = (item.timeSlot || '').trim()
					if (!slot) return false
					// 解析时间段的开始小时
					const startTime = slot.split('-')[0]
					const hour = startTime ? parseInt(startTime.slice(0, 2), 10) : 0
					return hour >= 14 && hour < 17
				})
			}
		},
		watch: {
			filterDoctorIndex() { this.page = 1; this.loadList() },
			filterSiteIndex() { this.page = 1; this.loadList() },
			filterDate() { this.page = 1; this.loadList() }
		},
		async onLoad() {
			await this.loadDoctors()
			await this.loadSites()
			await this.loadList()
		},
		methods: {
			async loadDoctors() {
				try {
					const res = await request({ url: '/api/admin/appointment/doctors', method: 'GET' })
					const data = res && res.data
					const arr = Array.isArray(data) ? data : []
					this.doctorOptions = [{ id: '', realName: '全部医生' }, ...arr]
					this.filterDoctorIndex = 0
					if (arr.length > 0) this.formDoctorIndex = 1
				} catch (e) { console.error(e) }
			},
			async loadSites() {
				try {
					const res = await request({ url: '/admin/site/list', method: 'GET', data: { current: 1, size: 100 } })
					const { list: rows } = parsePageResponse(res)
					const arr = rows || []
					this.siteOptions = [{ id: '', siteName: '全部接种点' }, ...arr]
					this.filterSiteIndex = 0
					if (arr.length > 0) this.formSiteIndex = 1
				} catch (e) { console.error(e) }
			},
			async loadList() {
				if (this.loading) return
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const doctorId = this.doctorOptions[this.filterDoctorIndex] && this.doctorOptions[this.filterDoctorIndex].id ? this.doctorOptions[this.filterDoctorIndex].id : undefined
					const siteId = this.siteOptions[this.filterSiteIndex] && this.siteOptions[this.filterSiteIndex].id ? this.siteOptions[this.filterSiteIndex].id : undefined
					const res = await request({
						url: '/api/admin/doctor-schedule/page',
						method: 'GET',
						data: { current: this.page, size: this.pageSize, doctorId, siteId, scheduleDate: this.filterDate }
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
			getDoctorName(doctorId) {
				if (!doctorId) return '未知医生'
				const doctor = this.doctorOptions.find(d => d.id === doctorId)
				return doctor ? doctor.realName : '未知医生'
			},
			getSiteName(siteId) {
				if (!siteId) return '未知接种点'
				const site = this.siteOptions.find(s => s.id === siteId)
				return site ? site.siteName : '未知接种点'
			},
			onFilterDoctorChange(e) { this.filterDoctorIndex = Number(e.detail.value) },
			onFilterSiteChange(e) { this.filterSiteIndex = Number(e.detail.value) },
			onFilterDateChange(e) { this.filterDate = e.detail.value || '' },
			onFormDoctorChange(e) { this.formDoctorIndex = Number(e.detail.value) },
			onFormSiteChange(e) { this.formSiteIndex = Number(e.detail.value) },
			onFormDateChange(e) { this.form.scheduleDate = e.detail.value || '' },
			onFormTimeSlotChange(e) {
				this.formTimeSlotIndex = Number(e.detail.value)
				this.form.timeSlot = this.timeSlots[this.formTimeSlotIndex]
			},
			openAdd() {
				this.editingId = null
				const today = new Date()
				const y = today.getFullYear()
				const m = String(today.getMonth() + 1).padStart(2, '0')
				const d = String(today.getDate()).padStart(2, '0')
				this.form = { doctorId: null, siteId: null, scheduleDate: y + '-' + m + '-' + d, timeSlot: TIME_SLOTS[0], maxCapacity: 1, status: 1 }
				this.formDoctorIndex = this.doctorOptions.length > 1 ? 1 : 0
				this.formSiteIndex = this.siteOptions.length > 1 ? 1 : 0
				this.formTimeSlotIndex = 0
				this.$refs.popup.open()
			},
			openEdit(item) {
				this.editingId = item.id
				this.form = {
					doctorId: item.doctorId,
					siteId: item.siteId,
					scheduleDate: item.scheduleDate,
					timeSlot: item.timeSlot || TIME_SLOTS[0],
					maxCapacity: item.maxCapacity != null ? item.maxCapacity : 1,
					status: item.status != null ? item.status : 1
				}
				const di = this.doctorOptions.findIndex(o => o.id === item.doctorId)
				this.formDoctorIndex = di >= 0 ? di : 0
				const si = this.siteOptions.findIndex(o => o.id === item.siteId)
				this.formSiteIndex = si >= 0 ? si : 0
				const ti = this.timeSlots.indexOf(item.timeSlot)
				this.formTimeSlotIndex = ti >= 0 ? ti : 0
				this.$refs.popup.open()
			},
			closePop() { this.$refs.popup.close() },
			async submitForm() {
				const doctor = this.doctorOptions[this.formDoctorIndex]
				const site = this.siteOptions[this.formSiteIndex]
				if (!doctor || !doctor.id) { uni.showToast({ title: '请选择医生', icon: 'none' }); return }
				if (!site || !site.id) { uni.showToast({ title: '请选择接种点', icon: 'none' }); return }
				if (!this.form.scheduleDate) { uni.showToast({ title: '请选择日期', icon: 'none' }); return }
				const maxCapacity = this.form.maxCapacity != null && this.form.maxCapacity > 0 ? this.form.maxCapacity : 1
				this.submitting = true
				try {
					if (this.editingId) {
						await request({
							url: '/api/admin/doctor-schedule/' + this.editingId,
							method: 'PUT',
							data: { scheduleDate: this.form.scheduleDate, timeSlot: this.form.timeSlot, maxCapacity, status: this.form.status }
						})
						uni.showToast({ title: '更新成功', icon: 'success' })
					} else {
						await request({
							url: '/api/admin/doctor-schedule',
							method: 'POST',
							data: {
								doctorId: doctor.id,
								siteId: site.id,
								scheduleDate: this.form.scheduleDate,
								timeSlot: this.form.timeSlot,
								maxCapacity,
								currentCount: 0,
								status: 1
							}
						})
						uni.showToast({ title: '新增成功', icon: 'success' })
					}
					this.closePop()
					this.page = 1
					this.loadList()
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.submitting = false
				}
			},
			doDelete(item) {
				uni.showModal({
					title: '确认删除',
					content: '确定删除该排班吗？已关联的预约将保留但排班记录不可恢复。',
					success: async (res) => {
						if (!res.confirm) return
						try {
							await request({ url: '/api/admin/doctor-schedule/' + item.id, method: 'DELETE' })
							uni.showToast({ title: '已删除', icon: 'success' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '删除失败', icon: 'none' })
						}
					}
				})
			},
			async autoGenerateSchedules() {
				uni.showModal({
					title: '确认一键排班',
					content: '确定要为本月所有工作日自动生成医生排班吗？此操作将为所有启用的接种点和正常状态的医生生成排班。',
					success: async (res) => {
						if (!res.confirm) return
						uni.showLoading({ title: '正在生成排班...' })
						try {
							const res = await request({
								url: '/api/admin/doctor-schedule/auto-generate-current-month',
								method: 'POST'
							})
							uni.hideLoading()
							if (res && res.code === 200) {
								uni.showToast({ title: res.message || '排班生成成功', icon: 'success' })
								// 重新加载排班列表
								this.page = 1
								this.loadList()
							} else {
								uni.showToast({ title: res.message || '排班生成失败', icon: 'none' })
							}
						} catch (e) {
							uni.hideLoading()
							uni.showToast({ title: e.message || '排班生成失败', icon: 'none' })
						}
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; justify-content: space-between; align-items: center; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.toolbar-buttons { display: flex; gap: 20rpx; }
	.btn-auto-generate { font-size: 28rpx; color: #007aff; background: #f0f8ff; padding: 10rpx 20rpx; border-radius: 8rpx; border: 1rpx solid #007aff; }
	.btn-add { font-size: 28rpx; color: #007aff; }
	.filter-row { display: flex; gap: 16rpx; padding: 20rpx; background: #fff; border-bottom: 1rpx solid #eee; flex-wrap: wrap; }
	.filter-item { padding: 16rpx 24rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 26rpx; color: #333; }
	.filter-date { min-width: 240rpx; font-weight: 500; color: #007aff; }
	.period-section { margin-bottom: 32rpx; }
	.period-title { display: block; font-size: 30rpx; font-weight: 600; color: #333; margin: 16rpx 0 16rpx 20rpx; padding-left: 12rpx; border-left: 6rpx solid #007aff; }
	.scroll { flex: 1; height: 0; }
	.card-list { padding: 20rpx; }
	.card {
		background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 20rpx;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
	}
	.title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 12rpx; }
	.meta { display: block; font-size: 26rpx; color: #666; margin-bottom: 6rpx; }
	.meta-warn { color: #e6a23c; font-size: 24rpx; }
	.card-actions { margin-top: 24rpx; display: flex; gap: 16rpx; }
	.btn-danger { color: #f56c6c; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.popup-content { background: #fff; border-radius: 16rpx; padding: 40rpx; min-width: 560rpx; }
	.popup-title { display: block; font-size: 34rpx; font-weight: 600; margin-bottom: 28rpx; }
	.form-item { margin-bottom: 24rpx; }
	.label { display: block; font-size: 26rpx; color: #666; margin-bottom: 8rpx; }
	.picker-value, .input { padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 8rpx; font-size: 28rpx; color: #333; }
	.input { margin-top: 8rpx; }
	.popup-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 32rpx; }
</style>