# PawPedigree 技术方案对比 · 3 选 1

> 配套文档：[SPEC.md](SPEC.md) · [DESIGN_PROPOSALS.md](DESIGN_PROPOSALS.md) · [design-preview.html](design-preview.html)
>
> 设计方案已锁定 → **方案 C 奶油绒感**。本文档是 **人工检查点 ②**：在用户选定的产品和视觉前提下，提出 2-3 个技术方案对比，决定大模型供应商、后端部署、状态管理细节。
>
> 版本：v1.0 · 2026-05-16

---

## 0. 决策上下文（来自 SPEC.md）

| 约束 | 来源 | 值 |
|---|---|---|
| 平台 | SPEC §5.1 | iOS 17.0+，Swift 5.10+，SwiftUI |
| 后端职责 | SPEC §5.4 | 仅 API 代理转发，不存数据库、不存照片 |
| 性能 | SPEC §5.6 | 鉴定流程 < 10s、冷启动 < 1.5s |
| 成本 | SPEC §5.7 | 单次 < ¥0.15，月度 ¥1500 上限 |
| 网络兜底 | SPEC §3.2 场景 6 | 超时/失败时输出娱乐结果，不显示"识别失败" |
| 隐私 | SPEC §3.2 场景 8 | 照片识别后销毁、不留存 |
| 合规 | SPEC §5.5 | App 备案 + 网信办算法备案 |
| 数据持久化 | SPEC §4.5 | SwiftData |

### 共通技术决策（3 方案共用）

这些在 SPEC 已经定了，不用再选：

- **UI**：SwiftUI（不用 UIKit，不用 Storyboard）
- **状态管理基线**：`@Observable` 宏 + `@State` 局部状态（iOS 17+ 标配，CLAUDE.md §7.2 强制）
- **导航**：`NavigationStack`（不用 NavigationView）
- **持久化**：SwiftData `@Model`（不用 Core Data、不用 Realm）
- **图片选择**：PhotosUI `PhotosPicker`（不用第三方）
- **图片渲染**：SwiftUI `ImageRenderer`（不用 UIGraphicsImageRenderer）
- **分享**：`ShareLink`（不用 UIActivityViewController）
- **网络**：`URLSession` + async/await（不引入 Alamofire / Moya）
- **JSON**：`Codable`
- **依赖管理**：Swift Package Manager（**V1 目标 0 第三方依赖**）

**待选的就 3 个维度**：大模型供应商、后端部署位置、客户端架构层次。

---

## 1. 方案对比矩阵（速览）

| 维度 | 🥇 方案甲（性价比党） | 方案乙（合规稳定党） | 方案丙（品质优先党） |
|---|---|---|---|
| 大模型 | 通义千问 VL-Max（阿里） | 智谱 GLM-4V Plus | Gemini 2.5 Flash（Google） |
| 单次成本 | ~¥0.05 | ~¥0.10 | ~¥0.08 |
| 月度成本（15k 次） | **~¥750/月** | ~¥1500/月 | ~¥1200/月 |
| 后端部署 | Cloudflare Workers（海外） | 阿里云函数计算（国内） | Vercel Edge Functions（海外） |
| ICP 备案 | ✅ 豁免 | ❌ 必做（5-20 工作日） | ✅ 豁免 |
| 算法备案 | ⚠️ 引用阿里备案号 + 自报 | ⚠️ 引用智谱备案号 + 自报 | ❌ 需自己提交（用海外模型不能蹭备案） |
| 中国访问稳定性 | ★★★（偶尔抖动） | ★★★★★ | ★★（依赖 Vercel 边缘节点） |
| 文案能力 | ★★★★ | ★★★★ | ★★★★★ |
| 上架时间影响 | 0 | +2-3 周（备案排期） | 0 |
| 客户端架构 | 分层 ViewModel | 分层 ViewModel + Repository | 分层 ViewModel + Repository + Service |
| 实现工期 | 3 周 | 3.5 周 | 3.5 周 |
| 风险 | Cloudflare 大陆抖动 | 备案流程不可控 | 算法备案最难、Gemini 文案中文反差感未验证 |
| **推荐度** | **🥇 强烈推荐** | 🥈 备选 | 🥉 不推荐 |

---

## 2. 方案甲：性价比党 · 通义千问 + Cloudflare 🥇

> **定位**：用最低成本、最快上架、最少备案麻烦跑通 V1，验证产品后再决定要不要升级。

