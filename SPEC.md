# PawPedigree · 萌宠品相鉴定馆 — V1 规格文档

> 本文档是 PawStar 项目经过需求发现后的**重新定位版**，是后续技术设计与编码实现的唯一权威输入。
>
> 与 `PROJECT_BRIEF.md` 的关系：PROJECT_BRIEF 是项目最初的产品蓝图，SPEC.md 是经过用户调研、方向调整后**当前生效**的需求规格。两份文档冲突时以 **SPEC.md 为准**。
>
> 版本：v1.2 · 2026-05-16

---

## 1. 目标与范围

### 1.1 一句话定义

**PawPedigree（萌宠品相鉴定馆）** 是一款 iOS 工具型应用：用户上传猫/狗照片 → 后端调用 AI 大模型识别品种 + 按规则评出血统/颜值/性格三类鉴定结果 → 生成证件式"鉴定挂牌卡" → 保存/分享，可选附主人微信二维码作为"配种联系名片"。

**产品本质**：单点工具型 App，不做社区、不做撮合、不做账户体系。永久维持"个人作品 / 小成本运营"形态。

### 1.2 与原 PROJECT_BRIEF 的关键差异

| 维度 | 原 PROJECT_BRIEF | SPEC.md V1（本文档） |
|------|-----------------|---------------------|
| 核心动作 | 用户填表 → 生成娱乐证件 | 拍照 → AI 评估 → 生成鉴定结果 |
| 证件类型 | 身份证 / 驾驶证 / 毕业证 | 血统鉴定书 / 颜值鉴定书 / 性格画像证 |
| 内容来源 | 用户脑补 + 随机文案 | AI 大模型按规则识别 + 个性化点评 |
| 网络依赖 | 完全本地 | **需联网**（大模型 API） |
| 后端 | 无 | **最小后端**（API Key 代理转发层，不存数据） |
| 配种维度 | 无 | 通过"挂牌卡 + 微信二维码"生成可分享名片，用户自己发到小红书/朋友圈/配种群。**App 不做撮合、不做社区** |
| 预计开发周期 | 2-3 周 | **4-5 周** |

### 1.3 V1 不做清单（永久或暂缓）

| 项 | 范畴 |
|---|---|
| 用户登录、注册、账户系统 | **永久不做** |
| 配种社区、撮合、聊天、定位、IM | **永久不做**（经成本/复杂度评估后排除） |
| 服务器端用户数据存储 | **永久不做**（后端仅 API 转发，不持久化任何用户数据） |
| 多宠物档案 UI | V1 暂缓（Schema 预留多宠物字段，UI 限 1 只，V1.5 解锁） |
| 内购订阅、Pro 版 | V1 暂缓（V1.5 加） |
| AI 抠图、滤镜、贴纸合成 | V1 暂缓 |
| 多语言 | V1 暂缓（V1 仅中文） |
| 实体卡邮寄、电商 | V1 暂缓（V2 候选） |
| 分析 SDK / 埋点 | V1 暂缓 |
| Apple Watch / Widget | V1 暂缓 |

### 1.4 V1.5+ 路线图（不在 V1 范围，仅作上下文）

> **本项目永久不做社区方向**。V1.5+ 的扩展全部在"工具型 App"轨道内。

- **V1.5**：内购 Pro 版（高清证书、去水印、自定义模板、多宠物切换）
- **V1.5**：更多鉴定类型（吃货证 / 穿搭达人证 / 萌宠星座等）
- **V2**：实体卡邮寄 + 小红书电商对接
- **V2**：出海英文版（北美/日本宠物市场）

---

## 2. 目标用户

### 2.1 核心画像

- 18-35 岁，70%+ 女性
- 重度小红书用户，习惯晒宠物
- 有猫或狗（V1 不覆盖其他宠物种类）
- 子群体诉求：部分用户希望为宠物寻找配种对象，PawPedigree 提供"挂牌卡 + 微信二维码"导出能力作为他们的传播素材；**App 本身不撮合**

### 2.2 用户痛点 → V1 解法对照

| 场景 | 痛点 | PawPedigree V1 如何解 |
|------|------|---------------------|
| 晒宠物 | 朋友圈晒了几年缺新玩法 | 鉴定挂牌卡 = 全新视觉化呈现 |
| 仪式感 | 想表达"我家小宝贝很特别" | "SSR 级品相""稀有血统"等结果给予仪式感 |
| 社交货币 | 想在小红书引发讨论 | AI 个性化点评天然带反差/惊喜，易引发评论 |
| 配种素材 | 想宣传自家宠物找配种对象但缺呈现形式 | 挂牌卡 + 微信二维码 = 可发布到任何平台的"宠物名片"（**配种行为发生在 App 外**） |

