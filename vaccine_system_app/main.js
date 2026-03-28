import App from './App'
import store from './store'

// ========== 全局错误处理 ==========

/**
 * 全局错误处理器
 * 统一处理应用中的未捕获错误
 */
uni.onError((error) => {
	console.error('[全局错误]', error);

	// 错误信息格式化
	let errorMessage = '系统错误，请稍后重试';

	if (error instanceof Error) {
		errorMessage = error.message || errorMessage;
	} else if (typeof error === 'string') {
		errorMessage = error;
	} else if (error && error.errMsg) {
		errorMessage = error.errMsg;
	}

	// 置顶显示错误提示（避免被其他toast覆盖）
	uni.showToast({
		title: errorMessage,
		icon: 'none',
		duration: 3000,
		position: 'center',
		mask: true
	});

	// 在开发环境下输出完整的错误堆栈
	// #ifdef MP-WEIXIN || H5
	if (error instanceof Error && error.stack) {
		console.error('[错误堆栈]', error.stack);
	}
	// #endif
});

/**
 * 未处理的Promise拒绝处理
 */
uni.onUnhandledRejection((rejection) => {
	console.error('[未处理的Promise拒绝]', rejection);

	let errorMessage = '操作失败，请稍后重试';

	if (rejection instanceof Error) {
		errorMessage = rejection.message || errorMessage;
	} else if (typeof rejection === 'string') {
		errorMessage = rejection;
	}

	uni.showToast({
		title: errorMessage,
		icon: 'none',
		duration: 2000
	});
});

// #ifndef VUE3
import Vue from 'vue'
Vue.config.productionTip = false
Vue.prototype.$store = store
Vue.prototype.$adpid = "1111111111"
Vue.prototype.$backgroundAudioData = {
	playing: false,
	playTime: 0,
	formatedPlayTime: '00:00:00'
}
App.mpType = 'app'

// Vue全局错误处理
Vue.config.errorHandler = (err, vm, info) => {
	console.error('[Vue错误]', err, info);
	uni.showToast({
		title: '页面错误: ' + (err.message || '未知错误'),
		icon: 'none',
		duration: 3000
	});
};

const app = new Vue({
	store,
	...App
})
app.$mount()
// #endif

// #ifdef VUE3
import {
	createSSRApp
} from 'vue'
import * as Pinia from 'pinia';
import Vuex from "vuex";
export function createApp() {
	const app = createSSRApp(App)
	app.use(store)
	app.use(Pinia.createPinia());
	app.config.globalProperties.$adpid = "1111111111"
	app.config.globalProperties.$backgroundAudioData = {
		playing: false,
		playTime: 0,
		formatedPlayTime: '00:00:00'
	}

	// Vue3全局错误处理
	app.config.errorHandler = (err, instance, info) => {
		console.error('[Vue3错误]', err, info);
		uni.showToast({
			title: '页面错误: ' + (err.message || '未知错误'),
			icon: 'none',
			duration: 3000
		});
	};

	return {
		app,
		Vuex, // 如果 nvue 使用 vuex 的各种map工具方法时，必须 return Vuex
		Pinia // 此处必须将 Pinia 返回
	}
}
// #endif
