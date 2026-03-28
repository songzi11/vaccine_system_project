<template>
	<view class="page">
		<AppHeader ref="appHeader" />
		<!-- 顶部欢迎区 -->
		<view class="header">
			<text class="title">疫苗接种</text>
			<text class="subtitle">{{ roleLabel }} · 欢迎使用</text>
		</view>

		<!-- 家长端：绑定儿童卡片 + 智能提醒 -->
		<template v-if="isResident">
			<ChildrenSection
				ref="childrenSectionRef"
				:vaccine-map="vaccineMap"
				@update:vaccineMap="vaccineMap = $event"
			/>
		</template>

		<!-- 按角色展示的宫格菜单（核心功能区使用 Grid，非纵向列表） -->
		<FunctionMenu
			:title="isResident ? '功能' : '工作台'"
			:menu-items="menuItems"
			:dispatch-unread-count="dispatchUnreadCount"
			:pending-notice-count="pendingNoticeCount"
			:pending-appointment-count="pendingAppointmentCount"
			@click="navTo"
		/>

		<view class="footer">
			<button class="btn-out" type="default" @click="logout">退出登录</button>
			<ClockBar ref="clockBarRef" />
			<text class="copyright">此App知识产权归宋子嘉所有</text>
		</view>
		<!-- 顶部 AppHeader 已提供【角色名（用户名）】与退出，此处保留底部退出按钮以兼容 -->
	</view>
</template>

