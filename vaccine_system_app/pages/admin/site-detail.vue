<template>
	<view class="page">
		<view class="toolbar">
			<text class="back" @click="back">返回</text>
			<text class="page-title">接种点详情</text>
		</view>
		<scroll-view scroll-y class="scroll" v-if="detail">
			<!-- 基础信息 -->
			<view class="block">
				<text class="block-title">基础信息</text>
				<view class="info-row"><text class="label">名称</text><text>{{ detail.siteName }}</text></view>
				<view class="info-row"><text class="label">地址</text><text>{{ detail.address || '-' }}</text></view>
				<view class="info-row"><text class="label">联系电话</text><text>{{ detail.contactPhone || '-' }}</text></view>
				<view class="info-row"><text class="label">工作时间</text><text>{{ detail.workTime || '-' }}</text></view>
				<view class="info-row"><text class="label">状态</text><text :class="detail.status === 1 ? 'text-green' : 'text-red'">{{ detail.statusDesc || (detail.status === 1 ? '启用' : '禁用') }}</text></view>
				<view class="info-row"><text class="label">驻场医生</text><text>{{ detail.currentDoctorName || '空' }}</text></view>
				<view class="info-row" v-if="detail.todayAppointmentCount != null"><text class="label">今日预约数</text><text>{{ detail.todayAppointmentCount }}</text></view>
			</view>

			<!-- 启用/禁用 -->
			<view class="block">
				<text class="block-title">启用状态</text>
				<view class="btn-row">
					<button class="btn btn-enable" :disabled="detail.status === 1" @click="doEnable">启用</button>
					<button class="btn btn-disable" :disabled="detail.status === 0" @click="doDisable">禁用</button>
				</view>
			</view>

			<!-- 驻场医生（直接指派，指派后向医生推送派遣信息） -->
			<view class="block">
				<text class="block-title">驻场医生</text>
				<picker :range="doctorList" range-key="realName" @change="onDoctorPick" :value="doctorPickIndex">
					<view class="picker-wrap">
						<text>{{ (doctorList[doctorPickIndex] && doctorList[doctorPickIndex].realName) || '选择医生' }}</text>
						<uni-icons type="right" size="16" color="#999"></uni-icons>
					</view>
				</picker>
				<button class="btn btn-primary" @click="openAssignConfirm">指派为驻场医生</button>
				<button class="btn btn-outline" @click="clearDoctor">清空驻场医生</button>
			</view>

			<!-- 删除接种点（二次确认） -->
			<view class="block">
				<text class="block-title">危险操作</text>
				<button class="btn btn-danger" @click="openDeleteConfirm">删除接种点</button>
			</view>

			<!-- 疫苗库存（只读，增减请在「疫苗管理-库存管理」中分配） -->
			<view class="block">
				<text class="block-title">疫苗库存</text>
				<view v-if="!detail.stockList || detail.stockList.length === 0" class="empty-tip">暂无库存记录</view>
				<view v-else class="stock-list">
					<view v-for="s in detail.stockList" :key="s.vaccineId" class="stock-row">
						<view class="stock-info">
							<text class="stock-name">{{ s.vaccineName }}</text>
							<text class="stock-qty">库存 {{ s.quantity }}</text>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>
		<view v-else class="loading-wrap"><uni-load-more status="loading" /></view>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		data() {
			return {
				siteId: null,
				detail: null,
				doctorList: [],
				doctorPickIndex: 0
			}
		},
		onLoad(options) {
			this.siteId = options.id ? Number(options.id) : null
			if (!this.siteId) {
				uni.showToast({ title: '缺少接种点ID', icon: 'none' })
				return
			}
			this.loadDetail()
			this.loadDoctors()
		},
		methods: {
			back() {
				uni.navigateBack()
			},
			async loadDetail() {
				try {
					// 与库存接口同一控制器，优先用 /admin/site 保证权限一致
					const res = await request({ url: '/admin/site/' + this.siteId, method: 'GET' })
					this.detail = (res && res.data) ? res.data : null
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				}
			},
			async loadDoctors() {
				try {
					const res = await request({ url: '/admin/user/page', method: 'GET', data: { current: 1, size: 200, role: 'DOCTOR' } })
					const data = res && res.data
					this.doctorList = (data && data.records) ? data.records : []
				} catch (_) {
					this.doctorList = []
				}
			},
			onDoctorPick(e) {
				this.doctorPickIndex = Number(e.detail.value)
			},
			openAssignConfirm() {
				const doc = this.doctorList[this.doctorPickIndex]
				if (!doc || !doc.id) {
					uni.showToast({ title: '请选择医生', icon: 'none' })
					return
				}
				uni.showModal({
					title: '确认指派',
					content: '驻场医生不可重复。指派后该医生将仅驻场本接种点，其原驻场接种点将自动禁用。是否继续？',
					success: (r) => {
						if (!r.confirm) return
						request({
							url: '/admin/site/' + this.siteId + '/assignDoctor/' + doc.id,
							method: 'POST'
						}).then(() => {
							uni.showToast({ title: '已指派，医生将收到调遣通知', icon: 'success' })
							this.loadDetail()
						}).catch(err => uni.showToast({ title: err.message || '操作失败', icon: 'none' }))
					}
				})
			},
			clearDoctor() {
				uni.showModal({
					title: '确认',
					content: '确定清空该接种点的驻场医生吗？',
					success: (r) => {
						if (!r.confirm) return
						request({ url: '/admin/site/' + this.siteId + '/clearDoctor', method: 'POST' })
							.then(() => {
								uni.showToast({ title: '已清空', icon: 'success' })
								this.loadDetail()
							})
							.catch(err => uni.showToast({ title: err.message || '操作失败', icon: 'none' }))
					}
				})
			},
			doEnable() {
				request({ url: '/admin/site/enable/' + this.siteId, method: 'POST' })
					.then(() => { uni.showToast({ title: '已启用', icon: 'success' }); this.loadDetail() })
					.catch(err => uni.showToast({ title: err.message || '失败', icon: 'none' }))
			},
			doDisable() {
				uni.showModal({
					title: '确认',
					content: '确定禁用该接种点吗？禁用后用户端将不可见。',
					success: (r) => {
						if (!r.confirm) return
						request({ url: '/admin/site/disable/' + this.siteId, method: 'POST' })
							.then(() => { uni.showToast({ title: '已禁用', icon: 'success' }); this.loadDetail() })
							.catch(err => uni.showToast({ title: err.message || '失败', icon: 'none' }))
					}
				})
			},
			openDeleteConfirm() {
				const name = (this.detail && this.detail.siteName) ? this.detail.siteName : '该接种点'
				uni.showModal({
					title: '确认删除',
					content: `确定要删除接种点「${name}」吗？`,
					success: (r) => {
						if (!r.confirm) return
						uni.showModal({
							title: '二次确认',
							content: '删除后数据不可恢复，是否确认删除？',
							confirmText: '确认删除',
							confirmColor: '#ee0a24',
							success: (r2) => {
								if (!r2.confirm) return
								request({ url: '/admin/site/' + this.siteId, method: 'DELETE' })
									.then(() => {
										uni.showToast({ title: '已删除', icon: 'success' })
										setTimeout(() => { uni.navigateBack() }, 500)
									})
									.catch(err => uni.showToast({ title: err.message || '删除失败', icon: 'none' }))
							}
						})
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; background: #f5f5f5; display: flex; flex-direction: column; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; align-items: center; gap: 20rpx; }
	.back { font-size: 30rpx; color: #007AFF; }
	.page-title { font-size: 34rpx; font-weight: bold; color: #333; }
	.scroll { flex: 1; padding: 20rpx; }
	.loading-wrap { padding: 120rpx; text-align: center; }
	.block { background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 24rpx; }
	.block-title { font-size: 30rpx; font-weight: 600; color: #333; display: block; margin-bottom: 20rpx; }
	.block-desc { font-size: 24rpx; color: #999; display: block; margin-bottom: 16rpx; }
	.block-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
	.block-head .block-title { margin-bottom: 0; }
	.link { font-size: 28rpx; color: #007AFF; }
	.info-row { font-size: 28rpx; color: #333; margin-top: 12rpx; }
	.label { color: #999; margin-right: 12rpx; }
	.text-green { color: #2e7d32; }
	.text-red { color: #c62828; }
	.btn-row { display: flex; gap: 20rpx; margin-top: 12rpx; }
	.btn { margin-top: 12rpx; }
	.btn-enable { background: #2e7d32; color: #fff; }
	.btn-disable { background: #c62828; color: #fff; }
	.btn-outline { background: transparent; color: #007AFF; border: 1rpx solid #007AFF; }
	.btn-primary { background: #007AFF; color: #fff; }
	.btn-danger { background: #ee0a24; color: #fff; }
	.picker-wrap { padding: 20rpx; background: #f5f5f5; border-radius: 12rpx; font-size: 28rpx; display: flex; justify-content: space-between; align-items: center; }
	.empty-tip { font-size: 26rpx; color: #999; padding: 20rpx 0; }
	.stock-list { }
	.stock-row { display: flex; justify-content: space-between; align-items: center; padding: 20rpx 0; border-bottom: 1rpx solid #eee; }
	.stock-info { flex: 1; min-width: 0; }
	.stock-name { font-size: 28rpx; color: #333; display: block; }
	.stock-qty { font-size: 24rpx; color: #666; margin-top: 4rpx; display: block; }
	.stock-actions { display: flex; gap: 24rpx; }
	.act { font-size: 26rpx; color: #007AFF; }
	.act-danger { color: #ee0a24; }
	.modal-mask { position: fixed; left: 0; right: 0; top: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 100; }
	.modal { background: #fff; border-radius: 20rpx; padding: 36rpx; width: 100%; max-width: 600rpx; }
	.modal-fixed { position: fixed; left: 50%; top: 50%; transform: translate(-50%, -50%); z-index: 101; margin: 0; width: 85%; max-width: 600rpx; box-sizing: border-box; }
	.modal-title { font-size: 32rpx; font-weight: 600; display: block; margin-bottom: 12rpx; }
	.modal-desc { font-size: 26rpx; color: #666; display: block; margin-bottom: 24rpx; }
	.form-item { margin-bottom: 24rpx; }
	.form-label { font-size: 26rpx; color: #666; display: block; margin-bottom: 8rpx; }
	.form-input { width: 100%; padding: 20rpx; border: 1rpx solid #eee; border-radius: 12rpx; font-size: 28rpx; box-sizing: border-box; }
	.modal-btns { display: flex; gap: 20rpx; margin-top: 24rpx; }
	.modal-btns .btn { flex: 1; }
</style>
