# rtp2httpd-fnos-app

rtp2httpd - IPTV 流媒体转发服务器，这是一个为飞牛 fnOS 平台开发的应用程序包，用于将组播 RTP/UDP 流转换为单播 HTTP 流，支持 RTSP 转 HTTP，并提供 M3U/M3U8 播放列表。

<img width="3574" height="1740" alt="Image" src="https://github.com/user-attachments/assets/9d7e4d27-ec37-40b7-b4d5-375492a30377" />

## 🚀 功能特性

完整功能说明见 https://github.com/stackia/rtp2httpd 项目。

## 📋 系统要求

- fnOS 1.1.3100 或更高版本
- 架构：x86_64 或 aarch64

## 📦 安装与部署

1. 通过 fnOS 应用中心搜索 `rtp2httpd` 安装
2. 安装过程中需要配置以下参数：
   - 默认上游接口（默认：enp2s0）
   - 服务监听端口（默认：5140；留空或 0 时只通过统一网关访问）

## ⚙️ 配置说明

应用程序的主要配置文件位于 `${TRIM_PKGETC}/rtp2httpd.conf`。具体参数请参考 [配置文件格式](https://rtp2httpd.com/reference/configuration#%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F)。

## 🔧 使用方法

1. 安装完成后，服务会自动启动
2. 访问 Web 管理界面：
   - 状态页面：`http://<your-server-ip>:5140/app/rtp2httpd/status`
   - 播放器页面：`http://<your-server-ip>:51也可以从你的飞牛桌面直接访问40/app/rtp2httpd/player`
   - 也可以点击飞牛桌面上的 `rtp2httpd 面板` / `rtp2httpd 播放器` 直接在桌面内访问
3. 通过应用中心可以管理服务的启停

## 🛠️ 维护与故障排除

- 日志位置：`${TRIM_PKGVAR}/info.log` / `${TRIM_PKGVAR}/script.log`
- 进程ID文件：`${TRIM_PKGVAR}/app.pid`
- 可通过命令行控制服务：
  - 启动：`./main start`
  - 停止：`./main stop`
  - 状态检查：`./main status`

## 🤝 贡献

非常感谢 JetBrains 向我提供了执照，可以从事该项目和其他开源项目。

[![](https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg)](https://www.jetbrains.com/?from=https://github.com/liangguifeng)

## 📚 相关资源

- [rtp2httpd 官方文档](https://rtp2httpd.com) - 安装指南、配置参数、M3U使用说明
- [论坛教程](https://www.right.com.cn/forum/thread-8461513-1-1.html) - IPTV内网融合、组播转单播实例

## ©️ 版权信息

- 维护者：stackia
- 分发者：liangguifeng
