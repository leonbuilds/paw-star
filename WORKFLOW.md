# PawPedigree 实现工作流（Workflow）

> 这是给 Claude Code 编码 Session 用的**实施手册**。
> 每个任务都标注了：依赖、产出文件、验收标准、关键代码片段、Git 规范。
>
> 上游文档（必读，按优先级）：
> 1. [SPEC.md](SPEC.md) — 需求规格（v1.2 已锁定技术栈）
> 2. [DESIGN_PROPOSALS.md](DESIGN_PROPOSALS.md) §3 — 方案 C 视觉规范
> 3. [TECH_OPTIONS.md](TECH_OPTIONS.md) §2 — 方案甲技术栈
> 4. [CLAUDE.md](CLAUDE.md) — 多 Agent 并行规范
>
> 版本：v1.0 · 2026-05-16

---

## 0. 全局规范

### 0.1 角色边界（硬约束）

Claude Code 在编码阶段：
- ✅ **必须**严格遵循 SPEC.md，不增删功能
- ✅ **必须**在每个 Phase 结束时跑 `swift build` 和预览，确保不破坏现有功能
- ✅ **必须**遵循"0 第三方依赖"原则（SPM Apple 官方包除外）
- ✅ 遇到 SPEC 歧义 → 记录到 `CHANGELOG.md` 并跳过，**不要猜测**
- ✅ 自动修复测试失败最多 3 次，3 次失败后跳过并记录
- ❌ **不得**修改已有测试使其适配新代码
- ❌ **不得**修改 `.env`、`Info.plist`（除明确任务）
- ❌ **不得**直接 push 到 main，所有改动走 Draft PR
- ❌ **不得**自己合并 PR

### 0.2 Git 规范

```
branch: feat/<phase>-<short-name>   例: feat/p1-scaffold, feat/p2-home-view
commit: <type>(<scope>): <subject>
        例: feat(home): add HomeView with 3 entry cards
            fix(network): handle timeout per spec scenario 6
            chore(theme): add Theme.swift with palette C
```

每个 Phase 结束 → 一个 Draft PR，等用户 review。

### 0.3 代码规范

- 文件头不写多行 docstring，只写一行 `// PawStar/<Module>/<File>.swift`
- 命名：UpperCamel for types, lowerCamel for properties/methods
- SwiftUI View：`struct XxxView: View`，单一职责
- ViewModel：`@Observable final class XxxViewModel`，依赖通过 init 注入
- 颜色/字体绝不硬编码，全部走 `Theme.xxx`
- 注释只写"为什么"，不写"做什么"（命名要够清晰）
- 错误处理：网络层 throw，UI 层 catch + fallback

### 0.4 文件大小限制

- 单个 SwiftUI View 文件 < 250 行（超了拆 subview）
- 单个 ViewModel 文件 < 200 行
- 长卡片视图（如 PedigreeCardView）允许到 350 行

### 0.5 并行规则（多 Agent worktree）

按 CLAUDE.md §3 / §7，Phase 2 和 Phase 4 可并行：
- 每个并行任务一个独立 worktree
- 不可同时改 `Theme.swift` / `PetProfile.swift` 等核心文件
- Phase 间串行（前一 Phase Draft PR merge 后才启动下一 Phase）

---

## Phase 1 · 脚手架（Day 1-3，串行，1 Session 完成）

**目标**：从空目录到能跑通 SwiftUI Hello World + SwiftData 注入 + Theme 调色板。

### T1.1 创建 Xcode 项目

- **依赖**：无
- **产出**：`PawStar.xcodeproj` + 默认 SwiftUI App template
- **操作**：
  - Xcode → File → New Project → iOS App
  - Product Name: `PawStar`
  - Interface: SwiftUI
  - Storage: SwiftData
  - Language: Swift
  - Bundle ID: `com.pawstar.app`（占位，正式上架前可改）
  - Minimum Deployments: **iOS 17.0**（启用 SwiftData）—— **注意**：方案文档提到 iOS 26 Liquid Glass API，编译用 iOS 26 SDK，但运行时降级到 iOS 17 兼容（Liquid Glass 在低版本 fallback 到 `.regularMaterial`）
  - Include Tests: ✅
