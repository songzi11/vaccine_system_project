<template>
	<view class="page">
		<view class="date-bar">{{ nowDate }}</view>
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
					<view v-if="!form.siteId || !form.orderDate" class="picker-value hint">请先选择接种点和预约日期</view>
					<view v-else class="slot-wrap">
						<scroll-view scroll-x class="slot-scroll" :show-scrollbar="true">
							<view class="slot-list">
								<view
									v-for="slot in slotsForSelectedDate"
									:key="slot.id"
									class="slot-item"
									:class="{ booked: slot.booked, selected: form.doctorScheduleId === slot.id, expired: slot.expired }"
									@click="onSlotClick(slot)"
								>
									<text class="slot-time">{{ slot.timeSlot || '-' }}</text>
									<text class="slot-status">{{ slot.expired ? '已过期' : slot.booked ? '已约' : '可约' }}</text>
								</view>
							</view>
						</scroll-view>
						<view v-if="slotsForSelectedDate.length === 0 && !scheduleLoading" class="slot-empty">该日期暂无排班</view>
						<view v-if="scheduleLoading" class="slot-loading">加载排班中...</view>
					</view>
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
				loading: false,
				nowDate: '',
				dateTimer: null,
				scheduleList: [],
				scheduleLoading: false
			}
		},
		created() {
			this.updateNowDate()
		},
		onLoad(options) {
			this.updateNowDate()
			this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			if (options.childId) this.form.childId = options.childId
			if (options.vaccineId) this.form.vaccineId = options.vaccineId
			this.setDateRange()
			this.loadChildren()
			this.loadVaccines()
			this.loadSites()
		},
		onShow() {
			this.updateNowDate()
			if (!this.dateTimer) {
				this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			}
		},
		onHide() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
			}
		},
		onUnload() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
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
			},
			slotsForSelectedDate() {
				if (!this.form.orderDate || !this.scheduleList.length) return []
				const dateStr = String(this.form.orderDate).slice(0, 10)
				const list = this.scheduleList.filter(s => String(s.scheduleDate || '').slice(0, 10) === dateStr)
				return list.map(s => ({
					id: s.id,
					timeSlot: s.timeSlot,
					booked: (s.currentCount != null && s.maxCapacity != null) && s.currentCount >= s.maxCapacity,
					expired: this.isSlotExpired(s),
					doctorId: s.doctorId,
					siteId: s.siteId,
					scheduleDate: s.scheduleDate
				}))
			}
		},
		methods: {
			updateNowDate() {
				const d = new Date()
				const y = d.getFullYear()
				const m = String(d.getMonth() + 1).padStart(2, '0')
				const day = String(d.getDate()).padStart(2, '0')
				const h = String(d.getHours()).padStart(2, '0')
				const min = String(d.getMinutes()).padStart(2, '0')
				const s = String(d.getSeconds()).padStart(2, '0')
				const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
				this.nowDate = `${y}年${m}月${day}日 周${week} ${h}:${min}:${s}`
			},
			// 判断排班时段是否已过期
			isSlotExpired(slot) {
				// 如果没有排班日期或时间段，认为不过期
				if (!slot.scheduleDate || !slot.timeSlot) return false

				// 获取当前时间
				const now = new Date()

				// 解析排班日期
				const scheduleDate = new Date(slot.scheduleDate)

				// 如果排班日期早于今天，则过期
				if (scheduleDate < new Date(now.getFullYear(), now.getMonth(), now.getDate())) {
					return true
				}

				// 如果是今天的排班，需要进一步判断时间
				if (scheduleDate.getDate() === now.getDate() &&
					scheduleDate.getMonth() === now.getMonth() &&
					scheduleDate.getFullYear() === now.getFullYear()) {

					// 解析时间段（假设格式为 "HH:MM-HH:MM"）
					const timeMatch = slot.timeSlot.match(/^(\d{1,2}):(\d{2})/)
					if (timeMatch) {
						const slotHour = parseInt(timeMatch[1])
						const slotMinute = parseInt(timeMatch[2])

						// 创建排班时段的结束时间
						const slotEndTime = new Date(scheduleDate)
						slotEndTime.setHours(slotHour, slotMinute, 0, 0)

						// 如果当前时间已经过了排班时段的结束时间，则过期
						return now > slotEndTime
					}
				}

				// 默认不过期
				return false
			},
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
					const res = await request({ url: '/vaccine/list', method: 'GET', data: { current: 1, size: 999, status: 1 } })
					const { list: rows } = parsePageResponse(res)
					// 仅展示上架疫苗；不可用（年龄/禁忌症/间隔）由后端智能接口校验
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
					this.loadSchedules()
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
				this.loadSchedules()
			},
			async loadSchedules() {
				if (!this.form.siteId) {
					this.scheduleList = []
					return
				}
				this.scheduleLoading = true
				try {
					const from = this.dateRangeStart
					const end = this.dateRangeEnd
					const res = await request({
						url: '/api/appointment/schedules',
						method: 'GET',
						data: { siteId: this.form.siteId, fromDate: from, toDate: end }
					})
					this.scheduleList = (res && res.data && Array.isArray(res.data)) ? res.data : []
				} catch (_) {
					this.scheduleList = []
				} finally {
					this.scheduleLoading = false
				}
			},
			onSlotClick(slot) {
				if (slot.expired) {
					uni.showToast({ title: '该时段已过期', icon: 'none' })
					return
				}
				if (slot.booked) {
					uni.showToast({ title: '该时段已约满', icon: 'none' })
					return
				}
				// 检查该医生在该时段是否已经被预约
				this.checkDoctorSlotOccupied(slot).then(isOccupied => {
					if (isOccupied) {
						uni.showToast({ title: '该医生在此时间段已有预约', icon: 'none' })
						return
					}
					this.form.doctorScheduleId = slot.id
				})
			},

			// 检查医生在特定时段是否已经被预约
			async checkDoctorSlotOccupied(slot) {
				if (!slot.doctorId || !slot.scheduleDate || !slot.timeSlot) {
					return false
				}

				try {
					// 这里需要调用后端API检查医生时段占用情况
					// 由于当前API没有提供此功能，我们暂时返回false
					// 在实际实现中，这里应该调用后端API
					return false
				} catch (e) {
					console.error('检查医生时段占用情况失败', e)
					return false
				}
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
					// 使用智能预约接口：后端校验年龄、禁忌症、间隔、库存防超卖；提交所选排班ID
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
	.date-bar {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		background-color: #667eea;
		color: #fff;
		text-align: center;
		padding: 20rpx 24rpx;
		font-size: 28rpx;
		font-weight: 500;
		min-height: 40rpx;
		flex-shrink: 0;
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
	.picker-value.hint {
		color: #999;
	}
	.slot-label-wrap {
		display: flex;
		flex-direction: column;
		gap: 4rpx;
		.slot-label-main { font-size: 28rpx; font-weight: 500; color: #333; }
		.slot-label-sub { font-size: 22rpx; color: #999; }
	}
	.slot-wrap { width: 100%; }
	.slot-scroll { white-space: nowrap; width: 100%; }
	.slot-list {
		display: inline-flex;
		flex-wrap: nowrap;
		gap: 20rpx;
		padding: 12rpx 0 24rpx;
		min-width: min-content;
	}
	.slot-item {
		flex-shrink: 0;
		min-width: 200rpx;
		padding: 24rpx 28rpx;
		background: #f0f9ff;
		border-radius: 12rpx;
		border: 2rpx solid #e0e0e0;
		display: inline-flex;
		align-items: center;
		justify-content: space-between;
		&.booked {
			background: #f5f5f5;
			color: #999;
			border-color: #eee;
		}
		&.expired {
			background: #f5f5f5;
			color: #999;
			border-color: #eee;
		}
		&.selected {
			border-color: #07c160;
			background: #e8f8f0;
		}
		.slot-time { font-size: 28rpx; color: #333; }
		.slot-status { font-size: 24rpx; color: #07c160; }
		&.booked .slot-status { color: #999; }
		&.expired .slot-status { color: #999; }
	}
	.slot-empty, .slot-loading {
		width: 100%;
		padding: 24rpx;
		text-align: center;
		color: #999;
		font-size: 26rpx;
	}
</style>