### 2.1 技术栈

```
┌──────────────────────────────────────────────────┐
│  iOS App (SwiftUI + SwiftData)                   │
│  ├─ Theme + Liquid Glass UI                      │
│  ├─ ViewModels (@Observable)                     │
│  ├─ NetworkService (URLSession + async/await)    │
│  └─ Codable models                               │
└──────────────────────────────────────────────────┘
                       │ HTTPS
                       ▼
┌──────────────────────────────────────────────────┐
│  Cloudflare Workers（pawpedigree-api.workers.dev）│
│  ├─ 路由 /api/v1/certify                          │
│  ├─ 速率限制（IP + 设备指纹）                       │
│  ├─ Prompt 注入                                   │
│  ├─ 图片预处理（resize 到 1024px 长边）             │
│  └─ 出错兜底（返回娱乐型 fallback JSON）           │
└──────────────────────────────────────────────────┘
                       │ HTTPS（出海回国内）
                       ▼
┌──────────────────────────────────────────────────┐
│  阿里云 通义千问 VL-Max                            │
│  https://dashscope.aliyuncs.com                  │
│  - 多模态视觉理解                                  │
│  - 中文文案能力强                                  │
│  - 已完成网信办算法备案（可引用）                    │
│  - ¥0.02/千 input + ¥0.03/千 output              │
└──────────────────────────────────────────────────┘
```

### 2.2 关键模块（客户端）

**目录结构（在 PawStar 项目基础上）**

```
PawStar/
├── App/
│   └── PawStarApp.swift              # @main, ModelContainer 注入
├── Theme/
│   └── Theme.swift                   # 方案 C 配色 + 字体常量
├── Models/
│   ├── PetProfile.swift              # @Model
│   ├── CertificateRecord.swift       # @Model
│   └── AIResultPayload.swift         # Codable
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Create/
│   │   ├── PhotoPickerView.swift
│   │   ├── PetFormView.swift
│   │   ├── AIInferenceView.swift
│   │   └── CreateViewModel.swift
│   ├── Cards/
│   │   ├── PedigreeCardView.swift
│   │   ├── BeautyCardView.swift
│   │   └── PersonalityCardView.swift
│   ├── Preview/
│   │   ├── CertificatePreviewView.swift
│   │   └── PreviewViewModel.swift
│   └── History/
│       ├── HistoryView.swift
│       └── HistoryViewModel.swift
├── Services/
│   ├── NetworkService.swift          # URLSession 封装
│   ├── ImageProcessor.swift          # 压缩、裁剪、合成
│   └── FallbackProvider.swift        # 兜底文案库
└── Utilities/
    └── SerialNumberGenerator.swift   # 18 位伪鉴定编号
```

**状态管理：@Observable ViewModel 模式**

```swift
@Observable
final class CreateViewModel {
    var pet: PetProfile?
    var selectedImage: UIImage?
    var phase: Phase = .idle

    enum Phase {
        case idle
        case form
        case inferring(progress: Double)
        case done(CertificateRecord)
        case fallback(CertificateRecord)
    }

    private let network: NetworkService
    private let fallback: FallbackProvider

    init(network: NetworkService = .shared,
         fallback: FallbackProvider = .shared) {
        self.network = network
        self.fallback = fallback
    }

    func certify(type: CertificateType) async {
        guard let image = selectedImage, let pet else { return }
        phase = .inferring(progress: 0.1)

        do {
            let result = try await network.certify(
                type: type, image: image, petCategory: pet.category
            )
            let record = makeRecord(type: type, payload: result)
            phase = .done(record)
        } catch {
            // 场景 6 兜底
            let record = fallback.makeRecord(type: type, pet: pet)
            phase = .fallback(record)
        }
    }
}
```

**网络层：单一 endpoint + 类型安全**

```swift
struct CertifyRequest: Encodable {
    let type: String           // "pedigree" / "beauty" / "personality"
    let image: String          // base64
    let petCategory: String    // "cat" / "dog"
}

struct CertifyResponse: Decodable {
    let primaryLabel: String
    let grade: String
    let attributes: [String: String]
    let description: String
}

@Observable
final class NetworkService {
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://pawpedigree-api.workers.dev")!

    func certify(type: CertificateType,
                 image: UIImage,
                 petCategory: PetCategory) async throws -> CertifyResponse {
        let resized = ImageProcessor.resize(image, longEdge: 1024)
        let base64 = resized.jpegData(compressionQuality: 0.85)!.base64EncodedString()

        let req = CertifyRequest(
            type: type.rawValue,
            image: base64,
            petCategory: petCategory.rawValue
        )

        var request = URLRequest(url: baseURL.appending(path: "api/v1/certify"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)
        request.timeoutInterval = 8

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError
        }
        return try JSONDecoder().decode(CertifyResponse.self, from: data)
    }
}
```