- **验收**：Xcode 打开能 ⌘R 在模拟器跑出空白 App

### T1.2 建立目录结构

- **依赖**：T1.1
- **产出**：完整目录树（按 SPEC §5.2 + TECH_OPTIONS §2.2）

```
PawStar/
├── App/
│   └── PawStarApp.swift                 # @main
├── Theme/
│   └── Theme.swift
├── Models/
│   ├── PetProfile.swift
│   ├── CertificateRecord.swift
│   └── AIResultPayload.swift
├── Features/
│   ├── Home/                            # T2.1
│   ├── Create/                          # T2.2 + T2.3
│   ├── Cards/                           # T2.4-T2.6
│   ├── Preview/                         # T4.2
│   └── History/                         # T4.1
├── Services/
│   ├── NetworkService.swift             # T3.3
│   ├── ImageProcessor.swift             # T2.2
│   └── FallbackProvider.swift           # T5.1
├── Utilities/
│   └── SerialNumberGenerator.swift
└── Resources/
    └── Assets.xcassets
```

- **验收**：所有目录创建好，每个文件先空着（占位 `// TODO: T2.x`）

### T1.3 实现 Theme.swift（方案 C 配色）

- **依赖**：T1.2
- **产出**：`PawStar/Theme/Theme.swift`

```swift
import SwiftUI

enum Theme {
    // MARK: - Colors (方案 C 奶油绒感)
    enum Color {
        static let primary       = SwiftUI.Color(hex: "FF8A3D")  // 暖橙
        static let primaryDark   = SwiftUI.Color(hex: "E5701F")
        static let sakuraPink    = SwiftUI.Color(hex: "FFC2D1")  // 樱花粉
        static let gold          = SwiftUI.Color(hex: "FFCB47")  // 证件金
        static let bgWarm        = SwiftUI.Color(hex: "FFF8F0")  // 暖白
        static let bgCard        = SwiftUI.Color.white
        static let textPrimary   = SwiftUI.Color(hex: "1A1A1A")
        static let textSecondary = SwiftUI.Color(hex: "6B6B6B")
        static let border        = SwiftUI.Color(hex: "EDEDED")
    }

    // MARK: - Typography
    enum Font {
        static func title() -> SwiftUI.Font {
            .system(size: 22, weight: .heavy, design: .default)
        }
        static func cardTitle() -> SwiftUI.Font {
            .system(size: 16, weight: .bold)
        }
        static func body() -> SwiftUI.Font {
            .system(size: 14, weight: .regular)
        }
        static func caption() -> SwiftUI.Font {
            .system(size: 11, weight: .regular)
        }
        static func mono() -> SwiftUI.Font {
            .system(size: 11, design: .monospaced)
        }
    }

    // MARK: - Liquid Glass tint
    static let glassTintColor = Color.sakuraPink.opacity(0.06)
}

// 辅助：hex 转 Color
extension SwiftUI.Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >>  8) & 0xFF) / 255
        let b = Double( v        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
```

- **验收**：Theme.Color.primary 等所有常量在 Swift Playground / Preview 能渲染出正确颜色

### T1.4 定义数据模型

- **依赖**：T1.2
- **产出**：`Models/` 下 3 个文件
- **代码**：直接复制 SPEC.md §4.5 的 Swift code（已经写好），分到 3 个文件

```swift
// PetProfile.swift
import SwiftData
import Foundation

@Model
final class PetProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: PetCategory
    var birthday: Date?
    var avatarImageData: Data?
    var wechatQRImageData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CertificateRecord.pet)
    var certificates: [CertificateRecord]

    init(name: String, category: PetCategory, birthday: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.birthday = birthday
        self.createdAt = .now
        self.certificates = []
    }
}

enum PetCategory: String, Codable {
    case cat, dog
}
```

