# 贴记 PinNote · Flutter 桌面端

Windows 桌面待办 + 便签应用。UI 按 `ui/` 目录下的设计稿（HTML + 设计语言 V1.0）
1:1 还原为 Flutter 实现，浅色 / 深色双主题。

## 快速开始

```bash
# macOS 本机预览
flutter run -d macos

# Windows 目标平台
flutter run -d windows
```

窗口为无边框 + 自绘 Windows 风格标题栏（右上角最小化 / 最大化 / 关闭）。
标题栏主题按钮可切换浅色 / 深色（对应设计稿 dark.html）。

## 页面地图（与 ui/*.html 对应）

| 路由 | 页面 | 设计稿 |
| --- | --- | --- |
| `/` | 今日（三栏：侧栏 / 任务列表 / 详情） | home.html |
| `/notes` | 便签库（8 色便签卡墙） | notes.html |
| `/note-editor` | 便签编辑（画布页） | note-editor.html |
| `/desktop-pins` | 桌面贴总览（壁纸场景） | desktop-pins.html |
| `/pin-controls` | 桌面贴控制（工具条 + 右键菜单） | pin-controls.html |
| `/quick-capture` | 快速捕获（全局捕获窗） | quick-capture.html |
| `/search` | 搜索（Ctrl+K 浮层） | search.html |
| `/task-edit` | 任务编辑（弹层 + 迷你日历） | task-edit.html |
| `/settings` | 设置 · 外观 | settings.html |
| `/tray` | 托盘与通知 | tray.html |
| `/empty-states` | 空状态与反馈 | empty-states.html |
| `/onboarding` | 首次启动引导 | onboarding.html |
| `/account` | 登录与账户 | account.html |
| `/design-language` | 设计语言规范（活文档页） | design-language.html |
| 深色 | 标题栏主题按钮切换 | dark.html |

## 目录与规范

- `AGENTS.md` — AI 协作约束总纲（主题红线 + 代码红线）
- `docs/AI_THEME_GUIDE.md` — 设计变量 → Flutter 映射细则
- `docs/CODE_STANDARDS.md` — 代码开发规范（结构 / 命名 / 门禁）
- `lib/design/` 设计系统 · `lib/widgets/` 通用组件 · `lib/screens/` 页面

## 质量门禁

```bash
flutter analyze   # 零告警
flutter test      # 冒烟 + 组件测试
```

## 技术说明

- 图标：`ui/icons.svg` 的 40+ Fluent 线性图标经内嵌 SVG path 解析器逐字移植
  （`lib/design/icons.dart`），保持 1.75px 线宽与 `currentColor` 语义。
- 便签：8 色（lemon/apricot/cherry/mint/sky/lavender/paper/night）、胶带 / 图钉 /
  右下折角，见 `lib/widgets/sticky_note.dart`。
- 桌面场景：壁纸四款（wp-a~d）+ 毛玻璃任务栏（BackdropFilter）。
- 窗口：`window_manager` 隐藏系统标题栏，自绘拖拽区与窗口按钮；
  插件不可用（测试 / 预览）时静默降级。