### 2.3 后端模块（Cloudflare Worker）

```typescript
// worker.ts
export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method !== 'POST') return new Response('', { status: 405 });

    // 速率限制（KV-based，IP 维度）
    const ip = req.headers.get('cf-connecting-ip') || 'unknown';
    const allowed = await checkRateLimit(env.KV, ip);
    if (!allowed) return jsonError(429, 'rate_limited');

    const body = await req.json() as CertifyBody;

    // 调用通义千问 VL-Max
    const prompt = buildPrompt(body.type, body.petCategory);
    const aiResp = await fetch(
      'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${env.DASHSCOPE_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'qwen-vl-max',
          input: {
            messages: [{
              role: 'user',
              content: [
                { image: `data:image/jpeg;base64,${body.image}` },
                { text: prompt }
              ]
            }]
          },
          parameters: { result_format: 'message' }
        })
      }
    );

    if (!aiResp.ok) return jsonError(502, 'upstream_error');

    const aiData = await aiResp.json();
    const parsed = parseAIResult(aiData);  // 提取 JSON
    return Response.json(parsed);
  }
};
```

### 2.4 月度成本

| 项 | 月度 | 备注 |
|---|---|---|
| 通义千问 VL-Max | ¥750 | 5000 用户 × 3 次 × ¥0.05 |
| Cloudflare Workers | ¥0 | 免费层 100k 请求/天足够 |
| Cloudflare KV（速率限制） | ¥0 | 免费层 1k 写入/天足够 |
| 域名（pawpedigree.app） | ¥5 | ¥60/年摊月 |
| **合计** | **~¥755/月** | |

### 2.5 合规适配

| 项 | 处理方式 |
|---|---|
| App 备案 | 上架前完成（必须） |
| **网信办算法备案** | App 自己提交备案，但可在材料中**引用阿里通义千问的算法备案号**，简化材料 |
| ICP 备案 | ✅ 豁免（后端部署在海外 Cloudflare） |
| 个保法合规 | 隐私政策明示"照片传输至阿里云通义千问识别后销毁" |
| 苹果审核数据披露 | App Store 数据采集表填写"照片：仅用于本次鉴定" |

### 2.6 实现工期

复用 SPEC §6 的 Phase 1-5 → **总 28 天，含 1 周缓冲**：

| Phase | 工作 | 天 |
|---|---|---|
| 1 | 脚手架 + Theme + 数据模型 | 3 |
| 2 | 3 类挂牌卡 + 表单 + 拍照流程 | 9 |
| 3 | **Cloudflare Worker + 通义 API 集成** | 6 |
| 4 | 历史本 + 分享 + 二维码合成 | 4 |
| 5 | 兜底文案库 + 上架素材 + 算法备案 | 6 |

### 2.7 优势

- **成本最低**：月 ¥755，个人开发者完全可承担
- **合规最省心**：通义已备案，自己只需引用 + 自报，比 Gemini 路线省 1-2 个月
- **ICP 免备案**：Cloudflare 海外部署
- **国产模型中文文案天然合适**：阿里训练数据中文优势
- **0 第三方 iOS SDK**：完全符合 SPEC §5.4 "0 第三方依赖"原则

### 2.8 劣势

- **Cloudflare 大陆访问偶尔抖动**：晚高峰可能 1-2 秒延迟，但有兜底逻辑，体验不受致命影响
- **Worker → 阿里 API 出海回国延迟**：约 200-400ms，但鉴定本身 1-2s，整体仍 < 5s
- **通义文案能力略弱于 GPT-4o**：但已经够"反差感"，且可后续替换

### 2.9 风险与对策

| 风险 | 概率 | 对策 |
|---|---|---|
| Cloudflare 大陆访问被阻断 | 低 | 准备 Vercel 备份部署（10 分钟切换） |
| 通义涨价/限流 | 中 | 设计抽象 `AIProvider` 接口，可热切换至智谱/豆包 |
| 算法备案被驳回 | 低 | 引用通义备案号 + 备齐 SPEC.md 与文案规则文档 |

