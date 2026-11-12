# 代码开发规范 · PinNote Flutter

> 本规范是 `flutter analyze` 之外的人为约定。红线条款用 **必须** 表述。

## 1. 工程结构

```
lib/
├── main.dart              # 入口：窗口初始化 + runApp
├── app/
│   ├── app.dart           # MaterialApp、路由表、主题装配
│   ├── app_scope.dart     # AppController（主题模式）+ AppScope
│   └── desktop_window.dart# window_manager 封装（无边框窗口）
├── design/                # 设计系统层 —— 只放变量与原子能力
│   ├── tokens.dart        # 静态变量（字号/间距/圆角/便签色/壁纸）
│   ├── theme.dart         # PinSpec 主题扩展 + ThemeData 装配
│   └── icons.dart         # PinIcon（SVG path 解析 + painter）
├── widgets/               # 通用组件层 —— 只放可复用组件
├── screens/               # 页面层 —— 组装 widgets，一屏一文件
└── data/                  # 演示数据（后续由 Repository/Service 替代）
```

**依赖方向**：`screens → widgets → design`，禁止反向依赖；`design/` 不得 import
widgets/screens；页面之间不互相 import（跳转一律走路由名）。

## 2. 命名与文件

- 文件 `snake_case.dart`，一屏一文件：`<feature>_screen.dart`
- 类 `PascalCase`；页面类以 `Screen` 结尾；私有组件 `_Xxx`，仅页面内可见
- 组件参数：必填在前，`super.key` 固定写法；回调命名 `onTap/onChanged`
- 常量命名：`kXxx`（顶层）或 `static const`（类内）

## 3. Widget 书写规则

1. 页面/组件优先 `StatelessWidget` + `const` 构造；悬停等局部状态用
   `HoverBuilder` / `StatefulWidget`，禁止全页 setState。
2. 布局层级尽量浅：能用 `Row/Column/Stack` 组合就不写 CustomPaint；
   自绘（折角、进度环、点阵）集中在 painter 类。
3. 文本必须指定 `fontFamilyFallback: PinFont.sans`（或用 `PinSpec.t*` 系列样式）。
4. 可滚动区域一律 `SingleChildScrollView` + 明确 `crossAxisAlignment`，
   页面底部留 `PinSpace.s5` 呼吸空间。
5. 禁止使用 Material 视觉组件（ElevatedButton / Card / InkWell 波纹）；
   交互反馈用 HoverBuilder + GestureDetector（自绘组件保持设计语言一致性）。
6. **导航约定（P0 起强制）**：
   - 主屏之间一律 `AppNav.go(context, route)`（pushReplacement），栈深恒为 1；
   - 浮层（任务编辑 / 快速捕获）用 `showTaskEditDialog` / `showQuickCaptureDialog`
     （showGeneralDialog + EscHandler）：点蒙层 / Esc / 确定 / 取消都是 `pop`；
   - 走查基准：全流程操作后 `Navigator` 栈深必须为 0（见 integration_test 走查）。

## 4. 状态管理（当前阶段）

- 全局仅 `AppController`（主题模式），经 `AppScope.of(context)` 访问
- 页面内临时状态：局部 StatefulWidget
- 后续接入真实数据时：Repository 层放 `lib/data/`，通过 Provider/Riverpod 注入
  （引入前先更新本规范与依赖说明）

## 5. 注释与文档

- 每个文件顶部 `///` 库注释：中文一句话说明 + 对应设计稿（如「对应 ui/home.html」）
- 公开类/方法写 `///` doc comment，说明对应 CSS 类名（如「对应 .task」）
- 复杂样式数值写行内注释引用 CSS，如 `// rgba(15,23,42,.08)`

## 6. 质量门禁（提交前全部通过）

```bash
flutter analyze    # 零 error / 零 warning
flutter test       # 冒烟测试 + 组件测试
```

- 新页面必须加入 `test/screens_smoke_test.dart` 冒烟用例（浅色 pump 不抛错）
- 新通用组件必须有渲染测试；设计 tokens 有不变式测试（浅深色关键色不同）

## 7. Git 约定

- 分支：`main` 稳定；功能分支 `feat/<屏名或模块>`
- 提交信息：`feat: 今日页三栏布局` / `fix: 深色模式便签折角颜色`（中文动词开头）
- 提交前运行第 6 节门禁；不提交 `--save` 后的无关格式化 diff

## 8. 已知技术债（按优先级）

1. ~~P0：勾选完成 / 栈管理 / Esc 弹层~~ → 已完成
2. ~~P1：搜索输入过滤 / 键盘导航 / 全局快捷键 / 首启引导~~ → 已完成
   （任务编辑：标题/优先级/标签可编辑并保存，删除可撤销；详情面板联动选中任务）
3. 主题/偏好不持久化——首启引导为会话级标记，重启重置（P2 用 shared_preferences）
4. 快速捕获的识别段（明天9:00 / #工作 / !!）仍为静态展示，未做自然语言解析（P2）
5. 窗口 <900px 侧栏缩窄未实现（P2）；编辑器富文本、桌面贴拖拽/缩放（P2）
6. `PinButton` hover 深化用 sRGB lerp 近似 color-mix