<script>
	import AppHeader from '@/components/AppHeader.vue'
	import request { parsePageResponse, getUserId, getRole, clearAuth } from '@/common/request.js'

	const RESIDENT_MENU = [
		{ title: '宝宝档案', desc: '宝宝CRUD', icon: 'contact', url: '/pages/user/child/list' },
		{ title: '预约接种', desc: '选择宝宝与疫苗', icon: 'plusempty', url: '/pages/order/add' },
		{ title: '我的预约', desc: '查看预约状态', icon: 'calendar', url: '/pages/user/appointment/list' },
		{ title: '接种记录', desc: '接种历史时间线', icon: 'checkbox', url: '/pages/user/record/list' },
		{ title: '疫苗列表', desc: '查看可接种疫苗', icon: 'list', url: '/pages/vaccine/list' },
		{ title: '接种点信息', desc: '库存·地点·驻场医生', icon: 'location', url: '/pages/user/site/list' },
		{ title: '系统公告', desc: '查看公告', icon: 'notification', url: '/pages/notice/list' }
	]
	const MENU_BY_ROLE = {
		RESIDENT: RESIDENT_MENU,
		USER: RESIDENT_MENU,
		DOCTOR: [
			{ title: '待接种核销', desc: '已排期接种核销', icon: 'checkbox', url: '/pages/doctor/vaccinate/list', color: '#34C759' },
			{ title: '医生工作台', desc: '扫码核销与录入', icon: 'contact', url: '/pages/doctor/workbench', color: '#34C759' },
			{ title: '调遣通知', desc: '查看调遣通知', icon: 'redo', url: '/pages/doctor/dispatch/list', color: '#5856D6' },
			{ title: '系统公告', desc: '查看公告', icon: 'notification', url: '/pages/notice/list' }
		],
		ADMIN: [
			{ title: '排期管理', desc: '排期与扣库存', icon: 'calendar', url: '/pages/admin/schedule/list', color: '#34C759' },
			{ title: '用户管理', desc: '系统用户', icon: 'person', url: '/pages/admin/users', color: '#5856D6' },
			{ title: '疫苗管理', desc: '疫苗信息与批次管理', icon: 'list', url: '/pages/admin/vaccine', color: '#007AFF' },
			{ title: '接种点管理', desc: '接种点维护', icon: 'location', url: '/pages/admin/site', color: '#FF9500' },
			{ title: '公告发布', desc: '通知公告', icon: 'compose', url: '/pages/admin/notice', color: '#FF2D55' },
			{ title: '统计大屏', desc: '数据统计', icon: 'bars', url: '/pages/stats/dashboard', color: '#30B0C7' }
		]
	}

	export default {
		components: {
			AppHeader,
			ChildrenSection: () => import('@/components/ChildrenSection.vue'),
			FunctionMenu: () => import('@/components/FunctionMenu.vue'),
			ClockBar: () => import('@/components/ClockBar.vue')
		},
		data() {
			return {
				role: '',
				vaccineMap: {},
				dispatchUnreadCount: 0,
				pendingNoticeCount: 0,
				pendingAppointmentCount: 0
			}
		},
		computed: {
			roleLabel() {
				const map = { RESIDENT: '家长', USER: '家长', DOCTOR: '医生', ADMIN: '管理员' }
				return map[this.role] || this.role
			},
			isResident() {
				const r = (this.role || '').toUpperCase()
				return r === 'RESIDENT' || r === 'USER'
			},
			menuItems() {
				const r = (this.role || '').toUpperCase()
				return MENU_BY_ROLE[r] || RESIDENT_MENU
			}
		},
		onShow() {
			const userId = getUserId()
			const role = getRole()
			this.role = role || ''
			if (role === 'DOCTOR' && userId) {
				this.loadDispatchUnreadCount()
			} else {
				this.dispatchUnreadCount = 0
			}
			if (role === 'ADMIN') {
				this.loadPendingNoticeCount()
			} else {
				this.pendingNoticeCount = 0
			}
			if (this.isResident && userId) {
				this.loadPendingAppointmentCount()
			} else {
				this.pendingAppointmentCount = 0
			}
			if (!userId || !role) {
				uni.reLaunch({ url: '/pages/login/login' })
				return
			}
			this.role = role
			if (this.$refs.appHeader) this.$refs.appHeader.refreshUser()
		},
		methods: {
			async loadDispatchUnreadCount() {
				try {
					const doctorId = getUserId()
					if (!doctorId) return
					const res = await request({
						url: '/doctor/dispatch/unreadCount',
						method: 'GET',
						data: { doctorId: Number(doctorId) }
					})
					this.dispatchUnreadCount = (res && res.data && res.data.count != null) ? res.data.count : 0
				} catch (_) {
					this.dispatchUnreadCount = 0
				}
			},
			async loadPendingNoticeCount() {
				try {
					const res = await request({ url: '/notice/pending', method: 'GET', data: { current: 1, size: 1 } })
					const { total } = parsePageResponse(res)
					this.pendingNoticeCount = total != null ? total : 0
				} catch (_) {
					this.pendingNoticeCount = 0
				}
			},
			async loadPendingAppointmentCount() {
				try {
					const userId = getUserId()
					if (!userId) return
					const res = await request({
						url: '/order/list',
						method: 'GET',
						data: { current: 1, size: 1, userId, statusType: 'pending' }
					})
					const { total } = parsePageResponse(res)
					this.pendingAppointmentCount = total != null ? total : 0
				} catch (_) {
					this.pendingAppointmentCount = 0
				}
			},
			navTo(url) {
				if (!url) return
				uni.navigateTo({ url })
			},
			logout() {
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
	.page {
		min-height: 100vh;
		background: #f0f2f5;
		padding: 32rpx;
		box-sizing: border-box;
	}
	.header {
		background: linear-gradient(135deg, #007AFF 0%, #5ac8fa 100%);
		border-radius: 24rpx;
		padding: 40rpx 36rpx;
		margin-bottom: 36rpx;
		box-shadow: 0 8rpx 24rpx rgba(0, 122, 255, 0.25);
		.title { display: block; font-size: 38rpx; font-weight: bold; color: #fff; margin-bottom: 8rpx; }
		.subtitle { font-size: 26rpx; color: rgba(255,255,255, 0.9); }
	}
	.footer {
		margin-top: 48rpx;
		.copyright {
			display: block;
			text-align: center;
			font-size: 22rpx;
			color: #bbb;
			margin-bottom: 24rpx;
		}
		.btn-out {
			width: 100%;
			height: 88rpx;
			line-height: 88rpx;
			border-radius: 44rpx;
			font-size: 28rpx;
			color: #666;
			background: #fff;
			box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
			margin-bottom: 24rpx;
		}
	}
</style>