### 2.3 非目标用户

- ❌ 需要专业血统鉴定的繁育者（我们是娱乐用途，不出具官方文件）
- ❌ 需要宠物医疗记录的用户
- ❌ 希望出境带宠物的用户
- ❌ 希望通过 App 内匹配/聊天找配种对象的用户（**我们不做社区，建议引导至其他平台**）

---

## 3. 核心闭环与验收场景

### 3.1 核心闭环

```
首页（鉴定馆）→ 选择鉴定类型 → 拍照/相册选择 → 填写宠物档案 →
等待 AI 鉴定（2-3 秒）→ 生成鉴定挂牌卡 → 保存/分享 → 历史本可重新查看
```

### 3.2 验收场景（EARS 语法）

**场景 1：首次血统鉴定（核心闭环）**

> While 用户首次进入 App，the 系统 shall 在首页展示 3 类鉴定入口（血统/颜值/性格）。
> When 用户点击"血统鉴定" → 调用 PhotosPicker 选照片 → 系统 shall 提示用户方形裁剪 → When 用户输入宠物名字、品类（猫/狗）、生日（选填） → the 系统 shall 调用后端 API 进行品种识别与品相评分，within 5 秒内返回结果；如失败 shall 进入兜底流程（场景 6）。
> When AI 返回成功，the 系统 shall 生成一张"血统挂牌卡"，包含：品种名（如"中华田园猫"）、血统等级（SSR/SR/R/N）、毛色描述、个性化血统点评（30-80 字）、"仅供娱乐"标识、PawPedigree 水印。
> When 用户点击"保存到相册" → the 系统 shall 将挂牌卡渲染为 PNG（1080×1920 或类证件尺寸）并写入相册。
> When 用户点击"分享" → the 系统 shall 调起 ShareLink 原生分享面板。

**场景 2：颜值鉴定**

> When 用户在首页点击"颜值鉴定" → 流程同场景 1，但 AI 输出维度为：颜值评分（S+/S/A/B/C）、同品种均值对比（如"颜值超越 87% 的橘猫"）、面部特征点评（眉眼/对称/圆度等）、个性化文案。
> the 系统 shall 生成"颜值鉴定书"挂牌卡。

**场景 3：性格画像**

> When 用户点击"性格画像证" → 流程同上，AI 输出维度为：性格关键词 3-5 个（如"小恶魔""粘人精"）、性格故事化描述（50-100 字）、星座式标签。
> the 系统 shall 生成"性格画像证"挂牌卡。

**场景 4：导出"配种名片"（纯客户端图像合成，无任何后端/撮合）**

> When 用户在挂牌卡预览页点击"为配种制作名片" → the 系统 shall 引导用户从相册上传微信二维码图片 → 系统 shall 将二维码合成到挂牌卡右下角"配种联系"区域 → 重新渲染挂牌卡。
> 默认未点击该按钮时，挂牌卡 **不显示**联系方式。
> **明确说明**：App 仅完成"图像合成"，二维码本地处理、不上传服务器、不撮合；用户拿到合成后的图自己去小红书/朋友圈/配种群发布。

**场景 5：回访 / 历史本**

> When 用户再次打开 App 且本地有历史鉴定记录 → the 系统 shall 在底部 Tab 显示"我的鉴定本" → 列表式展示所有历史挂牌卡缩略图 → 点击可全屏查看 + 重新分享或导出。
> the 系统 shall 通过 SwiftData 持久化 PetProfile 和 CertificateRecord。

**场景 6：识别失败兜底**

> When AI 调用超时 / 返回低置信度 / 网络异常 → the 系统 shall **不向用户显示"识别失败"**，而是生成"娱乐型兜底结果"：
>   - 血统鉴定 → 输出"神秘血统 · 稀有混血"，等级 SSR
>   - 颜值鉴定 → 输出"独一无二的可爱"，等级 S+
>   - 性格画像 → 输出"未解之谜 · 薛定谔的喵汪"
> the 系统 shall 在挂牌卡角落以极小字号标注"娱乐结果"，避免引导用户重复请求消耗 API 配额。

**场景 7：宠物档案管理**