```swift
// CertificateRecord.swift
import SwiftData
import Foundation

@Model
final class CertificateRecord {
    @Attribute(.unique) var id: UUID
    var type: CertificateType
    var serialNumber: String
    var aiResultData: Data    // JSON-encoded AIResultPayload
    var renderedImageData: Data?
    var includesWechatQR: Bool
    var createdAt: Date

    var pet: PetProfile?

    init(type: CertificateType,
         serialNumber: String,
         payload: AIResultPayload,
         pet: PetProfile?) {
        self.id = UUID()
        self.type = type
        self.serialNumber = serialNumber
        self.aiResultData = (try? JSONEncoder().encode(payload)) ?? Data()
        self.includesWechatQR = false
        self.createdAt = .now
        self.pet = pet
    }

    var payload: AIResultPayload? {
        try? JSONDecoder().decode(AIResultPayload.self, from: aiResultData)
    }
}

enum CertificateType: String, Codable {
    case pedigree, beauty, personality
}
```

```swift
// AIResultPayload.swift
import Foundation

struct AIResultPayload: Codable {
    var primaryLabel: String          // 品种名 / 颜值等级 / 性格主标签
    var grade: String                 // SSR / SR / S+ 等
    var attributes: [String: String]  // {"coatColor": "橘金", "saturation": "92"}
    var description: String           // 个性化点评

    static func sample(type: CertificateType) -> Self {
        switch type {
        case .pedigree:
            return .init(
                primaryLabel: "中华田园猫",
                grade: "SSR",
                attributes: ["coatColor": "橘金", "saturation": "92"],
                description: "此猫眉眼带星，骨相端正，是难得一见的「村霸气质 + 御猫风骨」复合品相。"
            )
        case .beauty:
            return .init(
                primaryLabel: "S+",
                grade: "S+",
                attributes: ["facialSymmetry": "98", "roundness": "92"],
                description: "圆脸 + 对称眼线，自带迪士尼脸滤镜，颜值超越 87% 的同款。"
            )
        case .personality:
            return .init(
                primaryLabel: "小恶魔",
                grade: "S",
                attributes: ["zodiac": "处女座猫"],
                description: "看似温顺实则心机深沉，最爱半夜跑酷把主人吵醒。"
            )
        }
    }
}
```

- **验收**：Models 编译通过；SwiftData ModelContainer 能注入

### T1.5 跑通 SwiftData ModelContainer

- **依赖**：T1.4
- **产出**：`App/PawStarApp.swift`

```swift
import SwiftUI
import SwiftData

@main
struct PawStarApp: App {
    var sharedContainer: ModelContainer = {
        let schema = Schema([PetProfile.self, CertificateRecord.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()                     // T2.1 后实现 HomeView 时替换为 HomeView
                .preferredColorScheme(.light)  // V1 仅浅色
        }
        .modelContainer(sharedContainer)
    }
}

struct RootView: View {
    var body: some View {
        Text("PawPedigree · 即将上线 🐾")
            .font(Theme.Font.title())
            .foregroundStyle(Theme.Color.primary)
    }
}
```

- **验收**：⌘R 跑出 "PawPedigree · 即将上线 🐾" 暖橙色文字

### T1.6 状态管理基线 Example

- **依赖**：T1.5
- **产出**：写一个 dummy `@Observable` ViewModel 验证模式

```swift
// Features/Home/HomeViewModel.swift (Phase 2 会扩展)
import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var greeting: String = "给家里的小明星办张鉴定"

    init() {}
}
```

- **验收**：能在 SwiftUI Preview 里 `@State var vm = HomeViewModel()` 实例化

### Phase 1 验收 + Draft PR

