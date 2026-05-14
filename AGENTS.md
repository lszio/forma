# Claude.md — Intent Organizer System Design

# 0. Vision

Intent Organizer 不是传统 Launcher。

它是：

> 一个位于系统与用户之间的 Intent Layer。

目标：

```text
在正确的上下文中，
以最少的认知负担，
提供最正确的 App / Action。
```

系统强调：

* 极简交互
* 上下文感知
* 可解释性
* 低操作成本
* 高可扩展性
* 本地优先
* Apple 原生体验

---

# 1. Product Philosophy

---

## 1.1 核心哲学

用户不应该：

```text
寻找 App
```

而应该：

```text
进入 Intent
```

---

## 1.2 系统目标

系统不是：

* Folder
* Launcher
* Automation Tool

系统是：

```text
Intent Operating Layer
```

---

# 2. SICP Architecture Principles

参考 Structure and Interpretation of Computer Programs。

---

## 2.1 抽象优先

先定义：

* Context
* Rule
* Action
* Intent Space

再定义 UI。

---

## 2.2 数据驱动

行为必须由数据决定。

禁止：

```swift
if workMode {
   ...
}
```

必须：

```swift
Rule.evaluate(context)
```

---

## 2.3 组合优先

复杂行为必须由简单对象组合。

例如：

```text
And(
  TimeRule,
  FocusRule,
  BatteryRule
)
```

---

## 2.4 最小副作用

系统唯一真正 Effect：

```text
Execute(Action)
```

---

# 3. Core System Architecture

---

## 3.1 Global Pipeline

```text
        Context Layer
              ↓
         Rule Engine
              ↓
       Intent Resolver
              ↓
         Action Graph
              ↓
          Renderer
              ↓
           Effects
```

---

# 4. Core Models

---

## 4.1 AppID

```swift
struct AppID: Hashable, Codable {

    let bundleId: String
}
```

---

## 4.2 Context

```swift
struct Context {

    let now: Date

    let weekday: Int

    let batteryLevel: Float

    let lowPowerMode: Bool

    let focusMode: String?

    let recentUsage: [AppID: Date]

    let appUsageFrequency: [AppID: Int]

    let deviceState: DeviceState
}
```

---

## 4.3 DeviceState

```swift
struct DeviceState {

    let isCharging: Bool

    let screenBrightness: Float

    let thermalState: ThermalState

    let networkType: NetworkType
}
```

---

# 5. Intent Space

Intent Space 是系统核心。

---

## 5.1 Space Definition

```swift
struct Space: Identifiable, Codable {

    let id: UUID

    var name: String

    var icon: String

    var actions: [ActionNode]

    var ruleTree: RuleNode?

    var presentation: PresentationStyle

    var customization: SpaceCustomization
}
```

---

# 6. Rule Engine

---

## 6.1 Rule Philosophy

规则必须：

* Declarative
* Pure
* Serializable
* Composable

---

## 6.2 Rule Protocol

```swift
protocol Rule {

    func evaluate(context: Context) -> Bool
}
```

---

## 6.3 Rule AST

```swift
indirect enum RuleNode {

    case and([RuleNode])

    case or([RuleNode])

    case not(RuleNode)

    case time(TimeRule)

    case battery(BatteryRule)

    case focus(FocusModeRule)

    case usage(UsageRule)
}
```

---

## 6.4 Rule Engine

```swift
struct RuleEngine {

    func resolve(
        spaces: [Space],
        context: Context
    ) -> [Space] {

        spaces.filter {

            guard let rule = $0.ruleTree else {
                return true
            }

            return evaluate(rule, context)
        }
    }
}
```

---

# 7. Action System

---

## 7.1 Action Philosophy

Action 是系统唯一可执行对象。

---

## 7.2 ActionNode

```swift
enum ActionNode: Codable {

    case openApp(AppID)

    case openSpace(UUID)

    case shortcut(String)

    case siriIntent(String)

    case sequence([ActionNode])
}
```

---

## 7.3 Action Graph

复杂行为由 Action Graph 表达。

例如：

```text
Open Work Space
    ↓
Open Mail
    ↓
Open Calendar
```

---

# 8. Renderer System

Renderer 是解释器。

---

## 8.1 Renderer Principle

```text
同一数据模型
可被多个 Renderer 解释
```

---

## 8.2 Renderer Types

```swift
enum RendererType {

    case appGrid

    case widgetCompact

    case widgetExpanded

    case stack

    case focus
}
```

---

# 9. UI / UX System

---

# 9.1 UX Philosophy

用户操作必须：

```text
接近 O(1)
```

即：

* 少思考
* 少点击
* 少配置

---

# 9.2 Main Navigation

整个 App 只有三层。

---

## Layer 1 — Home

展示：

```text
Spaces
```

形式：

* Card Grid
* Horizontal Stack
* Adaptive Layout

用户操作：

* Tap → Open Space
* Long Press → Quick Edit
* Swipe → Pin / Hide

---

## Layer 2 — Space

展示：

```text
Resolved Actions
```

即：

```text
Rule Engine → Action List
```

用户操作：

* Tap Action
* Drag reorder（可选）
* Long press customization

---