> While V1，the 系统 shall 仅维护 1 个宠物档案（包括名字、品类、生日、头像照、可选微信二维码图）。
> When 用户首次使用 → 引导建档；后续鉴定自动复用该档案。
> When 用户点击"更换宠物"（V1.5 才暴露入口） → 覆盖式替换当前档案。
> the 数据模型 shall 支持多宠物字段结构，仅 UI 限制为 1 只。

**场景 8：隐私 first**

> the 系统 shall **不**默认上传或要求微信二维码。
> When 用户主动点击"为配种制作名片"时，shall 弹窗告知："上传的二维码仅本地保存与渲染，不会上传到任何服务器"。
> the 系统 shall 在隐私政策中明确："上传的宠物照片会传输至 [大模型供应商] 用于品相识别，识别后即销毁，不留存"。
> the 系统 shall 在 App Store 提交时按"数据采集"披露：照片（仅用于本次鉴定，不留存）、可选位置（无）、识别码（无）。

---

## 4. 功能行为详述

### 4.1 首页（HomeView）

- 顶部：App 名称 + 副标题"给家里的小明星办张鉴定"
- 中央：3 个大卡片（血统鉴定 / 颜值鉴定 / 性格画像），每张卡片有图标 + 标题 + 一句话 hook
- 底部 Tab：[鉴定馆] [我的鉴定本]
- 设计风格：Playful Luxury（保留原 PROJECT_BRIEF §6 设计哲学）
- 颜色：使用 PROJECT_BRIEF §6.2 中已定义的 9 色系统

### 4.2 鉴定流程（CreateFlow）

1. **PhotoPickerView**：调用 PhotosPicker，仅支持单张选择，提示"建议正面照、光线明亮"
2. **PhotoCropView**：方形裁剪（1:1），SwiftUI ImageRenderer 实现
3. **PetFormView**（首次或档案不全时显示）：
   - 名字（必填，String，1-12 字）
   - 品类（必选枚举：猫 / 狗）
   - 生日（选填 Date，可跳过）
4. **AIInferenceView**：
   - 显示鉴定中动画（"正在加盖公章…🐾" 或品相鉴定专属动画）
   - 后台调用后端 API → 大模型 → 返回结构化 JSON
   - 超时阈值 8 秒，失败走场景 6 兜底
5. **CertificatePreviewView**：
   - 展示生成的挂牌卡
   - 按钮：[保存到相册] [分享] [为配种制作名片] [重新鉴定]

### 4.3 三类鉴定书的内容规格

#### 4.3.1 血统鉴定书

| 字段 | 来源 | 示例 |
|------|------|------|
| 品种名 | AI 识别 | "中华田园猫" / "金毛寻回犬" |
| 血统等级 | AI 按规则评分 | SSR / SR / R / N |
| 毛色描述 | AI 按规则提取 | "橘金色 · 饱和度 92%" |
| 血统点评 | AI 生成 | 30-80 字，反差/惊喜风格 |
| 鉴定编号 | 客户端生成 | 18 位伪号（含日期 + 随机） |
| "仅供娱乐"标识 | 固定 | 右上角小字 |
| 水印 | 固定 | 底部"PawPedigree · 萌宠品相鉴定馆" |

#### 4.3.2 颜值鉴定书

| 字段 | 来源 | 示例 |
|------|------|------|
| 颜值评分 | AI 按规则评分 | S+ / S / A / B / C |
| 同品种排位 | AI 生成（玄学） | "颜值超越 87% 的同款" |
| 面部特征点评 | AI 生成 | "圆脸+对称眼线，自带迪士尼脸滤镜" |
| 鉴定编号、标识、水印 | 同上 | |

#### 4.3.3 性格画像证

| 字段 | 来源 | 示例 |
|------|------|------|
| 性格关键词 | AI 生成 3-5 个 | "小恶魔 / 粘人精 / 嘴炮王 / 玻璃心" |
| 性格故事化描述 | AI 生成 | 50-100 字 |
| 星座式标签 | AI 生成 | "处女座猫 / 摩羯狗" 等 |
| 鉴定编号、标识、水印 | 同上 | |

### 4.4 历史本（HistoryView）

- 列表展示所有已鉴定的挂牌卡缩略图
- 按"鉴定时间倒序"排列
- 点击进入详情页：全屏挂牌卡 + [重新分享] [删除]
- V1 仅支持当前 1 只宠物的历史
- 空状态："还没鉴定过 给小明星办张证吧"