- 所有 T1.x 完成
- `swift build` 通过
- Xcode Preview 正常
- 提 Draft PR：`feat/p1-scaffold`
- PR 标题：`Phase 1: 脚手架 + Theme + 数据模型`
- 通知用户 review

---

## Phase 2 · 本地闭环（Day 4-12，**可并行 3 个 Agent**）

### 并行组 A（互不依赖）

| 任务 | 文件 | 关键点 |
|---|---|---|
| **T2.1 HomeView** | `Features/Home/HomeView.swift` | 方案 C 设计，3 张入口卡片，底部 Liquid Glass Tab Bar |
| **T2.2 PhotoPicker + Crop** | `Features/Create/PhotoPickerView.swift` + `ImageProcessor.swift` | PhotosUI + 方形裁剪 |
| **T2.3 PetFormView** | `Features/Create/PetFormView.swift` | 名字 + 品类 + 生日 |

### 串行组 B（依赖 Theme + 模型）

| 任务 | 文件 | 关键点 |
|---|---|---|
| **T2.4 PedigreeCardView** | `Features/Cards/PedigreeCardView.swift` | 方案 C §3.5 挂牌卡（血统） |
| **T2.5 BeautyCardView** | `Features/Cards/BeautyCardView.swift` | 方案 C §3.5 变体（颜值） |
| **T2.6 PersonalityCardView** | `Features/Cards/PersonalityCardView.swift` | 方案 C §3.5 变体（性格） |

### T2.1 HomeView 实施细节

**对照设计**：DESIGN_PROPOSALS.md §3.3 + design-preview.html `.design-c .home`

**结构**：
```swift
struct HomeView: View {
    @State private var vm = HomeViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 标题栏
                HeaderBar()
                // 鉴定入口列表
                ScrollView {
                    VStack(spacing: 12) {
                        EntryCard(type: .pedigree)
                        EntryCard(type: .beauty)
                        EntryCard(type: .personality)
                    }
                    .padding(20)
                }
                Spacer()
            }
            .background(creamGradient)
            .overlay(alignment: .bottom) { GlassTabBar() }
        }
    }
}
```

**Liquid Glass Tab Bar 关键代码**：
```swift
struct GlassTabBar: View {
    var body: some View {
        HStack {
            TabItem(icon: "🏠", label: "鉴定馆", active: true)
            TabItem(icon: "📖", label: "我的本本", active: false)
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .glassEffect(.clear.tint(Theme.glassTintColor), in: Capsule())
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}
```

**验收**：
- 视觉与 [design-preview.html](design-preview.html) 方案 C 首页 95% 还原
- 3 个卡片点击有反馈（NavigationLink 占位 → 跳转到 T2.2）

### T2.2 PhotoPicker + ImageProcessor

**关键约束**：
- 只支持 PhotosUI `PhotosPicker`，不调相机（V1 简化）
- 方形裁剪：1:1 比例
- 压缩长边 1024px，JPEG 0.85

```swift
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var croppedImage: UIImage?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            // ...
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    croppedImage = await ImageProcessor.squareCrop(uiImage)
                }
            }
        }
    }
}

enum ImageProcessor {
    static func squareCrop(_ image: UIImage) async -> UIImage { ... }
    static func resize(_ image: UIImage, longEdge: CGFloat) -> UIImage { ... }
}
```

**验收**：选图后能进入预览页看到方形裁剪结果

### T2.3 PetFormView

**字段**：name (TextField) + category (Picker `.cat`/`.dog`) + birthday (DatePicker, optional)

**保存**：通过 modelContext 写入 PetProfile

**验收**：保存后能在 SwiftData 数据库里看到记录

### T2.4 / T2.5 / T2.6 三类挂牌卡

**核心规范**：
- 严格按 DESIGN_PROPOSALS.md §3.5 + design-preview.html `.design-c .cert-card` 还原
- 每张卡 350 行以内
- 接收 `CertificateRecord` 作为输入
- 暴露 `func render() -> UIImage` 通过 `ImageRenderer` 输出 PNG（1080×1920）

