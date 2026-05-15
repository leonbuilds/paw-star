# CLAUDE.md — PawStar 多 Agent 协作规范

> 本文档定义本项目使用 Claude Code Agent View（`claude agents`）进行并行开发的规则和最佳实践。
> 版本：v1.0 · 2026-05-15

---

## 1. 为什么 PawStar 需要多 Agent 并行

PawStar 是 iOS 单文件 App（SwiftUI），开发周期极短（2-3 周），且证件模板（身份证/驾驶证/毕业证）天然**互相独立**——这恰好是并行 Session 的最佳场景。

多 Agent 并行不是"多个 AI 聊天窗口"，而是把任务拆成独立的线程，让 AI 在隔离的 worktree 中工作，你只在验收节点介入。

---

## 2. 启动方式

```bash
# 进入项目目录后启动 Agent View
claude agents

# 只看当前项目的会话（如果开了多个项目）
claude agents --cwd /Users/a58/Documents/personal/ai-coding/paw-star
```

每个输入（按 Enter）启动一个**独立 Session**，不是追加到现有对话。

---

## 3. PawStar 的并行任务模型

### 3.1 可并行的任务（互相独立）

PawStar 的代码结构天然适合按 **Feature 目录** 拆分。以下任务可以并行派发：

| 任务编号 | 任务描述 | 目标文件 | 依赖 |
|---------|---------|---------|------|
| A | 开发「身份证」证件模板 | `Features/Cards/IDCardView.swift` | 无 |
| B | 开发「驾驶证」证件模板 | `Features/Cards/DrivingLicenseView.swift` | 无 |
| C | 开发「毕业证」证件模板 | `Features/Cards/GraduationCardView.swift` | 无 |
| D | 开发「历史证件本」UI | `Features/History/HistoryView.swift` | 需要数据模型 |
| E | 开发文案生成器 | `Utilities/CopyGenerator.swift` | 无 |
| F | 开发照片选择 + 裁剪流程 | `Features/Create/PhotoPickerView.swift` | 无 |
| G | 开发首页「办证大厅」 | `Features/Home/HomeView.swift` | 无 |

**原则**：只要两个任务不修改同一组核心文件，就可以并行。

### 3.2 不可并行的任务（有依赖或冲突）

以下任务**必须串行**，因为会修改同一份核心代码：

- **数据模型定义**（`PetProfile.swift`, `Certificate.swift`）→ 必须先定好，再并行开发模板
- **主题/颜色系统**（`Theme.swift`）→ 全局生效，统一由一人（你）定稿
- **SwiftData Schema 变更** → 影响所有用到 `@Model` 的视图
- **App 入口（`PawStarApp.swift`）** → 各 Feature 的注册都在这里

---

## 4. 实操流程（按阶段）

### Phase 1：串行定骨架（Day 1）

先开一个 Session 完成全局基础设施，这是后续所有并行的前提：

```
Task: 搭建 PawStar 项目脚手架
- 创建 Xcode 项目
- 定义数据模型：PetProfile, Certificate, CertificateRecord
- 定义主题系统（颜色、字体常量）
- 创建目录结构
- 提交到 git（主干）
```

**产出**：干净的主干代码 + git commit。这是所有人的地基。

### Phase 2：多 Agent 并行开发（Day 2-8）

进入 `claude agents`，派发以下 3-4 个并行 Session：

```
Session 1: 实现身份证证件模板（IDCardView）
- 仿照中国二代身份证布局，但颜色和版式有差异
- 字段：姓名、性别、民族（橘猫族等）、出生、住址、证件号
- 右上角加"仅供娱乐"标识
- 底部加"made with PawStar"水印
- 使用 Theme 中的颜色和字体常量

Session 2: 实现驾驶证证件模板（DrivingLicenseView）
- 仿照 C 类驾照
- 字段：姓名、性别、国籍（喵星/汪星）、准驾车型（纸箱/主人腿等）
- 同样需要娱乐标识和水印

Session 3: 实现首页办证大厅（HomeView）
- 卡片式展示 3 种证件入口
- 使用 Theme 颜色和 SF Pro Display 字体
- Playful Luxury 风格

Session 4: 实现照片选择 + 裁剪流程
- 使用 PhotosPicker 选择照片
- 方形裁剪（模拟证件照）
- 引导到表单页
```

