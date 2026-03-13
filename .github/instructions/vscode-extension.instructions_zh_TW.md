---
description: "當在 vscode-extension/ 中開發 VS Code 擴充功能時使用。涵蓋建置、Git 整合、路徑別名以及擴充功能特定模式。"
applyTo: "vscode-extension/**"
---

# VS Code 擴充功能開發

該擴充功能位於 `vscode-extension/` 中，並在 VS Code 中呈現 AgentRC CLI 指令。

## 建置

```sh
cd vscode-extension
node esbuild.mjs         # CJS 組合（bundle） → out/extension.js
node esbuild.mjs --watch  # 監看模式
npx tsc --noEmit          # 型別檢查
```

輸出格式為 CommonJS（不像 CLI 是 ESM）。使用 esbuild 進行打包，而非 tsup。

## 透過路徑別名重用服務

擴充功能透過 `agentrc/*` 路徑別名匯入 CLI 服務：

```typescript
// vscode-extension/src/services.ts — 重新匯出層
export { analyzeRepo } from "agentrc/services/analyzer.js";
```

這之所以可行，是因為 `tsconfig.json` 將 `"agentrc/*": ["../src/*"]` 進行了映射，且 esbuild 在打包時會對其進行解析。切勿在擴充功能中重複寫入 CLI 服務邏輯。

## Git 整合

- 使用內建的 `vscode.git` 擴充功能 API —— **絕不匯入或打包 `simple-git`**。
- 擴充功能宣告了 `"extensionDependencies": ["vscode.git"]`。
- 型別（Types）是從上游 VS Code 儲存庫取得並放在 `src/git.d.ts`。
- `gitUtils.ts` 會尋找最深層匹配的儲存庫，以支援單一儲存庫（monorepo）。

## 指令模式

`vscode-extension/src/commands/` 中的指令是精簡的封裝：

1. 呼叫來自 `services.ts` 的共享服務
2. 更新樹狀提供者（tree providers）/ 狀態列
3. 為結果顯示 VS Code 通知

## 與 CLI 的主要差異

| 面向          | CLI           | 擴充功能       |
| ------------- | ------------- | -------------- |
| 模組格式      | ESM           | CommonJS       |
| 打包工具      | tsup          | esbuild        |
| Git 程式庫    | simple-git    | vscode.git API |
| 輸出          | stdout/stderr | VS Code UI     |