```swift
struct PedigreeCardView: View {
    let record: CertificateRecord

    var body: some View {
        VStack(spacing: 0) {
            CardHeader(title: "萌宠品相鉴定书", english: "PawPedigree Certificate")
            CardDivider()
            CardPhotoRow(record: record)
            CardColorRow(color: record.payload?.attributes["coatColor"] ?? "")
            CardCommentBox(text: record.payload?.description ?? "")
            CardSerial(serial: record.serialNumber)
            CardFooter()
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .topTrailing) { ToyBadge() }
    }
}
```

**验收**：
- Preview 渲染与 design-preview.html 95% 一致
- 用 sample data 渲染所有 3 类卡片正常

### Phase 2 验收 + Draft PR

- 所有 T2.x 完成
- 首页可点击进入完整流程（不含 AI 调用，先 mock）
- 提 3 个 Draft PR（如果并行）或 1 个合并 PR

---

## Phase 3 · AI 后端 + 集成（Day 13-18，串行）

### T3.1 Cloudflare Worker 转发层

- **新仓库**：`pawpedigree-api`（独立于 iOS 项目）
- **依赖**：Cloudflare 账号、阿里云 DashScope API Key
- **关键文件**：

```typescript
// worker.ts
export interface Env {
  DASHSCOPE_API_KEY: string;
  KV: KVNamespace;
}

interface CertifyRequest {
  type: 'pedigree' | 'beauty' | 'personality';
  image: string;       // base64
  petCategory: 'cat' | 'dog';
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method === 'OPTIONS') return cors();
    if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 });

    const ip = req.headers.get('cf-connecting-ip') ?? 'unknown';
    if (!(await rateLimit(env.KV, ip))) {
      return jsonError(429, 'rate_limited');
    }

    const body = await req.json<CertifyRequest>();
    const prompt = buildPrompt(body.type, body.petCategory);

    try {
      const upstream = await callQwen(env.DASHSCOPE_API_KEY, prompt, body.image);
      const parsed = parseAIResult(upstream);
      return Response.json(parsed, { headers: corsHeaders() });
    } catch (e) {
      return jsonError(502, 'upstream_error');
    }
  }
};
```

- **Prompt 模板**：T3.2 提供
- **部署**：`wrangler deploy`，绑定环境变量
- **验收**：用 curl 测试能返回有效 JSON

### T3.2 三类 Prompt 设计

**通用规则**：
- 强制 JSON 输出（`response_format` 或 prompt 内强制）
- description 30-100 字
- 反差/惊喜语气示例
- 低置信度时 prompt 内置兜底文案

**示例（血统鉴定）**：
```
你是「PawPedigree 萌宠品相鉴定馆」的资深鉴定师。

任务：分析这张{猫|狗}的照片，输出一份娱乐性的"血统鉴定"。

输出 JSON 格式严格如下：
{
  "primaryLabel": "<品种名，如 中华田园猫>",
  "grade": "<SSR|SR|R|N>",
  "attributes": {
    "coatColor": "<毛色描述>",
    "saturation": "<0-100 数字>"
  },
  "description": "<30-100 字反差/惊喜风格的血统点评，要好笑、要走心>"
}

风格示例：
- "此猫眉眼带星，骨相端正，是难得一见的「村霸气质 + 御猫风骨」复合品相。"
- "金毛中的天选打工人，工作能力九十分，撒娇能力一百二十分。"

如果照片模糊/不是猫狗/识别困难：
- primaryLabel 写"神秘血统"
- grade 写"SSR"
- description 写"自带神秘东方血脉，识别系统都无法定义其独特之美。"

只输出 JSON，不要任何前后缀。
```

颜值、性格类同理。**写在 worker.ts 同目录的 `prompts.ts` 中。**

