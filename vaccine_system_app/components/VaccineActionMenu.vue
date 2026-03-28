<template>
	<uni-popup ref="actionMenuPopup" type="bottom">
		<view class="action-menu">
			<view class="action-item" @click="handleAction('toggleStatus')">
				<text>{{ actionMenuItem && actionMenuItem.status === 1 ? '下架' : '上架' }}</text>
			</view>
			<view class="action-item" @click="handleAction('edit')">
				<text>编辑</text>
			</view>
			<view class="action-item danger" @click="handleAction('delete')">
				<text>删除</text>
			</view>
			<view class="action-cancel" @click="close">
				<text>取消</text>
			</view>
		</view>
	</uni-popup>
</template>

<script>
	export default {
		data() {
			return {
				actionMenuItem: null
			}
		},
		methods: {
			open(item) {
				this.actionMenuItem = item
				this.$refs.actionMenuPopup && this.$refs.actionMenuPopup.open()
			},
			close() {
				this.$refs.actionMenuPopup && this.$refs.actionMenuPopup.close()
				this.actionMenuItem = null
			},
			handleAction(action) {
				this.close()
				this.$emit('action', action, this.actionMenuItem)
			}
		}
	}
</script>

<style lang="scss" scoped>
	.action-menu {
		background: #fff;
		border-radius: 16rpx 16rpx 0 0;
		padding: 20rpx 0;
	}
	.action-item {
		padding: 30rpx;
		font-size: 32rpx;
		color: #333;
		text-align: center;
		border-bottom: 1rpx solid #eee;
	}
	.action-item:last-child {
		border-bottom: none;
	}
	.action-item.danger {
		color: #f44336;
	}
	.action-cancel {
		margin-top: 16rpx;
		padding: 30rpx;
		font-size: 32rpx;
		color: #666;
		text-align: center;
		background: #f5f5f5;
		border-radius: 16rpx;
		margin: 20rpx;
	}
</style>
