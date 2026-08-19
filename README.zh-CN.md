# Sparkloom

*Weave ideas into action.*

[English](README.md)

Sparkloom 是一个跨工具的轻量 AI 工作流灵感工作台。你只需自然描述一个想法，它会先和已有灵感对比，再记录现有方案中最值得复用的部分，并给出一个最小下一步。

它以本地 Markdown 项目运行，适用于 Codex、Claude Code 和 Cursor，不需要应用服务器、账号、数据库或固定命令。

## 每条灵感会得到什么

每条新灵感只生成一张简短卡片，记录：

- 一句话想法；
- 与已有灵感的关系；
- 需要检索时最相关的 1–3 个外部参考；
- 值得复用的 Skill、Agent、MCP、Prompt、脚本、数据或设计模式；
- 一个结果可观察的最小下一步。

现有完整报告继续作为历史资料保留，但新灵感不再要求生成长篇研究报告。

## 快速开始

用支持的 AI 编程工具打开这个文件夹，然后自然说出灵感，例如：

```text
我想把团队里反复出现的 Slack 问题整理成可复用的 Codex Skill。
```

也可以要求工具把新想法和已有内容对比：

```text
把这个想法和已有灵感卡片对比一下，告诉我能复用什么。
```

工作流会先检查[灵感目录](ideas/INDEX.md)，读取相关卡片或历史报告，必要时寻找少量高度相关的外部参考，再用当前交流语言把一张卡片保存到 `ideas/`。

## 支持的工具

| 工具 | 灵感隔离方式 |
|---|---|
| Codex | 当前环境支持创建任务时使用独立任务；不支持时在当前任务中生成独立卡片。 |
| Claude Code | 环境支持时使用独立任务或新会话；否则通过独立卡片文件隔离灵感。 |
| Cursor | 默认在当前聊天工作，每条灵感使用独立卡片文件隔离。 |

适配器不会假设平台具备实际不存在的能力。创建任务或会话失败时，会留在当前会话继续，避免灵感丢失。

## 如何判断相似

相似度主要依据目标用户、核心问题、使用场景、工作流程和最终产出。仅有相同关键词、模型、框架或技术栈并不足以构成高度相似。

外部检索前，Agent 会先检查当前索引和相关文件，并将关系记录为重复、变体、互补、依赖或无明显关联。

## 文件说明

- `instructions/core-workflow.md`：所有平台共同使用的规范性核心规则。
- `instructions/core-workflow.zh-CN.md`：完整中文对照。
- `AGENTS.md`：Codex 适配器。
- `CLAUDE.md`：Claude Code 适配器。
- `.cursor/rules/inspiration-workflow.mdc`：Cursor 适配器。
- `templates/inspiration-card.en.md`：英文卡片模板。
- `templates/inspiration-card.zh-CN.md`：中文卡片模板。
- `ideas/INDEX.md`：卡片与历史报告共用的单一双语目录。
- `scripts/validate-workspace.ps1`：无额外依赖的结构校验脚本。

## 它不是什么

- 不是创业评分工具或自动商业计划报告；
- 不是通用笔记或知识库应用；
- 不要求固定长度的深度研究；
- 除非用户明确要求，否则不会实现灵感、发布内容或联系第三方。

## 隐私与维护

长期数据只使用本地 Markdown，可以直接使用 Git 管理或迁移，不绑定专有数据库。外部检索、模型请求、隐私边界和工具可用性取决于你选择的 AI 产品与配置。复用外部项目之前，应检查链接、许可证和敏感数据。

## 校验工作区

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

校验成功时会输出 `Workspace validation passed.`。
