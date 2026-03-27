<template>
	<view class="page">
		<AppHeader ref="appHeader" />
		<view class="toolbar">
			<text class="page-title">用户管理</text>
			<button class="btn-add" size="mini" type="primary" @click="toAdd">添加用户</button>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无用户</view>
			<view v-else class="list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					:class="['item-row', item.status === 2 ? 'row-deactivated' : '']"
				>
					<view class="item-main" @click="toDetail(item.id)">
						<view class="item-title">{{ item.username || '-' }}</view>
						<view class="item-note">{{ item.realName || '' }} · {{ item.role || '' }}</view>
						<view class="item-meta">
							<text class="status-tag" :class="statusClass(item.status)">{{ item.statusLabel || '-' }}</text>
							<text class="meta-text">创建：{{ formatTime(item.createTime) }}</text>
							<text class="meta-text" v-if="item.lastLoginTime">登录：{{ formatTime(item.lastLoginTime) }}</text>
						</view>
					</view>
					<view class="item-actions" v-if="item.status !== 2">
						<button v-if="item.status === 0" class="btn-action btn-disable" size="mini" @click.stop="disable(item)">禁用</button>
						<button v-if="item.status === 1" class="btn-action btn-enable" size="mini" @click.stop="enable(item)">恢复</button>
						<button class="btn-action btn-deactivate" size="mini" @click.stop="confirmDeactivate(item)">注销</button>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
		<!-- 注销二次确认：输入管理员密码 -->
		<view v-if="showDeactivateForm" class="deactivate-form">
			<view class="form-title">请输入当前登录的管理员密码以确认注销</view>
			<input class="form-input" type="password" v-model="adminPassword" placeholder="管理员密码" />
			<view class="form-btns">
				<button class="btn-cancel" @click="closeDeactivate">取消</button>
				<button class="btn-confirm-danger" @click="submitDeactivate">确认注销</button>
			</view>
		</view>
		<view v-if="showDeactivateForm" class="deactivate-mask" @click="closeDeactivate"></view>
	</view>
</template>

