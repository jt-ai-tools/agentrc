# 更新日誌 (Changelog)

此專案的所有顯著變更都將記錄在此檔案中。

## [2.0.0]

### 完全重寫

AgentRC vNext 是一個完全重寫的 TypeScript CLI 工具（ESM, strict, ES2022），用於為 AI 輔助開發和評估準備程式庫。

### 新命令

- **`agentrc readiness`** — AI 準備就緒程度報告，根據 9 個支柱（風格、建置、測試、文件、開發環境、程式碼品質、可觀測性、安全性、AI 工具化）對程式庫進行評分，採用 5 級成熟度模型（Functional → Autonomous）。
- **`agentrc readiness --visual`** — 以 GitHub 為主題的 HTML 報告，具有淺色/深色模式切換、可展開的支柱詳情和成熟度模型描述。
- **`agentrc readiness --per-area`** — 針對 monorepo 的分區準備就緒程度評分，具有區域範圍的標準和聚合閾值。
- **`agentrc readiness --policy`** — 可透過 JSON、JS/TS 或 npm 套件自定義準備就緒策略（禁用/覆寫標準、調整閾值）；支援鏈式調用，採用最後贏家（last-wins）語義。
- **`agentrc batch-readiness`** — 整合多個程式庫的可視化準備就緒程度報告，支援 `--policy`。
- **`agentrc generate instructions`** — 透過 Copilot SDK 生成 `copilot-instructions.md`，支援 monorepo 的 `--per-app` 選項。
- **`agentrc generate agents`** — 生成 `AGENTS.md` 指引檔案。
- **`agentrc instructions --areas`** — 在檢測到的區域中生成範圍限定的 `.instructions.md` 檔案，支援 `applyTo` glob 模式。
- **`agentrc eval --init`** — AI 驅動的評估腳手架生成，分析程式碼庫並生成跨領域、感知區域的評估案例。
- **`agentrc eval --list-models`** — 列出可用的 Copilot CLI 模型。
- **`agentrc analyze`** — 獨立的程式庫分析命令，具有結構化的 `--json` 輸出。

### VS Code 擴充功能

- 8 個命令面板命令：分析、生成配置、生成指令、AI 準備就緒程度報告、執行評估、建置評估腳手架、初始化程式庫、建立 PR。
- 側邊欄樹狀檢視：分析（語言、框架、monorepo 區域）和準備就緒程度（帶有顏色編碼標準的 9 支柱評分）。
- 用於顯示準備就緒程度 HTML 報告和評估結果的 Webview 面板。
- 分析後顯示檢測到的語言的動態狀態列。
- PR 建立功能，包含預設分支保護、選擇性檔案暫存以及透過 VS Code API 進行 GitHub 驗證。
- 經 esbuild 捆綁的 CJS 輸出；CI 類型檢查和發佈時的 VSIX 打包。

### 新功能

- **Azure DevOps 整合** — 全面支持透過 Azure DevOps PAT 驗證進行批次處理、PR 建立和程式庫複製。
- **無介面 (Headless) 自動化** — 所有命令均支援全域 `--json` 和 `--quiet` 標誌；使用 `CommandResult<T>` 包裝，包含 `ok`/`status`/`data`/`errors`。支援透過位置參數或標準輸入管道進行無介面批次模式。
- **策略系統** — 用於準備就緒報告的分層策略鏈：禁用/覆寫標準、添加額外項、調整通過率閾值。出於安全考慮，從配置來源的策略僅限於 JSON。
- **分區準備就緒程度** — 4 個區域範圍的標準（`area-readme`, `area-build-script`, `area-test-script`, `area-instructions`），聚合通過閾值為 80%。
- **基於檔案的區域指令** — 帶有 YAML frontmatter（`description`, `applyTo`）的 `.instructions.md` 檔案，用於 VS Code Copilot 區域範圍設定。
- **擴展的 monorepo 檢測** — 除 Cargo, Go, .NET, Gradle, Maven, npm/pnpm/yarn 工作區外，還支援 Bazel (`MODULE.bazel`/`WORKSPACE`), Nx (`project.json`), Pants (`pants.toml`), Turborepo 覆蓋。
- **智能區域回退** — 具有 10 個以上頂層目錄的大型程式庫會透過啟發式掃描和符號連結安全的目錄遍歷自動發現區域。
- **評估軌跡查看器 (Eval trajectory viewer)** — 互動式 HTML 查看器，比較有/無指令時的回應，包括 Token 使用量、工具調用指標和持續時間跟蹤。
- **Windows Copilot CLI 支援** — 透過 `cmd /c` 處理 `.cmd`/`.bat` 包裝器，檢測 npm-loader.js，並使用 `CopilotCliConfig` 類型取代純字串路徑。
- **Copilot CLI 發現** — 具有 TTL 快取和針對 VS Code 擴充功能路徑的 glob 回退的跨平台發現。
- **集中式模型預設值** — 透過 `src/config.ts` 將預設模型設置為 `claude-sonnet-4.5`。

