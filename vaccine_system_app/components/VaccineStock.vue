<template>
	<view>
		<view class="stock-toolbar">
			<text class="stock-desc">总仓剩余实时查看 · 支持按接种点批量分配多种疫苗 · 接种点司退回</text>
			<button class="btn-add" @click="openAllocate">+ 批量分配</button>
		</view>
		<!-- 总仓按疫苗剩余（实时） -->
		<view class="warehouse-summary" v-if="warehouseSummary.length > 0">
			<text class="summary-title">总仓剩余（实时）</text>
			<view class="summary-tags">
				<text class="tag" v-for="s in warehouseSummary" :key="s.vaccineId">{{ s.vaccineName }}：{{ s.stock }}</text>
			</view>
		</view>
		<!-- 分配表单：支持单选(旧) 或 批量(选接种点+多行疫苗数量) -->
		<view class="allocate-form" v-if="showAllocateForm">
			<view class="form-item">
				<text class="label">接种点</text>
				<picker mode="selector" :range="siteOptions" range-key="label" :value="allocateSiteIndex" @change="onAllocateSiteChange">
					<view class="picker-wrap">{{ (siteOptions[allocateSiteIndex] && siteOptions[allocateSiteIndex].label) || '请选择接种点' }}</view>
				</picker>
			</view>
			<view class="form-item">
				<text class="label">分配多种疫苗（可多行）</text>
				<view class="batch-rows">
					<view class="batch-row" v-for="(row, idx) in batchAllocateRows" :key="idx">
						<picker mode="selector" :range="stockVaccineOptions" range-key="label" :value="row.vaccineIndex" @change="e => onBatchVaccineChange(idx, e)">
							<view class="picker-wrap small">{{ (stockVaccineOptions[row.vaccineIndex] && stockVaccineOptions[row.vaccineIndex].label) || '疫苗' }}</view>
						</picker>
						<uni-easyinput v-model="row.quantity" type="number" placeholder="数量" :inputBorder="true" class="qty-input" />
						<text class="act danger" @click="removeBatchRow(idx)">删除</text>
					</view>
					<text class="act" @click="addBatchRow">+ 添加一行</text>
				</view>
			</view>
			<view class="form-actions">
				<button size="mini" @click="closeAllocate">取消</button>
				<button size="mini" type="primary" :loading="allocateSubmitting" @click="submitBatchAllocate">确认批量分配</button>
			</view>
		</view>
		<!-- 按接种点查看批次并退回 -->
		<view class="stock-filter">
			<text class="label">按接种点查看批次/退回：</text>
			<picker mode="selector" :range="siteOptionsForDetail" range-key="label" :value="detailSitePickerIndex" @change="onDetailSiteChange">
				<view class="picker-wrap">{{ (siteOptionsForDetail[detailSitePickerIndex] && siteOptionsForDetail[detailSitePickerIndex].label) || '选择接种点' }}</view>
			</picker>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onRefresh">
			<template v-if="detailSiteId">
				<view v-if="siteStockDetail.length === 0 && !detailLoading" class="empty">该接种点暂无按批次库存</view>
				<view v-else class="list-wrap">
					<view class="list-item stock-item batch-row-item" v-for="(item, index) in siteStockDetail" :key="item.id || index">
						<view class="item-main">
							<text class="item-title">{{ item.vaccineName || '-' }} · {{ item.batchNo || '-' }}</text>
							<text class="item-note">可用 {{ item.availableStock }} · 锁定 {{ item.lockedStock || 0 }} · 效期 {{ item.expiryDate }}</text>
							<text class="item-status" v-if="item.availableStock > 0" @click.stop="openReturn(item)">退回</text>
						</view>
					</view>
				</view>
			</template>
			<template v-else>
				<view v-if="stockList.length === 0 && !loading" class="empty">请先选择接种点查看批次，或直接批量分配</view>
				<view v-else class="list-wrap">
					<view class="list-item stock-item" v-for="(item, index) in stockList" :key="(item.siteId || '') + '-' + (item.vaccineId || '') + '-' + index">
						<view class="item-main">
							<text class="item-title">{{ item.vaccineName || '-' }}</text>
							<text class="item-note">{{ item.siteName || '-' }} · 可用库存 {{ item.quantity }}</text>
						</view>
					</view>
				</view>
			</template>
			<uni-load-more v-if="stockList.length > 0 || siteStockDetail.length > 0" :status="loadStatus" />
		</scroll-view>
		<!-- 退回弹窗 -->
		<uni-popup ref="returnPopup" type="center">
			<view class="popup-content">
				<text class="popup-title">退回总仓</text>
				<view class="form-item" v-if="returnTarget">
					<text class="label">疫苗</text>
					<text class="value">{{ returnTarget.vaccineName }} · {{ returnTarget.batchNo }}</text>
				</view>
				<view class="form-item">
					<text class="label">退回数量（可用最多 {{ returnTarget ? returnTarget.availableStock : 0 }}）</text>
					<uni-easyinput v-model="returnQuantity" type="number" placeholder="数量" :inputBorder="true" />
				</view>
				<view class="popup-actions">
					<button size="mini" @click="closeReturn">取消</button>
					<button size="mini" type="primary" :loading="returnSubmitting" @click="submitReturn">确认退回</button>
				</view>
			</view>
		</uni-popup>
	</view>
