<template>
	<view class="page">
		<view class="toolbar"><text class="page-title">编辑宝宝</text></view>
		<uni-forms v-if="form.id" ref="formRef" :model="form" :rules="rules" label-width="140rpx" label-position="top">
			<view class="form-card">
				<uni-forms-item label="宝宝姓名" name="name" required>
					<uni-easyinput v-model="form.name" placeholder="请输入姓名" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="出生日期" name="birthDate" required>
					<picker
						mode="date"
						:value="form.birthDate"
						:start="birthDateStart"
						:end="birthDateEnd"
						@change="onBirthDateChange"
					>
						<view class="picker-value">{{ form.birthDate || '请选择出生日期' }}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="性别" name="gender" required>
					<picker mode="selector" :range="genderOptions" range-key="label" :value="genderIndex" @change="onGenderChange">
						<view class="picker-value">{{ genderOptions[genderIndex] ? genderOptions[genderIndex].label : '请选择' }}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="接种卡号" name="vaccinationCardNo">
					<uni-easyinput v-model="form.vaccinationCardNo" placeholder="选填" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="禁忌症/过敏史" name="contraindicationAllergy">
					<textarea v-model="form.contraindicationAllergy" placeholder="如鸡蛋过敏等，选填" class="textarea" maxlength="500" />
				</uni-forms-item>
			</view>
			<view class="btn-wrap">
				<button class="btn-submit" type="primary" :loading="loading" @click="submit">保存</button>
			</view>
		</uni-forms>
		<view v-else class="loading-wrap">加载中...</view>
	</view>
</template>

<script>
	import request, { getUserId } from '@/common/request.js'

	export default {
		data() {
			const today = new Date()
			const y = today.getFullYear()
			const m = today.getMonth() + 1
			const d = today.getDate()
			const todayStr = y + '-' + (m < 10 ? '0' + m : m) + '-' + (d < 10 ? '0' + d : d)
			const past = new Date(y - 20, today.getMonth(), d)
			const py = past.getFullYear()
			const pm = past.getMonth() + 1
			const pd = past.getDate()
			const pastStr = py + '-' + (pm < 10 ? '0' + pm : pm) + '-' + (pd < 10 ? '0' + pd : pd)
			return {
				id: '',
				form: { id: null, name: '', birthDate: '', gender: 1, vaccinationCardNo: '', contraindicationAllergy: '' },
				genderOptions: [{ value: 0, label: '未知' }, { value: 1, label: '男' }, { value: 2, label: '女' }],
				genderIndex: 1,
				birthDateStart: pastStr,
				birthDateEnd: todayStr,
				rules: {
					name: { rules: [{ required: true, errorMessage: '请输入宝宝姓名' }] },
					birthDate: { rules: [{ required: true, errorMessage: '请选择出生日期' }] }
				},
				loading: false
			}
		},
		onLoad(opts) {
			this.id = opts.id || ''
			if (this.id) this.loadDetail()
		},
		methods: {
			onBirthDateChange(e) {
				this.form.birthDate = e.detail.value || ''
			},
			onGenderChange(e) {
				this.genderIndex = Number(e.detail.value)
				this.form.gender = this.genderOptions[this.genderIndex].value
			},
			async loadDetail() {
				try {
					const res = await request({ url: '/child/' + this.id, method: 'GET' })
					const d = res && res.data
					if (d) {
						this.form = { id: d.id, name: d.name, birthDate: d.birthDate, gender: d.gender != null ? d.gender : 1, vaccinationCardNo: d.vaccinationCardNo || '', contraindicationAllergy: d.contraindicationAllergy || '' }
						this.genderIndex = this.genderOptions.findIndex(o => o.value === this.form.gender)
						if (this.genderIndex < 0) this.genderIndex = 0
					}
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				}
			},
			submit() {
				this.$refs.formRef.validate().then(() => {
					this.doSave()
				}).catch(() => {})
			},
			async doSave() {
				this.loading = true
				try {
					await request({
						url: '/child/' + (this.form.id || this.id),
						method: 'PUT',
						data: {
							name: this.form.name,
							birthDate: this.form.birthDate,
							gender: this.form.gender,
							vaccinationCardNo: this.form.vaccinationCardNo || undefined,
							contraindicationAllergy: this.form.contraindicationAllergy || undefined
						}
					})
					uni.showToast({ title: '保存成功', icon: 'success' })
					setTimeout(() => uni.navigateBack(), 800)
				} catch (e) {
					uni.showToast({ title: e.message || '保存失败', icon: 'none' })
				} finally {
					this.loading = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; background: #f5f5f5; padding-bottom: 40rpx; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.form-card { background: #fff; margin: 20rpx; border-radius: 16rpx; padding: 28rpx; }
	.picker-value { padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 8rpx; font-size: 28rpx; color: #333; }
	.textarea { width: 100%; min-height: 120rpx; padding: 20rpx; border: 1rpx solid #e5e5e5; border-radius: 8rpx; font-size: 28rpx; }
	.btn-wrap { padding: 40rpx 30rpx; }
	.btn-submit { width: 100%; }
	.loading-wrap { padding: 80rpx; text-align: center; color: #999; }
</style>