### 改進

- 所有檔案寫入路徑現在都使用 `safeWriteFile()` — 指令、Agent 和區域檔案都會拒絕符號連結並遵循 `--force`。
- 統一的 `agentrc pr` 命令：GitHub 和 Azure DevOps 都會生成所有三種產物（指令 + MCP + VS Code 配置），並具有一致的分支命名。
- `CommandResult<T>` 輸出包裝，將結構化 JSON 輸出到標準輸出；將人類可讀的輸出輸出到標準錯誤。
- `ProgressReporter` 介面，用於在 CLI 和無介面模式下顯示靜默或人類可讀的進度。
- 透過 `isScannableDirectory()` 進行符號連結安全的目錄掃描，並包含 `lstat` + `realpath` 包含檢查。
- 透過 `validateCachePath` 提供路徑遍歷保護（針對複製的程式庫路徑），以及針對區域 `applyTo` 模式的雙層防禦。
- 在 git push 錯誤訊息中進行憑據脫敏，以防止 Token 洩漏。
- `buildAuthedUrl` 工具，支援 GitHub (`x-access-token`) 和 Azure DevOps (`pat`) 驗證。
- `checkRepoHasInstructions` 現在會重新拋出非 404 錯誤，而不是靜默返回 false。
- `init --yes` 現在會生成指令、MCP 和 VS Code 配置（以前僅生成指令）。
- 在評估和準備就緒程度 HTML 報告生成器中添加了 CSP meta 標籤。

### 移除

- 移除了佔位命令：`templates`, `update`, `config`。
- 移除了 `src/utils/cwd.ts` — 由 Copilot SDK `workingDirectory` 會話配置取代。

### 測試與工具

- Vitest 測試框架，在 13 個測試檔案中包含 267 個測試，涵蓋分析器、生成器、git、準備就緒程度、可視化報告、檔案系統工具、快取路徑驗證、策略、邊界、CLI、輸出工具和 PR 助手。
- ESLint flat config，整合了 TypeScript、導入排序和 Prettier。
- CI 工作流，包含 lint、類型檢查、測試（Node 20/22, Ubuntu/macOS/Windows）、建置驗證和擴充功能類型檢查。
- CI 自行測試 (Dogfooding)：在程式庫本身執行 `agentrc analyze --json` 和 `agentrc readiness --json`。
- 透過 release-please 進行自動化發佈，並為 VS Code 擴充功能進行 VSIX 打包。
- 透過 `@vitest/coverage-v8` 進行程式碼覆蓋率分析。

### 專案設置

- 添加了 CONTRIBUTING_zh_TW.md, SECURITY_zh_TW.md, LICENSE (MIT) 和 CODEOWNERS。
- 添加了 Issue 模板（錯誤報告、功能請求）和 PR 模板。
- 添加了 `.github/agents/`，包含多模型程式碼審查 Agent (Opus, Gemini, Codex)。
- 添加了 `.github/prompts/`，包含可重用的 Prompt（脫水、審查、生成改進建議）。
- 添加了 examples 資料夾，包含範例評估配置和 CLI 使用指南。
- 添加了 `.prettierrc.json`，包含專案格式化規則。
