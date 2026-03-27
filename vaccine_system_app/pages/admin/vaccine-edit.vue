<template>
	<view class="page">
		<view class="form-card">
			<uni-forms ref="formRef" :model="form" :rules="rules" label-width="160rpx" label-position="top">
				<uni-forms-item label="疫苗名称" name="vaccineName" required>
					<uni-easyinput v-model="form.vaccineName" placeholder="请输入疫苗名称" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="类别" name="category">
					<picker mode="selector" :range="categoryOptions" range-key="label" :value="categoryIndex" @change="onCategoryChange">
						<view class="picker-value">{{ categoryOptions[categoryIndex].label }}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="生产厂家" name="manufacturer">
					<uni-easyinput v-model="form.manufacturer" placeholder="选填" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="疫苗类型" name="vaccineType">
					<uni-easyinput v-model="form.vaccineType" placeholder="如：灭活疫苗、减毒活疫苗" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="总剂次" name="totalDoses">
					<uni-easyinput v-model="form.totalDoses" type="number" placeholder="如：1" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="剂次间隔(天)" name="intervalDays">
					<uni-easyinput v-model="form.intervalDays" type="number" placeholder="选填，如：28" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="适用起始月龄" name="applicableAgeMonths">
					<uni-easyinput v-model="form.applicableAgeMonths" type="number" placeholder="选填，如：0" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="剂型/规格" name="dosageDesc">
					<uni-easyinput v-model="form.dosageDesc" placeholder="如：0.5ml/支" :clearable="true" :inputBorder="true" />
				</uni-forms-item>
				<uni-forms-item label="疫苗说明" name="description">
					<textarea v-model="form.description" class="textarea" placeholder="选填，注意事项等" />
				</uni-forms-item>
				<uni-forms-item label="不良反应说明" name="adverseReactionDesc">
					<textarea v-model="form.adverseReactionDesc" class="textarea" placeholder="选填" />
				</uni-forms-item>
				<uni-forms-item label="状态" name="status" v-if="id">
					<picker mode="selector" :range="statusOptions" range-key="label" :value="statusIndex" @change="onStatusChange">
						<view class="picker-value">{{ statusOptions[statusIndex].label }}</view>
					</picker>
				</uni-forms-item>
			</uni-forms>
			<view class="btn-wrap">
				<button class="btn-save" type="primary" :loading="submitting" @click="submit">{{ id ? '保存' : '新增' }}</button>
			</view>
		</view>
	</view>
</template>

<script>
	import request from '@/common/request.js'

	const CATEGORY_OPTIONS = [
		{ value: 'CLASS_I', label: '一类疫苗' },
		{ value: 'CLASS_II', label: '二类疫苗' }
	]
	const STATUS_OPTIONS = [
		{ value: 0, label: '下架' },
		{ value: 1, label: '上架' }
	]

	export default {
		data() {
			return {
				id: null,
				form: {
					vaccineName: '',
					category: 'CLASS_II',
					manufacturer: '',
					vaccineType: '',
					totalDoses: 1,
					intervalDays: null,
					applicableAgeMonths: null,
					dosageDesc: '',
					description: '',
					adverseReactionDesc: '',
					status: 1
				},
				rules: {
					vaccineName: { rules: [{ required: true, errorMessage: '请输入疫苗名称' }] }
				},
				categoryOptions: CATEGORY_OPTIONS,
				categoryIndex: 0,
				statusOptions: STATUS_OPTIONS,
				statusIndex: 1,
				submitting: false
			}
		},
		onLoad(options) {
			this.id = options.id ? Number(options.id) : null
			if (this.id) {
				uni.setNavigationBarTitle({ title: '编辑疫苗' })
				this.loadDetail()
			} else {
				uni.setNavigationBarTitle({ title: '新增疫苗' })
			}
		},
		methods: {
			onCategoryChange(e) {
				this.categoryIndex = Number(e.detail.value)
				this.form.category = CATEGORY_OPTIONS[this.categoryIndex].value
			},
			onStatusChange(e) {
				this.statusIndex = Number(e.detail.value)
				this.form.status = STATUS_OPTIONS[this.statusIndex].value
			},
			async loadDetail() {
				try {
					const res = await request({ url: '/admin/vaccine/' + this.id, method: 'GET' })
					const d = res && res.data
					if (!d) return
					this.form.vaccineName = d.vaccineName || ''
					this.form.category = (d.category || 'CLASS_II').toUpperCase()
					this.form.manufacturer = d.manufacturer || ''
					this.form.vaccineType = d.vaccineType || ''
					this.form.totalDoses = d.totalDoses != null ? d.totalDoses : 1
					this.form.intervalDays = d.intervalDays != null ? d.intervalDays : null
					this.form.applicableAgeMonths = d.applicableAgeMonths != null ? d.applicableAgeMonths : null
					this.form.dosageDesc = d.dosageDesc || ''
					this.form.description = d.description || ''
					this.form.adverseReactionDesc = d.adverseReactionDesc || ''
					this.form.status = d.status != null ? d.status : 1
					const catIdx = CATEGORY_OPTIONS.findIndex(c => c.value === this.form.category)
					this.categoryIndex = catIdx >= 0 ? catIdx : 0
					const stIdx = STATUS_OPTIONS.findIndex(s => s.value === this.form.status)
					this.statusIndex = stIdx >= 0 ? stIdx : 1
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
				if (this.submitting) return
				this.submitting = true
				try {
					const payload = {
						vaccineName: this.form.vaccineName,
						category: this.form.category,
						manufacturer: this.form.manufacturer || null,
						vaccineType: this.form.vaccineType || null,
						totalDoses: this.form.totalDoses != null && this.form.totalDoses !== '' ? Number(this.form.totalDoses) : 1,
						intervalDays: this.form.intervalDays != null && this.form.intervalDays !== '' ? Number(this.form.intervalDays) : null,
						applicableAgeMonths: this.form.applicableAgeMonths != null && this.form.applicableAgeMonths !== '' ? Number(this.form.applicableAgeMonths) : null,
						dosageDesc: this.form.dosageDesc || null,
						description: this.form.description || null,
						adverseReactionDesc: this.form.adverseReactionDesc || null,
						status: this.form.status != null ? this.form.status : 1
					}
					if (this.id) {
						await request({
							url: '/admin/vaccine/' + this.id,
							method: 'PUT',
							data: payload
						})
						uni.showToast({ title: '保存成功' })
					} else {
						await request({
							url: '/admin/vaccine',
							method: 'POST',
							data: payload
						})
						uni.showToast({ title: '新增成功' })
					}
					uni.setStorageSync('vaccine_list_refresh', '1')
					setTimeout(() => uni.navigateBack(), 500)
				} catch (e) {
					uni.showToast({ title: e.message || '保存失败', icon: 'none' })
				} finally {
					this.submitting = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; background: #f5f5f5; padding: 24rpx; padding-bottom: 80rpx; }
	.form-card { background: #fff; border-radius: 16rpx; padding: 30rpx; }
	.picker-value { padding: 20rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 28rpx; color: #333; }
	.textarea { width: 100%; min-height: 120rpx; padding: 20rpx; background: #f5f5f5; border-radius: 8rpx; font-size: 28rpx; box-sizing: border-box; }
	.btn-wrap { margin-top: 48rpx; }
	.btn-save { width: 100%; height: 88rpx; line-height: 88rpx; background: #007AFF; color: #fff; border-radius: 12rpx; font-size: 32rpx; border: none; }
</style>
