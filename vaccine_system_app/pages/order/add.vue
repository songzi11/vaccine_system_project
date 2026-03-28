<template>
	<view class="page">
		<ClockBar ref="clockBarRef" />
		<view class="steps-hint">选择儿童 → 选择疫苗 → 选择时段 → 提交</view>
		<uni-forms ref="formRef" :model="form" :rules="rules" label-width="120rpx" label-position="top">
			<view class="form-card">
				<uni-forms-item label="选择儿童" name="childId" required>
					<picker
						mode="selector"
						:range="childOptions"
						range-key="label"
						:value="childIndex"
						@change="onChildChange"
					>
						<view class="picker-value">
							{{ childOptions[childIndex] ? childOptions[childIndex].label : '请选择要接种的宝宝' }}
						</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="疫苗" name="vaccineId" required>
					<picker
						mode="selector"
						:range="vaccineOptions"
						range-key="label"
						:value="vaccineIndex"
						@change="onVaccineChange"
					>
						<view class="picker-value">
							{{ vaccineOptions[vaccineIndex] ? vaccineOptions[vaccineIndex].label : '请选择疫苗' }}
						</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="接种点" name="siteId" required>
					<picker
						mode="selector"
						:range="siteOptions"
						range-key="label"
						:value="siteIndex"
						@change="onSiteChange"
					>
						<view class="picker-value">
							{{ siteOptions[siteIndex] ? siteOptions[siteIndex].label : '请选择接种点' }}
						</view>
					</picker>
				</uni-forms-item>
				<view v-if="stockHint !== null" class="stock-hint" :class="{ 'low': stockHint === 0 }">
					{{ stockHint === 0 ? '该接种点该疫苗库存不足，请换接种点或疫苗' : '当前库存：' + stockHint }}
				</view>
				<uni-forms-item label="预约日期" name="orderDate" required>
					<picker
						mode="date"
						:value="form.orderDate"
						:start="dateRangeStart"
						:end="dateRangeEnd"
						@change="onOrderDateChange"
					>
						<view class="picker-value">
							{{ form.orderDate || '请选择日期（仅未来30天内）' }}
						</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item name="doctorScheduleId" required>
					<template #label>
						<view class="slot-label-wrap">
							<text class="slot-label-main">预约时段</text>
							<text class="slot-label-sub">驻场医生排班</text>
						</view>
					</template>
					<TimeSlotPicker
						ref="timeSlotPickerRef"
						:site-id="form.siteId"
						:order-date="form.orderDate"
						:date-range-start="dateRangeStart"
						:date-range-end="dateRangeEnd"
						@select="onSlotSelect"
					/>
				</uni-forms-item>
				<uni-forms-item label="备注" name="remark">
					<textarea v-model="form.remark" placeholder="选填" class="textarea" maxlength="200" />
				</uni-forms-item>
			</view>
			<view class="btn-wrap">
				<button class="btn-submit" type="primary" :loading="loading" @click="submit">提交预约</button>
			</view>
		</uni-forms>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

	export default {
		components: {
			TimeSlotPicker: () => import('@/components/TimeSlotPicker.vue'),
			ClockBar: () => import('@/components/ClockBar.vue')
		},
		data() {
			return {
				form: {
					childId: '',
					vaccineId: '',
					siteId: '',
					orderDate: '',
					doctorScheduleId: '',
					remark: ''
				},
				rules: {
					childId: { rules: [{ required: true, errorMessage: '请选择儿童' }] },
					vaccineId: { rules: [{ required: true, errorMessage: '请选择疫苗' }] },
					siteId: { rules: [{ required: true, errorMessage: '请选择接种点' }] },
					orderDate: { rules: [{ required: true, errorMessage: '请填写预约日期' }] },
					doctorScheduleId: { rules: [{ required: true, errorMessage: '请选择可约时段' }] }
				},
				childOptions: [],
				childIndex: 0,
				vaccineOptions: [],
				vaccineIndex: 0,
				siteOptions: [],
				siteIndex: 0,
				stockHint: null,
				loading: false
			}
		},
		computed: {
			dateRangeStart() {
				const d = new Date()
				const y = d.getFullYear()
				const m = d.getMonth() + 1
				const day = d.getDate()
				return y + '-' + (m < 10 ? '0' + m : m) + '-' + (day < 10 ? '0' + day : day)
			},
			dateRangeEnd() {
				const d = new Date()
				d.setDate(d.getDate() + 30)
				const y = d.getFullYear()
				const m = String(d.getMonth() + 1).padStart(2, '0')
				const day = String(d.getDate()).padStart(2, '0')
				return y + '-' + m + '-' + day
			}
		},
		onLoad(options) {
			this.setDateRange()
			if (options.childId) this.form.childId = options.childId
			if (options.vaccineId) this.form.vaccineId = options.vaccineId
			this.loadChildren()
			this.loadVaccines()
			this.loadSites()
		},
		methods: {
			setDateRange() {
				if (!this.form.orderDate) {
					const d = new Date()
					const y = d.getFullYear()
					const m = d.getMonth() + 1
					const day = d.getDate()
					this.form.orderDate = y + '-' + (m < 10 ? '0' + m : m) + '-' + (day < 10 ? '0' + day : day)
				}
			},
			onOrderDateChange(e) {
				this.form.orderDate = e.detail.value || ''
				this.form.doctorScheduleId = ''
				if (this.$refs.timeSlotPickerRef) {
					this.$refs.timeSlotPickerRef.setSelectedId('')
				}
			},
			async loadChildren() {
				try {
					const userId = getUserId()
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: 1, size: 50, parentId: userId }
					})
					const { list } = parsePageResponse(res)
					this.childOptions = (list || []).map(c => ({
						label: (c.name || '宝宝') + '（' + this.ageMonths(c) + '月龄）',
						value: c.id
					}))
					if (this.childOptions.length && !this.form.childId) {
						this.form.childId = this.childOptions[0].value
						this.childIndex = 0
					}
					if (this.form.childId) {
						const i = this.childOptions.findIndex(o => String(o.value) === String(this.form.childId))
						this.childIndex = i >= 0 ? i : 0
						if (i >= 0) this.form.childId = this.childOptions[i].value
					}
				} catch (e) {
					uni.showToast({ title: e.message || '加载儿童列表失败', icon: 'none' })
				}
			},
			ageMonths(c) {
				if (!c.birthDate) return '-'
				const birth = new Date(c.birthDate)
				const now = new Date()
				let m = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth())
				if (now.getDate() < birth.getDate()) m--
				return m < 0 ? 0 : m
			},
			async loadVaccines() {
				try {
					const res = await request({ url: '/vaccine/list', method: 'GET', data: { current:1, size: 999, status: 1 } })
					const { list: rows } = parsePageResponse(res)
					this.vaccineOptions = (rows || []).filter(r => r.status !== 0).map(r => ({
						label: r.vaccineName || r.name || ('疫苗' + (r.id || '')),
						value: r.id
					}))
					if (this.vaccineOptions.length && !this.form.vaccineId) {
						this.form.vaccineId = this.vaccineOptions[0].value
						this.vaccineIndex = 0
					}
					if (this.form.vaccineId) {
						const i = this.vaccineOptions.findIndex(o => String(o.value) === String(this.form.vaccineId))
						this.vaccineIndex = i >= 0 ? i : 0
					}
					this.fetchStockHint()
				} catch (e) {
					uni.showToast({ title: e.message || '加载疫苗列表失败', icon: 'none' })
				}
			},
			async loadSites() {
				try {
					const res = await request({ url: '/user/site/listWithStock', method: 'GET' })
					const list = (res && res.data && Array.isArray(res.data)) ? res.data : []
					this.siteOptions = (list || []).map(r => {
						const name = r.siteName || r.name || ('接种点' + (r.id || ''))
						const doctor = r.currentDoctorName ? ' · 驻场医生：' + r.currentDoctorName : ''
						return {
							label: name + doctor,
							value: r.id
						}
					})
					if (this.siteOptions.length && !this.form.siteId) {
						this.form.siteId = this.siteOptions[0].value
						this.siteIndex = 0
					} else if (this.form.siteId) {
						this.siteIndex = this.siteOptions.findIndex(o => String(o.value) === String(this.form.siteId))
						if (this.siteIndex < 0) this.siteIndex = 0
					}
					this.fetchStockHint()
				} catch (e) {
					uni.showToast({ title: e.message || '加载接种点失败', icon: 'none' })
				}
			},
			onChildChange(e) {
				const i = Number(e.detail.value)
				this.childIndex = i
				if (this.childOptions[i]) this.form.childId = this.childOptions[i].value
			},
			onVaccineChange(e) {
				const i = Number(e.detail.value)
				this.vaccineIndex = i
				if (this.vaccineOptions[i]) this.form.vaccineId = this.vaccineOptions[i].value
				this.fetchStockHint()
			},
			onSiteChange(e) {
				const i = Number(e.detail.value)
				this.siteIndex = i
				if (this.siteOptions[i]) this.form.siteId = this.siteOptions[i].value
				this.form.doctorScheduleId = ''
				this.fetchStockHint()
				if (this.$refs.timeSlotPickerRef) {
					this.$refs.timeSlotPickerRef.setSelectedId('')
				}
			},
			onSlotSelect(slot) {
				if (this.$refs.timeSlotPickerRef) {
					this.$refs.timeSlotPickerRef.setSelectedId(slot.id)
				}
				this.form.doctorScheduleId = slot.id
			},
			async fetchStockHint() {
				if (!this.form.vaccineId || !this.form.siteId) {
					this.stockHint = null
					return
				}
				try {
					const res = await request({
						url: '/order/stock',
						method: 'GET',
						data: { vaccineId: this.form.vaccineId, siteId: this.form.siteId }
					})
					this.stockHint = (res && res.data != null) ? res.data : 0
				} catch (_) {
					this.stockHint = null
				}
			},
			submit() {
				this.$refs.formRef.validate().then(() => {
					this.doSubmit()
				}).catch(err => {
					uni.showToast({ title: err[0]?.errorMessage || '请完善表单', icon: 'none' })
				})
			},
			async doSubmit() {
				this.loading = true
				try {
					if (this.stockHint !== null && this.stockHint <= 0) {
						uni.showToast({ title: '当前接种点该疫苗库存不足', icon: 'none' })
						return
					}
					await request({
						url: '/api/appointment/create',
						method: 'POST',
						data: {
							childId: this.form.childId,
							vaccineId: this.form.vaccineId,
							doctorScheduleId: this.form.doctorScheduleId,
							userId: getUserId() ? Number(getUserId()) : undefined,
							remark: this.form.remark || undefined
						}
					})
					uni.showToast({ title: '预约成功', icon: 'success' })
					setTimeout(() => {
						uni.navigateBack()
					}, 1000)
				} catch (e) {
					uni.showToast({ title: e.message || '提交失败', icon: 'none' })
				} finally {
					this.loading = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		min-height: 100vh;
		background: #f5f5f5;
		padding: 30rpx;
	}
	.steps-hint {
		font-size: 24rpx;
		color: #666;
		margin-bottom: 24rpx;
		padding: 16rpx 20rpx;
		background: #fff;
		border-radius: 12rpx;
	}
	.form-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		margin-bottom: 30rpx;
	}
	.picker-value {
		padding: 24rpx;
		background: #f8f8f8;
		border-radius: 12rpx;
		font-size: 28rpx;
		color: #333;
	}
	.textarea {
		width: 100%;
		min-height: 160rpx;
		padding: 20rpx;
		background: #f8f8f8;
		border-radius: 12rpx;
		font-size: 28rpx;
	}
	.stock-hint {
		font-size: 24rpx;
		color: #07c160;
		padding: 12rpx 0 16rpx;
		&.low { color: #ee0a24; }
	}
	.btn-wrap {
		padding: 0 10rpx;
		.btn-submit {
			width: 100%;
			height: 88rpx;
			line-height: 88rpx;
			border-radius: 44rpx;
			font-size: 32rpx;
		}
	}
	.slot-label-wrap {
		display: flex;
		flex-direction: column;
		gap: 4rpx;
		.slot-label-main { font-size: 28rpx; font-weight: 500; color: #333; }
		.slot-label-sub { font-size: 22rpx; color: #999; }
	}
</style>
