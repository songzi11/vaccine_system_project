<template>
	<view class="page">
		<view class="toolbar">
			<text class="page-title">接种记录</text>
			<view class="child-picker-row">
				<text class="label">选择宝宝</text>
				<picker
					mode="selector"
					:range="childOptions"
					range-key="label"
					:value="childIndex"
					@change="onChildChange"
				>
					<view class="picker-value">
						{{ childOptions[childIndex] ? childOptions[childIndex].label : '请选择宝宝' }}
					</view>
				</picker>
			</view>
		</view>
		<scroll-view scroll-y class="scroll" @scrolltolower="loadMore" :lower-threshold="80">
			<view v-if="list.length === 0 && !loading" class="empty">暂无接种记录</view>
			<view v-else class="timeline">
				<view v-for="(item, index) in list" :key="(item.source || '') + '-' + (item.id || index)" class="timeline-item">
					<view class="dot"></view>
					<view class="content">
						<text class="title">{{ item.vaccineName || '接种记录#' + (item.id || '') }}</text>
						<text class="date">{{ formatDate(item.vaccinateTime) }}</text>
						<text class="meta" v-if="item.vaccineCode">疫苗编号：{{ item.vaccineCode }}</text>
						<text class="meta" v-if="item.siteName">接种点：{{ item.siteName }}</text>
						<text class="meta" v-if="item.doctorName">接种医生：{{ item.doctorName }}</text>
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
				childOptions: [{ label: '全部宝宝', value: '' }],
				childIndex: 0,
				list: [],
				loading: false,
				loadStatus: 'noMore'
			}
		},
		onLoad(opts) {
			const urlChildId = opts.childId || ''
			this.loadChildren(urlChildId).then(() => this.loadList())
		},
		methods: {
			formatDate(d) {
				if (!d) return '-'
				const s = String(d)
				return s.replace('T', ' ').substring(0, 19)
			},
			async loadChildren(selectChildId) {
				try {
					const userId = getUserId()
					const res = await request({
						url: '/child/list',
						method: 'GET',
						data: { current: 1, size: 50, parentId: userId }
					})
					const { list: rows } = parsePageResponse(res)
					const options = [{ label: '全部宝宝', value: '' }]
					;(rows || []).forEach(c => {
						options.push({
							label: c.name || '宝宝#' + (c.id || ''),
							value: c.id
						})
					})
					this.childOptions = options
					const idx = selectChildId
						? options.findIndex(o => String(o.value) === String(selectChildId))
						: 0
					this.childIndex = idx >= 0 ? idx : 0
				} catch (_) {}
				return Promise.resolve()
			},
			onChildChange(e) {
				const i = Number(e.detail.value)
				this.childIndex = i
				this.loadList()
			},
			async loadList() {
				if (this.loading) return Promise.resolve()
				this.loading = true
				this.loadStatus = 'loading'
				try {
					const userId = getUserId()
					const selected = this.childOptions[this.childIndex]
					const childId = selected && selected.value !== '' ? selected.value : undefined
					const res = await request({
						url: '/record/list',
						method: 'GET',
						data: {
							userId: childId ? undefined : (userId || undefined),
							childId: childId || undefined
						}
					})
					const list = (res && res.data && Array.isArray(res.data)) ? res.data : []
					this.list = list
					this.loadStatus = 'noMore'
				} catch (e) {
					uni.showToast({ title: e.message || '加载失败', icon: 'none' })
					this.list = []
					this.loadStatus = 'noMore'
				} finally {
					this.loading = false
				}
			},
			loadMore() {}
		}
	}
</script>

<style lang="scss" scoped>
	.page { height: 100vh; display: flex; flex-direction: column; background: #f5f5f5; }
	.toolbar {
		background: #fff; padding: 24rpx 30rpx; border-bottom: 1rpx solid #eee;
		.page-title { display: block; font-size: 36rpx; font-weight: bold; color: #333; }
		.child-picker-row {
			display: flex; align-items: center; margin-top: 16rpx;
			.label { font-size: 26rpx; color: #666; margin-right: 16rpx; }
			.picker-value {
				flex: 1; padding: 16rpx 20rpx; background: #f5f5f5;
				border-radius: 12rpx; font-size: 28rpx; color: #333;
			}
		}
	}
	.scroll { flex: 1; height: 0; }
	.timeline { padding: 30rpx 30rpx 30rpx 50rpx; }
	.timeline-item { position: relative; padding-bottom: 32rpx; }
	.dot {
		position: absolute; left: -28rpx; top: 12rpx; width: 16rpx; height: 16rpx;
		background: #007aff; border-radius: 50%;
	}
	.content {
		background: #fff; border-radius: 12rpx; padding: 24rpx 28rpx;
		box-shadow: 0 4rpx 12rpx rgba(0,0,0,0.06);
	}
	.title { display: block; font-size: 30rpx; font-weight: 500; color: #333; margin-bottom: 8rpx; }
	.date { display: block; font-size: 26rpx; color: #007aff; margin-bottom: 6rpx; }
	.meta { display: block; font-size: 24rpx; color: #999; }
	.empty { padding: 120rpx; text-align: center; color: #999; font-size: 28rpx; }
</style>
