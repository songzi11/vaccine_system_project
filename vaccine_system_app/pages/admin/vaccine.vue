<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">疫苗管理</text>
			<button v-if="tabIndex === 0" class="btn-add" @click="goAdd">新增疫苗</button>
		</view>
		<!-- Tab：疫苗列表 | 批次管理 | 库存管理 -->
		<view class="tabs">
			<view class="tab" :class="{ active: tabIndex === 0 }" @click="tabIndex = 0">疫苗列表</view>
			<view class="tab" :class="{ active: tabIndex === 1 }" @click="switchToBatch">批次管理</view>
			<view class="tab" :class="{ active: tabIndex === 2 }" @click="switchToStock">库存管理</view>
		</view>

		<!-- 疫苗列表 Tab -->
		<template v-if="tabIndex === 0">
			<VaccineList
				ref="vaccineListRef"
				:warehouse-summary="warehouseSummary"
				@action-menu="openActionMenu"
			/>
		</template>

		<!-- 批次管理 Tab -->
		<template v-else-if="tabIndex === 1">
			<VaccineBatch ref="vaccineBatchRef" />
		</template>

		<!-- 库存管理 Tab -->
		<template v-else>
			<VaccineStock
				ref="vaccineStockRef"
				:warehouse-summary="warehouseSummary"
				@refresh-warehouse="loadWarehouseSummary"
			/>
		</template>

		<!-- 操作菜单弹窗 -->
		<VaccineActionMenu
			ref="actionMenuRef"
			@action="handleAction"
		/>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	export default {
		components: {
			VaccineList: () => import('@/components/VaccineList.vue'),
			VaccineBatch: () => import('@/components/VaccineBatch.vue'),
			VaccineStock: () => import('@/components/VaccineStock.vue'),
			VaccineActionMenu: () => import('@/components/VaccineActionMenu.vue')
		},
		data() {
			return {
				tabIndex: 0,
				warehouseSummary: []
			}
		},
		onLoad(options) {
			if (options && options.tab === 'batch') {
				this.tabIndex = 1
				this.loadWarehouseSummary()
			} else {
				this.loadWarehouseSummary()
			}
		},
		onShow() {
			const needRefresh = uni.getStorageSync('vaccine_list_refresh')
			if (needRefresh) {
				uni.removeStorageSync('vaccine_list_refresh')
				if (this.$refs.vaccineListRef && this.$refs.vaccineListRef.loadList) {
					this.$refs.vaccineListRef.loadList()
				}
			}
		},
		methods: {
			async loadWarehouseSummary() {
				try {
					const res = await request({ url: '/admin/stock/warehouse-summary', method: 'GET' })
					this.warehouseSummary = (res && res.data) ? res.data : []
				} catch (_) {
					this.warehouseSummary = []
				}
			},
			goAdd() {
				uni.navigateTo({ url: '/pages/admin/vaccine-edit' })
			},
			switchToBatch() {
				this.tabIndex = 1
				this.loadWarehouseSummary()
			},
			switchToStock() {
				this.tabIndex = 2
				this.loadWarehouseSummary()
			},
			openActionMenu(item) {
				if (this.$refs.actionMenuRef && this.$refs.actionMenuRef.open) {
					this.$refs.actionMenuRef.open(item)
				}
			},
			handleAction(action, item) {
				if (!this.$refs.vaccineListRef) return

				switch (action) {
					case 'toggleStatus':
						if (this.$refs.vaccineListRef.toggleStatus) {
							this.$refs.vaccineListRef.toggleStatus(item)
						}
						break
					case 'edit':
						uni.navigateTo({ url: '/pages/admin/vaccine-edit?id=' + item.id })
						break
					case 'delete':
						if (this.$refs.vaccineListRef.doDelete) {
							this.$refs.vaccineListRef.doDelete(item)
						}
						break
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
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
	.tabs {
		display: flex;
		background: #fff;
		border-bottom: 1rpx solid #eee;
		.tab {
			flex: 1;
			text-align: center;
			padding: 24rpx;
			font-size: 28rpx;
			color: #666;
			&.active { color: #007AFF; font-weight: 600; border-bottom: 4rpx solid #007AFF; }
		}
	}
</style>
