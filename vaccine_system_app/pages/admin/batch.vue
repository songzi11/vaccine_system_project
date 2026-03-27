<template>
	<view class="page">
		<view class="redirect-tip">已整合到「疫苗管理」→ 批次管理</view>
	</view>
</template>

<script>
	export default {
		onLoad() {
			// 批次管理已整合到疫苗管理页，直接跳转并打开批次 Tab
			uni.redirectTo({ url: '/pages/admin/vaccine?tab=batch' })
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; align-items: center; justify-content: center; background: #f5f5f5; }
	.redirect-tip { font-size: 28rpx; color: #666; }
</style>
