# 此儲存庫的 Copilot 指令

**AgentRC** 是一個 TypeScript CLI + VS Code 擴充功能，用於為 AI 輔助開發準備儲存庫。有關完整架構、指令參考和服務詳情，請參閱 `README_zh_TW.md`。

## 開發檢查清單

在被視為完成之前，所有變更必須根據此檢查清單進行驗證：

- [ ] 實作涵蓋了 CLI 和 VS Code 擴充功能（如果適用）
- [ ] 執行了 lint/typecheck/test/build npm 任務。全部通過
- [ ] 執行了 Review 子代理程式（subagent）。未報告阻礙（BLOCKERS）

## 建置與測試

```sh
npm run build          # tsup → dist/
npm run typecheck      # tsc --noEmit
npm run lint           # eslint (層次化配置/flat config)
npm run test           # vitest (單次執行)
npm run test:watch     # vitest (監看模式)
```

無需建置即可執行：`npx tsx src/index.ts <command> [options]`

VS Code 擴充功能：從 `vscode-extension/` 執行 `node esbuild.mjs`；在該目錄使用 `npx tsc --noEmit` 進行型別檢查。

## 程式碼風格

- 全面使用 ESM 語法 (`"type": "module"`)。TypeScript 嚴格模式，目標為 ES2022。
- 相容 Windows/macOS/Linux —— 使用 `path.join()`，避免使用特定於 Shell 的語法。
- 請勿新增新的建置/lint/測試工具；請使用現有的 npm 腳本。

## 架構

- **進入點：** `src/index.ts` → `src/cli.ts` 中的 `runCli()`
- **指令** (`src/commands/`) 是精簡的編排器 —— 解析選項、呼叫服務、格式化輸出。
- **服務** (`src/services/`) 包含所有業務邏輯。指令絕不直接存取 API 或檔案系統。
- **UI** (`src/ui/`) —— 用於互動式 TUI 的 Ink/React 19 元件。使用 Ink 6 API。
- **工具函式** (`src/utils/`) —— `output.ts`、`fs.ts`、`logger.ts`、`repo.ts`、`pr.ts`。
- **VS Code 擴充功能** (`vscode-extension/`) —— 附屬擴充功能；透過路徑別名 `agentrc/*` 匯入 CLI 服務。詳情請參閱擴充功能特定指令。

## 慣例

### 輸出規範

- `stdout` 僅用於 JSON（配合 `--json` 選項）；**所有人類可讀的輸出均傳送至 `stderr`**。
- 所有指令必須支援 `--json` 和 `--quiet` 旗標。使用 `src/cli.ts` 中的 `withGlobalOpts()` 將全域旗標合併至指令選項中。
- 指令回傳 `CommandResult<T>`，包含 `{ ok, status, data?, errors? }`（來自 `src/utils/output.ts`）。狀態值：`"success"`、`"partial"`、`"noop"`、`"error"`。
- 使用 `outputResult()` / `outputError()` 進行最終輸出 —— 絕不使用 `console.log()`。

### 檔案安全性

- 使用 `src/utils/fs.ts` 中的 `safeWriteFile()` 進行所有使用者路徑的檔案寫入。它會拒絕符號連結（symlinks），且除非使用 `--force`，否則會跳過現有檔案。
- 使用 `validateCachePath()` 防止 `.agentrc-cache/` 中的遍歷攻擊（traversal attacks）。

### 錯誤處理

- 服務丟出具有意義的 `Error` 訊息。指令擷取並傳遞給 `outputError()`。
- 不要在 catch 區塊中重新封裝錯誤或添加額外的日誌。

### 依賴項

- CLI 使用 Commander、simple-git、Octokit。VS Code 擴充功能使用內建的 `vscode.git` API —— **絕不在擴充功能中打包 `simple-git`**。
- Copilot SDK 會話使用 `SessionConfig` 中的 `workingDirectory` 進行範圍限定。

## 測試

- **框架：** Vitest。測試位於 `src/services/__tests__/`，帶有 `.test.ts` 後綴。
- **模擬 (Mocking)：** 對於函式使用 `vi.fn()`，對於方法使用 `vi.spyOn()`。不使用 `vi.mock()` —— 偏好使用內聯模擬（inline mocks）和工廠輔助函式。
- **檔案系統測試：** 使用真實的暫存目錄（`os.tmpdir()` + `fs.mkdtemp`）。在 `afterEach()` 中清理。
- **測試命名：** 每個函式/匯出使用一個 `describe()`，`it()` 名稱以動詞開頭並構成句子。
- **不使用共享測試工具** —— 輔助函式限定在每個測試檔案的 `describe()` 區塊範圍內。

## 先決條件

- 已安裝 **Copilot CLI** 並通過 SDK 呼叫驗證
- **GitHub:** `GITHUB_TOKEN` 或 `GH_TOKEN` 環境變數，或 `gh` CLI
- **Azure DevOps:** `AZURE_DEVOPS_PAT` 環境變數
