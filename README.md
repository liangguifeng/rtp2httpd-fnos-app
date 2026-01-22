# rtp2httpd-fnos-app

rtp2httpd - IPTV 流媒体转发服务器，这是一个为飞牛OS（fnOS）平台开发的应用程序包，用于将组播RTP/UDP流转换为单播HTTP流，支持RTSP转HTTP，并提供M3U/M3U8播放列表。

## 🚀 功能特性

- **多协议支持**：组播RTP/UDP转单播HTTP，RTSP转HTTP，支持M3U/M3U8播放列表
- **FCC快速换台**：毫秒级换台响应，媲美原生机顶盒体验
- **实时状态监控**：Web状态页面显示客户端连接、带宽和传输量
- **内置Web播放器**：浏览器直接播放，支持时移回看
- **高性能优化**：非阻塞IO、多核优化、缓冲池共享、零拷贝技术

## 📋 系统要求

- 飞牛OS（fnOS）0.9.0或更高版本
- 架构：x86_64
- 管理员权限（root）

## 📦 安装与部署

1. 将本项目打包为飞牛OS应用程序格式
2. 通过飞牛OS应用中心安装
3. 安装过程中需要配置以下参数：
   - 端口（默认：5140）
   - 上游接口（默认：enp2s0）
   - 是否启用udpxy（默认：yes）
   - 最大客户端数（默认：20）

## ⚙️ 配置说明

应用程序的主要配置文件位于 `${TRIM_PKGETC}/rtp2httpd.conf`，包含以下配置项：

- `verbosity`：日志详细程度
- `maxclients`：最大并发客户端数量
- `udpxy`：是否启用udpxy功能
- `workers`：工作线程数量
- `status-page-path`：状态页面路径
- `player-page-path`：播放器页面路径
- `upstream-interface`：上游网络接口
- `external-m3u`：外部M3U播放列表路径
- `fcc-listen-port-range`：FCC监听端口范围
- `buffer-pool-max-size`：缓冲池最大大小

## 🔧 使用方法

1. 安装完成后，服务会自动启动
2. 访问Web管理界面：
   - 状态页面：`http://<your-server-ip>:<port>/status`
   - 播放器页面：`http://<your-server-ip>:<port>/player`
3. 通过飞牛OS应用中心可以管理服务的启停

## 🌐 网络接口

- 默认服务端口：5140
- FCC端口范围：40000-40100
- 支持HTTP协议进行流媒体转发

## 📊 监控功能

- 实时连接状态监控
- 带宽使用情况统计
- 传输流量统计
- 客户端连接信息

## 🛠️ 维护与故障排除

- 日志文件位置：`${TRIM_PKGVAR}/info.log`
- 进程ID文件：`${TRIM_PKGVAR}/app.pid`
- 可通过命令行控制服务：
  - 启动：`./main start`
  - 停止：`./main stop`
  - 状态检查：`./main status`

## 📄 更新历史

- 网页播放器：频道logo图片加载使用no-referrer策略，避免防盗链导致图片加载失败
- 修复在极少情况下RTSP连接卡在TEARDOWN状态且一直不会释放的问题
- 设置UDP RCVBUF时尝试使用SO_RCVBUFFORCE，以突破内核参数net.core.rmem_max限制，可改善4K视频流偶尔花屏马赛克问题
- 修复对于一些特殊RTSP上游，断开连接时出现RTSP: Socket event handling failed报错


## 🤝 贡献

1. 本项目基于 [oskar456/rtp2httpd](https://github.com/oskar456/rtp2httpd) 重写，专为中国大陆IPTV环境设计。

2. 非常感谢 JetBrains 向我提供了执照，可以从事该项目和其他开源项目。

[![](https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg)](https://www.jetbrains.com/?from=https://github.com/liangguifeng)

## 📚 相关资源

- [GitHub仓库](https://github.com/stackia/rtp2httpd) - 安装指南、配置参数、M3U使用说明
- [论坛教程](https://www.right.com.cn/forum/thread-8461513-1-1.html) - IPTV内网融合、组播转单播实例

## ©️ 版权信息

- 维护者：stackia
- 分发者：liangguifeng
- 基于开源项目重写，专为中国IPTV环境优化
