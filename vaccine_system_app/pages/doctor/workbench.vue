<template>
	<view class="page">
		<view class="header">
			<text class="title">医生工作台</text>
			<text class="subtitle">待接种查看 · 录入核销</text>
		</view>

		<view class="grid-wrap">
			<view class="grid-row">
				<view class="grid-item" @click="showList = true">
					<view class="grid-icon list">
						<uni-icons type="list" size="48" color="#fff"></uni-icons>
					</view>
					<text class="grid-title">待接种</text>
					<text class="grid-desc">今日与未来三个月待接种列表</text>
				</view>
				<view class="grid-item" @click="goVaccinate">
					<view class="grid-icon form">
						<uni-icons type="compose" size="48" color="#fff"></uni-icons>
					</view>
					<text class="grid-title">录入核销</text>
					<text class="grid-desc">填写批号并确认接种</text>
				</view>
				<view class="grid-item" @click="showDoctorInfo = true">
					<view class="grid-icon info">
						<uni-icons type="person" size="48" color="#fff"></uni-icons>
					</view>
					<text class="grid-title">医生信息</text>
					<text class="grid-desc">个人信息与接种过的宝宝记录</text>
				</view>
				<view class="grid-item" @click="goNotice">
					<view class="grid-icon-wrap">
						<view class="grid-icon notice">
							<uni-icons type="notification" size="48" color="#fff"></uni-icons>
						</view>
						<view v-if="noticePendingCount > 0" class="grid-badge"></view>
					</view>
					<text class="grid-title">发布公告</text>
					<text class="grid-desc">申请发布公告，管理员审批通过后展示</text>
				</view>
			</view>
		</view>

		<!-- 待接种列表弹窗：今日 | 未来三个月，点开仅查看详情（无核销） -->
		<view v-if="showList" class="list-panel">
			<view class="panel-head">
				<text class="panel-title">待接种</text>
				<text class="panel-close" @click="closeList">关闭</text>
			</view>
			<view class="panel-tabs">
				<view class="ptab" :class="{ active: listTab === 'today' }" @click="listTab = 'today'; loadToday(); loadFuture();">
					<text>今日</text>
				</view>
				<view class="ptab" :class="{ active: listTab === 'future' }" @click="listTab = 'future'; loadToday(); loadFuture();">
					<text>未来三个月</text>
				</view>
			</view>
			<scroll-view scroll-y class="panel-scroll">
				<view v-if="pendingLoading" class="loading-row"><uni-load-more status="loading" /></view>
				<view v-else-if="displayList.length === 0" class="empty">暂无待接种预约</view>
				<view v-else class="pending-cards">
					<view
						v-for="(item, i) in displayList"
						:key="item.id || i"
						class="pending-card"
						@click="openDetail(item)"
					>
						<view class="card-main">
							<text class="card-title">预约 #{{ item.id }}</text>
							<text class="card-info">疫苗ID：{{ item.vaccineId }} · 接种点：{{ item.siteId }}</text>
							<text class="card-info">日期：{{ item.appointmentDate }} {{ item.timeSlot || '' }}</text>
							<text class="card-info" v-if="item.childId">儿童ID：{{ item.childId }}</text>
						</view>
						<text class="card-action">查看详情</text>
					</view>
				</view>
			</scroll-view>
		</view>

		<!-- 待接种详情（只读：宝宝、家长、过往接种），无核销 -->
		<view v-if="detailVO" class="detail-panel">
			<view class="panel-head">
				<text class="panel-title">预约详情</text>
				<text class="panel-close" @click="detailVO = null">关闭</text>
			</view>
			<scroll-view scroll-y class="panel-scroll">
				<view class="detail-card">
					<text class="detail-title">预约信息</text>
					<view class="detail-row">预约号：{{ detailVO.appointment && detailVO.appointment.id }}</view>
					<view class="detail-row">疫苗：{{ detailVO.vaccineName || detailVO.appointment.vaccineId }}</view>
					<view class="detail-row">接种点：{{ detailVO.siteName || detailVO.appointment.siteId }}</view>
					<view class="detail-row">日期：{{ detailVO.appointment && detailVO.appointment.appointmentDate }} {{ detailVO.appointment && detailVO.appointment.timeSlot }}</view>
				</view>
				<view class="detail-card" v-if="detailVO.child">
					<text class="detail-title">宝宝档案</text>
					<view class="detail-row">姓名：{{ detailVO.child.name }}</view>
					<view class="detail-row">出生日期：{{ detailVO.child.birthDate }}</view>
					<view class="detail-row" v-if="detailVO.child.contraindicationAllergy">禁忌/过敏：{{ detailVO.child.contraindicationAllergy }}</view>
				</view>
				<view class="detail-card">
					<text class="detail-title">所属家长</text>
					<view class="detail-row">姓名：{{ detailVO.parentName || '-' }}</view>
					<view class="detail-row">电话：{{ detailVO.parentPhone || '-' }}</view>
				</view>
				<view class="detail-card" v-if="detailVO.pastRecords && detailVO.pastRecords.length">
					<text class="detail-title">过往接种记录（医生提交）</text>
					<view v-for="(r, j) in detailVO.pastRecords" :key="r.id || j" class="past-row">
						<text>{{ r.vaccineName }} · {{ r.siteName }} · {{ r.vaccinateTime || '' }} · 医生：{{ r.doctorName || '-' }}</text>
					</view>
				</view>
				<view class="detail-card" v-else>
					<text class="detail-title">过往接种记录</text>
					<view class="detail-row">暂无</view>
				</view>
			</scroll-view>
		</view>

		<!-- 医生信息弹窗：个人信息 + 接种过的宝宝记录 -->
		<view v-if="showDoctorInfo" class="list-panel">
			<view class="panel-head">
				<text class="panel-title">医生信息</text>
				<text class="panel-close" @click="closeDoctorInfo">关闭</text>
			</view>
			<scroll-view scroll-y class="panel-scroll">
				<view v-if="profileLoading" class="loading-row"><uni-load-more status="loading" /></view>
				<template v-else>
					<view v-if="doctorProfile" class="detail-card profile-card">
						<text class="detail-title">个人信息</text>
						<view class="detail-row">姓名：{{ doctorProfile.realName || '-' }}</view>
						<view class="detail-row">账号：{{ doctorProfile.username || '-' }}</view>
						<view class="detail-row">电话：{{ doctorProfile.phone || '-' }}</view>
						<view class="detail-row" v-if="doctorProfile.address">地址：{{ doctorProfile.address }}</view>
					</view>
					<view class="detail-card">
						<text class="detail-title">接种过的宝宝记录</text>
						<view v-if="vaccinatedRecords.length === 0" class="detail-row">暂无记录</view>
						<view v-else v-for="(r, k) in vaccinatedRecords" :key="r.id || k" class="past-row">
							<text>{{ r.childName || '宝宝' }} · {{ r.vaccineName || '-' }} · {{ r.siteName || '-' }} · {{ formatDate(r.vaccinationDate) }} {{ r.doseNumber ? '第' + r.doseNumber + '针' : '' }}</text>
						</view>
						<view v-if="vaccinatedRecords.length > 0 && recordTotal > vaccinatedRecords.length" class="detail-row load-more" @click="loadMoreRecords">加载更多</view>
					</view>
				</template>
			</scroll-view>
		</view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

	export default {
		data() {
			return {
				showList: false,
				listTab: 'today',
				todayList: [],
				futureList: [],
				pendingLoading: false,
				detailVO: null,
				showDoctorInfo: false,
				doctorProfile: null,
				profileLoading: false,
				vaccinatedRecords: [],
				recordPage: 1,
				recordPageSize: 20,
				recordTotal: 0,
				noticePendingCount: 0  // 我的公告申请待审批数，用于红点
			}
		},
		onShow() {
			this.loadNoticePendingCount()
		},
		computed: {
			displayList() {
				return this.listTab === 'today' ? this.todayList : this.futureList
			}
		},
		onLoad(options) {
			if (options.tab === 'list') this.showList = true
		},
		methods: {
			closeList() {
				this.showList = false
				this.detailVO = null
			},
			async loadToday() {
				this.pendingLoading = true
				try {
					const uid = getUserId()
					const doctorId = uid ? Number(uid) : undefined
					const res = await request({
						url: '/api/doctor/appointments/scheduled',
						method: 'GET',
						data: { current: 1, size: 100, doctorId }
					})
					const data = res && res.data
					this.todayList = (data && data.records) ? data.records : []
				} catch (_) {
					this.todayList = []
				} finally {
					this.pendingLoading = false
				}
			},
			async loadFuture() {
				if (this.listTab !== 'future') return
				try {
					const uid = getUserId()
					const doctorId = uid ? Number(uid) : undefined
					const res = await request({
						url: '/api/doctor/appointments/scheduled/future',
						method: 'GET',
						data: { current: 1, size: 100, doctorId }
					})
					const data = res && res.data
					this.futureList = (data && data.records) ? data.records : []
				} catch (_) {
					this.futureList = []
				}
			},
			async openDetail(item) {
				if (!item || !item.id) return
				try {
					uni.showLoading({ title: '加载中...' })
					const res = await request({
						url: '/api/doctor/appointments/scheduled/detail/' + item.id,
						method: 'GET'
					})
					if (res && res.data) {
						this.detailVO = res.data
						this.showList = false
					}
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
				} finally {
					uni.hideLoading()
				}
			},
			goVaccinate() {
				uni.navigateTo({ url: '/pages/doctor/vaccinate/list' })
			},
			goNotice() {
				uni.navigateTo({ url: '/pages/doctor/notice' })
			},
			async loadNoticePendingCount() {
				try {
					const doctorId = getUserId()
					if (!doctorId) return
					const res = await request({
						url: '/api/doctor/notice/my',
						method: 'GET',
						data: { doctorId: Number(doctorId) }
					})
					const list = (res && res.data && Array.isArray(res.data)) ? res.data : []
					this.noticePendingCount = list.filter(n => (n.auditStatus || '') === 'PENDING').length
				} catch (_) {
					this.noticePendingCount = 0
				}
			},
			closeDoctorInfo() {
				this.showDoctorInfo = false
				this.doctorProfile = null
				this.vaccinatedRecords = []
				this.recordPage = 1
			},
			formatDate(d) {
				if (!d) return ''
				const s = String(d)
				return s.slice(0, 16).replace('T', ' ')
			},
			async loadDoctorProfile() {
				const uid = getUserId()
				if (!uid) return
				this.profileLoading = true
				try {
					const [profileRes, recordsRes] = await Promise.all([
						request({ url: '/api/doctor/profile', method: 'GET', data: { doctorId: Number(uid) } }),
						request({ url: '/api/doctor/profile/vaccinated-records', method: 'GET', data: { doctorId: Number(uid), current: 1, size: this.recordPageSize } })
					])
					if (profileRes && profileRes.data) this.doctorProfile = profileRes.data
					if (recordsRes && recordsRes.data) {
						this.vaccinatedRecords = recordsRes.data.records || []
						this.recordTotal = recordsRes.data.total != null ? recordsRes.data.total : 0
						this.recordPage = 1
					}
				} catch (_) {
					this.doctorProfile = null
					this.vaccinatedRecords = []
				} finally {
					this.profileLoading = false
				}
			},
			async loadMoreRecords() {
				const uid = getUserId()
				if (!uid || this.vaccinatedRecords.length >= this.recordTotal) return
				const nextPage = this.recordPage + 1
				try {
					const res = await request({
						url: '/api/doctor/profile/vaccinated-records',
						method: 'GET',
						data: { doctorId: Number(uid), current: nextPage, size: this.recordPageSize }
					})
					if (res && res.data && res.data.records) {
						this.vaccinatedRecords = this.vaccinatedRecords.concat(res.data.records)
						this.recordPage = nextPage
					}
				} catch (_) {}
			}
		},
		watch: {
			showList(v) {
				if (v) {
					this.loadToday()
					if (this.listTab === 'future') this.loadFuture()
				}
			},
			showDoctorInfo(v) {
				if (v) this.loadDoctorProfile()
			},
			listTab() {
				if (this.listTab === 'future' && this.futureList.length === 0) this.loadFuture()
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page {
		min-height: 100vh;
		background: #f0f2f5;
		padding: 32rpx;
		box-sizing: border-box;
	}
	.header {
		background: linear-gradient(135deg, #34C759 0%, #30d158 100%);
		border-radius: 24rpx;
		padding: 40rpx 36rpx;
		margin-bottom: 36rpx;
		box-shadow: 0 8rpx 24rpx rgba(52, 199, 89, 0.3);
		.title { display: block; font-size: 38rpx; font-weight: bold; color: #fff; margin-bottom: 8rpx; }
		.subtitle { font-size: 26rpx; color: rgba(255, 255, 255, 0.9); }
	}
	.grid-wrap { margin-bottom: 32rpx; }
	.grid-row {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 24rpx;
	}
	.grid-icon.notice { background: linear-gradient(135deg, #5856d6 0%, #af52de 100%); }
	.grid-item {
		background: #fff;
		border-radius: 24rpx;
		padding: 36rpx 28rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
		&:active { opacity: 0.92; transform: scale(0.98); }
	}
	.grid-icon-wrap {
		position: relative;
		display: inline-block;
		margin-bottom: 20rpx;
		.grid-icon { margin-bottom: 0; }
	}
	.grid-icon {
		width: 96rpx;
		height: 96rpx;
		border-radius: 24rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		margin-bottom: 20rpx;
		&.list { background: linear-gradient(135deg, #34C759 0%, #30d158 100%); }
		&.form { background: linear-gradient(135deg, #ff9500 0%, #ffb340 100%); }
		&.info { background: linear-gradient(135deg, #007AFF 0%, #5ac8fa 100%); }
	}
	.grid-badge {
		position: absolute;
		top: -4rpx;
		right: -4rpx;
		width: 20rpx;
		height: 20rpx;
		border-radius: 50%;
		background: #ff3b30;
		border: 2rpx solid #fff;
	}
	.grid-title { font-size: 30rpx; font-weight: 600; color: #333; }
	.grid-desc { font-size: 22rpx; color: #999; margin-top: 8rpx; }

	.list-panel, .detail-panel {
		position: fixed;
		left: 0;
		right: 0;
		bottom: 0;
		top: 0;
		background: rgba(0,0,0,0.4);
		z-index: 100;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: flex-end;
	}
	.panel-head {
		width: 100%;
		background: #fff;
		padding: 24rpx 30rpx;
		display: flex;
		align-items: center;
		justify-content: space-between;
		border-radius: 24rpx 24rpx 0 0;
		.panel-title { font-size: 34rpx; font-weight: bold; color: #333; }
		.panel-close { font-size: 28rpx; color: #007AFF; }
	}
	.panel-tabs {
		display: flex;
		background: #fff;
		padding: 0 20rpx 16rpx;
		.ptab {
			flex: 1;
			text-align: center;
			padding: 16rpx;
			font-size: 28rpx;
			color: #666;
			&.active { color: #007AFF; font-weight: 600; border-bottom: 4rpx solid #007AFF; }
		}
	}
	.panel-scroll {
		width: 100%;
		max-height: 70vh;
		background: #f5f5f5;
		padding: 20rpx;
	}
	.loading-row { padding: 48rpx; text-align: center; }
	.empty { padding: 80rpx; text-align: center; color: #999; font-size: 28rpx; }
	.pending-cards { padding: 0 0 40rpx; }
	.pending-card {
		background: #fff;
		border-left: 6rpx solid #34C759;
		border-radius: 16rpx;
		padding: 24rpx 28rpx;
		margin-bottom: 20rpx;
		display: flex;
		align-items: center;
		justify-content: space-between;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
	}
	.card-main { flex: 1; }
	.card-title { display: block; font-size: 30rpx; font-weight: 600; color: #333; margin-bottom: 8rpx; }
	.card-info { display: block; font-size: 24rpx; color: #666; margin-top: 4rpx; }
	.card-action { font-size: 26rpx; color: #007AFF; }

	.detail-card {
		background: #fff;
		border-radius: 16rpx;
		padding: 24rpx 28rpx;
		margin-bottom: 20rpx;
		.detail-title { display: block; font-size: 30rpx; font-weight: 600; color: #333; margin-bottom: 16rpx; }
		.detail-row { font-size: 26rpx; color: #666; margin-top: 8rpx; }
		.past-row { font-size: 24rpx; color: #666; margin-top: 8rpx; padding: 8rpx 0; border-bottom: 1rpx solid #eee; }
		.load-more { color: #007AFF; margin-top: 16rpx; }
		.profile-card { margin-bottom: 20rpx; }
	}
</style>
