# AI 主题约束细则 · Design Tokens → Flutter 映射

> 面向 AI 会话的**主题实现约束**。目标：任何由 AI 产出的界面在浅色 / 深色模式下
> 都与 `ui/tokens.css`（设计语言 V1.0）保持一致，且不引入设计系统之外的颜色。

## 1. 变量映射总表

`ui/tokens.css` → `lib/design/`，**一对一**，改动必须同步两边：

| CSS 变量 / 值 | Flutter | 说明 |
| --- | --- | --- |
| `--font-sans` | `PinFont.sans` | 字体族回退列表 |
| `--font-mono` | `PinFont.mono` | hex / 快捷键标注 |
| `--text-2xs..2xl`（11/12/13/14/16/18/22） | `PinFontSize.xs2..xxl` + `PinSpec.t2xs..t2xl` | 桌面密度字号阶梯 |
| `--space-1..7`（4/8/12/16/24/32/48） | `PinSpace.s1..s7` | 4/8 基准 |
| `--radius-sm/md/lg/full`（8/10/14/999） | `PinRadius.*` | 控件/卡片/窗口 |
| `--color-bg/surface/surface-2/surface-3` | `PinSpec.bg/surface/surface2/surface3` | 背景 · 面板 · 侧栏 · 输入底 |
| `--color-text/text-2/faint` | `PinSpec.text/text2/faint` | 三级文本 |
| `--color-line/line-strong/hover` | `PinSpec.line/lineStrong/hover` | 边框与悬停 |
| `--color-primary/-strong/-tint` | `PinSpec.primary/primaryStrong/primaryTint` | 主色 |
| `--color-sel-bg/-text` | `PinSpec.selBg/selText` | 选中行 |
| `--color-success/warning/danger/violet/teal/pink`（各 `*`/`-strong`/`-tint`） | `PinSpec.success/.../pinkTint` | 语义色（strong 文字、tint 底色） |
| `--shadow-sm/far/lift` | `PinSpec.shadowSm/shadowFar/shadowLift` | 近/远/悬浮阴影 |
| `--sticky-*`（8 色 × 5 值） | `kStickySchemes[StickyColor.*]` | 便签 bg/line/ink/ink2/fold |
| `--dot-*` 清单色点 | `PinListDots.*` | 收件箱/工作/生活/学习/阅读 |
| `--tack-red` / `--tape` | `PinDecor.tackRed/tape` | 图钉 / 胶带 |
| `--ease` / `--dur`（180ms） | `PinMotion.ease/dur` | 动效曲线与时长 |
| `@media (prefers-reduced-motion)` | 暂不实现（桌面端跟随系统可后补） | 已知偏差 |

## 2. 颜色使用规则

1. **角色优先**：按语义取色（`text2` 表示二级文本），禁止「看起来像」的取值。
2. **语义色配对**：`dangerStrong`（文字）配 `dangerTint`（底色）成对出现；
   深色模式下 strong/tint 会同时变化，单独混用会破坏对比度。
3. **主色 hover**：`primary` 悬停 = `Color.lerp(primary, black, 0.2)`
   （对应 CSS `color-mix(80% primary, black)`），封装在 `PinButton` 内，业务勿重复实现。
4. **color-mix 白底混合**（便签上的 chip / 工具条）：
   `Color.lerp(scheme.bg, Colors.white, 混白比例)`，比例取 CSS 里的百分比。
5. **场景固定色**：壁纸、任务栏、画布页底、托盘毛玻璃等是设计稿的固定值，
   使用 `const Color(0x...)` 并在行内注释 CSS 来源，如 `// rgba(14,18,26,.82)`。

## 3. 深色模式（dark.html / PRD 7.8）

- 切换入口：标题栏主题按钮（`AppController.toggle()`）
- 深色值全部在 `pinSpecDark`；新增 PinSpec 字段必须**同时**补浅色与深色值
- 便签 8 色与深浅无关（`night` 色本身即深色便签）
- 深色下阴影加深（`.30/.42`），由 `pinSpecDark` 承载，无需业务处理

## 4. 文字规范

- 一级文本 `spec.text`，二级 `spec.text2`，占位/时间戳 `spec.faint`
- 标题 22/18 页面·区块，卡片标题 14 w600，正文 13 行高 1.4，辅助 12，标签/时间 11
- 删除线文本：`TextDecoration.lineThrough` + `decorationColor: spec.faint`

## 5. 布局与交互数值

- 主窗口：侧栏 220（`PinSize.sidebar`）、详情面板 340、<1180 隐藏详情、<900 侧栏 190
- 标题栏高 44，右上 146×32 为窗口按钮区，自绘 Windows 按钮（`_WindowButtons`）
- 任务行 hover `spec.hover`、选中 `spec.selBg` + 左侧 3px 主色条
- 悬停联动：父级 `HoverBuilder` 包裹后，子级 `PinCheckbox` 自动跟随
  `a:hover .cb { border-color: primary }`
- 动效：180ms `Cubic(0.2, 0.8, 0.2, 1)`，按压 scale 0.97

## 6. 新增设计变量的流程

1. 在 `ui/tokens.css` 补 CSS 变量（保持设计语言同步）
2. `PinSpec` 加字段并补浅/深两份值（或 `tokens.dart` 加静态常量）
3. `AGENTS.md` 术语表登记
4. 才能在业务代码中使用
