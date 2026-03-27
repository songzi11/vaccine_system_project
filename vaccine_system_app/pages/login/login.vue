<template>
	<view class="page">
		<view class="header">
			<text class="title">疫苗接种管理系统</text>
			<text class="subtitle">{{ isRegister ? '用户注册' : '用户登录' }}</text>
		</view>
		<view class="tabs">
			<text class="tab" :class="{ active: !isRegister }" @click="isRegister = false">登录</text>
			<text class="tab" :class="{ active: isRegister }" @click="isRegister = true">注册</text>
		</view>
		<!-- 登录 -->
		<uni-forms v-if="!isRegister" ref="formRef" :model="form" :rules="rules" label-width="120rpx" label-position="top">
			<view class="form-card">
				<uni-forms-item label="用户名" name="username" required>
					<uni-easyinput v-model="form.username" placeholder="请输入用户名" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="密码" name="password" required>
					<uni-easyinput v-model="form.password" type="password" placeholder="请输入密码" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
			</view>
			<view class="btn-wrap">
				<button class="btn-login" type="primary" :loading="loading" @click="submit">登 录</button>
			</view>
		</uni-forms>
		<!-- 注册 -->
		<uni-forms v-else ref="registerFormRef" :model="registerForm" :rules="registerRules" label-width="120rpx" label-position="top">
			<view class="form-card">
				<uni-forms-item label="用户名" name="username" required>
					<uni-easyinput v-model="registerForm.username" placeholder="请输入用户名（注销过的不可再用）" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="密码" name="password" required>
					<uni-easyinput v-model="registerForm.password" type="password" placeholder="请输入密码" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="角色" name="role" required>
					<picker mode="selector" :range="roleOptions" range-key="label" :value="registerRoleIndex" @change="onRoleChange">
						<view class="picker-value">{{ roleOptions[registerRoleIndex].label }}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="姓名" name="realName">
					<uni-easyinput v-model="registerForm.realName" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="手机" name="phone">
					<uni-easyinput v-model="registerForm.phone" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="地址" name="address">
					<uni-easyinput v-model="registerForm.address" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
			</view>
			<view class="btn-wrap">
				<button class="btn-login" type="primary" :loading="loading" @click="submitRegister">注 册</button>
			</view>
		</uni-forms>
	</view>
</template>

<script>
	import request from '@/common/request.js'
	import { setToken, setUserId, setUsername, setRole } from '@/common/request.js'

	const ROLE_OPTIONS = [
		{ value: 'RESIDENT', label: '家长' },
		{ value: 'DOCTOR', label: '医生' },
		{ value: 'ADMIN', label: '管理员' }
	]

	export default {
		data() {
			return {
				isRegister: false,
				form: { username: '', password: '' },
				rules: {
					username: { rules: [{ required: true, errorMessage: '请输入用户名' }] },
					password: { rules: [{ required: true, errorMessage: '请输入密码' }] }
				},
				registerForm: {
					username: '',
					password: '',
					role: 'RESIDENT',
					realName: '',
					phone: '',
					address: ''
				},
				registerRules: {
					username: { rules: [{ required: true, errorMessage: '请输入用户名' }] },
					password: { rules: [{ required: true, errorMessage: '请输入密码' }] },
					role: { rules: [{ required: true, errorMessage: '请选择角色' }] }
				},
				roleOptions: ROLE_OPTIONS,
				registerRoleIndex: 0,
				loading: false
			}
		},
		methods: {
			onRoleChange(e) {
				this.registerRoleIndex = Number(e.detail.value)
				this.registerForm.role = ROLE_OPTIONS[this.registerRoleIndex].value
			},
			showLoginError(message) {
				uni.showModal({ title: '登录失败', content: message, showCancel: false, confirmText: '知道了' })
			},
			showRegisterError(message) {
				uni.showModal({ title: '注册失败', content: message, showCancel: false, confirmText: '知道了' })
			},
			submit() {
				this.$refs.formRef.validate().then(() => this.doLogin()).catch(err => {
					uni.showToast({ title: err[0]?.errorMessage || '请完善表单', icon: 'none' })
				})
			},
			async doLogin() {
				this.loading = true
				try {
					const res = await request({
						url: '/api/users/login',
						method: 'POST',
						data: { username: this.form.username, password: this.form.password }
					})
					if (!res || res.code !== 200 || !res.data) {
						this.showLoginError((res && res.message) || '用户名或密码错误，请重试')
						return
					}
					const user = res.data
					const token = res.token || user.token
					const userId = user.id ?? user.userId
					const username = user.username || ''
					const role = user.role || ''
					if (token) setToken(token)
					if (userId != null && userId !== '') setUserId(String(userId))
					if (username) setUsername(username)
					if (role) setRole(role)
					uni.showToast({ title: '登录成功', icon: 'success' })
					setTimeout(() => uni.reLaunch({ url: '/pages/home/home' }), 800)
				} catch (e) {
					this.showLoginError(e.message || '登录失败，请检查网络或稍后重试')
				} finally {
					this.loading = false
				}
			},
			submitRegister() {
				const ref = this.$refs.registerFormRef
				if (!ref) return
				ref.validate().then(() => this.doRegister()).catch(err => {
					uni.showToast({ title: err[0]?.errorMessage || '请完善表单', icon: 'none' })
				})
			},
			async doRegister() {
				this.loading = true
				try {
					const res = await request({
						url: '/api/users/register',
						method: 'POST',
						data: {
							username: this.registerForm.username.trim(),
							password: this.registerForm.password,
							role: this.registerForm.role,
							realName: this.registerForm.realName || undefined,
							phone: this.registerForm.phone || undefined,
							address: this.registerForm.address || undefined
						}
					})
					if (!res || res.code !== 200 || !res.data) {
						this.showRegisterError((res && res.message) || '该用户名已被使用或已注销，不可再次使用')
						return
					}
					const user = res.data
					const userId = user.id ?? user.userId
					const username = user.username || ''
					const role = user.role || ''
					if (userId != null && userId !== '') setUserId(String(userId))
					if (username) setUsername(username)
					if (role) setRole(role)
					uni.showToast({ title: '注册成功', icon: 'success' })
					setTimeout(() => uni.reLaunch({ url: '/pages/home/home' }), 800)
				} catch (e) {
					this.showRegisterError(e.message || '该用户名已被使用或已注销，不可再次使用')
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
		background: linear-gradient(180deg, #007AFF 0%, #5ac8fa 100%);
		padding: 80rpx 40rpx 40rpx;
	}
	.tabs { display: flex; justify-content: center; margin-bottom: 24rpx; }
	.tab { padding: 16rpx 40rpx; font-size: 28rpx; color: rgba(255,255,255,0.8); }
	.tab.active { color: #fff; font-weight: 600; border-bottom: 4rpx solid #fff; }
	.picker-value {
		padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 12rpx; background: #fff;
		font-size: 28rpx; color: #333;
	}
	.header {
		text-align: center;
		margin-bottom: 40rpx;
		.title {
			display: block;
			font-size: 44rpx;
			font-weight: bold;
			color: #fff;
			margin-bottom: 16rpx;
		}
		.subtitle {
			font-size: 28rpx;
			color: rgba(255, 255, 255, 0.9);
		}
	}
	.form-card {
		background: #fff;
		border-radius: 24rpx;
		padding: 40rpx;
		margin-bottom: 40rpx;
	}
	.btn-wrap {
		padding: 0 20rpx;
		.btn-login {
			width: 100%;
			height: 88rpx;
			line-height: 88rpx;
			border-radius: 44rpx;
			font-size: 32rpx;
		}
	}
</style>
