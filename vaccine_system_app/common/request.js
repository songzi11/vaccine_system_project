/**
 * 疫苗接种系统 - 请求封装
 * 所有请求基础路径：http://localhost:8080（登录：POST /api/users/login，用户列表：GET /api/users）
 * 小程序/App 真机调试请改为本机局域网 IP，如 http://192.168.1.100:8080
 * H5 开发若启用 manifest.json 中 devServer.proxy，可临时将 BASE_URL 设为 '' 走代理避免跨域
 *
 * @author vaccine-system
 * @since 2026-03-27
 */

// 常量定义
const BASE_URL = 'http://localhost:8080'
const TOKEN_KEY = 'token'
const USER_ID_KEY = 'userId'
const USERNAME_KEY = 'username'
const ROLE_KEY = 'role'

// 默认配置
const DEFAULT_CONFIG = {
	timeout: 20000,
	loadingText: '加载中...'
}

// 状态码常量
const HTTP_STATUS = {
	OK: 200,
	UNAUTHORIZED: 401,
	FORBIDDEN: 403,
	NOT_FOUND: 404,
	SERVER_ERROR: 500
}

// 获取本地存储数据
function getStorageData(key, defaultValue = '') {
	try {
		return uni.getStorageSync(key) || defaultValue
	} catch (e) {
		console.error(`获取本地存储失败: ${key}`, e)
		return defaultValue
	}
}

// 设置本地存储数据
function setStorageData(key, value) {
	try {
		uni.setStorageSync(key, value)
	} catch (e) {
		console.error(`设置本地存储失败: ${key}`, e)
		throw new Error('存储空间不足，请清理后重试')
	}
}

// 移除本地存储数据
function removeStorageData(key) {
	try {
		uni.removeStorageSync(key)
	} catch (e) {
		console.error(`移除本地存储失败: ${key}`, e)
	}
}

// 获取认证信息
export function getToken() {
	return getStorageData(TOKEN_KEY, '')
}

export function getUserId() {
	return getStorageData(USER_ID_KEY, '')
}

export function getUsername() {
	return getStorageData(USERNAME_KEY, '')
}

export function getRole() {
	return getStorageData(ROLE_KEY, '')
}

// 设置认证信息
export function setToken(token) {
	if (!token) {
		console.warn('设置空token')
	}
	setStorageData(TOKEN_KEY, token)
}

export function setUserId(userId) {
	setStorageData(USER_ID_KEY, String(userId))
}

export function setUsername(username) {
	setStorageData(USERNAME_KEY, username ? String(username) : '')
}

export function setRole(role) {
	setStorageData(ROLE_KEY, role ? String(role) : '')
}

// 清除认证信息
export function clearAuth() {
	removeStorageData(TOKEN_KEY)
	removeStorageData(USER_ID_KEY)
	removeStorageData(USERNAME_KEY)
	removeStorageData(ROLE_KEY)
}

// 构建URL
function buildUrl(path, method, data) {
	const base = path.startsWith('http') ? path : (BASE_URL + (path.startsWith('/') ? path : '/' + path))
	if (method === 'GET' && data && typeof data === 'object' && Object.keys(data).length > 0) {
		const query = Object.keys(data)
			.filter(k => data[k] !== undefined && data[k] !== null && data[k] !== '')
			.map(k => encodeURIComponent(k) + '=' + encodeURIComponent(data[k]))
			.join('&')
		return query ? (base + (base.indexOf('?') >= 0 ? '&' : '?') + query) : base
	}
	return base
}

// 显示加载中
function showLoading(text) {
	uni.showLoading({ title: text || DEFAULT_CONFIG.loadingText, mask: true })
}

// 隐藏加载中
function hideLoading() {
	uni.hideLoading()
}

// 显示提示
function showToast(title, icon = 'none', duration = 2000) {
	uni.showToast({ title, icon, duration })
}

// 处理401未授权
function handleUnauthorized() {
	clearAuth()
	showToast('请重新登录', 'none')
	// 延迟跳转，避免跳转前toast还没显示
	setTimeout(() => {
		uni.reLaunch({ url: '/pages/login/login' })
	}, 1500)
}

