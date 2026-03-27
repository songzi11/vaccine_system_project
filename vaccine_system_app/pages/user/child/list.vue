<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">宝宝档案</text>
			<text class="btn-add" @click="goAdd">+ 添加宝宝</text>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无宝宝档案，点击右上角添加</view>
			<view v-else class="card-list">
				<view
					v-for="(item, index) in list"
					:key="item.id || index"
					class="card"
					@click="goEdit(item)"
				>
					<view class="card-body">
						<text class="name">{{ item.name || '未填写姓名' }}</text>
						<text class="meta">出生日期：{{ item.birthDate || '-' }}</text>
						<text class="meta">性别：{{ genderText(item.gender) }}</text>
						<text class="meta" v-if="item.contraindicationAllergy">禁忌/过敏：{{ item.contraindicationAllergy }}</text>
					</view>
					<view class="card-actions">
						<text class="link" @click.stop="goEdit(item)">编辑</text>
						<text class="link" @click.stop="goRecord(item)">接种记录</text>
						<text class="link highlight" @click.stop="goAppointment(item)">去预约</text>
						<text class="link link-danger" @click.stop="doDelete(item)">删除</text>
					</view>
				</view>
			</view>
			<uni-load-more v-if="list.length > 0" :status="loadStatus" />
		</scroll-view>
	</view>
</template>

<script>
	import request, { parsePageResponse, getUserId } from '@/common/request.js'

	export default {
		data() {
			return {
				list: [],
				loading: false,
				loadStatus: 'more',
				page: 1,
				pageSize: 20
			}
		},
		onLoad() {
			this.loadList()
		},
		onShow() {
			// 每次进入页面刷新列表，与管理员端维护的宝宝档案实时同步
			this.page = 1
			this.loadList()
		},
		methods: {
			genderText(g) {
				const map = { 0: '未知', 1: '男', 2: '女' }
				return map[g] != null ? map[g] : (g != null ? String(g) : '-')
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const parentId = getUserId()
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: this.page, size: this.pageSize, parentId: parentId || undefined }
					})
					const { list: rows } = parsePageResponse(res)
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
			goAdd() {
				uni.navigateTo({ url: '/pages/user/child/add' })
			},
			goEdit(item) {
				uni.navigateTo({ url: '/pages/user/child/edit?id=' + (item.id || '') })
			},
			goRecord(item) {
				uni.navigateTo({ url: '/pages/user/record/list?childId=' + (item.id || '') })
			},
			goAppointment(item) {
				uni.navigateTo({ url: '/pages/order/add?childId=' + (item.id || '') })
			},
			doDelete(item) {
				if (!item || !item.id) return
				uni.showModal({
					title: '确认删除',
					content: '确定删除宝宝档案「' + (item.name || '') + '」吗？删除后不可恢复。',
					success: async (res) => {
						if (!res.confirm) return
						try {
							const parentId = getUserId()
							await request({
								url: '/child/' + item.id + (parentId ? '?parentId=' + parentId : ''),
								method: 'DELETE'
							})
							uni.showToast({ title: '已删除', icon: 'success' })
							this.page = 1
							this.loadList()
						} catch (e) {
							uni.showToast({ title: e.message || '删除失败', icon: 'none' })
						}
					}
				})
			}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar {
		background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee;
		display: flex; justify-content: space-between; align-items: center;
		.page-title { font-size: 36rpx; font-weight: bold; color: #333; }
		.btn-add { font-size: 28rpx; color: #007aff; }
	}
	.scroll { flex: 1; height: 0; }
	.card-list { padding: 20rpx; }
	.card {
		background: #fff; border-radius: 16rpx; padding: 28rpx; margin-bottom: 20rpx;
		box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.06);
	}
	.card-body { margin-bottom: 20rpx; }
	.name { display: block; font-size: 32rpx; font-weight: 600; color: #333; margin-bottom: 12rpx; }
	.meta { display: block; font-size: 26rpx; color: #666; margin-bottom: 6rpx; }
	.card-actions { display: flex; gap: 24rpx; }
	.link { font-size: 26rpx; color: #666; }
	.link.highlight { color: #007aff; }
	.link-danger { color: #ee0a24; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
</style>