### T3.3 iOS NetworkService

- **文件**：`Services/NetworkService.swift`
- **依赖**：T3.1 后端已部署
- **代码**：见 TECH_OPTIONS.md §2.2 NetworkService 完整示例

**关键约束**：
- 超时 8 秒（URLRequest.timeoutInterval）
- 失败 throw，由 ViewModel catch 后走 FallbackProvider
- baseURL 通过 Info.plist 配置（方便 dev/prod 切换）

### T3.4 AIInferenceView 鉴定中页面

- **对照设计**：DESIGN_PROPOSALS.md §3.4 + design-preview.html `.design-c .inference-content`
- **核心动画**：圆点进度 + "小爪印盖章中" 文案
- **状态机**：
  ```swift
  enum InferencePhase {
      case loading(progress: Double)
      case success(AIResultPayload)
      case fallback(AIResultPayload)
  }
  ```

### T3.5 联调

- 3 类鉴定都端到端跑通：选图 → 表单 → 鉴定 → 卡片
- 网络异常测试：关 WiFi → 应该走 Fallback，不报错
- 超时测试：手动让 Worker delay 10s → 应该 8s 后走 Fallback

### Phase 3 验收 + Draft PR

- 提 2 个 Draft PR：
  1. `feat/p3-backend`（pawpedigree-api 仓库）
  2. `feat/p3-network-integration`（PawStar 仓库）

---

## Phase 4 · 历史本 + 分享（Day 19-22，**可并行 2 个 Agent**）

### T4.1 HistoryView

- **文件**：`Features/History/HistoryView.swift` + ViewModel
- **数据源**：`@Query` 从 SwiftData 获取所有 CertificateRecord，按 `createdAt` 倒序
- **空状态**：方案 C 风格的插画 + "还没鉴定过 给小明星办张证吧"
- **详情页**：点击进入全屏卡片预览（复用 PedigreeCardView 等）

### T4.2 ImageRenderer 导出 + ShareLink

- **文件**：`Features/Preview/CertificatePreviewView.swift`
- **关键代码**：

```swift
struct CertificatePreviewView: View {
    let record: CertificateRecord

    var body: some View {
        VStack {
            CardView(record: record)  // 复用 T2.4-T2.6
            HStack {
                Button("保存到相册") { saveToAlbum() }
                ShareLink(item: renderImage(),
                          preview: SharePreview("PawPedigree 鉴定书", image: Image(uiImage: renderImage())))
            }
        }
    }

    @MainActor
    private func renderImage() -> UIImage {
        let renderer = ImageRenderer(content: CardView(record: record).frame(width: 1080))
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }

    private func saveToAlbum() {
        UIImageWriteToSavedPhotosAlbum(renderImage(), nil, nil, nil)
    }
}
```

**Info.plist**：加 `NSPhotoLibraryAddUsageDescription`

### T4.3 配种名片合成

- **入口**：CertificatePreviewView 增加按钮"为配种制作名片"
- **流程**：
  1. 点击 → PhotosPicker 选二维码图
  2. 二维码合成到挂牌卡右下角"配种联系"区域
  3. 重新调用 ImageRenderer 渲染
- **隐私提示**：弹 Alert "上传的二维码仅本地处理，不会上传服务器"

### Phase 4 验收 + Draft PR

`feat/p4-history-share`

---

## Phase 5 · 打磨 + 上架（Day 23-28，串行）

### T5.1 兜底文案库（FallbackProvider）

- **文件**：`Services/FallbackProvider.swift`
- **数据结构**：每类鉴定 5-10 条预制兜底文案，随机选

