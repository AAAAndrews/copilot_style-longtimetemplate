# Copilot/Cursor IDE Agent 长流程工作模板

这个仓库提供了一套可直接落地的、面向 IDE Agent 的长流程开发工作流。

整体设计借鉴了 long-running agent harness 的关键思想：
- 显式环境初始化
- 严格单会话单任务
- 机器可读的任务清单
- 会话之间可交接的进度记录
- 高频小步提交，便于回滚与追踪

本模板专为 GitHub Copilot Chat 与 Cursor Agent 模式适配，而不是 Claude Code CLI。

## 目标

- 让每次 Agent 会话都短小、可验证、可恢复。
- 避免跨上下文窗口留下半成品改动。
- 让新会话可以快速恢复项目上下文。

## 仓库结构

- `.github/copilot-instructions.md`: Copilot 专用执行说明。
- `.cursor/rules/agent-workflow.mdc`: Cursor 规则文件，与 AGENTS 契约保持一致。
- `AGENTS.md`: 面向任意 IDE Agent 的统一工作契约与检查清单。
- `docs/architecture.md`: 项目架构与约束模板。
- `docs/task-list.json`: 机器可读任务清单与完成状态。
- `docs/progress.md`: 会话交接日志（按时间追加）。
- `docs/phases.md`: 阶段总结（多模块项目适用）。
- `scripts/init-session.sh`: 会话启动检查脚本。
- `scripts/select-next-task.sh`: 按优先级建议下一个任务。

---

## 快速开始：从脚手架初始化新项目

### 1. 初始化项目（第一次）

```bash
# 方案 A：本地克隆改成自己的项目
git clone https://github.com/your-org/copilot_style-longtimetemplate.git my-quant-project
cd my-quant-project
git remote rename origin scaffold-template
git remote add origin https://github.com/your-org/my-quant-project.git
git branch -M main
git push -u origin main

# 方案 B：已有项目，引入脚手架
cd existing-project
git remote add scaffold-template https://github.com/your-org/copilot_style-longtimetemplate.git
git fetch scaffold-template main
git checkout scaffold-template/main -- \
  .github/copilot-instructions.md \
  .cursor/rules/agent-workflow.mdc \
  AGENTS.md \
  docs/architecture.md \
  docs/task-list.json \
  docs/progress.md \
  docs/phases.md \
  scripts/init-session.sh \
  scripts/select-next-task.sh
git add .
git commit -m "chore: init scaffold framework"
```

### 2. 定制脚手架（个性化）

编辑以下文件**适配你的项目**：

| 文件 | 修改内容 | 示例 |
|-----|--------|------|
| `docs/architecture.md` | 产品目标、技术栈、模块架构 | 因子挖掘系统、交易接口、数据管道 |
| `docs/task-list.json` | 第一个模块的任务列表 | T001-T004 定义因子模块的里程碑 |
| `docs/progress.md` | 删除 BOOTSTRAP 日志，新增自己的初始记录 | 记录第一次会话决策 |
| `docs/phases.md` | 描述多模块的进度追踪需求 | 因子 v1 → 交易 v1 → 集成 |
| `AGENTS.md` / `.github/copilot-instructions.md` | 可选：简化规则或添加域特定约束 | 例如：量化投研的验证标准 |

### 3. 开始第一轮开发

```bash
./scripts/init-session.sh
./scripts/select-next-task.sh

# 按输出选择最高优先级的待办任务，只做那一个
# 完成后：
#   1. 运行验证（测试、lint 等）
#   2. 更新 docs/task-list.json（该任务的 passes 字段）
#   3. 在 docs/progress.md 追加交接记录
#   4. 提交：git add . && git commit -m "feat(T001): your summary"
```

---

## 多模块迭代工作流（重点）

当你需要在同一个项目里**顺序构建多个模块**（如：因子挖掘 → 交易接口 → 风险控制），用下面的方式维护脚手架和代码分离：