### 4.5 数据模型（SwiftData）

```swift
@Model
final class PetProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: PetCategory     // .cat | .dog
    var birthday: Date?
    var avatarImageData: Data?    // 本地存储宠物头像
    var wechatQRImageData: Data?  // 可选，主人微信二维码
    var createdAt: Date

    // V1 仅维护 1 个 PetProfile 实例，但模型已支持多只
    @Relationship(deleteRule: .cascade) var certificates: [CertificateRecord]
}

@Model
final class CertificateRecord {
    @Attribute(.unique) var id: UUID
    var type: CertificateType     // .pedigree | .beauty | .personality
    var serialNumber: String      // 18 位伪鉴定编号
    var aiResult: AIResultPayload // 结构化的 AI 返回，Codable
    var renderedImageData: Data?  // 生成的挂牌卡 PNG（可缓存可重新渲染）
    var includesWechatQR: Bool    // 该次输出是否带二维码
    var createdAt: Date

    var pet: PetProfile?
}

enum PetCategory: String, Codable { case cat, dog }
enum CertificateType: String, Codable { case pedigree, beauty, personality }

struct AIResultPayload: Codable {
    var primaryLabel: String          // 品种 / 颜值等级 / 性格主标签
    var grade: String                 // SSR / SR / S+ 等
    var attributes: [String: String]  // 各类属性
    var description: String           // 个性化点评
}
```

### 4.6 AI 鉴定 API 调用

V1 后端只承担**转发**职责：

```
[iOS App] --HTTPS--> [后端转发层 (Vercel/Cloudflare Worker)] --API Key--> [大模型供应商]
                              ↓
                       不存任何用户数据
                       不留照片
                       仅做 Key 保护 + Prompt 注入 + 速率限制
```

后端 endpoint 设计（草案，技术方案阶段细化）：

```
POST /api/v1/certify
Body: { type: "pedigree" | "beauty" | "personality",
        image: base64, petCategory: "cat" | "dog" }
Response: AIResultPayload (见 §4.5)
```

**Prompt 设计原则**（技术方案阶段详化）：
- 每类鉴定独立 Prompt，包含「评分规则 + 输出格式 + 反差感语气示例」
- 强制 JSON 输出
- 限制 description 字数（30-100 字）
- 显式禁止"识别失败"输出，低置信度时按场景 6 兜底（兜底逻辑可在 Prompt 层做，也可在客户端做）

### 4.7 大模型选型（暂定，技术方案阶段决定）

候选：
- **GPT-4o / GPT-4 Vision**：贵但稳，文案能力强
- **Gemini 1.5 Flash**：便宜，多模态能力够用
- **Claude 3.5 Sonnet**：贵，文案能力最强
- **国产视觉模型**：智谱 GLM-4V / 通义千问 VL / 豆包视觉 / 阶跃视觉（合规优势 + 价格友好，中国大陆区上架强烈推荐）

V1 推荐路径：先用 **国产视觉模型或 Gemini Flash** 降本，文案能力对比后选定。

---

## 5. 技术约束

### 5.1 平台与版本

- iOS 17.0+（启用 SwiftData 与 @Observable）
- Swift 5.10+
- SwiftUI 全 UI

### 5.2 设计与渲染

- 配色与字体沿用 PROJECT_BRIEF §6（仍是 Playful Luxury 风格）
- 挂牌卡渲染用 SwiftUI `ImageRenderer` 输出高清 PNG
- 分享用 `ShareLink`

### 5.3 网络

- 仅与自有后端通信，不直连大模型供应商
- HTTPS only，URLSession，超时 8 秒
- 失败走兜底（场景 6），不抛错给用户

### 5.4 后端

- V1 最小化：Cloudflare Worker 或 Vercel Function 单一端点 + API Key 代理 + 简单速率限制
- 不存数据库
- 不存照片（请求处理完毕即丢弃 base64）
- 日志只保留匿名调用计数（用于成本统计）

### 5.5 合规

| 项 | V1 要求 | 备注 |
|---|---|---|
| 苹果审核合规 | 每张挂牌卡显眼位置含"仅供娱乐 · NOT REAL"标识 | 防止被认定为模仿官方证件 |
| 隐私政策 | 明示照片传输到第三方大模型用于一次性识别（识别后即销毁） | App Store 数据采集表必须如实披露 |
| App 备案 | 上架前完成（2024 起工信部新规强制） | 免费但耗时 |
| **网信办算法备案** | **V1 必做**——使用 AI 大模型生成内容属"生成合成类算法" | 免费但流程繁琐，建议先备案再上架 |
| ICP 备案 | 后端服务部署在国内则需要；部署在海外（Cloudflare/Vercel）可豁免 | V1 倾向部署海外避免备案 |
| 商标 | 上架前完成 PawPedigree / 萌宠品相鉴定馆 中美商标查询 | 防止被抢注 |

