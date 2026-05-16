# 下一个 Claude Code Session 启动 Prompt

> 此文件是为 **下一个新的 Claude Code 会话**准备的入口 Prompt。
> 当前 Session（需求发现 + 技术决策）已完成。
> 复制下方 Prompt 到新 Session 即可开始编码 Phase 1。

---

## 启动方式

打开新的 Claude Code Session（建议用 `claude` 或 `claude --dangerously-skip-permissions` 视你的偏好），把下面整段复制为第一条消息：

---

## 📋 复制以下内容到新 Session

```
我是 PawPedigree 项目的开发者。前一个 Session 完成了需求发现 + 视觉设计 + 技术方案决策。
现在进入 Phase 1：脚手架 + Theme + 数据模型。

请你先按以下顺序阅读项目文档建立上下文（必读）：
1. SPEC.md（v1.2，需求规格，含 §5.8 已锁定的技术栈）
2. CLAUDE.md（多 Agent 并行规范，0 第三方依赖原则）
3. WORKFLOW.md §0（全局规范）+ §Phase 1（本次要做的）
4. DESIGN_PROPOSALS.md §3（方案 C 奶油绒感）
5. TECH_OPTIONS.md §2（方案甲 通义+Cloudflare 技术栈）

读完后，告诉我：
- 你理解的 Phase 1 任务清单（T1.1 - T1.6）
- 有没有任何歧义需要我先澄清
- 你打算先做哪一个，预计什么节奏

不要直接开始写代码，先等我确认你的理解再开始。

注意硬约束：
- 严格按 SPEC + WORKFLOW，不增删功能
- 0 第三方依赖（仅 Apple 官方包）
- 颜色字体绝不硬编码，全部走 Theme.*
- Liquid Glass 用统一的 .liquidGlass(...) 扩展（WORKFLOW 附录 C）
- 每个 Phase 提 Draft PR，等我 review 再合并
- 遇到 SPEC 歧义 → 记 CHANGELOG.md 跳过，不要猜
- 不要修改已有测试使其适配新代码
- 不要直接 push main，不要自己合并 PR

代码规范：
- branch: feat/p1-scaffold
- commit: feat(scope): subject
- 单 View 文件 < 250 行
- 文件头只写 1 行 // PawStar/<Module>/<File>.swift
- 注释只写"为什么"

准备好之后告诉我你的 Phase 1 任务理解。
```

---

## 后续 Phase 启动 Prompt 模板

每个 Phase 开始时用类似 Prompt（替换 Phase 号和文件路径）：

### Phase 2 启动

```
Phase 1 已 merge 到 main。现在进入 Phase 2：本地闭环。

请阅读 WORKFLOW.md §Phase 2，然后告诉我：
- 你打算并行还是串行做 T2.1 / T2.2 / T2.3
- T2.4-T2.6 的实施顺序
- 任何对 SPEC §3.2 场景 1-4 的疑问

注意：T2.4-T2.6 严格按 DESIGN_PROPOSALS.md §3.5 和 design-preview.html 还原。
```

### Phase 3 启动

```
Phase 2 已 merge。现在进入 Phase 3：AI 后端 + 集成。

请阅读 WORKFLOW.md §Phase 3 和 TECH_OPTIONS.md §2.3。

特别注意：
- Cloudflare Worker 是独立仓库（pawpedigree-api），不是当前 iOS 仓库
- 我会先准备好 Cloudflare 账号和阿里云 DashScope API Key，告诉我准备好了你再开始 T3.1
- Prompt 设计（T3.2）是产品/文案问题，先 draft 给我审，确认后再用
```

### Phase 4 启动

```
Phase 3 已联调通过。进入 Phase 4：历史本 + 分享。

WORKFLOW.md §Phase 4。T4.1 和 T4.2 可并行（不同 worktree），T4.3 串行。

注意 Info.plist 要加 NSPhotoLibraryAddUsageDescription，
但不要直接改 Info.plist 主文件，先告诉我，我自己加。
```

### Phase 5 启动

```
Phase 4 已 merge。进入 Phase 5：打磨 + 上架。

WORKFLOW.md §Phase 5。T5.5（备案）我会自己启动，你不用做。
但你需要给我备案材料的素材：
- Prompt 规则文档（从 worker.ts 提取）
- 数据流图（App → CF Worker → 通义千问）
- 隐私政策草稿
```

---

## 跨 Session 的 CHANGELOG.md 接力

每个 Session 结束时，让 Claude Code 追加到 CHANGELOG.md。下次开 Session 时让它先读 CHANGELOG.md 了解上文。

CHANGELOG.md 暂未创建，第一个 Phase 1 Session 完成时由 Claude Code 自动创建并按 WORKFLOW.md 附录 A 的模板写入。

---

## 检查点对齐

| 阶段 | 检查点 | 状态 |
|---|---|---|
| 需求发现 | ① 用户确认 SPEC.md | ✅ v1.2 通过 |
| 技术决策 | ② 用户选定技术方案 | ✅ 方案甲锁定 |
| 编码实现 | — | 🟡 待启动（Phase 1） |
| 测试审查 | ③ 用户判断测试是否充分 | ⏸ Phase 3 完成后 |
| Code Review | ④ 用户 Review PR + Merge | ⏸ 每个 Phase 完成后 |

---

## 紧急联系

如果新 Session 表现异常（比如想引入第三方依赖、想跳过 PR 直接 push、想猜测 SPEC 歧义）：
- 立刻打断它
- 让它读 WORKFLOW.md §0 角色边界
- 提醒它走 Draft PR 流程

如果出现"context 衰减"（响应变慢/质量下降）：
- 让它先把进度写入 CHANGELOG.md
- /compact 压缩上下文
- 或开新 Session（用上面 Phase X 启动 Prompt）