### 阶段 1：模块 A 开发（如：因子挖掘）

```bash
# 基于初始脚手架定义 T001-T004（因子任务）
# 没有特殊的分支需求，直接在 main 开发

# 完成因子模块后
git add docs/progress.md  # 阶段总结
git commit -m "phase(factor-mining): module v1.0 completed"
```

编辑 `docs/phases.md`：
```markdown
## 阶段交接记录

### 阶段 1：因子挖掘（完成）
- 任务：T001-T004
- 输出：因子库、回测框架
- 下一步：交易接口需调用这些输出
```

### 阶段 2：模块 B 开发（如：交易接口）

```bash
# 1. 手工决定模块 B 的接口与职责（不涉及脚手架）

# 2. 决定是否需要新脚手架版本
#    如果新模块的验证标准/文件结构有改化，从上游拉：
git fetch scaffold-template main
git diff scaffold-template/main -- docs/architecture.md  # 看改动

# 3. 选择是否合并新脚手架文件
#    只拉你需要的：
git checkout scaffold-template/main -- \
  docs/architecture.md \
  docs/task-list.json
#    上面动作会更新 architecture.md，可能对因子部分有影响
#    手工审视冲突，确保因子部分不变

# 4. 手工编辑 docs/task-list.json，追加新任务
#    保留因子任务（T001-T004），新增交易任务（T101-T103）
```

编辑 `docs/task-list.json`：
```json
{
  "version": 2,
  "modules": {
    "factor-mining": {
      "tasks": [{"id": "T001", ...}, ...],
      "status": "completed",
      "version": "v1.0"
    },
    "trading-interface": {
      "tasks": [{"id": "T101", ...}, ...],
      "status": "in-progress",
      "version": "v1.0"
    }
  }
}
```

编辑 `docs/phases.md`：
```markdown
### 阶段 2：交易接口（进行中）
- 任务：T101-T103
- 依赖：因子库输出（阶段 1）
- 当前：开发中
```

```bash
# 5. 照脚手架流程开发这个模块
#    与阶段 1 完全相同的工作循环

git commit -m "feat(T101): trading interface foundation"
```

### 阶段 3：集成与全流程（可选）

```bash
# 1. 创建新任务：全流程端到端
#    T201: 因子 → 交易接口 → 完整回测可运行

# 2. 除此之外，脚手架不需要改动
#    继续用既有的 AGENTS.md 流程

git add docs/task-list.json docs/progress.md
git commit -m "feat(T201): end-to-end pipeline integration"
```

---

## 脚手架更新维护（可选）

如果脚手架上游有改进，可以这样同步**而不污染项目代码**：

```bash
# 1. 检查上游有什么改动
git fetch scaffold-template main
git log --oneline scaffold-template/main ^main | head -10

# 2. 看具体改了什么文件（只关注脚手架文件）
git diff main scaffold-template/main -- \
  AGENTS.md \
  .github/copilot-instructions.md \
  scripts/

# 3. 如果改动对你有用，选择性合并
#    仅更新你决定的文件，不触及业务代码：
git checkout scaffold-template/main -- AGENTS.md
git add AGENTS.md
git commit -m "chore: sync scaffold improvements"

# 4. 如果脚手架的 docs/architecture.md 改了，十分谨慎：
#    先看改动，再手工合并关键部分，避免覆盖业务架构：
git show scaffold-template/main:docs/architecture.md | head -50
# 然后手工 copy 你需要的模板部分到本地文件
```

---

## 零基础安全方案：把脚手架放到独立目录（推荐）

如果你担心脚手架文件混进业务代码，最稳妥的方法是把脚手架固定放在项目内的 `scaffold/` 目录。

这样做的好处：
- 业务代码在 `src/`、`tests/`，脚手架在 `scaffold/`，天然隔离。
- 以后拉取脚手架更新，只会影响 `scaffold/`，不会碰业务目录。
- 你可以继续用脚手架中的模板指导 Agent，但项目代码结构保持干净。

