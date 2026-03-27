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
			<!-- 绑定儿童卡片（宫格展示，显示姓名、月龄） -->
			<view class="section">
				<text class="section-title">我的宝宝</text>
				<view v-if="childrenLoading" class="loading-row">
					<uni-load-more status="loading" />
				</view>
				<view v-else-if="children.length === 0" class="empty-card" @click="navTo('/pages/user/child/add')">
					<text class="empty-text">暂未添加儿童档案</text>
					<text class="empty-hint">点击前往「宝宝档案」添加</text>
				</view>
				<view v-else class="children-grid">
					<view
						v-for="(c, i) in children"
						:key="c.id || i"
						class="child-card"
						@click="navTo('/pages/order/add?childId=' + (c.id || ''))"
					>
						<view class="child-avatar">{{ (c.name || '宝宝').charAt(0) }}</view>
						<text class="child-name">{{ c.name || '宝宝' }}</text>
						<text class="child-age">{{ ageMonths(c) }}月龄</text>
					</view>
				</view>
			</view>

			<!-- 智能提醒栏：根据后端数据高亮显示“宝宝下周该打XXX第N针了” -->
			<view v-if="reminderText" class="reminder-bar">
				<uni-icons type="notification" size="20" color="#ff9500"></uni-icons>
				<text class="reminder-text">{{ reminderText }}</text>
				<text class="reminder-link" @click="navTo('/pages/order/add')">去预约</text>
			</view>
		</template>

		<!-- 按角色展示的宫格菜单（核心功能区使用 Grid，非纵向列表） -->
		<view class="section">
			<text class="section-title">{{ isResident ? '功能' : '工作台' }}</text>
			<view class="menu-grid">
				<view
					v-for="(item, index) in menuItems"
					:key="index"
					class="tile"
					@click="navTo(item.url)"
				>
					<view class="tile-icon-wrap">
						<view class="tile-icon" :style="{ background: (item.color || '#007AFF') + '18' }">
							<uni-icons :type="item.icon" size="44" :color="item.color || '#007AFF'"></uni-icons>
						</view>
						<view v-if="showTileBadge(item)" class="tile-badge"></view>
					</view>
					<text class="tile-title">{{ item.title }}</text>
					<text class="tile-desc" v-if="item.desc">{{ item.desc }}</text>
				</view>
			</view>
		</view>

		<view class="footer">
			<button class="btn-out" type="default" @click="logout">退出登录</button>
			<view class="date-bar">{{ nowDate }}</view>
			<text class="copyright">此App知识产权归宋子嘉所有</text>
		</view>
		<!-- 顶部 AppHeader 已提供【角色名（用户名）】与退出，此处保留底部退出按钮以兼容 -->
	</view>
</template>

