# AgentRC

> 為您的程式庫做好 AI 輔助開發的準備。

[![CI](https://github.com/microsoft/agentrc/actions/workflows/ci.yml/badge.svg)](https://github.com/microsoft/agentrc/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> [!WARNING]
> **實驗性** — 此專案正在積極開發中。請預期命令、API 和輸出格式會發生重大變更。歡迎早期採用者提供回饋 — [提交 Issue](https://github.com/microsoft/agentrc/issues)。

AI 程式碼開發 Agent 的效率取決於它們接收到的上下文（context）。AgentRC 是一個 CLI 工具和 VS Code 擴充功能，旨在彌合這一差距 — 從單個程式庫到組織內的數百個程式庫。

**衡量 (Measure)** — 分析程式庫結構，並根據 5 級成熟度模型對 AI 準備就緒程度（readiness）進行評分。
**生成 (Generate)** — 使用 Copilot SDK 生成量身定制的指令（instructions）、評估（evals）和開發配置（dev configs）。
**維護 (Maintain)** — 在 CI 中執行評估，以捕捉隨著程式碼演進而產生的指令偏移。

![AgentRC — 衡量、生成、維護週期](docs/assets/agentrc-overview.png)

## 快速開始

```bash
# 直接執行（無需安裝）
npx github:microsoft/agentrc readiness
```

`npx github:<owner>/agentrc ...` 會從 Git 程式庫安裝並執行套件的 `prepare` 腳本，該腳本會在第一次使用前建置 CLI。

或在本地安裝：

```bash
git clone https://github.com/microsoft/agentrc.git
cd agentrc && npm install && npm run build && npm link

# 1. 檢查程式庫結構
agentrc analyze

# 2. 檢查程式庫的 AI 準備就緒程度
agentrc readiness

# 3. 生成 AI 指令
agentrc instructions

# 4. 生成 MCP 和 VS Code 配置
agentrc generate mcp
agentrc generate vscode

# 或以互動方式執行引導流程
agentrc init
```

## 先決條件

| 需求 | 備註 |
| --------------------------------- | ---------------------------------------------------------------- |
| **Node.js 20+** | 執行階段 |
| **GitHub Copilot CLI** | 隨附於 VS Code Copilot Chat 擴充功能中 |
| **Copilot 驗證** | 執行 `copilot` → `/login` |
| **GitHub CLI** _(選填)_ | 用於批次處理和 PR：`brew install gh && gh auth login` |
| **Azure DevOps PAT** _(選填)_ | 為 Azure DevOps 工作流設置 `AZURE_DEVOPS_PAT` |

## 命令

### `agentrc analyze` — 檢查程式庫結構

檢測語言、框架、monorepo/工作區結構以及區域映射（area mappings）：

```bash
agentrc analyze                                # 終端機摘要
agentrc analyze --json                         # 機器可讀的分析結果
agentrc analyze --output analysis.json         # 儲存 JSON 報告
agentrc analyze --output analysis.md           # 儲存 Markdown 報告
agentrc analyze --output analysis.json --force # 覆寫現有報告
```

### `agentrc readiness` — 評估 AI 準備就緒程度

從歸類為 **程式庫健康狀況（Repo Health）** 和 **AI 設置（AI Setup）** 的 9 個支柱對程式庫進行評分：

```bash
agentrc readiness                        # 終端機摘要
agentrc readiness --visual               # GitHub 風格的 HTML 報告
agentrc readiness --per-area             # 包含分區細目
agentrc readiness --output readiness.json # 儲存 JSON 報告
agentrc readiness --output readiness.md   # 儲存 Markdown 報告
agentrc readiness --output readiness.html # 儲存 HTML 報告
agentrc readiness --policy ./examples/policies/strict.json # 應用自定義策略
agentrc readiness --json                 # 機器可讀的 JSON
agentrc readiness --fail-level 3         # CI 門檻：若低於等級 3 則以結束代碼 1 退出
```

**成熟度等級：**

| 等級 | 名稱 | 意義 |
| ----- | ---------- | -------------------------------------------------- |
| 1 | Functional | 已具備建置、測試和基礎工具 |
| 2 | Documented | 存在 README、CONTRIBUTING 和自定義 AI 指令 |

在等級 2，AgentRC 還會檢查**指令一致性** — 當程式庫有多個 AI 指令文件（例如 `copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`）時，它會檢測它們是否發生分歧。符號連結或完全相同的檔案會通過檢查；分歧的檔案將失敗，並顯示相似度分數和合併建議。

| 3 | Standardized | 具備 CI/CD、安全策略、CODEOWNERS 和可觀測性 |
| 4 | Optimized | 已配置 MCP 伺服器、自定義 Agent 和 AI 技能 |
| 5 | Autonomous | 在最小監督下實現全 AI 原生開發 |

### `agentrc instructions` — 生成指令

使用 Copilot SDK 生成 `copilot-instructions.md` 或 `AGENTS.md`：

```bash
agentrc instructions                      # copilot-instructions.md (預設)
agentrc instructions --format agents-md   # AGENTS.md
agentrc instructions --per-app            # monorepo 中的每個應用程式
agentrc instructions --areas              # 根目錄 + 所有檢測到的區域
agentrc instructions --area frontend      # 單一區域
agentrc instructions --model claude-sonnet-4.5
```

### `agentrc eval` — 評估指令

使用評審模型衡量指令如何改進 AI 的回應：

```bash
agentrc eval --init                       # 從程式碼庫建置評估配置
agentrc eval agentrc.eval.json             # 執行評估
agentrc eval --model gpt-4.1 --judge-model claude-sonnet-4.5
agentrc eval --fail-level 80              # CI 門檻：若通過率 < 80% 則以結束代碼 1 退出
```

### `agentrc generate` — 生成配置

```bash
agentrc generate mcp                      # .vscode/mcp.json
agentrc generate vscode --force           # .vscode/settings.json (覆寫)
```

### `agentrc batch` / `agentrc pr` — 批次處理與 PR

```bash
agentrc batch                             # 互動式 TUI (GitHub)
agentrc batch --provider azure            # Azure DevOps
agentrc batch owner/repo1 owner/repo2 --json
agentrc batch-readiness --output team.html
agentrc pr owner/repo-name                # 複製 → 生成 → 開啟 PR
```

### `agentrc tui` — 互動模式

```bash
agentrc tui
```

### `agentrc init` — 引導式設置

互動式或自動化程式庫導入 — 檢測您的技術棧並引導完成準備就緒程度檢查、指令生成和配置生成。對於 monorepo，會自動檢測工作區並引導生成包含工作區和區域定義的 `agentrc.config.json`。

### 全域選項

所有命令都支援 `--json`（將結構化 JSON 輸出到標準輸出）和 `--quiet`（隱藏標準錯誤）。JSON 輸出使用 `CommandResult<T>` 包裝：

```json
{ "ok": true, "status": "success", "data": { ... } }
```

### 準備就緒策略 (Readiness Policies)

策略可用於自定義評分標準、覆寫元數據並調整閾值：

```bash
agentrc readiness --policy ./examples/policies/strict.json
agentrc readiness --policy ./examples/policies/strict.json,./my-overrides.json  # 鏈接多個策略
```

```json
{
  "name": "my-org-policy",
  "criteria": {
    "disable": ["lint-config"],
    "override": { "readme": { "impact": "high", "level": 2 } }
  },
  "extras": { "disable": ["pre-commit"] },
  "thresholds": { "passRate": 0.9 }
}
```

策略也可以在 `agentrc.config.json` 中設置 (`{ "policies": ["./my-policy.json"] }`)。

### 配置文件

`agentrc.config.json`（位於程式庫根目錄或 `.github/`）用於配置區域、工作區和策略：

```json
{
  "areas": [{ "name": "docs", "applyTo": "docs/**" }],
  "workspaces": [
    {
      "name": "frontend",
      "path": "packages/frontend",
      "areas": [
        { "name": "app", "applyTo": "app/**" },
        { "name": "shared", "applyTo": ["shared/**", "common/**"] }
      ]
    }
  ],
  "policies": ["./policies/strict.json"]
}
```

- **`areas`** — 具有 glob 模式（相對於程式庫根目錄）的獨立區域
- **`workspaces`** — monorepo 子專案；每個工作區將限定於子目錄的區域分組。區域的 `applyTo` 模式相對於工作區路徑。工作區區域會獲得命名空間化的名稱（`frontend/app`）以及用於範圍化評估會話的 `workingDirectory`。
- `agentrc init` 會自動檢測工作區（透過 `.vscode` 資料夾和同級區域分組）並引導生成此檔案。

> **安全性：** 從配置來源的策略僅限於 JSON 檔案 — JS/TS 模組策略必須透過 `--policy` 傳遞。

請參閱 [docs/plugins_zh_TW.md](docs/plugins_zh_TW.md) 以獲取完整的插件開發指南，包括指令式 TypeScript 插件、生命週期掛鉤和信任模型。

## 開發

```bash
npm run typecheck        # 類型檢查
npm run lint             # ESLint (flat config + Prettier)
npm run test             # Vitest 測試
npm run test:coverage    # 包含測試覆蓋率
npm run build            # 透過 tsup 進行生產建置
npx tsx src/index.ts --help  # 從原始碼執行
```

### VS Code 擴充功能

```bash
cd vscode-extension
npm install && npm run build
# 按 F5 啟動擴充功能開發主機 (Extension Development Host)
```

請參閱 [CONTRIBUTING_zh_TW.md](CONTRIBUTING_zh_TW.md) 以獲取工作流和程式碼風格指南。

## 專案結構

```
packages/core/
└── src/
  ├── index.ts          # 共享的公共 API 表面
  ├── services/         # 由 CLI 和擴充功能重用的核心產品邏輯
  │   ├── readiness.ts   # 具有支柱分組的 9 支柱評分引擎
  │   ├── visualReport.ts # HTML 報告生成器
  │   ├── instructions.ts # Copilot SDK 整合
  │   ├── analyzer.ts    # 程式庫掃描（語言、框架、monorepo）
  │   ├── evaluator.ts   # 評估執行器 + 軌跡查看器
  │   ├── generator.ts   # MCP/VS Code 配置生成
  │   ├── policy.ts      # 準備就緒策略載入和鏈解析
  │   ├── policy/        # 插件引擎（類型、編譯器、載入器、適配器、陰影）
  │   ├── git.ts         # Git 操作（複製、分支、推送）
  │   ├── github.ts      # GitHub API (Octokit)
  │   └── azureDevops.ts # Azure DevOps API
  └── utils/            # 共享工具 (fs, logger, output)

src/
├── cli.ts                # Commander CLI 佈線
├── commands/             # CLI 子命令（輕量級編排器）
├── index.ts              # CLI 進入點
└── ui/                   # Ink/React 終端機 UI

vscode-extension/         # 基於 packages/core 的 VS Code 擴充功能殼層
```

## 疑難排解

**"Copilot CLI not found"** — 請在 VS Code 中安裝 GitHub Copilot Chat 擴充功能。CLI 隨附於其中。

**"Copilot CLI not logged in"** — 在終端機執行 `copilot`，然後執行 `/login` 進行驗證。

**"GitHub authentication required"** — 安裝 GitHub CLI (`brew install gh && gh auth login`) 或設置 `GITHUB_TOKEN` / `GH_TOKEN`。

## 授權條款

[MIT](LICENSE)

## 商標

本專案可能包含專案、產品或服務的商標或標誌。授權使用 Microsoft 商標或標誌必須遵守並遵循 [Microsoft 的商標與品牌指南](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general)。在本專案的修改版本中使用 Microsoft 商標或標誌不得造成混淆或暗示 Microsoft 的贊助。任何第三方商標或標誌的使用均須遵守該第三方的政策。