每个 Session 在自己的 worktree 中工作，不会互相干扰。

### Phase 3：串行集成（Day 9）

所有 Session 完成后，你负责：

1. 逐个 review 每个 worktree 的 diff
2. 把代码 cherry-pick / merge 到主干
3. 解决任何命名或接口不一致的问题
4. 跑一次完整流程：选照片 → 填信息 → 生成证件 → 保存

### Phase 4：再一轮并行优化（Day 10-12）

集成完成后，可以再并行：

```
Session 5: 实现历史证件本 + SwiftData 持久化
Session 6: 实现 ImageRenderer 导出 + ShareLink 分享
Session 7: 实现梗文案随机生成器
Session 8: 实现毕业证件模板（如果有余力）
```

---

## 5. 任务描述模板

给 Agent 派活时，使用以下格式，确保上下文完整：

```
项目：PawStar，一个 iOS SwiftUI 萌宠证件生成 App。
技术栈：Swift 5.10+, SwiftUI, SwiftData, iOS 17+, 无第三方依赖。
主题文件：`PawStar/Utilities/Theme.swift`（颜色/字体常量）
数据模型：`PawStar/Models/PetProfile.swift`

任务：开发 [具体功能]

要求：
1. [功能要求 1]
2. [功能要求 2]
3. 使用 Theme 中定义的颜色，不要硬编码
4. 遵循 Playful Luxury 设计风格（俏皮 + 庄重）
5. 每张证件必须有"仅供娱乐"标识（苹果审核要求）
6. 完成后用 git diff 展示改动

注意：不要修改 Models/ 下的数据模型定义。
```

---

## 6. 验收标准

每个 Session 完成后，你检查以下清单：

- [ ] 代码是否使用了 Theme 常量（而非硬编码颜色/字体）
- [ ] 是否有"仅供娱乐"标识
- [ ] 是否引入了新依赖（V1 禁止第三方依赖）
- [ ] 是否修改了不该改的模型文件
- [ ] 预览（Canvas）是否正常渲染
- [ ] 是否遵循 Playful Luxury 设计风格

**不检查**（AI 的无效劳动）：
- [ ] 语法细节（AI 通常不会错）
- [ ] 代码格式（用 Xcode 自动格式化即可）

---

## 7. 避坑指南

### 7.1 不要同时改同一批文件

错误示范：
- Session A 和 Session B 同时改 `PetProfile.swift`
- 结果：merge 时冲突，两个 worktree 都白跑

正确做法：先串行定好模型，再并行开发视图。

### 7.2 worktree 隔离 ≠ 逻辑隔离

两个 Session 可能各自实现了不同的数据流方式：
- Session A 用 `@State` + `@Binding`
- Session B 用 `@Environment` + ViewModel

合并后会出现两种风格并存。**在 Phase 1 就定好状态管理方案**，所有 Agent 必须遵守。

### 7.3 删除 Session 前保存代码

后台 Session 使用 `.claude/worktrees/` 做隔离。**删除 Session 会清理 worktree**。如果里面有你要保留的改动，必须先 merge 或手动复制。

### 7.4 并行 Session 消耗更多额度

10 个并行 Session ≈ 10 倍额度消耗。PawStar 开发建议**最多同时开 3-4 个**，优先处理高价值任务（证件模板 > 历史本）。

### 7.5 电脑休眠 = Session 暂停

Agent View 的后台 Session 在本地运行。如果你合上 MacBook 盖子，Session 会停止。不要指望关机后 AI 还在跑。

---

## 8. 参考：PROJECT_BRIEF.md

更详细的产品需求、设计规范、开发顺序，见同目录下的 `PROJECT_BRIEF.md`。给 Agent 派活前，建议把相关章节复制进任务描述里作为上下文。

---

## 9. 快速启动命令参考

```bash
# 1. 进项目目录
cd /Users/a58/Documents/personal/ai-coding/paw-star

# 2. 启动 Agent View
claude agents

# 3. 在底部输入任务，按 Enter 启动新 Session
# （每次 Enter = 新 Session，追加到同一个输入框 = 同一个 Session）

# 4. 按 Space 查看 Session 输出（peek panel）
# 5. 需要回复时直接在 peek panel 里输入
```

---

*本文档应在开发过程中持续更新。每次使用 Agent View 后如有新经验，追加到第 7 节避坑指南中。*
