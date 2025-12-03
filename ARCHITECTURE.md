# Kitty — 架构草案（v0.1）

个人开源项目，目标是用现代 SwiftUI + Clean Architecture + TCA 展示工程能力，同时保持后续扩展的清晰度。

## 总体思路
- 垂直切片：每个工具自成一条线（Domain + Data + Presentation + UI），避免跨工具耦合。
- 依赖方向：`App(UI) → Presentation(TCA) → Domain(协议/实体) ← Data(实现)`，仅向内依赖。
- 可测试性：Domain 纯协议/值类型；Data 可单测；Presentation 用 TCA `TestStore`；UI 仅绑定状态。
- 可扩展性：新工具按同样目录模板复制；少量跨切片基础能力通过协议抽象（Clipboard/Gateway 等）。

## 分层与包划分
- **Domain（Swift Package：KittyDomain）**：协议、实体、用例模型，不依赖 Foundation/SwiftUI。示例：`JsonTransformUseCase`、`JsonTransformRequest/Result/Mode`。
- **Data（Swift Package：KittyData）**：协议实现，使用 Foundation 或系统 API。示例：`DefaultJsonTransformUseCase`（基于 `JSONSerialization`、字符串处理）。
- **Presentation（Swift Package：KittyPresentation）**：TCA Reducer/State/Action，依赖 Domain 协议。通过 TCA Dependencies 注入具体 UseCase。
- **App（macOS Target：Kitty）**：SwiftUI 视图 + 入口，持有 `Store` 并将依赖注入到 TCA 环境。平台相关适配器（如 ClipboardService）放这里或 Platform 子目录。现有 Xcode 项目里的 `Kitty` target 直接作为 App 层。

## 目录建议（示例）
```
Kitty/
├─ Kitty/                      # macOS UI target（现有）
│  └─ Features/
│       └─ JsonTool/
│            └─ JsonToolView.swift
├─ KittyTests/                 # Unit tests（Data/Presentation/Domain）
├─ KittyUITests/               # UI tests（SwiftUI/TCA flows）
├─ KittyPresentation/          # Swift Package
│  └─ Features/JsonTool/JsonToolReducer.swift
├─ KittyDomain/                # Swift Package
│  └─ Features/JsonTool/{JsonTransformMode,Request,Result,UseCase}.swift
└─ KittyData/                  # Swift Package
   └─ Features/JsonTool/DefaultJsonTransformUseCase.swift
```
> 后续工具（Timestamp、QR、Encode 等）按同样切片结构复制。

## TCA 接线
- Reducer 依赖 Domain 协议：`@Dependency(\.jsonTransformUseCase) var jsonUseCase`.
- App 启动时注册依赖：在 `DependencyValues` 或自定义 DI 容器内提供 `DefaultJsonTransformUseCase`。
- View 仅绑定 `Store<State, Action>`；动作通过 Reducer 驱动 UseCase。
- 键盘快捷键等平台输入在 View 层转为 Action。

## v0.1 垂直切片（JSON Tool）
- 功能：格式化/压缩/转义/反转义，错误提示，字符数，复制输出，⌘+↩ 运行。
- 数据流：View → Action(.run/.clear/.copy) → Reducer 调 UseCase → State 更新输出/错误 → View 显示。
- 测试：`DefaultJsonTransformUseCase` 覆盖成功/失败/边界；`JsonToolReducer` 用 `TestStore` 验证状态变更和错误显示。

## 跨切片能力
- ClipboardGateway、FileGateway 等抽象定义在 Domain；默认实现放 Data 或 App 层，通过依赖注入。
- 日志/遥测（如果需要）通过协议注入，避免直连系统 API。

## 代码风格与实践
- 纯 ASCII，尽量小文件，命名以 UseCase/Reducer/State/Action/Result 为核心。
- 面向协议依赖注入；避免单例。
- 预留 Preview 支持，便于演示与回归。

## 后续路线
- 先落地 JSON Tool 样板（代码+测试）作为模板。
- 按模板快速复制 Timestamp/QR/Encode 等模块，确保每个切片自包含。
- 补充 README/图示，展示架构和 TCA 依赖注入方式。