### 一次性初始化（已有项目）

```bash
# 0) 进入你的业务项目根目录
cd /path/to/your-project

# 1) 新建脚手架目录（专门放模板，不放业务代码）
mkdir -p scaffold

# 2) 添加模板仓库为远端（名字可自定义，这里用 scaffold-template）
git remote add scaffold-template https://github.com/your-org/copilot_style-longtimetemplate.git

# 3) 拉取模板仓库的 main 分支到本地（只下载，不修改你的文件）
git fetch scaffold-template main

# 4) 从远端分支读取指定文件，并写入 scaffold/ 下
#    说明：右侧路径是“写到你本地哪里”
git show scaffold-template/main:AGENTS.md > scaffold/AGENTS.md
git show scaffold-template/main:.github/copilot-instructions.md > scaffold/copilot-instructions.md
git show scaffold-template/main:.cursor/rules/agent-workflow.mdc > scaffold/agent-workflow.mdc
git show scaffold-template/main:docs/architecture.md > scaffold/architecture.template.md
git show scaffold-template/main:docs/task-list.json > scaffold/task-list.template.json
git show scaffold-template/main:docs/progress.md > scaffold/progress.template.md
git show scaffold-template/main:docs/phases.md > scaffold/phases.template.md
git show scaffold-template/main:scripts/init-session.sh > scaffold/init-session.sh
git show scaffold-template/main:scripts/select-next-task.sh > scaffold/select-next-task.sh

# 5) 给脚本执行权限（否则可能无法运行）
chmod +x scaffold/init-session.sh scaffold/select-next-task.sh

# 6) 提交这次初始化（建议单独一个 commit）
git add scaffold
git commit -m "chore: import scaffold into scaffold directory"
```

### 日常使用方式（不污染业务目录）

```bash
# 运行脚手架脚本（注意路径在 scaffold/）
./scaffold/init-session.sh
./scaffold/select-next-task.sh

# 你实际维护的项目文档，建议放在项目自己的 docs/ 下
# 可手工从 scaffold/*.template.* 复制一份到 docs/ 并按项目改造
```

### 拉取脚手架更新（只覆盖 scaffold/）

```bash
# 1) 获取上游模板最新内容
git fetch scaffold-template main

# 2) 先看模板仓库最近更新了什么（帮助你判断要不要同步）
git log --oneline HEAD..scaffold-template/main | head -20

# 3) 仅覆盖 scaffold/ 下的模板文件，不触碰 src/ tests/ 等业务目录
git show scaffold-template/main:AGENTS.md > scaffold/AGENTS.md
git show scaffold-template/main:.github/copilot-instructions.md > scaffold/copilot-instructions.md
git show scaffold-template/main:scripts/init-session.sh > scaffold/init-session.sh
git show scaffold-template/main:scripts/select-next-task.sh > scaffold/select-next-task.sh

# 4) 查看本次变更，确认只有 scaffold/ 被改动
git status --short

# 5) 单独提交，便于回滚
git add scaffold
git commit -m "chore: sync scaffold templates"
```

---

## 全项目完成后，回头升级旧模块怎么做

场景：你已经做完 A 模块（因子挖掘）和 B 模块（交易接口），后来要升级 A 模块。

核心原则：
- 不直接在 `main` 上改旧模块。
- 每次升级开一个独立分支。
- 升级任务单独写进 `docs/task-list.json`（保留历史任务）。
- 在 `docs/progress.md` 和 `docs/phases.md` 明确记录“为什么升级、影响范围、验证结果”。

### 升级旧模块的标准流程（详细注释）

