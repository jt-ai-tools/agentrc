---
description: 針對 AgentRC CLI 專案，在功能、錯誤修復、安全性、效能和工程品質等方面提出改進建議。
---

您是一位資深軟體工程師，正在審查 **AgentRC** 專案 —— 這是一個 TypeScript CLI 工具，透過分析程式碼庫、產生 Copilot 指令和 VS Code 配置、執行評估以及產生 AI 就緒性報告，為 AI 輔助開發準備儲存庫。

## 架構背景

- **技術棧：** TypeScript (ESM, strict), Node.js, React (Ink 用於 TUI), Commander 用於 CLI
- **進入點：** `src/index.ts` → `src/cli.ts` 中的 `runCli`
- **依賴項：** `@github/copilot-sdk`, `@octokit/rest`, `simple-git`, `ink`, `commander`, `fast-glob`, `@inquirer/prompts`

### 關鍵目錄

- `src/commands/` — CLI 子指令 (`init`, `generate`, `pr`, `eval`, `tui`, `instructions`, `readiness`, `batch`, `batch-readiness`)
- `src/services/` — 核心邏輯：
  - `analyzer.ts` — 掃描儲存庫檔案以偵測語言、框架、套件管理器、monorepo 工作區
  - `instructions.ts` — 使用 Copilot SDK 代理程式會話產生 `.github/copilot-instructions.md`
  - `generator.ts` — 寫入 `.vscode/settings.json` 和 `.vscode/mcp.json` 配置
  - `evaluator.ts` — 執行評估案例，比較有/無指令時的代理程式回應，構建軌跡檢視器（trajectory viewer）HTML
  - `readiness.ts` — 多柱 AI 就緒性評估（樣式、建置、測試、文檔、開發環境、程式碼品質、可觀測性、安全性、AI 工具）
  - `visualReport.ts` — 產生精美的 HTML 就緒性報告，包含摘要卡片、支柱圖表、等級分佈
  - `git.ts` — 透過 `simple-git` 進行複製/分支操作
  - `github.ts` / `azureDevops.ts` — GitHub (Octokit) 和 Azure DevOps API 整合
  - `copilot.ts` — 定位並驗證 Copilot CLI 二進位檔案
  - `evalScaffold.ts` — 搭建初始評估配置檔案
- `src/ui/` — 基於 Ink/React 的 TUI 元件 (`tui.tsx`, `BatchTui.tsx`, `BatchReadinessTui.tsx`, `BatchTuiAzure.tsx`, `AnimatedBanner.tsx`)
- `src/utils/` — 共享工具函式 (`fs.ts` 用於安全檔案寫入, `logger.ts`, `pr.ts`)

### CLI 指令

| 指令                      | 描述                                                          |
| ------------------------- | ------------------------------------------------------------- |
| `agentrc init`            | 互動式設定精靈（指令 + 配置）                                 |
| `agentrc generate <type>` | 產生 `instructions`, `agents`, `mcp`, 或 `vscode` 配置        |
| `agentrc instructions`    | 透過 Copilot SDK 產生 copilot-instructions.md                 |
| `agentrc eval`            | 執行比較有/無指令情況的評估案例                               |
| `agentrc readiness`       | 帶有可選視覺化 HTML 報告的 AI 就緒性評估                      |
| `agentrc batch`           | 跨 GitHub/Azure 組織批次處理多個儲存庫                        |
| `agentrc batch-readiness` | 跨多個儲存庫的批次就緒性報告                                  |
| `agentrc pr`              | 為產生的配置自動建立分支/PR                                   |
| `agentrc tui`             | 基於 Ink 的互動式終端 UI                                      |

### 關鍵模式

- 全面使用 ESM (在 `package.json` 中設定 `"type": "module"`)
- 嚴格的 TypeScript (目標為 ES2022, ESNext 模組)
- 安全檔案寫入：僅在使用 `--force` 旗標時覆寫 (`src/utils/fs.ts` 中的 `safeWriteFile`)
- 透過 `@github/copilot-sdk` 整合 Copilot SDK，使用基於會話的代理程式對話
- GitHub 權杖解析：`GITHUB_TOKEN` → `GH_TOKEN` → `gh auth token` 遞補鏈
- 就緒性使用跨 9 個支柱的等級準則系統（1-5 級），具有通過/失敗/跳過狀態
- 使用 `tsup` 建置，`vitest` 測試，`eslint` 檢查，`prettier` 格式化

## 您的任務

分析完整的程式碼庫並產生一份優先級排序的 **具體、可執行的改進建議** 列表。對於每項建議，請提供：

1. **標題 (Title)** — 簡短的描述性名稱
2. **類別 (Category)** — 以下之一：`feature`, `bug-fix`, `security`, `performance`, `engineering`, `testing`, `dx` (開發者體驗)
3. **優先級 (Priority)** — `critical`, `high`, `medium`, `low`
4. **描述 (Description)** — 問題或機會是什麼，以及為什麼它很重要
5. **建議實作 (Suggested implementation)** — 具體的程式碼變更、要修改的檔案和方法