<script>
	import AppHeader from '@/components/AppHeader.vue'
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

	export default {
		components: { AppHeader },
		data() {
			return {
				list: [],
				loading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20,
				showDeactivateForm: false,
				adminPassword: '',
				deactivateTargetId: null
			}
		},
		onLoad() {
			this.loadList()
		},
		onShow() {
			if (this.$refs.appHeader) this.$refs.appHeader.refreshUser()
		},
		methods: {
			formatTime(t) {
				if (!t) return '-'
				const d = new Date(t)
				return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0') + ' ' +
					String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0')
			},
			statusClass(status) {
				if (status === 0) return 'status-normal'
				if (status === 1) return 'status-disabled'
				if (status === 2) return 'status-deactivated'
				return ''
			},
			toDetail(id) {
				uni.navigateTo({ url: '/pages/admin/user-detail?id=' + (id || '') })
			},
			toAdd() {
				uni.navigateTo({ url: '/pages/admin/user-edit' })
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const res = await request({
						url: '/admin/user/page',
						method: 'GET',
						data: { current: this.page, size: this.pageSize }
					})
					const data = res && res.data
					const rows = (data && data.records) ? data.records : []
					if (this.page === 1) this.list = rows
					else this.list = this.list.concat(rows)
					this.loadStatus = (rows.length >= this.pageSize) ? 'more' : 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.loadStatus = 'more'
				} finally {
					this.loading = false
				}
			},
			loadMore() {
				if (this.loadStatus !== 'more' || this.loading) return
				this.page++
				this.loadList()
			},
			disable(item) {
				uni.showModal({
					title: '确认禁用',
					content: '禁用后该用户将无法登录，可随时恢复。确定禁用？',
					success: async (res) => {
						if (!res.confirm) return
						try {
							await request({ url: '/admin/user/disable/' + item.id, method: 'POST' })
							uni.showToast({ title: '已禁用', icon: 'success' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '操作失败', icon: 'none' })
						}
					}
				})
			},
			enable(item) {
				uni.showModal({
					title: '确认恢复',
					content: '确定恢复该用户为正常状态？',
					success: async (res) => {
						if (!res.confirm) return
						try {
							await request({ url: '/admin/user/enable/' + item.id, method: 'POST' })
							uni.showToast({ title: '已恢复', icon: 'success' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '操作失败', icon: 'none' })
						}
					}
				})
			},
			confirmDeactivate(item) {
				this.deactivateTargetId = item.id
				this.adminPassword = ''
				this.showDeactivateForm = true
			},
			closeDeactivate() {
				this.showDeactivateForm = false
				this.deactivateTargetId = null
				this.adminPassword = ''
			},
			async submitDeactivate() {
				if (!this.adminPassword || !this.adminPassword.trim()) {
					uni.showToast({ title: '请输入管理员密码', icon: 'none' })
					return
				}
				const adminId = getUserId()
				if (!adminId) {
					uni.showToast({ title: '请重新登录', icon: 'none' })
					return
				}
				try {
					await request({
						url: '/admin/user/deactivate/' + this.deactivateTargetId,
						method: 'POST',
						header: { 'X-User-Id': adminId },
						data: { adminPassword: this.adminPassword.trim() }
					})
					uni.showToast({ title: '已注销', icon: 'success' })
					this.closeDeactivate()
					this.page = 1
					this.loadList()
				} catch (e) {
					uni.showToast({ title: e.message || '操作失败', icon: 'none' })
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar { background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee; display: flex; justify-content: space-between; align-items: center; }
	.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
	.btn-add { margin: 0; }
	.scroll { flex: 1; height: 0; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
	.list { padding: 16rpx; }
	.item-row {
		background: #fff;
		border-radius: 16rpx;
		margin-bottom: 20rpx;
		padding: 24rpx 28rpx;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.06);
	}
	.item-row.row-deactivated { opacity: 0.6; background: #f8f8f8; color: #999; }
	.item-main { flex: 1; min-width: 0; }
	.item-title { font-size: 30rpx; font-weight: 600; color: #333; }
	.item-note { font-size: 24rpx; color: #666; margin-top: 8rpx; }
	.item-meta { margin-top: 12rpx; display: flex; flex-wrap: wrap; align-items: center; gap: 16rpx; }
	.status-tag { font-size: 22rpx; padding: 4rpx 12rpx; border-radius: 8rpx; }
	.status-normal { background: #e8f5e9; color: #2e7d32; }
	.status-disabled { background: #fff3e0; color: #e65100; }
	.status-deactivated { background: #ffebee; color: #c62828; }
	.meta-text { font-size: 22rpx; color: #888; }
	.item-actions { display: flex; gap: 16rpx; flex-shrink: 0; margin-left: 16rpx; }
	.btn-action { margin: 0; padding: 0 20rpx; height: 56rpx; line-height: 56rpx; font-size: 24rpx; }
	.btn-disable { color: #e65100; }
	.btn-enable { color: #2e7d32; }
	.btn-deactivate { color: #c62828; background: #ffebee; }
	.deactivate-mask { position: fixed; left: 0; right: 0; top: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 998; }
	.deactivate-form {
		position: fixed; left: 50%; top: 50%; transform: translate(-50%, -50%);
		width: 560rpx; background: #fff; border-radius: 24rpx; padding: 40rpx; z-index: 999;
	}
	.form-title { font-size: 28rpx; color: #333; margin-bottom: 24rpx; }
	.form-input { border: 1rpx solid #ddd; border-radius: 12rpx; padding: 24rpx; font-size: 28rpx; margin-bottom: 24rpx; }
	.form-btns { display: flex; gap: 24rpx; justify-content: flex-end; }
	.btn-cancel { flex: 1; background: #f5f5f5; color: #666; }
	.btn-confirm-danger { flex: 1; background: #c62828; color: #fff; }
</style>
