<template>
	<view class="date-bar">{{ currentDate }}</view>
</template>

<script>
	export default {
		data() {
			return {
				currentDate: '',
				timer: null
			}
		},
		created() {
			this.updateDate()
		},
		mounted() {
			this.startTimer()
		},
		beforeDestroy() {
			this.stopTimer()
		},
		methods: {
			updateDate() {
				const d = new Date()
				const y = d.getFullYear()
				const m = String(d.getMonth() + 1).padStart(2, '0')
				const day = String(d.getDate()).padStart(2, '0')
				const h = String(d.getHours()).padStart(2, '0')
				const min = String(d.getMinutes()).padStart(2, '0')
				const s = String(d.getSeconds()).padStart(2, '0')
				const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
				this.currentDate = `${y}年${m}月${day}日 周${week} ${h}:${min}:${s}`
			},
			startTimer() {
				if (!this.timer) {
					this.timer = setInterval(() => this.updateDate(), 1000)
				}
			},
			stopTimer() {
				if (this.timer) {
					clearInterval(this.timer)
					this.timer = null
				}
			}
		}
	}
</script>

<style lang="scss" scoped>
	.date-bar {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		background-color: #667eea;
		color: #fff;
		text-align: center;
		padding: 20rpx 24rpx;
		font-size: 28rpx;
		font-weight: 500;
		min-height: 40rpx;
		flex-shrink: 0;
	}
</style>