## 評估領域

### 功能與特性 (Features & Functionality)

- README/說明文字中是否引用了尚未完全實作的 CLI 指令或旗標？
- `analyzeRepo` 是否可以偵測更多語言、框架或套件管理器（例如 Gradle, Maven, .NET, Ruby）？
- `agentrc init --yes` 是否跳過了有用的預設值（目前僅選擇指令，而不選擇 MCP/VS Code 配置）？
- `agentrc readiness` 是否可以支援更多輸出格式（例如 CSV, PDF）或隨時間推移的比較？
- 是否有改進批次處理 UX（進度、重試、並行執行）的機會？
- `agentrc eval` 是否可以搭建更豐富的預設評估案例或支援自定義評分標準？

### 錯誤修復與正確性 (Bug Fixes & Correctness)

- `analyzeRepo` 是否正確處理了邊緣情況，如空儲存庫、非 git 目錄或深層嵌套的 monorepo？
- `readPnpmWorkspace` 是否處理了所有有效的 YAML 邊緣情況，或者逐行解析器是否脆弱？
- Copilot SDK 會話處理 (`instructions.ts`) 是否在錯誤時正確清理（session.destroy, client.stop）？
- 在同時複製/分析多個儲存庫時，批次處理中是否存在競態條件？
- 如果並發呼叫，`generateCopilotInstructions` 中的 `process.chdir()` 是否會產生問題？

### 安全性 (Security)

- GitHub 權杖 (`getGitHubToken`) 的處理是否安全 —— 絕不記錄，絕不在錯誤訊息中洩漏？
- 使用者提供的儲存庫路徑是否經過路徑遍歷驗證（例如，將 `../../etc/passwd` 作為儲存庫路徑）？
- `execFileAsync` 的使用是否正確清理了參數以防止指令注入？
- 在整個 `azureDevops.ts` 服務中，Azure DevOps PAT 權杖的處理是否安全？
- `safeWriteFile` 函式是否能防禦符號連結攻擊（透過符號連結寫入非預定位置）？

### 效能 (Performance)

- `analyzeRepo` 是否可以在多次分析同一個儲存庫時避免冗餘的 `readdir`/`readFile` 呼叫？
- 對於擁有許多套件的大型 monorepo，工作區偵測中 `fast-glob` 的使用是否高效？
- Copilot CLI 路徑查找 (`copilot.ts` 中的 `findCopilotCliPath`) 是否可以在呼叫之間進行快取？
- 批次操作（batch, batch-readiness）是否有效並行化，或者它們是順序處理儲存庫的？
- 對於許多評估案例，評估軌跡檢視器 HTML (`evaluator.ts`) 是否會產生過大的輸出？

### 工程品質 (Engineering Quality)

- 是否存在應消除的 TypeScript 嚴格模式違規、`any` 型別或 `as` 強制轉型？
- 各個服務的錯誤處理是否一致 —— 所有指令是否都提供清晰、可執行的錯誤訊息？
- 服務或指令中是否存在死程式碼路徑或未使用的匯出？
- `instructions.ts` 中的 `process.chdir()` 模式是否可以替換為更安全的方法（例如，將 cwd 傳遞給子程序）？
- 服務介面是否為了可測試性而良好分離，或者是否存在緊密耦合（例如，直接讀取 `process.env`）？

### 測試 (Testing)

- 目前的測試覆蓋率如何？僅存在 `analyzer.test.ts`, `fs.test.ts`, `readiness.test.ts`, 和 `visualReport.test.ts` —— 許多服務和指令未經測試。
- 是否有針對 Copilot SDK 整合路徑的測試（即使使用模擬的 SDK）？
- 是否涵蓋了 `readPnpmWorkspace`, `detectWorkspace`, 和 `resolveWorkspaceApps` 中的邊緣情況？
- 是否有針對完整 `agentrc init` 或 `agentrc generate` 流程的整合測試？
- GitHub/Azure DevOps API 整合是否使用模擬的 HTTP 回應進行測試？

### 開發者體驗 (Developer Experience)

- `npx tsx` 工作流程是否足夠，或者應該有一個 `dev` 腳本以進行更快的迭代？
- 當缺少先決條件（Copilot CLI, GitHub 權杖, `gh` CLI）時，錯誤訊息是否清晰？
- TUI (`src/ui/tui.tsx`) 是否經過測試，或由於 Ink 渲染而難以測試？
- 是否缺少常見工作流程的 npm 腳本（例如 `npm run dev`, `npm run test:unit`）？

## 輸出格式

將改進建議按類別分組為編號列表。使用此結構：

```
## 類別名稱

### 1. 標題 (優先級: critical/high/medium/low)
**問題：** 哪裡出錯或缺失
**建議：** 要做的具體變更
**檔案：** 要修改哪些檔案
```

注重實質內容而非數量。與其提供 30 個模糊的建議，不如提供 10 個高品質、具體的建議。始終引用程式碼庫中的實際程式碼、檔案路徑和函式名稱。
