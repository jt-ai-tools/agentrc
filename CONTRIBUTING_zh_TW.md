# 貢獻指南 (Contributing)

感謝您對 Agent Init 的貢獻。

此專案已採用 [Microsoft 開源行為準則 (Microsoft Open Source Code of Conduct)](https://opensource.microsoft.com/codeofconduct/)。欲了解更多資訊，請參閱 [行為準則常見問答 (Code of Conduct FAQ)](https://opensource.microsoft.com/codeofconduct/faq/)，若有任何其他問題或建議，請聯繫 [opencode@microsoft.com](mailto:opencode@microsoft.com)。

## 快速開始

1. Fork 並 Clone 此程式庫。
2. 安裝依賴項目：`npm install`
3. 本地建置：`npm run build`
4. 在開啟 PR 之前執行 lint/類型檢查/測試：
   - `npm run lint`
   - `npm run typecheck`
   - `npm run test`

## 開發工作流

- 從 `main` 分支建立一個功能分支 (feature branch)。
- 使用清晰、約定式的提交訊息（例如 `feat: add readiness report`）。
- 保持 PR 專注，並在說明中包含背景上下文。
- 當行為發生變更時，請添加或更新測試。

## 程式碼風格

- CI 中強制執行 ESLint + Prettier。
- 偏好具有清晰類型的小型、可組合函數。

## 回報問題

- 使用 GitHub Issues 提交 Bug 和功能請求。
- 提供重現步驟和預期行為。

## CI 與分支保護 (Branch Protection)

所有 Pull Request 在合併前都必須通過以下必要的狀態檢查：

| 工作項目 (Job) | 驗證內容 |
| --------------------- | ----------------------------------------------- |
| `lint` | ESLint + Prettier (根目錄) |
| `lint-workflows` | 針對所有 `.github/workflows/*.yml` 的 actionlint |
| `lint-extension` | ESLint (vscode-extension) |
| `typecheck` | TypeScript (根目錄) |
| `typecheck-extension` | TypeScript (vscode-extension) |
| `test` | Vitest (Node 20 + 22, ubuntu + windows) |
| `build` | tsup 建置 + CLI 版本斷言 + 擴充功能捆綁 |

要在 GitHub 中配置分支保護規則：

1. 前往 **Settings → Branches → Branch protection rules**。
2. 為 `main` 分支添加規則。
3. 啟用 **Require status checks to pass before merging**。
4. 搜尋並添加上述列出的每個工作項目名稱。
5. 啟用 **Require branches to be up to date before merging**。

## 發佈

當變更合併到 `main` 時，會透過 release-please 自動化發佈。
