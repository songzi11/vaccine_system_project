<template>
	<view>
		<view class="toolbar">
			<text class="page-title">批次管理</text>
			<button class="btn-add" @click="openAddBatch">新增批次</button>
		</view>
		<view class="search-bar">
			<picker mode="selector" :range="vaccineOptions" range-key="label" :value="vaccineIndex" @change="onVaccineChange">
				<view class="picker-wrap">{{ vaccineOptions[vaccineIndex].label }}</view>
			</picker>
			<picker mode="selector" :range="batchStatusOptions" range-key="label" :value="batchStatusIndex" @change="onBatchStatusChange">
				<view class="picker-wrap">{{ batchStatusOptions[batchStatusIndex].label }}</view>
			</picker>
			<button class="btn-search" size="mini" @click="onBatchSearch">查询</button>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadBatchMore" :lower-threshold="80" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onBatchRefresh">
			<view v-if="batchList.length === 0 && !loading" class="empty">暂无批次数据</view>
			<view v-else class="list-wrap">
				<view class="list-item batch-item" v-for="(item, index) in batchList" :key="item.id || index">
					<view class="item-main">
						<text class="item-title">{{ getVaccineName(item.vaccineId) || '疫苗#' + item.vaccineId }}</text>
						<text class="item-note">批号：{{ item.batchNo || '-' }} · 保质期至：{{ item.expiryDate || '-' }} · 库存：{{ item.stock }}</text>
						<text class="item-status" :class="batchStatusClass(item.status)">{{ batchStatusText(item.status) }}</text>
					</view>
					<view class="item-actions">
						<text class="act danger" v-if="canDispose(item)" @click="doDispose(item)">执行销毁</text>
					</view>
				</view>
			</view>
			<uni-load-more v-if="batchList.length > 0" :status="loadStatus" />
		</scroll-view>

		<!-- 销毁弹窗 -->
		<uni-popup ref="disposePopup" type="center">
			<view class="popup-content">
				<text class="popup-title">执行销毁</text>
				<view class="form-item">
					<text class="label">批次</text>
					<text class="value">{{ disposeTarget ? disposeTarget.batchNo : '' }}</text>
				</view>
				<view class="form-item">
					<text class="label">销毁原因</text>
					<uni-easyinput v-model="disposeForm.disposalReason" placeholder="如：过期销毁" :inputBorder="true" />
				</view>
				<view class="form-item">
					<text class="label">备注</text>
					<uni-easyinput v-model="disposeForm.remark" placeholder="选填" :inputBorder="true" />
				</view>
				<view class="popup-actions">
					<button size="mini" @click="closeDispose">取消</button>
					<button size="mini" type="primary" :loading="disposeSubmitting" @click="submitDispose">确认销毁</button>
				</view>
			</view>
		</uni-popup>

		<!-- 新增批次弹窗 -->
		<uni-popup ref="addBatchPopup" type="center">
			<view class="popup-content">
				<text class="popup-title">新增批次</text>
				<view class="form-item">
					<text class="label">疫苗</text>
					<picker mode="selector" :range="vaccineOptionsForBatch" range-key="label" :value="batchForm.vaccineIndex" @change="onBatchVaccineChange">
						<view class="picker-wrap">{{ (vaccineOptionsForBatch[batchForm.vaccineIndex] && vaccineOptionsForBatch[batchForm.vaccineIndex].label) || '请选择疫苗' }}</view>
					</picker>
				</view>
				<view class="form-item">
					<text class="label">批号（自动生成）</text>
					<view class="batch-no-display">{{ generatedBatchNo || '请选择疫苗并设置生产日期' }}</view>
				</view>
				<view class="form-item">
					<text class="label">生产日期</text>
					<uni-datetime-picker v-model="batchForm.productionDate" type="date" :border="true" @change="onProductionDateChange" />
				</view>
				<view class="form-item">
					<text class="label">有效期至</text>
					<uni-datetime-picker v-model="batchFormEXpiryDate" type="date" :border="true" />
				</view>
				<view class="form-item">
					<text class="label">库存数量</text>
					<uni-easyinput v-model="batchForm.stock" type="number" placeholder="请输入库存数量" :inputBorder="true" />
				</view>
				<view class="form-item">
					<text class="label">预警天数</text>
					<uni-easyinput v-model="batchForm.warningDays" type="number" placeholder="请输入预警天数，默认30天" :inputBorder="true" />
				</view>
				<view class="popup-actions">
					<button size="mini" @click="closeAddBatch">取消</button>
					<button size="mini" type="primary" :loading="batchSubmitting" @click="submitBatch">确认新增</button>
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
				batchList: [],
				loading: false,
				refreshing: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20,
				vaccineOptions: [{ value: '', label: '全部疫苗' }],
				vaccineIndex: 0,
				batchStatusIndex: 0,
				batchStatusOptions: [
					{ value: null, label: '全部状态' },
					{ value: 0, label: '正常' },
					{ value: 1, label: '临期' },
					{ value: 2, label: '过期' },
					{ value: 3, label: '已销毁' }
				],
				disposeTarget: null,
				disposeForm: { disposalReason: '过期销毁', remark: '' },
				disposeSubmitting: false,
				batchForm: {
					vaccineIndex: 0,
					batchNo: '',
					productionDate: '',
					expiryDate: '',
					stock: '',
					warningDays: '30'
				},
				batchSubmitting: false,
				vaccineOptionsForBatch: [{ value: null, label: '请选择疫苗' }]
			}
		},
		computed: {
			generatedBatchNo() {
				const vaccineOpt = this.vaccineOptionsForBatch[this.batchForm.vaccineIndex]
				if (!vaccineOpt || !vaccineOpt.value || !this.batchForm.productionDate) return ''
				const vaccine = vaccineOpt.label
				let shortCode = 'VAC'
				if (vaccine) shortCode = vaccine.substring(0, 3).toUpperCase()
				const dateStr = this.batchForm.productionDate.replace(/-/g, '')
				return shortCode + dateStr + '001'
			}
		},
		mounted() {
			this.loadVaccineOptions()
		},
		methods: {
			batchStatusText(code) {
				const m = { 0: '正常', 1: '临期', 2: '过期', 3: '已销毁' }
				return m[code] != null ? m[code] : '未知'
			},
			batchStatusClass(code) {
				const m = { 0: 'status-ok', 1: 'status-warn', 2: 'status-expired', 3: 'status-disposed' }
				return m[code] || ''
			},
			getVaccineName(vaccineId) {
				if (vaccineId == null) return ''
				const opt = this.vaccineOptions.find(o => o.value === vaccineId || o.value === Number(vaccineId))
				return opt ? opt.label : ''
			},
			canDispose(item) {
				return item && (item.status === 1 || item.status === 2) && item.stock >= 0
			},
			onVaccineChange(e) {
				this.vaccineIndex = Number(e.detail.value)
				this.page = 1
				this.loadBatchList()
			},
			onBatchStatusChange(e) {
				this.batchStatusIndex = Number(e.detail.value)
				this.page = 1
				this.loadBatchList()
			},
			onBatchSearch() {
				this.page = 1
				this.loadBatchList()
			},
			onBatchRefresh() {
				this.refreshing = true
				this.page = 1
				this.loadBatchList().then(() => {
					this.refreshing = false
				})
			},
			async loadVaccineOptions() {
				try {
					const res = await request({
						url: '/admin/vaccine/page',
						method: 'GET',
						data: { current: 1, size: 200, status: 1 }
					})
					const { list: rows } = parsePageResponse(res)
					const options = [{ value: '', label: '全部疫苗' }]
					;(rows || []).forEach(v => {
						options.push({ value: v.id, label: v.vaccineName || '疫苗#' + v.id })
					})
					this.vaccineOptions = options
				} catch (_) {}
			},
			async loadBatchList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const vaccineId = this.vaccineOptions[this.vaccineIndex] ? this.vaccineOptions[this.vaccineIndex].value : undefined
					const status = this.batchStatusOptions[this.batchStatusIndex] ? this.batchStatusOptions[this.batchStatusIndex].value : undefined
					const res = await request({
						url: '/admin/batch/page',
						method: 'GET',
						data: {
							current: this.page,
							size: this.pageSize,
							vaccineId: vaccineId || undefined,
							status: status
						}
					})
					const data = res && res.data
					const rows = (data && data.records) ? data.records : (Array.isArray(data) ? data : [])
					if (this.page === 1) this.batchList = rows || []
					else this.batchList = this.batchList.concat(rows || [])
					this.loadStatus = (rows && rows.length >= this.pageSize) ? 'more' : 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.loadStatus = 'more'
				} finally {
					this.loading = false
				}
			},
			loadBatchMore() {
				if (this.loadStatus !== 'more' || this.loading) return
				this.page++
				this.loadBatchList()
			},
			doDispose(item) {
				this.disposeTarget = item
				this.disposeForm = { disposalReason: '过期销毁', remark: '' }
				this.$refs.disposePopup && this.$refs.disposePopup.open()
			},
			closeDispose() {
				this.$refs.disposePopup && this.$refs.disposePopup.close()
			},
			async submitDispose() {
				if (!this.disposeTarget || !this.disposeTarget.id) return
				this.disposeSubmitting = true
				try {
					const operatorId = getUserId()
					await request({
						url: '/admin/batch/dispose',
						method: 'POST',
						data: {
							batchId: this.disposeTarget.id,
							disposalReason: this.disposeForm.disposalReason || '过期销毁',
							operatorId: operatorId ? Number(operatorId) : undefined,
							remark: this.disposeForm.remark || undefined
						}
					})
					uni.showToast({ title: '销毁记录已提交', icon: 'success' })
					this.closeDispose()
					this.page = 1
					this.loadBatchList()
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.disposeSubmitting = false
				}
			},
			openAddBatch() {
				this.loadVaccineOptionsForBatch()
				this.batchForm = {
					vaccineIndex: 0,
					batchNo: '',
					productionDate: '',
					expiryDate: '',
					stock: '',
					warningDays: '30'
				}
				this.$refs.addBatchPopup && this.$refs.addBatchPopup.open()
			},
			closeAddBatch() {
				this.$refs.addBatchPopup && this.$refs.addBatchPopup.close()
			},
			async loadVaccineOptionsForBatch() {
				try {
					const res = await request({
						url: '/admin/vaccine/page',
						method: 'GET',
						data: { current: 1, size: 200, status: 1 }
					})
					const { list: rows } = parsePageResponse(res)
					const options = [{ value: null, label: '请选择疫苗' }]
					;(rows || []).forEach(v => {
						options.push({ value: v.id, label: v.vaccineName || '疫苗#' + v.id })
					})
					this.vaccineOptionsForBatch = options
					this.batchForm.vaccineIndex = 0
				} catch (_) {}
			},
			onBatchVaccineChange(e) {
				const newIndex = Number(e.detail.value)
				if (newIndex >= 0 && newIndex < this.vaccineOptionsForBatch.length) {
					this.batchForm.vaccineIndex = newIndex
					if (!this.batchForm.batchNo && this.generatedBatchNo) {
						this.batchForm.batchNo = this.generatedBatchNo
					}
				}
			},
			onProductionDateChange(e) {
				this.batchForm.productionDate = e.detail.value
				if (!this.batchForm.batchNo && this.generatedBatchNo) {
					this.batchForm.batchNo = this.generatedBatchNo
				}
			},
			async submitBatch() {
				const vaccineOpt = this.vaccineOptionsForBatch[this.batchForm.vaccineIndex]
				if (!vaccineOpt || !vaccineOpt.value) {
					uni.showToast({ title: '请选择疫苗', icon: 'none' })
					return
				}
				if (!this.batchForm.batchNo && this.generatedBatchNo) {
					this.batchForm.batchNo = this.generatedBatchNo
				}
				if (!this.batchForm.batchNo) {
					uni.showToast({ title: '请输入批号', icon: 'none' })
					return
				}
				if (!this.batchForm.productionDate) {
					uni.showToast({ title: '请选择生产日期', icon: 'none' })
					return
				}
				if (!this.batchForm.expiryDate) {
					uni.showToast({ title: '请选择有效期', icon: 'none' })
					return
				}
				const stock = parseInt(this.batchForm.stock, 10)
				if (isNaN(stock) || stock < 0) {
					uni.showToast({ title: '请输入有效的库存数量', icon: 'none' })
					return
				}
				const warningDays = parseInt(this.batchForm.warningDays, 10)
				if (isNaN(warningDays) || warningDays < 0) {
					uni.showToast({ title: '请输入有效的预警天数', icon: 'none' })
					return
				}
				this.batchSubmitting = true
				try {
					const batchData = {
						vaccineId: vaccineOpt.value,
						batchNo: this.batchForm.batchNo,
						productionDate: this.batchForm.productionDate,
						expiryDate: this.batchForm.expiryDate,
						stock: stock,
						warningDays: warningDays,
						status: 0
					}
					await request({
						url: '/admin/batch',
						method: 'POST',
						data: batchData
					})
					uni.showToast({ title: '新增批次成功', icon: 'success' })
					this.closeAddBatch()
					this.page = 1
					this.loadBatchList()
				} catch (e) {
					uni.showToast({ title: e.message || '新增失败', icon: 'none' })
				} finally {
					this.batchSubmitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.toolbar {
		background: #fff;
		padding: 24rpx 30rpx;
		border-bottom: 1rpx solid #eee;
		display: flex;
		align-items: center;
		justify-content: space-between;
		.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
		.btn-add { font-size: 28rpx; padding: 12rpx 24rpx; background: #007AFF; color: #fff; border-radius: 8rpx; border: none; }
	}
	.search-bar {
		background: #fff;
		padding: 16rpx 30rpx;
		display: flex;
		align-items: center;
		gap: 16rpx;
		border-bottom: 1rpx solid #eee;
		.picker-wrap { min-width: 140rpx; padding: 16rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 26rpx; color: #333; }
		.btn-search { padding: 12rpx 24rpx; background: #007AFF; color: #fff; border-radius: 8rpx; font-size: 26rpx; border: none; }
	}
	.scroll { flex: 1; height: 0; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.list-wrap { padding: 20rpx; }
	.list-item {
		background: #fff;
		border-radius: 12rpx;
		margin-bottom: 20rpx;
		overflow: hidden;
		box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.06);
		.item-main { padding: 24rpx 30rpx; position: relative; }
		.item-title { font-size: 32rpx; font-weight: 600; color: #333; display: block; }
		.item-note { font-size: 26rpx; color: #666; margin-top: 8rpx; display: block; }
		.item-status { position: absolute; right: 30rpx; top: 24rpx; font-size: 24rpx; padding: 4rpx 12rpx; border-radius: 6rpx; }
		.item-actions { display: flex; border-top: 1rpx solid #eee; padding: 16rpx 30rpx; gap: 24rpx; }
		.act { font-size: 26rpx; color: #007AFF; }
		.act.danger { color: #f44336; }
		&.batch-item {
			.item-status.status-ok { color: #07c160; background: #e8f8f0; }
			.item-status.status-warn { color: #ed6a0c; background: #fff4e8; }
			.item-status.status-expired { color: #999; background: #f0f0f0; }
			.item-status.status-disposed { color: #666; background: #eee; }
		}
	}
	.popup-content { background: #fff; border-radius: 16rpx; padding: 40rpx; min-width: 560rpx; }
	.popup-title { display: block; font-size: 34rpx; font-weight: 600; margin-bottom: 28rpx; }
	.form-item { margin-bottom: 24rpx; }
	.form-item .label { display: block; font-size: 26rpx; color: #666; margin-bottom: 8rpx; }
	.form-item .value { font-size: 28rpx; color: #333; }
	.popup-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 32rpx; }
	.batch-no-display {
		font-size: 28rpx;
		color: #007AFF;
		padding: 16rpx;
		background: #f0f8ff;
		border-radius: 8rpx;
		border: 1rpx dashed #007AFF;
		min-height: 40rpx;
		display: flex;
		align-items: center;
	}
</style>