```swift
struct FallbackProvider {
    static func makePayload(type: CertificateType, pet: PetProfile) -> AIResultPayload {
        switch type {
        case .pedigree:
            return .init(
                primaryLabel: "神秘血统",
                grade: "SSR",
                attributes: ["coatColor": "稀有混血色"],
                description: pedigreeFallbacks.randomElement()!
            )
        // ...
        }
    }

    private static let pedigreeFallbacks = [
        "自带神秘东方血脉，识别系统都无法定义其独特之美。",
        "稀有混血品种，骨相奇特，建议主人妥善保管。",
        // ... 5-10 条
    ]
}
```

### T5.2 App 图标、启动屏、上架素材

- **图标**：1024×1024 PNG，方案 C 配色，主体爪印 + 证件元素
- **启动屏**：纯背景 + Logo（SwiftUI LaunchScreen）
- **App Store 截图**：5-8 张 6.5" / 5.5"，含首页、鉴定中、3 张证书
- **建议**：用 Figma 或直接 Swift Playground 生成

### T5.3 隐私政策 + 服务条款

- **位置**：托管在 GitHub Pages 或 Notion 公开页
- **必含内容**：
  - 照片传输至阿里云通义千问处理，识别后销毁
  - 二维码仅本地处理
  - 不收集个人信息
  - 不使用任何分析 SDK

### T5.4 App Store Connect 配置

- 数据采集表：照片（仅用于本次鉴定）/ 位置（无）/ 识别码（无）
- 分级：4+
- App 描述：突出"萌宠鉴定 + 仅供娱乐 + 隐私优先"

### T5.5 网信办算法备案 + App 备案（**与 T5.1-T5.4 并行启动**）

- 提前 2-4 周走流程
- 备案材料：SPEC.md + Prompt 规则文档 + 引用通义千问备案号
- 网信办网站：`https://beian.cac.gov.cn/`

### T5.6 真机测试

- 至少 iPhone 13 + iPhone 15
- 全流程跑 3 类鉴定
- 测试网络异常路径
- 测试历史本数据持久化

### T5.7 提审

- 提交 App Store Review
- 准备应对审核问题：
  - 强调"娱乐用途"
  - 强调"非真实证件"
  - 强调"数据本地处理 + 不留存"

### Phase 5 验收

- 已上架（或排队中）
- 提最终 PR `feat/p5-launch-ready` → main

---

## 附录 A：CHANGELOG.md 模板

每个 Session 结束时追加：

```markdown
## [日期] Phase X Session - <主题>

### 完成
- [x] T<x.y> <任务>

### 阻塞
- [ ] <任务>：<原因>

### 失败方案记录
- 尝试了 X → 失败原因 Y

### 环境状态
- 分支：<branch>
- 依赖变动：<有/无>

### 下次继续
- 从 T<x.y> 开始
```

---

## 附录 B：常见歧义 → 处理规则

| 情况 | 处理 |
|---|---|
| SPEC 没明确字体大小 | 按 Theme.Font 提供的层级，最相近的那一档 |
| SPEC 没明确间距 | 默认 16pt，重要分隔 24pt |
| AI 返回了 JSON 之外的内容 | NetworkService 内捕获 + 走 Fallback |
| 网络很慢但未超时 | 不打断，让用户等到 8s timeout |
| 用户首次未授权相册 | 显示原生授权提示，拒绝则禁用相关入口 |
| 多语言（英文）需求出现 | 记 CHANGELOG，跳过（V1 仅中文） |
| 出现 ProMotion 性能问题 | 按 60fps 优化，120fps 是 nice-to-have |

---

## 附录 C：Liquid Glass 兼容性 fallback

iOS 17.0-25.x（旧设备）没有 `.glassEffect`，需要 fallback：

```swift
extension View {
    @ViewBuilder
    func liquidGlass(tint: Color = Theme.glassTintColor,
                     in shape: some Shape = Capsule()) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.tint(tint), in: shape)
        } else {
            self
                .background(.regularMaterial, in: shape)
                .overlay(shape.fill(tint))
        }
    }
}
```

**统一在所有需要 Liquid Glass 的地方调 `.liquidGlass(...)`**，不直接调 `.glassEffect`。
