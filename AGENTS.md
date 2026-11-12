# AGENTS.md · AI 协作约束总纲

> 本文件是所有 AI 会话在本仓库工作时**必须遵守**的约束入口。
> 详细细则见 [docs/AI_THEME_GUIDE.md](docs/AI_THEME_GUIDE.md)（主题约束）与
> [docs/CODE_STANDARDS.md](docs/CODE_STANDARDS.md)（代码开发规范）。
> 冲突时优先级：`ui/ 设计稿与 tokens` > 本文件 > 你自己的判断。

## 0. 项目事实

- **产品**：贴记 PinNote — Windows 桌面端待办 + 便签（Flutter 实现）
- **设计稿**：`ui/` 目录（HTML + `tokens.css` + `design.json`），设计语言 V1.0
- **目标平台**：Windows 桌面优先（`os: windows`），其次 macOS / Linux
- **主题**：浅色 + 深色双主题，任何新 UI 必须两种主题下都成立

## 1. 主题约束（红线，违反即返工）

1. **禁止魔法颜色**。UI 代码中不允许出现未经注释的 `Color(0x...)`：
   - 随主题变化的颜色一律 `context.pin.xxx`（见 `lib/design/theme.dart` 的 `PinSpec`）
   - 主题无关的固定色（便签 8 色、清单色点、壁纸、画布底）一律引用
     `lib/design/tokens.dart` 的常量
   - 确需新增颜色：先加到 tokens/theme 并注明对应 CSS 变量名，再使用
2. **禁止魔法数字**：字号用 `PinFontSize`、间距用 `PinSpace`、圆角用 `PinRadius`、
   布局尺寸用 `PinSize`。不在集合内的数值（如 12.5px 正文）允许字面量，但须与设计稿一致。
3. **深色模式不可忽略**：任何新增界面的深色效果来自 PinSpec 的取值，
   不允许 `Colors.black/Colors.white` 硬编码前景背景（图标白色高光等设计稿固定色除外）。
4. **组件优先**：按钮/Chip/复选框/便签/菜单/Toast 等必须用 `lib/widgets/` 里的组件，
   不重复造轮子；需要新组件时先在设计系统层补齐再使用。
5. **文案、结构、数值与设计稿一致**：改 UI 前先读对应 `ui/*.html`，样式数值以
   `ui/app.css` 与 `ui/tokens.css` 为准。

## 2. 代码规范（红线）

1. **目录职责**（详见 CODE_STANDARDS.md）：
   - `lib/design/` 设计系统（tokens/theme/icons），不写业务
   - `lib/widgets/` 通用组件，不写页面专属逻辑
   - `lib/screens/` 页面组装，禁止直接写 hex
   - `lib/data/` 演示数据（后续由 Repository 替代）
2. **静态分析必须零告警**：`flutter analyze` 通过是提交前置条件。
3. **测试**：新页面加进 `test/screens_smoke_test.dart` 的冒烟用例；
   新组件至少一个渲染测试。
4. **依赖克制**：新增第三方包需在 PR/变更说明里给出理由；UI 一律不引 Material 风格
   组件（ElevatedButton/Card/InkWell 视觉体系）。

## 3. 工作流

1. 读设计稿（`ui/<screen>.html` + `ui/app.css` + `ui/tokens.css`）
2. 找/建组件 → 组装页面 → `flutter analyze` → 冒烟测试
3. 桌面验证：`flutter run -d macos`（本机）或 `flutter run -d windows`
4. 交付说明里列出：涉及屏、与设计稿的已知偏差及原因

## 4. 术语表（设计稿 → 代码）

| 设计稿 | 代码 |
| --- | --- |
| `--color-*` 变量 | `PinSpec` 字段（`context.pin`） |
| `--sticky-*` 便签色 | `kStickySchemes` / `StickyColor` |
| `.win` / `.titlebar` | `PinAppWindow` / `PinTitleBar` |
| `.sidebar` / `.nav-item` | `PinSidebar` / `SidebarEntry` |
| `.btn` / `.icon-btn` / `.link` | `PinButton` / `PinIconButton` / `PinLink` |
| `.chip` / `kbd` / `.flag` | `PinChip` / `PinKbd` / `PinFlag` |
| `.cb` / `.radio` / `.switch` / `.pbar` / `.ring` / `.seg` | `PinCheckbox` / `PinRadio` / `PinSwitch` / `PinProgressBar` / `PinRing` / `PinSeg` |
| `.sticky`（8 色/胶带/图钉/折角） | `PinSticky` + `StickyTitle/StickyLine/StickyCheckRow/PinNoteChip` |
| `.menu` / `.toast` | `PinMenu` / `PinToast` |
| `.scene` / `.taskbar` / `.wp-*` | `WallpaperScene` / `PinTaskbar` |
| `.canvas-page` / `.artboard` | `CanvasPage` / `Artboard` |
| `icons.svg#xxx` | `PinIcons.xxx` |
| （导航约定）主屏切换 | `AppNav.go`（pushReplacement，栈深恒 1） |
| （浮层）任务编辑 / 快速捕获 | `showTaskEditDialog` / `showQuickCaptureDialog`（Esc + 蒙层关闭） |
| （状态）任务勾选 / 快速添加 | `TaskScope.of(context)` → `TaskRepository` |
| （反馈）操作 Toast | `showPinToast`（5 秒消失，可撤销） |