</template>

<script>
	import request, { parsePageResponse } from '@/common/request.js'

	export default {
		props: {
			warehouseSummary: {
				type: Array,
				default: () => []
			}
		},
		data() {
			return {
				showAllocateForm: false,
				allocateVaccineIndex: 0,
				allocateSiteIndex: 0,
				allocateQuantity: '1',
				allocateSubmitting: false,
				stockVaccineOptions: [],
				siteOptions: [],
				stockList: [],
				loading: false,
				detailLoading: false,
				refreshing: false,
				loadStatus: 'more',
				batchAllocateRows: [],
				detailSitePickerIndex: 0,
				detailSiteId: null,
				siteStockDetail: [],
				returnTarget: null,
				returnQuantity: '1',
				returnSubmitting: false
			}
		},
		computed: {
			siteOptionsForDetail() {
				return [{ value: null, label: '选择接种点' }].concat(this.siteOptions || [])
			}
		},
		mounted() {
			this.loadSiteOptions()
			this.loadStockList()
			this.loadStockVaccineOptions()
		},
		methods: {
			openAllocate() {
				this.showAllocateForm = true
				if (this.batchAllocateRows.length === 0) this.batchAllocateRows = [{ vaccineIndex: 0, quantity: '1' }]
				if (this.stockVaccineOptions.length === 0) this.loadStockVaccineOptions()
				if (this.siteOptions.length === 0) this.loadSiteOptions()
			},
			closeAllocate() {
				this.showAllocateForm = false
			},
			addBatchRow() {
				this.batchAllocateRows.push({ vaccineIndex: 0, quantity: '1' })
			},
			removeBatchRow(idx) {
				this.batchAllocateRows.splice(idx, 1)
			},
			onBatchVaccineChange(idx, e) {
				const newIndex = Number(e.detail.value)
				if (idx >= 0 && idx < this.batchAllocateRows.length && newIndex >= 0 && newIndex < this.stockVaccineOptions.length) {
					this.$set(this.batchAllocateRows[idx], 'vaccineIndex', newIndex)
				}
			},
			onAllocateVaccineChange(e) {
				this.allocateVaccineIndex = Number(e.detail.value)
			},
			onAllocateSiteChange(e) {
				this.allocateSiteIndex = Number(e.detail.value)
			},
			onDetailSiteChange(e) {
				this.detailSitePickerIndex = Number(e.detail.value)
				const opts = this.siteOptionsForDetail
				const opt = opts && opts[this.detailSitePickerIndex]
				this.detailSiteId = opt && opt.value != null && opt.value !== '' ? opt.value : null
				if (this.detailSiteId) this.loadSiteStockDetail()
				else this.siteStockDetail = []
			},
			async loadSiteStockDetail() {
				if (!this.detailSiteId) return
				this.detailLoading = true
				try {
					const res = await request({ url: '/admin/stock/site-stock-detail', method: 'GET', data: { siteId: this.detailSiteId } })
					this.siteStockDetail = (res && res.data) ? res.data : []
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.siteStockDetail = []
				} finally {
					this.detailLoading = false
				}
			},
			openReturn(item) {
				this.returnTarget = item
				this.returnQuantity = String(item.availableStock > 0 ? item.availableStock : 1)
				this.$refs.returnPopup && this.$refs.returnPopup.open()
			},
			closeReturn() {
				this.$refs.returnPopup && this.$refs.returnPopup.close()
			},
			async submitReturn() {
				if (!this.returnTarget || !this.returnTarget.siteId || !this.returnTarget.batchId) return
				const qty = parseInt(this.returnQuantity, 10)
				if (isNaN(qty) || qty < 1 || qty > (this.returnTarget.availableStock || 0)) {
					uni.showToast({ title: '请输入有效退回数量（不超过可用）', icon: 'none' })
					return
				}
				this.returnSubmitting = true
				try {
					await request({
						url: '/admin/stock/return-to-warehouse',
						method: 'POST',
						data: { siteId: this.returnTarget.siteId, batchId: this.returnTarget.batchId, quantity: qty }
					})
					uni.showToast({ title: '退回成功', icon: 'success' })
					this.closeReturn()
					this.loadSiteStockDetail()
					this.loadStockList()
					this.$emit('refresh-warehouse')
				} catch (e) {
					uni.showToast({ title: e.message || '退回失败', icon: 'none' })
				} finally {
					this.returnSubmitting = false
				}
			},
			async loadStockVaccineOptions() {
				try {
					const res = await request({ url: '/admin/vaccine/page', method: 'GET', data: { current: 1, size: 200, status: 1 } })
					const { list: rows } = parsePageResponse(res)
					this.stockVaccineOptions = (rows || []).map(v => ({ value: v.id, label: v.vaccineName || '疫苗#' + v.id }))
					this.batchAllocateRows.forEach(row => {
						if (row.vaccineIndex >= this.stockVaccineOptions.length) {
							row.vaccineIndex = 0
						}
					})
				} catch (_) {
					this.stockVaccineOptions = []
				}
			},
			async loadSiteOptions() {
				try {
					const res = await request({ url: '/admin/site/list', method: 'GET', data: { current: 1, size: 200 } })
					const data = res && res.data
					const rows = (data && data.records) ? data.records : (Array.isArray(data) ? data : [])
					this.siteOptions = (rows || []).map(s => ({ value: s.id, label: s.siteName || '接种点#' + s.id }))
				} catch (_) {
					this.siteOptions = []
				}
			},
			async loadStockList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const res = await request({ url: '/admin/site/list', method: 'GET', data: { current: 1, size: 200 } })
					const data = res && res.data
					const sites = (data && data.records) ? data.records : (Array.isArray(data) ? data : [])
					const list = []
					for (const site of sites || []) {
						const siteId = site.id
						const siteName = site.siteName || ('接种点#' + siteId)
						try {
							const stockRes = await request({ url: '/admin/site/' + siteId + '/stock', method: 'GET' })
							const arr = (stockRes && stockRes.data) ? stockRes.data : []
							for (const s of arr) {
								list.push({
									siteId,
									siteName,
									vaccineId: s.vaccineId,
									vaccineName: s.vaccineName || '-',
									quantity: s.quantity != null ? s.quantity : 0
								})
							}
						} catch (_) {}
					}
					this.stockList = list
					this.loadStatus = 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.loadStatus = 'more'
				} finally {
					this.loading = false
				}
			},
			onRefresh() {
				this.refreshing = true
				this.loadStockList().then(() => { this.refreshing = false })
			},
			loadMore() {
				// 库存列表为全量汇总，无需分页加载
			},
			async submitBatchAllocate() {
				const siteOpt = this.siteOptions[this.allocateSiteIndex]
				if (!siteOpt || !siteOpt.value) {
					uni.showToast({ title: '请选择接种点', icon: 'none' })
					return
				}
				const items = []
				for (const row of this.batchAllocateRows) {
					const vaccineOpt = this.stockVaccineOptions[row.vaccineIndex]
					if (!vaccineOpt || !vaccineOpt.value) continue
					const qty = parseInt(row.quantity, 10)
					if (isNaN(qty) || qty < 1) continue
					items.push({ vaccineId: vaccineOpt.value, quantity: qty })
				}
				if (items.length === 0) {
					uni.showToast({ title: '请至少添加一种疫苗及数量', icon: 'none' })
					return
				}
				this.allocateSubmitting = true
				try {
					await request({
						url: '/admin/stock/allocate-batch',
						method: 'POST',
						data: { siteId: siteOpt.value, items }
					})
					uni.showToast({ title: '批量分配成功，接种点库存已联动更新', icon: 'success' })
					this.closeAllocate()
					this.batchAllocateRows = []
					this.loadStockList()
					this.$emit('refresh-warehouse')
					if (this.detailSiteId === siteOpt.value) this.loadSiteStockDetail()
				} catch (e) {
					uni.showToast({ title: e.message || '分配失败', icon: 'none' })
				} finally {
					this.allocateSubmitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.stock-toolbar { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16rpx; }
	.stock-desc { font-size: 24rpx; color: #666; flex: 1; min-width: 0; }
	.allocate-form { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; }
	.allocate-form .picker-wrap { min-width: 140rpx; padding: 16rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 26rpx; color: #333; }
	.form-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 24rpx; }
	.form-item .label { display: block; font-size: 26rpx; color: #666; margin-bottom: 8rpx; }
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
		.stock-item .item-note { font-size: 26rpx; color: #666; margin-top: 8rpx; display: block; }
		.stock-item.batch-row-item .item-status { position: static; margin-left: 16rpx; color: #007AFF; font-size: 26rpx; }
	}
	.popup-content { background: #fff; border-radius: 16rpx; padding: 40rpx; min-width: 560rpx; }
	.popup-title { display: block; font-size: 34rpx; font-weight: 600; margin-bottom: 28rpx; }
	.form-item .value { font-size: 28rpx; color: #333; }
	.popup-actions { display: flex; gap: 24rpx; justify-content: flex-end; margin-top: 32rpx; }
	.warehouse-summary { background: #fff; padding: 20rpx 30rpx; border-bottom: 1rpx solid #eee; }
	.summary-title { font-size: 26rpx; color: #666; display: block; margin-bottom: 12rpx; }
	.summary-tags { display: flex; flex-wrap: wrap; gap: 16rpx; }
	.summary-tags .tag { font-size: 24rpx; color: #333; background: #f0f8ff; padding: 8rpx 16rpx; border-radius: 8rpx; }
	.batch-rows { margin-top: 8rpx; }
	.batch-row { display: flex; align-items: center; gap: 16rpx; margin-bottom: 16rpx; }
	.batch-row .picker-wrap.small { min-width: 160rpx; padding: 12rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 26rpx; }
	.batch-row .qty-input { width: 120rpx; }
	.stock-filter { background: #fff; padding: 16rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; align-items: center; gap: 16rpx; }
	.stock-filter .label { font-size: 26rpx; color: #666; }
</style>
