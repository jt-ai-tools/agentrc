# AgentRC — AI 儲存庫設定

直接在 VS Code 中，為您的儲存庫做好 AI 輔助開發的準備。

## 開始使用

開啟指令面板 (`Cmd+Shift+P` / `Ctrl+Shift+P`) 並搜尋 **AgentRC** —— 或點擊活動列（Activity Bar）中的 **AgentRC** 圖示從側邊欄開始。

第一次使用？執行 **AgentRC: 開始使用 (Get Started)**（或從「歡迎」分頁開啟導覽），進行引導式的 5 步設定。

## 功能

### 分析儲存庫 (Analyze Repository)

偵測語言、框架、套件管理器和單一儲存庫（monorepo）結構。結果會填入側邊欄的**分析 (Analysis)** 樹狀檢視中。

`AgentRC: 分析儲存庫 (Analyze Repository)`

### AI 就緒性評估 (AI Readiness Assessment)

針對分為**儲存庫健康狀況 (Repo Health)** 和 **AI 設定 (AI Setup)** 的 **9 大支柱**對您的儲存庫進行評分，成熟度等級從功能性 (1) 到自主性 (5)。

- 具有深色/淺色主題的互動式 HTML 報告
- 在**就緒性 (Readiness)** 樹狀檢視中深入查看各項準則
- 帶有每項準則證據的通過/失敗圖示

`AgentRC: AI 就緒性報告 (AI Readiness Report)`

### 產生指令 (Generate Instructions)

使用 Copilot SDK 建立 AI 指令檔案。選擇您的格式：

- **copilot-instructions.md** — GitHub Copilot 的原生格式
- **AGENTS.md** — 儲存庫根目錄中更廣泛的代理程式格式

對於單一儲存庫，選擇特定區域以產生具有 `applyTo` 範圍限定的區域指令檔案。

`AgentRC: 產生 Copilot 指令 (Generate Copilot Instructions)`

### 產生配置 (Generate Configs)

根據您的專案調校，設定 MCP 伺服器 (`.vscode/mcp.json`) 和 VS Code 設定 (`.vscode/settings.json`)。

`AgentRC: 產生配置 (Generate Configs)`

### 評估指令 (Evaluate Instructions)

透過使用評審模型比較有/無指令的情況，衡量指令對 AI 回應的改進程度。結果會顯示在 VS Code 內部的互動式檢視器中。

`AgentRC: 執行評估 (Run Eval)` · `AgentRC: 搭建評估配置 (Scaffold Eval Config)`

### 初始化儲存庫 (Initialize Repository)

一個指令即可完成分析、產生指令並建立配置：

`AgentRC: 初始化儲存庫 (Initialize Repository)`

### 建立提取請求 (Create Pull Request)

直接從 VS Code 提交 AgentRC 產生的檔案並開啟 PR。支援 **GitHub** 和 **Azure DevOps** 儲存庫 —— 系統會從您的 git 遠端自動偵測平台。

`AgentRC: 建立提取請求 (Create Pull Request)`

## 側邊欄視圖

點擊 **AgentRC** 活動列圖示可開啟兩個樹狀檢視：

| 視圖          | 內容                                                                                          |
| ------------- | --------------------------------------------------------------------------------------------- |
| **分析 (Analysis)**  | 語言、框架、單一儲存庫區域 —— 帶有指令和配置的操作按鈕                                        |
| **就緒性 (Readiness)** | 成熟度等級、支柱群組（儲存庫健康狀況 / AI 設定）、帶有證據工具提示的準則通過/失敗狀態          |

當尚未載入數據時，兩個視圖都會顯示帶有操作按鈕的歡迎畫面。

## 設定

| 設定                  | 預設值              | 描述                                               |
| --------------------- | ------------------- | -------------------------------------------------- |
| `agentrc.model`       | `claude-sonnet-4.5` | 產生時使用的預設 Copilot 模型                      |
| `agentrc.autoAnalyze` | `false`             | 在開啟工作區時自動分析儲存庫                       |

## 系統要求

- **VS Code 1.100.0+**
- **GitHub Copilot Chat 擴充功能**（提供 Copilot CLI）
- **Copilot 驗證** — 在您的終端機執行 `copilot` → `/login`
- **GitHub 帳戶** — 用於建立 GitHub PR（透過 VS Code 驗證）
- **Microsoft 帳戶** _(選填)_ — 用於建立 Azure DevOps PR（透過 VS Code 驗證）

## 相關連結

- [GitHub 上的 AgentRC CLI](https://github.com/microsoft/agentrc)
- [貢獻指南 (Contributing Guide)](https://github.com/microsoft/agentrc/blob/main/CONTRIBUTING_zh_TW.md)
- [授權條款 (MIT)](https://github.com/microsoft/agentrc/blob/main/LICENSE)
