<template>
	<view v-if="hasError" class="error-boundary">
		<view class="error-content">
			<uni-icons type="info" size="60" color="#f44336" />
			<view class="error-message">{{ errorMessage }}</view>
			<button class="retry-btn" @click="handleRetry">重试</button>
		</view>
	</view>
	<slot v-else />
</template>

<script>
/**
 * 错误边界组件
 * 用于捕获组件树中的错误，展示友好的错误界面
 *
 * @usage
 * <ErrorBoundary @error="handleError">
 *   <YourComponent />
 * </ErrorBoundary>
 */
export default {
	name: 'ErrorBoundary',

	props: {
		// 自定义错误消息
		customErrorMessage: {
			type: String,
			default: ''
		},
		// 是否显示重试按钮
		showRetry: {
			type: Boolean,
			default: true
		}
	},

	data() {
		return {
			hasError: false,
			errorMessage: '',
			errorInfo: null
		};
	},

	methods: {
		/**
		 * 捕获错误
		 * @param {Error|String} error 错误对象或错误消息
		 * @param {Object} info 额外的错误信息
		 */
		captureError(error, info = null) {
			console.error('[ErrorBoundary] 捕获错误:', error, info);

			this.hasError = true;
			this.errorInfo = info;

			// 格式化错误消息
			if (this.customErrorMessage) {
				this.errorMessage = this.customErrorMessage;
			} else if (error instanceof Error) {
				this.errorMessage = error.message || '未知错误';
			} else if (typeof error === 'string') {
				this.errorMessage = error;
			} else {
				this.errorMessage = '操作失败，请稍后重试';
			}

			// 触发错误事件
			this.$emit('error', {
				error,
				message: this.errorMessage,
				info
			});
		},

		/**
		 * 重试操作
		 */
		handleRetry() {
			this.hasError = false;
			this.errorMessage = '';
			this.errorInfo = null;
			this.$emit('retry');
		},

		/**
		 * 手动触发错误（供子组件调用）
		 */
		triggerError(error, info) {
			this.captureError(error, info);
		}
	}
};
</script>

<style lang="scss" scoped>
.error-boundary {
	width: 100%;
	height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: #f5f5f5;
}

.error-content {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 40rpx;
	background-color: #ffffff;
	border-radius: 16rpx;
	box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);

	.error-message {
		margin-top: 24rpx;
		font-size: 28rpx;
		color: #333333;
		text-align: center;
		line-height: 1.5;
	}

	.retry-btn {
		margin-top: 32rpx;
		padding: 20rpx 48rpx;
		background-color: #007AFF;
		color: #ffffff;
		border: none;
		border-radius: 8rpx;
		font-size: 28rpx;

		&:active {
			opacity: 0.8;
		}
	}
}
</style>