---

## 3. 方案乙：合规稳定党 · 智谱 + 阿里云函数

> **定位**：国内访问最快最稳，合规走传统路线（ICP 备案），适合后续要做大规模运营或冲付费榜的场景。

### 3.1 核心差异（相对甲方案）

| 项 | 方案乙 |
|---|---|
| 大模型 | 智谱 GLM-4V Plus（¥0.05/千 input + ¥0.10/千 output） |
| 后端 | 阿里云函数计算 FC 3.0（国内华东） |
| 入口 | api.pawpedigree.app（CDN 在国内） |
| ICP | ❌ 必须备案（5-20 工作日） |
| 客户端架构 | 加 `Repository` 层（隔离数据来源） |

### 3.2 技术栈差异

```
iOS App → 阿里云 CDN → 阿里云函数计算 FC → 智谱 GLM-4V Plus
                                          ↑ 同区域内网调用，<50ms
```

### 3.3 客户端架构（多一层 Repository）

```swift
protocol CertificationRepository {
    func certify(type: CertificateType, image: UIImage,
                 petCategory: PetCategory) async throws -> AIResultPayload
}

final class RemoteCertificationRepository: CertificationRepository {
    let network: NetworkService
    func certify(...) async throws -> AIResultPayload {
        let response = try await network.certify(...)
        return AIResultPayload(from: response)
    }
}

// 测试时可注入 MockRepository
final class MockCertificationRepository: CertificationRepository {
    func certify(...) async throws -> AIResultPayload {
        try await Task.sleep(for: .seconds(1.5))
        return AIResultPayload.sample(type: type)
    }
}
```

### 3.4 月度成本

| 项 | 月度 | 备注 |
|---|---|---|
| 智谱 GLM-4V Plus | ¥1500 | 5000 用户 × 3 次 × ¥0.10 |
| 阿里云函数计算 FC | ¥30 | 免费额度外少量费用 |
| 阿里云 CDN | ¥20 | 流量 < 50GB |
| 域名 + SSL | ¥10 | |
| **合计** | **~¥1560/月** | |

### 3.5 优劣

| 优势 | 劣势 |
|---|---|
| 国内访问极稳定（同 IDC） | 成本是甲方案 2 倍 |
| 备案合规最规范 | ICP 备案排期影响上架时间（+2-3 周） |
| 智谱文案能力比通义略强 | 阿里云函数计算计费复杂 |
| 后续扩展容量易（直接升级 FC 规格） | 客户端代码量比甲方案多 ~15% |

### 3.6 适用场景

- 已有 ICP 备案主体（企业/工作室）
- 上架时间可以延后 2-3 周
- 月预算 ¥1500 内能接受

---

## 4. 方案丙：品质优先党 · Gemini + Vercel

> **定位**：用海外最强多模态模型获得最高质量文案，赌"反差感更强 = 小红书更易爆"。

### 4.1 核心差异

| 项 | 方案丙 |
|---|---|
| 大模型 | Gemini 2.5 Flash（$0.075/M input + $0.30/M output）≈ ¥0.08/次 |
| 后端 | Vercel Edge Functions（海外） |
| ICP | ✅ 豁免 |
| 算法备案 | ⚠️ **必须自己提交完整材料**（用海外模型不能引用国内备案号） |
| 客户端架构 | 加 `Service` 抽象层（为未来多供应商铺路） |

### 4.2 月度成本

| 项 | 月度 |
|---|---|
| Gemini 2.5 Flash | ¥1200 |
| Vercel Edge Functions | ¥0（免费层 100k/月） |
| 域名 + SSL | ¥10 |
| **合计** | **~¥1210/月** |

### 4.3 优劣

| 优势 | 劣势 |
|---|---|
| 文案反差感最强（Gemini 视觉理解 + 创意能力顶级） | **算法备案要自己写材料 + 解释海外模型合规**，难度大 |
| Vercel Edge Functions 启动快 | 国内访问 Vercel 抖动比 Cloudflare 严重 |
| Google API 文档完善 | 国内用户付费意愿低时，¥1200 月成本利润率压力大 |
| 已有 Google 账号生态可复用 | Gemini 中文文案"反差感"未实测，可能不如国产细腻 |

### 4.4 适用场景

- 目标用户海外（北美/日本）为主
- 文案质量是核心卖点
- 不在意上架时间（可花 3 个月跑算法备案）

