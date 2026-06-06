# Rem — 雷姆主题 AI 聊天应用

<p align="center">
  <img src="assets/images/app_icon.jpeg" width="120" alt="App Icon"/>
</p>

基于 Flutter 构建、[Agnes AI](https://agnes-ai.com) 驱动的移动端 AI 聊天应用，以《Re:从零开始的异世界生活》中雷姆为主题。

> 「昴君，雷姆一直在等你。」

## ✨ 功能

- 🤖 **Agnes AI 对话** — 支持 SSE 流式响应，打字机效果
- 💬 **多会话管理** — 创建、切换、删除对话，本地持久化
- 🎨 **雷姆风格 UI** — 樱花粒子特效、角色头像、专属配色
- 📸 **图片选择** — 自定义头像与聊天背景
- 🎤 **语音输入** — speech_to_text 语音转文字
- 🌙 **主题切换** — 浅色 / 深色主题
- 📱 **跨平台** — Android 为主，Flutter 可扩展至 iOS

## 📸 截图

| 开屏 | 首页 | 聊天 |
|:---:|:---:|:---:|
| <img src="assets/images/splash_bg.jpg" width="200"/> | 待补充 | 待补充 |

## 🛠 技术栈

| 类别 | 选择 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | flutter_riverpod |
| 路由 | go_router |
| 网络 | dio (SSE 流) |
| 本地存储 | sqflite + shared_preferences |
| Markdown | flutter_markdown |

## 🚀 快速开始

```bash
# 1. 克隆仓库
git clone git@github.com:kalev-ovo/Rem.git
cd Rem

# 2. 配置 API 密钥
cp .env.example .env
# 编辑 .env，填入你的 Agnes AI 密钥

# 3. 安装依赖
flutter pub get

# 4. 运行
flutter run
```

## 📁 项目结构

```
lib/
├── main.dart              # 入口 + 开屏动画
├── app.dart               # App + 路由配置
├── core/
│   ├── api/               # API 客户端、设置、图片资源
│   ├── db/                # 本地数据库
│   └── theme/             # 主题定义
├── models/                # 数据模型
├── providers/             # Riverpod 状态管理
├── repositories/          # 数据仓库层
└── ui/
    ├── screens/           # 页面
    └── widgets/           # 组件
```

## 📄 许可

仅供学习与个人使用。角色版权归原作者所有。