## Layer 3 — Editor

用于：

* 编辑 Rule
* 编辑 Presentation
* 编辑 Actions

---

# 10. Widget UX

基于 WidgetKit。

---

## 10.1 Widget Philosophy

Widget 不应该：

* 承担复杂交互
* 承担规则逻辑

Widget 只负责：

```text
Display Intent
```

---

## 10.2 Widget Types

---

### Compact Widget

显示：

* Top Actions
* 当前 Intent

---

### Expanded Widget

显示：

* Action Grid
* Dynamic Ranking
* Smart Suggestions

---

### Adaptive Widget（未来）

根据 Context 自动切换。

---

# 11. Customization System

---

# 11.1 Philosophy

用户应该：

```text
定制结果
而不是编程系统
```

---

# 11.2 Space Customization

```swift
struct SpaceCustomization {

    var accentColor: String

    var iconStyle: IconStyle

    var layoutStyle: LayoutStyle

    var animationStyle: AnimationStyle

    var rankingMode: RankingMode
}
```

---

# 11.3 Layout System

---

## Grid Layout

适合：

* 高频启动

---

## Stack Layout

适合：

* Context Flow

---

## Focus Layout

只显示：

```text
最重要 Action
```

---

# 12. Rule Builder UX

---

## 12.1 Philosophy

不允许用户接触 AST。

---

## 12.2 Visual Builder

用户编辑：

```text
IF
 Focus == Work
AND
 Time between 9~18

THEN
 Show Work Space
```

系统内部：

```text
And(
  FocusRule(work),
  TimeRule(9...18)
)
```

---

# 13. Siri / Apple Integration

---

# 13.1 Architecture

推荐：

* App Intents
* Shortcuts

避免：

* 旧 SiriKit 复杂结构

---

# 13.2 App Intents

---

## OpenSpaceIntent

```swift
struct OpenSpaceIntent: AppIntent {

    static var title: LocalizedStringResource = "Open Space"

    @Parameter(title: "Space")
    var space: String

    func perform() async throws -> some IntentResult {

        return .result()
    }
}
```

---

# 13.3 Siri UX

用户：

```text
“Open Work Space”
```

系统：

```text
Siri
 ↓
App Intent
 ↓
Intent Resolver
 ↓
Action Graph
```

---

# 14. AI Layer

---

# 14.1 AI Position

AI 不是系统核心。

AI 只能：

```text
Suggest
Generate
Explain
Optimize
```

---

# 14.2 AI Output

AI 必须输出：

```text
Rule AST
Action Graph
Ranking Suggestions
```

禁止：

```text
AI directly executes actions
```

---

# 14.3 AI Examples

用户：

```text
“下班后自动切换娱乐模式”
```

AI：

```text
And(
  TimeRule(18...24),
  Not(FocusRule(work))
)
```

---

# 15. Persistence

---

## 15.1 Storage

本地：

* SwiftData / SQLite

同步：

* iCloud / CloudKit

---

## 15.2 Sync Principle

```text
Local First
```

---

# 16. State Management

---

## 16.1 Architecture

推荐：

```text
Unidirectional Data Flow
```

---

## 16.2 State Layers

```text
SystemState
   ↓
ContextState
   ↓
ResolvedSpaces
   ↓
UIState
```

---

# 17. Performance Principles

---

## 17.1 Rule Engine

必须：

* Pure
* Incremental
* Cacheable

---

## 17.2 Renderer

必须：

* Stateless
* Declarative

---

# 18. Future Extensions

---

## 18.1 macOS

可增加：

* Floating Space
* Menu Bar Space
* Spotlight Extension
* Keyboard Navigation

---

## 18.2 AI Ranking

未来：

```text
Hybrid Ranking Engine
```

但：

```text
必须保持 deterministic fallback
```

---

# 19. Non-Negotiable Constraints

---

## 禁止：

```text
复杂脚本 system
```

---

## 禁止：

```text
用户编程
```

---

## 禁止：

```text
多层嵌套导航
```

---

## 禁止：

```text
规则与 UI 耦合
```

---

# 20. Final Architecture Summary

```text
            Context
               ↓
           Rule AST
               ↓
          Rule Engine
               ↓
        Intent Resolver
               ↓
          Action Graph
               ↓
            Renderer
               ↓
             Effects
```

---

# 21. Final Product Definition

> “A context-aware intent operating layer for organizing and executing digital actions.”

---

# 22. Refined Extensibility

## 22.1 Rule Extension
To add a new rule type (e.g., `LocationRule`):
1. Update `RuleNode` enum.
2. Update `RuleEngine.evaluate`.
3. Update `RuleEditorView`.

## 22.2 AI-to-AST Pipeline
The AI layer (using LLM) will be prompted to return JSON matching the `RuleNode` Codable structure.
Example Prompt: "Create a rule for weekend mornings."
Result: `{"time": {"startHour": 7, "endHour": 11, "weekdays": [1, 7]}}`

# 23. State Sync & Persistence
- Use `NSPersistentCloudKitContainer` with SwiftData for seamless sync.
- `Context` is transient and never persisted.
- `Space` and `RuleTree` are the primary persisted entities.

# End
