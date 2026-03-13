# AgentRC 範例 (AgentRC Examples)

此資料夾是一組小型、獨立的範例，涵蓋了最常見的 AgentRC 工作流程。當您想引導配置、評估儲存庫指南或自定義就緒度評分時，請將其作為參考。

## 此處內容

- `agentrc.config.json` 顯示了一個具有工作區（workspaces）、區域（areas）和鏈接就緒度策略的 monorepo 樣式專案配置。
- `agentrc.eval.json` 顯示了一個用於針對一小組提示（prompts）測試指令品質的起始評估檔案。
- `policies/` 包含您可以直接使用或複製並改編的示例就緒度策略。

## 常見工作流程

```bash
# 儲存庫的互動式設置
agentrc init /path/to/repo

# 在生成配置或指令之前檢查儲存庫
agentrc analyze /path/to/repo

# 在終端機中檢查 AI 就緒度
agentrc readiness /path/to/repo

# 生成視覺化就緒度報告
agentrc readiness /path/to/repo --visual

# 在評分就緒度時應用範例策略
agentrc readiness /path/to/repo --policy ./examples/policies/strict.json

# 使用任一命令樣式生成指令
agentrc instructions --repo /path/to/repo
agentrc generate instructions /path/to/repo

# 構建並執行評估 (evals)
agentrc eval --init --repo /path/to/repo
agentrc eval ./examples/agentrc.eval.json --repo /path/to/repo
```

## 如何使用這些範例

如果您想了解 AgentRC 如何看待儲存庫結構，請從 `agentrc analyze` 開始。當您需要對工作區進行建模或定義命名區域時，請使用 `agentrc.config.json` 作為參考，然後使用策略範例來縮小或加強就緒度檢查。

如果您正在調整儲存庫指令，請從 `agentrc eval --init` 開始構建案例，然後將 `agentrc.eval.json` 作為擴展的形狀。包含的檔案刻意保持較小，以便輕鬆適應您自己的提示和期望。

當您想要專用的指令生成工作流程及其區域特定選項時，請使用 `agentrc instructions`。當您偏好用於其他 AgentRC 輸出的共用 `generate` 入口點時，請使用 `agentrc generate instructions`。

## 範例檔案

對於需要區域層級指令生成或各個工作區就緒度追蹤的儲存庫，`agentrc.config.json` 是一個很好的起點。

`agentrc.eval.json` 是一個初學者的評估配置，用於比較儲存庫指令在幫助模型回答專案特定問題方面的效果。

有關所包含就緒度策略的詳細資訊以及如何組合它們，請參閱 `policies/README_zh_TW.md`。