### 5.6 性能预算

- 冷启动 < 1.5 秒（不用 Splash 屏）
- 鉴定流程总时长 < 10 秒（含网络）
- 挂牌卡渲染 < 1 秒

### 5.7 成本

- 单次鉴定 API 成本目标 **< ¥0.15**（实际 ~¥0.05）
- 月度估算：5000 用户 × 3 次 = 15000 次 × ¥0.05 ≈ **~¥755/月**（V1 预期，免费阶段开发者承担）
- 后端服务（Cloudflare Worker）：免费额度内
- 域名：¥60/年

### 5.8 选定的技术栈（来自 人工检查点 ② · 方案甲）

> 详见 [TECH_OPTIONS.md](TECH_OPTIONS.md) §2。本节是最终锁定的实现约束，后续编码不得偏离。

| 维度 | 选定 | 备注 |
|---|---|---|
| **视觉设计方案** | **方案 C 奶油绒感** | 详见 [DESIGN_PROPOSALS.md](DESIGN_PROPOSALS.md) §3 |
| **大模型** | 阿里云 **通义千问 VL-Max** (`qwen-vl-max`) | ¥0.02/千 input + ¥0.03/千 output |
| **后端部署** | **Cloudflare Workers**（海外，免 ICP） | 域名 `pawpedigree-api.workers.dev` 或自有域名 |
| **后端语言** | TypeScript（Cloudflare Workers 原生） | 单文件 `worker.ts` |
| **客户端架构** | View + `@Observable` ViewModel + `NetworkService` | **不引入 Repository/Service 抽象层**（V1 单数据源） |
| **网络层** | `URLSession` + `async/await` | 超时 8s，失败走兜底（SPEC §3.2 场景 6） |
| **图片处理** | 客户端压缩至长边 1024px，JPEG 0.85 质量，base64 上传 | 控制单次请求 < 500KB |
| **依赖管理** | Swift Package Manager | **V1 目标 0 第三方依赖** |
| **iOS 26 新 API 使用** | Liquid Glass (`.glassEffect`)、`@Observable`、SwiftData | 详见 DESIGN_PROPOSALS §0.1 |

### 5.9 成本与合规上限（绑定方案甲）

| 项 | 上限 / 路径 |
|---|---|
| 单次 AI 调用成本 | < ¥0.10（实际 ~¥0.05） |
| 月度总成本 | < ¥1500（实际预计 ~¥755 @ 5000 MAU） |
| **网信办算法备案** | 引用通义千问备案号 + 自报材料 |
| **App 备案** | 上架前完成 |
| **ICP 备案** | 免（后端在 Cloudflare 海外） |
| **隐私政策** | 明示"照片传输至阿里云通义千问识别后销毁，不留存" |

---

## 6. 任务拆解（按依赖排序）

> 每个任务的具体技术实现留到技术方案阶段。这里只列**WHAT**和**依赖关系**。
> 总周期 28 天（4 周），含 1 周缓冲到 5 周。

### Phase 1：脚手架（Day 1-3，**串行**）

- [ ] T1.1 创建 Xcode 项目，配置 Bundle ID、Capabilities、最低 iOS 17
- [ ] T1.2 建立目录结构（按 CLAUDE.md §5.2）
- [ ] T1.3 实现 Theme.swift（颜色/字体常量，从 PROJECT_BRIEF §6 移植）
- [ ] T1.4 定义数据模型 PetProfile / CertificateRecord / 枚举
- [ ] T1.5 跑通 SwiftData ModelContainer 注入
- [ ] T1.6 状态管理方案锁定：`@Observable` ViewModel + `@State` 局部状态（CLAUDE.md §7.2 要求）

### Phase 2：本地闭环（Day 4-12，**可并行 3 个 Agent**）

可并行：
- [ ] T2.1 HomeView 首页 + 3 类入口卡片
- [ ] T2.2 PhotoPickerView + PhotoCropView 拍照裁剪
- [ ] T2.3 PetFormView 宠物档案表单

