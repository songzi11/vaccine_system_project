/**
 * 疫苗接种系统 - 请求封装
 * 所有请求基础路径：http://localhost:8080（登录：POST /api/users/login，用户列表：GET /api/users）
 * 小程序/App 真机调试请改为本机局域网 IP，如 http://192.168.1.100:8080
 * H5 开发若启用 manifest.json 中 devServer.proxy，可临时将 BASE_URL 设为 '' 走代理避免跨域
 */
const BASE_URL = 'http://localhost:8080'

const TOKEN_KEY = 'token'
const USER_ID_KEY = 'userId'
const USERNAME_KEY = 'username'
const ROLE_KEY = 'role'

function getToken() {
	return uni.getStorageSync(TOKEN_KEY) || ''
}

function getUserId() {
	return uni.getStorageSync(USER_ID_KEY) || ''
}

function getUsername() {
	return uni.getStorageSync(USERNAME_KEY) || ''
}

function getRole() {
	return uni.getStorageSync(ROLE_KEY) || ''
}

export function setToken(token) {
	uni.setStorageSync(TOKEN_KEY, token)
}

export function setUserId(userId) {
	uni.setStorageSync(USER_ID_KEY, String(userId))
}

export function setUsername(username) {
	uni.setStorageSync(USERNAME_KEY, username ? String(username) : '')
}

export function setRole(role) {
	uni.setStorageSync(ROLE_KEY, role ? String(role) : '')
}

export function clearAuth() {
	uni.removeStorageSync(TOKEN_KEY)
	uni.removeStorageSync(USER_ID_KEY)
	uni.removeStorageSync(USERNAME_KEY)
	uni.removeStorageSync(ROLE_KEY)
}

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

function request(options) {
	const path = options.url || ''
	const method = (options.method || 'GET').toUpperCase()
	const url = buildUrl(path, method, options.data)
	const token = getToken()
	const header = { ...(options.header || {}) }
	if (!header['Content-Type'] && !header['content-type']) {
		header['Content-Type'] = 'application/json'
	}
	if (token) header['Authorization'] = 'Bearer ' + token
	if (token && !header['Authorization']) header['token'] = token

	const showLoading = options.loading === true
	if (showLoading) {
		uni.showLoading({ title: '加载中...', mask: true })
	}
	const finalData = method === 'GET' ? undefined : options.data
	return new Promise((resolve, reject) => {
		uni.request({
			...options,
			url,
			data: finalData,
			header,
			timeout: options.timeout != null ? options.timeout : 20000,
			success: (res) => {
				if (res.statusCode === 401) {
					clearAuth()
					uni.reLaunch({ url: '/pages/login/login' })
					const msg = '请重新登录'
					uni.showToast({ title: msg, icon: 'none' })
					reject({ message: msg })
					return
				}
				if (res.statusCode >= 200 && res.statusCode < 300) {
					const body = res.data
					// 后端统一格式 { code, message, data }，业务失败时仍为 HTTP 200 但 code !== 200
					if (body && typeof body.code === 'number' && body.code !== 200) {
						const msg = body.message || body.msg || '请求失败'
						uni.showToast({ title: msg, icon: 'none' })
						reject({ message: msg, data: body })
						return
					}
					resolve(body)
				} else {
					const msg = (res.data && res.data.message) || res.data?.msg || '请求失败(' + (res.statusCode || '') + ')'
					uni.showToast({ title: msg, icon: 'none' })
					reject({ message: msg, data: res.data })
				}
			},
			fail: (err) => {
				const msg = err.errMsg || err.message || ''
				const isTimeout = /timeout|超时/i.test(msg)
				const tip = isTimeout ? '连接超时，请确认后端已启动：' + BASE_URL : (msg || '网络错误，请检查后端或跨域')
				uni.showToast({ title: tip, icon: 'none', duration: 3000 })
				reject({ message: tip })
			},
			complete: () => {
				if (showLoading) uni.hideLoading()
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
	if (data && Array.isArray(data.records)) {
		list = data.records
		total = data.total != null ? Number(data.total) : list.length
	} else if (Array.isArray(data)) {
		list = data
		total = list.length
	} else if (Array.isArray(res.rows)) {
		list = res.rows
		total = res.total != null ? Number(res.total) : list.length
	} else if (Array.isArray(res.list)) {
		list = res.list
		total = res.total != null ? Number(res.total) : list.length
	}
	return { list, total }
}

export default request
export { BASE_URL, getToken, getUserId, getUsername, getRole }
