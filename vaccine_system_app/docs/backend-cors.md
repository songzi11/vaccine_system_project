# 后端对接说明

前端已配置接口地址：**http://localhost:8080**（见 `common/request.js`）。

## 1. 运行前端

- **H5**：用 HBuilderX 运行到浏览器，或 CLI 运行 `npm run dev:h5`（若项目带该脚本）。  
- **小程序 / App**：真机调试时请把 `common/request.js` 里的 `BASE_URL` 改为本机局域网 IP，例如：`http://192.168.1.100:8080`（`localhost` 在真机上指向手机本机）。

## 2. 跨域（仅 H5 需要）

H5 在浏览器里访问 `http://localhost:8080` 会触发跨域，Spring Boot 需允许该来源，例如：

```java
// 方式一：全局 CORS 配置
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")   // 或 .allowedOrigins("http://localhost:5173", "http://127.0.0.1:5173")
                .allowedMethods("*")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}

// 方式二：在 Controller 上使用 @CrossOrigin(origins = "*")
```

配置后重启后端，再刷新前端页面即可。

## 3. 接口路径约定

前端请求路径（相对 BASE_URL）：

| 接口     | 方法   | 路径           |
|----------|--------|----------------|
| 登录     | POST   | /user/login    |
| 疫苗列表 | GET    | /vaccine/list  |
| 预约列表 | GET    | /order/list?userId=xxx |
| 新增预约 | POST   | /order/add     |
| 取消预约 | DELETE | /order/{id}    |
| 接种记录 | GET    | /record/list   |
| 公告列表 | GET    | /notice/list   |

确保后端路径与上表一致（或在前端 `request.js` 及各页面中改成你实际路径）。