串行（依赖 Theme + 模型）：
- [ ] T2.4 PedigreeCardView 血统挂牌卡模板
- [ ] T2.5 BeautyCardView 颜值鉴定书模板
- [ ] T2.6 PersonalityCardView 性格画像证模板

### Phase 3：AI 后端 + 集成（Day 13-18，**串行**）

- [ ] T3.1 搭建 Cloudflare Worker / Vercel Function 转发层
- [ ] T3.2 编写三类 Prompt + mock 测试
- [ ] T3.3 iOS 端 NetworkService 封装 + AIResultPayload 解析
- [ ] T3.4 AIInferenceView 鉴定中动画 + 错误兜底
- [ ] T3.5 联调 3 类鉴定端到端

### Phase 4：历史本 + 分享（Day 19-22，**可并行 2 个 Agent**）

- [ ] T4.1 HistoryView 列表 + 详情
- [ ] T4.2 ImageRenderer 导出 PNG + ShareLink 集成
- [ ] T4.3 为配种制作名片：二维码图片选择 + 合成到挂牌卡

### Phase 5：打磨 + 上架（Day 23-28，**串行**）

- [ ] T5.1 兜底文案库（场景 6 用）
- [ ] T5.2 App 图标、启动屏、上架素材
- [ ] T5.3 隐私政策 + 服务条款页面
- [ ] T5.4 App Store 信息填写 + 数据采集披露
- [ ] T5.5 网信办算法备案 + App 备案（**与 T5.1-T5.4 并行启动**，提前 2-4 周走流程）
- [ ] T5.6 真机测试（至少 iPhone 13/15 各一台）
- [ ] T5.7 提审

---

## 7. 假设与待确认事项（技术方案阶段需厘清）

- [ ] **大模型供应商选型**（GPT-4o / Gemini Flash / 国产）→ 技术方案阶段
- [ ] **后端部署方式**（Cloudflare Worker / Vercel / 国内厂商）→ 技术方案阶段，涉及 ICP 决策
- [ ] **恶意上传过滤**：是否需要在 Prompt 层加入"非宠物照（人脸/裸照/违规图）→ 输出娱乐兜底结果"的护栏 → 技术方案阶段
- [ ] **挂牌卡视觉稿**：是否专门做 Figma 设计稿，还是直接 SwiftUI 手撸 → 用户决定

---

## 8. 变更记录

### v1.2 · 2026-05-16 技术方案锁定（人工检查点 ②）

- **视觉设计**：锁定方案 C 奶油绒感（详见 DESIGN_PROPOSALS.md §3）
- **大模型**：锁定阿里云通义千问 VL-Max（qwen-vl-max）
- **后端**：锁定 Cloudflare Workers 海外部署
- **客户端架构**：锁定 View + `@Observable` ViewModel + `NetworkService` 三层（不加 Repository/Service 抽象）
- 月度成本预估从 ¥1500 修正为 ~¥755
- 新增 §5.8 选定技术栈 + §5.9 成本与合规上限
- 配套交付：[WORKFLOW.md](WORKFLOW.md)（实现指南）、[KICKOFF.md](KICKOFF.md)（下一 Session 入口 Prompt）

### v1.1 · 2026-05-15 范围收敛

- **永久从 roadmap 移除"配种社区"方向**：经过成本测算（一次性 ¥1.25-3.7 万合规 + ¥2-3k/月运营 + 3-4 个月双边冷启动）后，与"个人作品/赚点零花"定位不匹配，永久排除
- V1.5+ 路线图重定为"工具型 App 扩展"轨道：Pro 版、更多鉴定类型、实体卡、出海
- 补充网信办算法备案要求（使用 AI 大模型生成内容触发，V1 就需要）
- 场景 4 明确："配种名片"仅是客户端图像合成功能，无任何后端/撮合含义
- Phase 5 加入算法备案任务，建议与上架素材并行启动

### v1.0 · 2026-05-15 初始版本

- 基于需求发现 + 方向调研 + 多轮用户对话产出
- 与 PROJECT_BRIEF.md 的关键转向：从"用户填表式娱乐证件"转向"AI 大模型识别 + 品相鉴定 + 配种名片"
- 锁定 V1 范围：3 类鉴定书 + 单宠物档案 + 历史本 + 挂牌卡分享 + 可选微信二维码
- 锁定不做清单：撮合 / 多宠物 UI / 内购 / 多语言（皆为 V1.5+ 候选）