```bash
# 0) 确保当前 main 是干净状态（没有未提交改动）
git checkout main
git pull
git status

# 1) 为这次升级创建专用分支
#    命名建议：upgrade/<模块名>-<版本>
git checkout -b upgrade/factor-mining-v1.1

# 2) 在 docs/task-list.json 追加升级任务（示例）
#    T301: 因子库性能优化
#    T302: 因子稳定性修复
#    T303: 回归验证（确保不破坏交易接口）

# 3) 开发与验证（根据任务逐条完成）
#    这里执行你的测试命令，例如：
#    pytest tests/factor -q
#    pytest tests/integration -q

# 4) 更新进度文档
#    docs/progress.md: 记录本次升级内容与验证结果
#    docs/phases.md: 给“因子挖掘”模块增加 v1.1 记录

# 5) 提交本次升级（可以分多次提交）
git add .
git commit -m "feat(T301): optimize factor mining performance"

# 6) 升级完成后合并回 main
git checkout main
git merge --no-ff upgrade/factor-mining-v1.1

# 7) 打版本标签（可选，但强烈建议）
#    方便以后回溯“哪个提交对应哪个模块版本”
git tag -a factor-mining-v1.1 -m "factor mining module v1.1"

# 8) 推送代码与标签
git push origin main
git push origin factor-mining-v1.1
```

### 为什么这样做最稳

1. 升级分支让旧模块改动与线上主线隔离，风险可控。
2. 任务清单追加而不覆盖，历史上下文不会丢。
3. 文档记录版本演进，后续接手者能快速理解承上启下关系。
4. 脚手架更新与业务升级解耦，冲突面最小。

---

## 避免冲突的最佳实践

1. **脚手架文件 + 业务文件分离**
   - 脚手架：`AGENTS.md`, `.github/`, `.cursor/`, `scripts/`, `docs/architecture.md 的模板部分`
   - 业务：`src/`, `tests/`, `docs/{task-list.json 的任务定义部分, progress.md}`

2. **docs 文件的分工**
   - `architecture.md`: 脚手架提供格式，你填实际内容（生产目标、技术栈、约束）
   - `task-list.json`: 允许追加新任务，不删旧任务；支持分模块管理
   - `progress.md`: 只增不删；脚手架不维护，内容全由项目控制
   - `phases.md`: 新增，用于多模块的阶段交接

3. **提交策略**
   - 脚手架同步 → 单独提交：`chore: sync scaffold from template`
   - 模块开发 → 按 AGENTS.md 提交：`feat(T001): description`
   - 文档更新 → 一起提交：`docs(T001): update architecture and task list`

4. **分支策略**（可选，小项目不需要）
   ```bash
   # 大型项目：为脚手架维护单独的追踪分支
   git branch scaffold-sync scaffold-template/main
   # 当需要更新时：
   git merge --no-commit scaffold-sync
   # 手工解决冲突，仅保留脚手架文件变更
   # 然后 git commit
   ```

---

## 建议会话循环

1. 运行 `./scripts/init-session.sh`。
2. 阅读 `docs/progress.md` 与近期 git 提交。
3. 在 `docs/task-list.json` 中选择一个 `passes: false` 的任务。
4. 只实现该任务。
5. 运行 lint、tests、build 等验证。
6. 仅更新该任务对象。
7. 在 `docs/progress.md` 追加交接记录。
8. 用聚焦提交信息完成提交。

## Copilot Chat 使用方式

- 在 VS Code 打开本目录。
- 在 Copilot Chat 中要求 Agent 严格遵循 `AGENTS.md` 完成下一个任务。
- 非必要不要关闭审批模式，避免误操作。

## Cursor Agent 使用方式

- 在 Cursor 打开本目录。
- 确认 `.cursor/rules/agent-workflow.mdc` 已生效。
- 指示 Agent 按同一循环执行：单任务、全验证、写进度、再提交。

## 说明

- 该模板默认是通用骨架，正式开发前请先替换成你的真实架构与任务拆解。
- 任务状态建议放在 JSON 中，能减少结构被误改的概率。
- 多模块项目建议在 `docs/phases.md` 维护阶段交接记录，便于后续人员快速获取上下文。