### 4.5 不推荐理由（针对你的项目）

1. SPEC §2.1 锁定中国大陆 70% 女性用户，海外模型访问劣势明显
2. **算法备案是最大坑**：用海外模型，备案材料里要解释"为什么不用国产"，审核员可能反复打回
3. 成本是甲方案 1.6 倍，但文案能力的边际收益对"娱乐型"产品很弱
4. SPEC §9 营销主战场是小红书，国产模型生成的中文文案对小红书用户更"地气"

---

## 5. 状态管理架构对比（3 方案的客户端层次差异）

| 层级 | 方案甲 | 方案乙 | 方案丙 |
|---|---|---|---|
| View | SwiftUI View | SwiftUI View | SwiftUI View |
| ViewModel | `@Observable` Class | `@Observable` Class | `@Observable` Class |
| Repository | — | `protocol CertificationRepository` | `protocol CertificationRepository` |
| Service | `NetworkService` 直接调 | `NetworkService` + 注入 | `NetworkService` + `AIProvider` 抽象 |
| Mock 能力 | 中 | 强 | 强 |
| 代码量（V1） | ~3000 行 | ~3500 行 | ~3800 行 |

**结论**：方案甲架构最薄，适合个人开发者 4-5 周窗口。方案乙/丙的抽象层在 V1 阶段是过度设计——V1 只有 1 个数据源、1 套 API，不需要 Repository/Service 抽象。**V1.5 加付费/多模型时再做架构升级**才是务实做法。

---

## 6. 我的推荐 → 方案甲 🥇

### 6.1 理由（按重要性排序）

1. **合规最快**：通义已备案，2-3 周内能搞定 App 备案 + 算法备案；方案乙要 +2-3 周 ICP 备案，方案丙要 +1-3 个月算法备案
2. **成本最低**：月 ¥755 vs ¥1560 vs ¥1210；V1 免费阶段是开发者自己掏钱，每省一半都关键
3. **中文文案天然合适**：通义中文优势 + "村霸气质 + 御猫风骨"这类反差文案，中文模型比 Gemini 更地气
4. **架构最薄**：复用 SPEC §6 任务拆解，无需引入 Repository/Service 抽象层
5. **Cloudflare 海外避 ICP**：个人主体备案困难，绕开是最务实选择
6. **可升级路径清晰**：抽象 `AIProvider` 接口预留，V1.5 可热切换至 GPT-4o 做 Pro 版

### 6.2 备选触发条件

- 如果你的目标用户海外为主 → 方案丙
- 如果你有公司主体 + 可接受 +2-3 周备案 → 方案乙
- 否则一律选方案甲

---

## 7. 选定方案甲后，写入 SPEC.md 的"技术约束"补充

```markdown
### 5.x 选定的技术栈（来自人工检查点 ②）

- 大模型：阿里云 通义千问 VL-Max（qwen-vl-max）
- 后端：Cloudflare Workers（pawpedigree-api.workers.dev）
- 客户端架构：SwiftUI View + @Observable ViewModel + NetworkService（不引入 Repository/Service 抽象层）
- 网络：URLSession + async/await，超时 8s，失败走兜底
- 数据：SwiftData（@Model 单例 PetProfile + CertificateRecord）
- 设计：方案 C 奶油绒感（详见 DESIGN_PROPOSALS.md §3）

### 5.x 成本上限

- 单次 < ¥0.10（实际 ~¥0.05）
- 月度上限 ¥1500（实际预计 ~¥755 @ 5000 MAU）

### 5.x 合规路径

- 网信办算法备案：引用通义千问备案号，材料附 SPEC.md + Prompt 规则
- ICP 备案：免（后端在 Cloudflare 海外）
- App 备案：上架前完成
```

---

## 8. 待你决策

请选择：

- 🥇 **方案甲 · 性价比党**（通义 + Cloudflare）— 推荐
- 🥈 **方案乙 · 合规稳定党**（智谱 + 阿里云）
- 🥉 **方案丙 · 品质优先党**（Gemini + Vercel）
- 🔀 **混合**：告诉我你想换哪一项（比如"甲方案但换成豆包视觉"）
- ❌ **都不满意**：告诉我哪里没击中，我重做对比

确认后我会：
1. 把选定方案写入 SPEC.md 的"技术约束"章节（v1.2）
2. 进入 **Phase 1 编码实现**：开新 Session 跑脚手架 + Theme + 数据模型
