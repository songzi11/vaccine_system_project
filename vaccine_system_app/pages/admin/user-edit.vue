<template>
	<view class="page">
		<AppHeader ref="appHeader" />
		<view class="form-card">
			<uni-forms ref="formRef" :model="form" :rules="rules" label-width="140rpx" label-position="top">
				<uni-forms-item label="用户名" name="username" required>
					<uni-easyinput v-model="form.username" placeholder="登录账号（注销过的不可再用）" :disabled="!!id" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="密码" :name="id ? 'passwordOpt' : 'password'">
					<uni-easyinput v-model="form.password" type="password" :placeholder="id ? '不填则不修改' : '请输入密码'" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="角色" name="role" required>
					<picker mode="selector" :range="roleOptions" range-key="label" :value="roleIndex" @change="onRoleChange">
						<view class="picker-value">{{ roleOptions[roleIndex].label }}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="姓名" name="realName">
					<uni-easyinput v-model="form.realName" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="手机" name="phone">
					<uni-easyinput v-model="form.phone" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="地址" name="address">
					<uni-easyinput v-model="form.address" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
			</uni-forms>
			<view class="btn-wrap">
				<button class="btn-save" type="primary" :loading="submitting" @click="submit">{{ id ? '保存' : '添加' }}</button>
			</view>
		</view>
	</view>
</template>

<script>
	import AppHeader from '@/components/AppHeader.vue'
	import request from '@/common/request.js'

	const ROLE_OPTIONS = [
		{ value: 'RESIDENT', label: '家长' },
		{ value: 'DOCTOR', label: '医生' },
		{ value: 'ADMIN', label: '管理员' }
	]

	export default {
		components: { AppHeader },
		data() {
			return {
				id: null,
				form: {
					username: '',
					password: '',
					role: 'RESIDENT',
					realName: '',
					phone: '',
					address: ''
				},
				rules: {
					username: { rules: [{ required: true, errorMessage: '请输入用户名' }] },
					password: { rules: [{ required: true, errorMessage: '请输入密码' }] },
					role: { rules: [{ required: true, errorMessage: '请选择角色' }] }
				},
				roleOptions: ROLE_OPTIONS,
				roleIndex: 0,
				submitting: false
			}
		},
		onLoad(options) {
			this.id = options.id || null
			if (this.id) {
				uni.setNavigationBarTitle({ title: '编辑用户' })
				this.loadDetail()
			} else {
				uni.setNavigationBarTitle({ title: '添加用户' })
			}
		},
		onShow() {
			if (this.$refs.appHeader) this.$refs.appHeader.refreshUser()
		},
		methods: {
			onRoleChange(e) {
				this.roleIndex = Number(e.detail.value)
				this.form.role = ROLE_OPTIONS[this.roleIndex].value
			},
			async loadDetail() {
				try {
					const res = await request({ url: '/admin/user/' + this.id, method: 'GET' })
					const d = res && res.data
					if (!d) return
					this.form.username = d.username || ''
					this.form.realName = d.realName || ''
					this.form.phone = d.phone || ''
					this.form.address = d.address || ''
					this.form.role = (d.role || 'RESIDENT').toUpperCase()
					const idx = ROLE_OPTIONS.findIndex(r => r.value === this.form.role)
					this.roleIndex = idx >= 0 ? idx : 0
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				}
			},
			submit() {
				const ref = this.$refs.formRef
				if (!ref) return
				const needPwd = !this.id
				ref.validate().then(() => {
					if (needPwd && (!this.form.password || !this.form.password.trim())) {
						uni.showToast({ title: '请输入密码', icon: 'none' })
						return
					}
					this.doSave()
				}).catch(err => {
					uni.showToast({ title: err[0]?.errorMessage || '请完善表单', icon: 'none' })
				})
			},
			async doSave() {
				this.submitting = true
				try {
					const payload = {
						username: this.form.username.trim(),
						role: this.form.role,
						realName: this.form.realName || null,
						phone: this.form.phone || null,
						address: this.form.address || null
					}
					if (this.form.password && this.form.password.trim()) {
						payload.password = this.form.password.trim()
					}
					if (this.id) {
						await request({
							url: '/admin/user/' + this.id,
							method: 'PUT',
							data: payload
						})
						uni.showToast({ title: '保存成功', icon: 'success' })
						setTimeout(() => uni.navigateBack(), 800)
					} else {
						await request({
							url: '/admin/user',
							method: 'POST',
							data: payload
						})
						uni.showToast({ title: '添加成功', icon: 'success' })
						setTimeout(() => uni.navigateBack(), 800)
					}
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				} finally {
					this.submitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; background: #f5f5f5; padding: 24rpx; }
	.form-card { background: #fff; border-radius: 16rpx; padding: 32rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06); }
	.picker-value { padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 12rpx; font-size: 28rpx; color: #333; }
	.btn-wrap { margin-top: 48rpx; }
	.btn-save { width: 100%; height: 88rpx; line-height: 88rpx; border-radius: 44rpx; font-size: 32rpx; }
</style>
