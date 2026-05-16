# CHANGELOG

## Phase 1 — 脚手架 + Theme + 数据模型

### 决策记录

**D1.1 aiResultData: Data（而非 AIResultPayload 直接存储）**
SPEC §4.5 写 `var aiResult: AIResultPayload`，但 SwiftData 不支持嵌套 Codable struct 直接持久化。
依据 WORKFLOW T1.4，改为 `var aiResultData: Data`（JSON 编码），计算属性 `payload` 负责解码。

**D1.2 SerialNumberGenerator 格式**
SPEC §4.3.1 描述"18 位"，但示例 `PP-2026-0515-7E3A2B-9F` 实际超过 18 字符。
以示例格式为准：`PP-YYYY-MMDD-XXXXXX-XX`。

**D1.3 iOS 26 Liquid Glass**
`.liquidGlass()` 扩展使用 `#available(iOS 26.0, *)` 分支，低版本 fallback `.regularMaterial`。
当前开发环境若无 iOS 26 SDK，`#available` 块不会编译执行，不影响构建。

**D1.4 PetProfile.birthday 类型**
SPEC §4.5 定义 `birthday: Date?`（可选），WORKFLOW T1.4 代码示例中也是可选，但任务描述中 `init` 签名未含可选标记。
以 SPEC §4.5 为准，birthday 是 `Date?`（可选），init 参数默认值为 nil。

**D1.5 Cards 目录占位文件名**
任务描述创建了 IDCardView.swift 和 DrivingLicenseView.swift 作为占位。
WORKFLOW §Phase 2 中实际目标文件是 PedigreeCardView / BeautyCardView / PersonalityCardView（与原 PROJECT_BRIEF 不同）。
Phase 2 开始时，Agent 需要在 Cards/ 下新建正确的文件名，占位文件可删除或复用。

### 完成任务

- [x] T1.1 PawStar.xcodeproj/project.pbxproj 创建（iOS 17 target，com.pawstar.app，SwiftData framework）
- [x] T1.2 目录结构创建，所有占位文件到位
- [x] T1.3 Theme.swift（方案 C 奶油绒感配色 + 字体常量 + Hex 扩展 + liquidGlass 扩展）
- [x] T1.4 数据模型（PetProfile / CertificateRecord / AIResultPayload）
- [x] T1.5 PawStarApp.swift（@main + ModelContainer 注入 + RootView 占位）
- [x] T1.6 HomeViewModel.swift（@Observable，Phase 2 扩展）
- [x] T1.7 SerialNumberGenerator.swift（PP-YYYY-MMDD-XXXXXX-XX 格式）
- [x] T1.8 Assets.xcassets（Contents + AccentColor + AppIcon）
- [x] T1.9 PawStarTests / PawStarUITests 占位

### 阻塞

无

### 失败方案记录

无

### 环境状态

- 分支：feat/p1-scaffold
- 依赖变动：无（0 第三方依赖）
- Swift 版本：5.0（SWIFT_VERSION）
- 最低部署版本：iOS 17.0

### 下次继续

Phase 2 开始前，用户 review 并 merge 此 Draft PR。
从 T2.1 HomeView、T2.2 PhotoPicker 并行开始。
注意：Cards/ 下需新建 PedigreeCardView / BeautyCardView / PersonalityCardView，对应 SPEC §4.3 三类鉴定书。
