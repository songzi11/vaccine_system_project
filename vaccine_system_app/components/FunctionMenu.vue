<template>
	<view class="section">
		<text class="section-title">{{ title }}</text>
		<view class="menu-grid">
			<view
				v-for="(item, index) in menuItems"
				:key="index"
				class="tile"
				@click="handleClick(item)"
			>
				<view class="tile-icon-wrap">
					<view class="tile-icon" :style="{ background: (item.color || '#007AFF') + '18' }">
						<uni-icons :type="item.icon" size="44" :color="item.color || '#007AFF'"></uni-icons>
					</view>
					<view v-if="showBadge(item)" class="tile-badge"></view>
				</view>
				<text class="tile-title">{{ item.title }}</text>
				<text class="tile-desc" v-if="item.desc">{{ item.desc }}</text>
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		props: {
			title: {
				type: String,
				default: '功能'
			},
			menuItems: {
				type: Array,
				default: () => []
			},
			dispatchUnreadCount: {
				type: Number,
				default: 0
			},
			pendingNoticeCount: {
				type: Number,
				default: 0
			},
			pendingAppointmentCount: {
				type: Number,
				default: 0
			}
		},
		methods: {
			showBadge(item) {
				if (!item || !item.url) return false
				if (item.url === '/pages/doctor/dispatch/list') return this.dispatchUnreadCount > 0
				if (item.url === '/pages/admin/notice') return this.pendingNoticeCount > 0
				if (item.url === '/pages/user/appointment/list') return this.pendingAppointmentCount > 0
				return false
			},
			handleClick(item) {
				this.$emit('click', item)
			}
		}
	}
</script>

<style lang="scss" scoped>
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
</style>
