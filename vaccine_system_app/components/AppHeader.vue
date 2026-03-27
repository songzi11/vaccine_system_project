<template>
	<view class="app-header">
		<view class="user-info" @click="toggleMenu">
			<text class="label">{{ roleLabel }}（{{ username || '未登录' }}）</text>
		</view>
		<view v-if="showMenu" class="menu-mask" @click="showMenu = false"></view>
		<view v-if="showMenu" class="menu-drop">
			<view class="menu-item" @click="logout">退出登录</view>
		</view>
	</view>
</template>

<script>
	import { getUserId, getUsername, getRole, clearAuth } from '@/common/request.js'

	export default {
		name: 'AppHeader',
		data() {
			return {
				username: '',
				role: '',
				showMenu: false
			}
		},
		mounted() {
			this.refreshUser()
		},
		computed: {
			roleLabel() {
				const map = { RESIDENT: '家长', USER: '家长', DOCTOR: '医生', ADMIN: '管理员' }
				return map[(this.role || '').toUpperCase()] || this.role || '用户'
			}
		},
		mounted() {
			this.refreshUser()
		},
		methods: {
			refreshUser() {
				this.username = getUsername()
				this.role = getRole()
			},
			toggleMenu() {
				if (!getUserId()) return
				this.showMenu = !this.showMenu
			},
			logout() {
				this.showMenu = false
				uni.showModal({
					title: '提示',
					content: '确定退出登录？',
					success: (res) => {
						if (res.confirm) {
							clearAuth()
							uni.reLaunch({ url: '/pages/login/login' })
						}
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.app-header {
		position: relative;
		display: flex;
		justify-content: flex-end;
		align-items: center;
		padding: 16rpx 24rpx 20rpx;
		min-height: 60rpx;
	}
	.user-info {
		font-size: 24rpx;
		color: #888;
	}
	.label {
		letter-spacing: 0.5rpx;
	}
	.menu-mask {
		position: fixed;
		left: 0;
		right: 0;
		top: 0;
		bottom: 0;
		z-index: 99;
	}
	.menu-drop {
		position: absolute;
		top: 100%;
		right: 24rpx;
		margin-top: 8rpx;
		background: #fff;
		border-radius: 12rpx;
		box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.12);
		z-index: 100;
		min-width: 180rpx;
		overflow: hidden;
	}
	.menu-item {
		padding: 24rpx 32rpx;
		font-size: 28rpx;
		color: #333;
	}
	.menu-item:active {
		background: #f5f5f5;
	}
</style>
