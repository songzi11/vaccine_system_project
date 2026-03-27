<template>
	<view class="page">
		<AppHeader ref="appHeader" />
		<view v-if="loading" class="loading"><text>加载中...</text></view>
		<view v-else-if="detail" class="content">
			<view class="card-actions" v-if="detail.id">
				<button class="btn-edit" size="mini" type="primary" @click="toEdit(detail.id)">编辑用户</button>
			</view>
			<view class="card">
				<view class="card-title">用户信息</view>
				<view class="row"><text class="label">用户名</text><text class="val">{{ detail.username }}</text></view>
				<view class="row"><text class="label">姓名</text><text class="val">{{ detail.realName }}</text></view>
				<view class="row"><text class="label">角色</text><text class="val">{{ detail.role }}</text></view>
				<view class="row"><text class="label">状态</text><text class="val">{{ detail.statusLabel }}</text></view>
				<view class="row"><text class="label">创建时间</text><text class="val">{{ formatTime(detail.createTime) }}</text></view>
				<view class="row"><text class="label">最后登录</text><text class="val">{{ formatTime(detail.lastLoginTime) }}</text></view>
			</view>
			<template v-if="detail.childList && detail.childList.length">
				<view class="card">
					<view class="card-title">关联儿童（{{ detail.childList.length }}）</view>
					<view v-for="c in detail.childList" :key="c.id" class="sub-item">{{ c.name }} · {{ c.birthDate }}</view>
				</view>
			</template>
			<template v-if="detail.appointmentList && detail.appointmentList.length">
				<view class="card">
					<view class="card-title">预约记录（{{ detail.appointmentList.length }}）</view>
					<view v-for="a in detail.appointmentList.slice(0, 10)" :key="a.id" class="sub-item">{{ a.appointmentDate }} {{ a.statusLabel }}</view>
					<view v-if="detail.appointmentList.length > 10" class="sub-item more">共 {{ detail.appointmentList.length }} 条</view>
				</view>
			</template>
			<template v-if="detail.recordList && detail.recordList.length">
				<view class="card">
					<view class="card-title">接种记录（{{ detail.recordList.length }}）</view>
					<view v-for="r in detail.recordList.slice(0, 10)" :key="r.id" class="sub-item">{{ formatTime(r.vaccinateTime) }} {{ r.status }}</view>
					<view v-if="detail.recordList.length > 10" class="sub-item more">共 {{ detail.recordList.length }} 条</view>
				</view>
			</template>
			<template v-if="detail.scheduleList && detail.scheduleList.length">
				<view class="card">
					<view class="card-title">排班/预约（{{ detail.scheduleList.length }}）</view>
					<view class="row"><text class="label">今日预约数</text><text class="val">{{ detail.todayAppointmentCount }}</text></view>
					<view class="row"><text class="label">历史接种数</text><text class="val">{{ detail.historyRecordCount }}</text></view>
				</view>
			</template>
		</view>
		<view v-else-if="!loading" class="empty">用户不存在</view>
	</view>
</template>

<script>
	import AppHeader from '@/components/AppHeader.vue'
	import request from '@/common/request.js'

	export default {
		components: { AppHeader },
		data() {
			return { detail: null, loading: true }
		},
		onLoad(options) {
			const id = options.id
			if (id) this.loadDetail(id)
			else this.loading = false
		},
		onShow() {
			if (this.$refs.appHeader) this.$refs.appHeader.refreshUser()
		},
		methods: {
			formatTime(t) {
				if (!t) return '-'
				const d = new Date(t)
				return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0') + ' ' + String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0')
			},
			toEdit(id) {
				uni.navigateTo({ url: '/pages/admin/user-edit?id=' + (id || '') })
			},
			async loadDetail(id) {
				this.loading = true
				try {
					const res = await request({ url: '/admin/user/detail/' + id, method: 'GET' })
					this.detail = res && res.data ? res.data : null
				} catch (e) {
					this.detail = null
				} finally {
					this.loading = false
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { min-height: 100vh; background: #f5f5f5; padding: 24rpx; padding-bottom: 48rpx; }
	.loading, .empty { padding: 80rpx; text-align: center; color: #999; }
	.content { padding-top: 8rpx; }
	.card-actions { margin-bottom: 24rpx; }
	.btn-edit { margin: 0; }
	.card { background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 24rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06); }
	.card-title { font-size: 30rpx; font-weight: 600; color: #333; margin-bottom: 20rpx; }
	.row { display: flex; margin-bottom: 16rpx; font-size: 28rpx; }
	.label { color: #666; width: 160rpx; flex-shrink: 0; }
	.val { color: #333; flex: 1; }
	.sub-item { font-size: 26rpx; color: #666; margin-bottom: 12rpx; }
	.sub-item.more { color: #999; }
</style>