// 处理网络错误
function handleNetworkError(err) {
	const msg = err.errMsg || err.message || ''
	const isTimeout = /timeout|超时/i.test(msg)
	const tip = isTimeout ? `连接超时，请确认后端已启动：${BASE_URL}` : (msg || '网络错误，请检查后端或跨域')
	showToast(tip, 'none', 3000)
	return { message: tip }
}

// 核心请求方法
function request(options) {
	const path = options.url || ''
	const method = (options.method || 'GET').toUpperCase()
	const url = buildUrl(path, method, options.data)
	const token = getToken()
	const header = { ...(options.header || {}) }

	// 设置Content-Type
	if (!header['Content-Type'] && !header['content-type']) {
		header['Content-Type'] = 'application/json'
	}

	// 设置认证头
	if (token) {
		header['Authorization'] = 'Bearer ' + token
		if (!header['token']) {
			header['token'] = token
		}
	}

	// 处理loading
	const showLoadingFlag = options.loading === true
	if (showLoadingFlag) {
		showLoading(options.loadingText)
	}

	const finalData = method === 'GET' ? undefined : options.data

	return new Promise((resolve, reject) => {
		uni.request({
			...options,
			url,
			data: finalData,
			header,
			timeout: options.timeout != != null ? options.timeout : DEFAULT_CONFIG.timeout,
			success: (res) => {
				// 处理401未授权
				if (res.statusCode === HTTP_STATUS.UNAUTHORIZED) {
					handleUnauthorized()
					reject({ message: '请重新登录' })
					return
				}

				// 处理HTTP错误
				if (res.statusCode < 200 || res.statusCode >= 300) {
					const msg = (res.data && res.data.message) || res.data?.msg || `请求失败(${res.statusCode})`
					showToast(msg, 'none')
					reject({ message: msg, data: res.data })
					return
				}

				// 处理业务错误（HTTP 200 但 code !== 200）
				const body = res.data
				if (body && typeof body.code === 'number' && body.code !== HTTP_STATUS.OK) {
					const msg = body.message || body.msg || '请求失败'
					showToast(msg, 'none')
					reject({ message: msg, data: body })
					return
				}

				// 请求成功
				resolve(body)
			},
			fail: (err) => {
				reject(handleNetworkError(err))
			},
			complete: () => {
				if (showLoadingFlag) {
					hideLoading()
				}
			}
		})
	})
}

/** 统一成功提示（可选 duration） */
export function showToast(title, icon = 'success', duration = 2000) {
	uni.showToast({ title, icon, duration })
}

/** 统一失败/无数据提示 */
export function showErrorToast(title) {
	uni.showToast({ title: title || '操作失败', icon: 'none' })
}

/**
 * 解析分页列表响应（兼容后端 PageResult：data.records 与旧格式 data/rows/list）
 * @param {Object} res - request 返回的完整响应体 { code, message, data }
 * @returns {{ list: Array, total: number }}
 */
export function parsePageResponse(res) {
	const data = res && res.data
	let list = []
	let total = 0

	// 兼容 PageResult 格式 (data.records)
	if (data && Array.isArray(data.records)) {
		list = data.records
		total = data.total != != null ? Number(data.total) : list.length
	}
	// 兼容直接返回数组
	else if (Array.isArray(data)) {
		list = data
		total = list.length
	}
	// 兼容旧格式 (data.rows)
	else if (Array.isArray(res.rows)) {
		list = res.rows
		total = res.total != = null ? Number(res.total) : list.length
	}
	// 兼容旧格式 (data.list)
	else if (Array.isArray(res.list)) {
		list = res.list
		total = res.total != = null ? Number(res.total) : list.length
	}

	return { list, total }
}

// 导出常量
export const CONSTANTS = {
	BASE_URL,
	TOKEN_KEY,
	USER_ID_KEY,
	USERNAME_KEY,
	ROLE_KEY,
	HTTP_STATUS,
	DEFAULT_CONFIG
}

// 默认导出
export default request