<script>
	import AppHeader from '@/components/AppHeader.vue'
	import request, { parsePageResponse, getUserId, getRole, clearAuth } from '@/common/request.js'

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
		components: { AppHeader },
		data() {
			return {
				role: '',
				children: [],
				childrenLoading: false,
				recordsWithNext: [], // 含 nextDoseDate 的接种记录
				vaccineMap: {},       // vaccineId -> vaccineName
				nowDate: '',
				dateTimer: null,
				dispatchUnreadCount: 0,  // 医生端调遣通知未读数量，用于红点
				pendingNoticeCount: 0,   // 管理员待审批公告数
				pendingAppointmentCount: 0  // 家长端待审批预约数
			}
		},
		created() {
			this.updateNowDate()
		},
		mounted() {
			this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
		},
		beforeDestroy() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
			}
		},
		onShow() {
			this.updateNowDate()
			if (!this.dateTimer) {
				this.dateTimer = setInterval(() => this.updateNowDate(), 1000)
			}
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
			if (this.isResident) {
				this.loadChildren()
				this.loadReminderData()
			}
		},
		onHide() {
			if (this.dateTimer) {
				clearInterval(this.dateTimer)
				this.dateTimer = null
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
			},
			// 智能提醒：下周该打的疫苗（nextDoseDate 在 7 天内）
			reminderText() {
				if (!this.recordsWithNext.length || !this.vaccineMap) return ''
				const today = new Date()
				today.setHours(0, 0, 0, 0)
				const in7 = new Date(today)
				in7.setDate(in7.getDate() + 7)
				for (const r of this.recordsWithNext) {
					if (!r.nextDoseDate) continue
					const d = new Date(r.nextDoseDate)
					d.setHours(0, 0, 0, 0)
					if (d >= today && d <= in7) {
						const name = this.vaccineMap[r.vaccineId] || ('疫苗#' + r.vaccineId)
						const dose = (r.doseNumber || 0) + 1
						return `宝宝下周该打${name}第${dose}针了`
					}
				}
				return ''
			}
		},
		methods: {
			updateNowDate() {
				const d = new Date()
				const y = d.getFullYear()
				const m = String(d.getMonth() + 1).padStart(2, '0')
				const day = String(d.getDate()).padStart(2, '0')
				const h = String(d.getHours()).padStart(2, '0')
				const min = String(d.getMinutes()).padStart(2, '0')
				const s = String(d.getSeconds()).padStart(2, '0')
				const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
				this.nowDate = `${y}年${m}月${day}日 周${week} ${h}:${min}:${s}`
			},
			// 儿童月龄：出生日到今天的月数
			ageMonths(c) {
				if (!c.birthDate) return '-'
				const birth = new Date(c.birthDate)
				const now = new Date()
				let m = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth())
				if (now.getDate() < birth.getDate()) m--
				return m < 0 ? 0 : m
			},
			showTileBadge(item) {
				if (!item || !item.url) return false
				if (item.url === '/pages/doctor/dispatch/list') return this.dispatchUnreadCount > 0
				if (item.url === '/pages/admin/notice') return this.pendingNoticeCount > 0
				if (item.url === '/pages/user/appointment/list') return this.pendingAppointmentCount > 0
				return false
			},
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
			async loadChildren() {
				this.childrenLoading = true
				try {
					const userId = getUserId()
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: 1, size: 50, parentId: userId }
					})
					const { list } = parsePageResponse(res)
					this.children = list || []
				} catch (e) {
					this.children = []
				} finally {
					this.childrenLoading = false
				}
			},
			async loadReminderData() {
				const userId = getUserId()
				try {
					const [recRes, vacRes] = await Promise.all([
						request({ url: '/record/list', method: 'GET', data: { current: 1, size: 100, userId } }),
						request({ url: '/vaccine/list', method: 'GET', data: { current: 1, size: 200, status: 1 } })
					])
					const { list: records } = parsePageResponse(recRes)
					const { list: vaccines } = parsePageResponse(vacRes)
					const map = {}
					;(vaccines || []).forEach(v => { map[v.id] = v.vaccineName || v.name || '' })
					this.vaccineMap = map
					this.recordsWithNext = (records || []).filter(r => r.nextDoseDate)
				} catch (_) {
					this.recordsWithNext = []
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
		.subtitle { font-size: 26rpx; color: rgba(255, 255, 255, 0.9); }
	}
	.section {
		margin-bottom: 36rpx;
		.section-title {
			display: block;
			font-size: 30rpx;
			font-weight: 600;
			color: #333;
			margin-bottom: 20rpx;
			padding-left: 8rpx;
		}
	}
	.loading-row { padding: 24rpx; text-align: center; }
	.empty-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 48rpx;
		text-align: center;
		.empty-text { display: block; font-size: 28rpx; color: #666; }
		.empty-hint { display: block; font-size: 24rpx; color: #999; margin-top: 12rpx; }
	}
	.children-grid {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 24rpx;
	}
	@media (min-width: 600px) {
		.children-grid { grid-template-columns: repeat(3, 1fr); }
	}
	.child-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 28rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
		&:active { opacity: 0.92; transform: scale(0.98); }
	}
	.child-avatar {
		width: 80rpx;
		height: 80rpx;
		border-radius: 50%;
		background: linear-gradient(135deg, #007AFF 0%, #5ac8fa 100%);
		color: #fff;
		font-size: 32rpx;
		font-weight: bold;
		display: flex;
		align-items: center;
		justify-content: center;
		margin-bottom: 16rpx;
	}
	.child-name { font-size: 30rpx; font-weight: 600; color: #333; }
	.child-age { font-size: 24rpx; color: #999; margin-top: 6rpx; }

	.reminder-bar {
		background: linear-gradient(90deg, #fff8e6 0%, #fff4d9 100%);
		border-left: 6rpx solid #ff9500;
		border-radius: 16rpx;
		padding: 24rpx 28rpx;
		margin-bottom: 32rpx;
		display: flex;
		align-items: center;
		gap: 16rpx;
		.reminder-text { flex: 1; font-size: 28rpx; color: #333; }
		.reminder-link { font-size: 26rpx; color: #007AFF; }
	}

	.menu-grid {
		display: grid;
		gap: 24rpx;
		grid-template-columns: repeat(2, 1fr);
	}
	@media (min-width: 600px) {
		.menu-grid { grid-template-columns: repeat(3, 1fr); }
	}
	.tile {
		background: #fff;
		border-radius: 24rpx;
		padding: 36rpx 24rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
		min-height: 200rpx;
		&:active { opacity: 0.92; transform: scale(0.98); }
	}
	.tile-icon-wrap {
		position: relative;
		display: inline-block;
		margin-bottom: 20rpx;
	}
	.tile-icon {
		width: 88rpx;
		height: 88rpx;
		border-radius: 20rpx;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.tile-badge {
		position: absolute;
		top: -4rpx;
		right: -4rpx;
		width: 20rpx;
		height: 20rpx;
		border-radius: 50%;
		background: #ff3b30;
		border: 2rpx solid #fff;
	}
	.tile-title { font-size: 28rpx; font-weight: 600; color: #333; text-align: center; }
	.tile-desc { font-size: 22rpx; color: #999; margin-top: 8rpx; text-align: center; }
	.footer {
		margin-top: 48rpx;
		.date-bar {
			text-align: center;
			padding: 20rpx 24rpx 8rpx;
			font-size: 28rpx;
			font-weight: 500;
			color: #333;
			margin-bottom: 4rpx;
		}
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
