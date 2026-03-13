# 策略範例 (Example Policies)

就緒度策略 (Readiness policies) 可以自定義評估哪些標準以及如何評分。這些範例旨在展示量身定制就緒度報告的三種常見方式：

- 將報告縮小到特定的關注點
- 排除不適用於您儲存庫的檢查
- 為希望更嚴格門檻的團隊提高品質標準

## 用法

使用相對路徑 `./` 並透過 `--policy` 傳遞策略檔案：

```sh
agentrc readiness --policy ./examples/policies/ai-only.json
agentrc readiness --policy ./examples/policies/strict.json
```

可以鏈接多個策略（以逗號分隔）：

```sh
agentrc readiness --policy ./examples/policies/ai-only.json,./my-overrides.json
```

當策略被鏈接時，後面的策略可以進一步禁用檢查或覆蓋前面策略的元數據。常見的模式是從廣泛的基準策略開始，然後在上方疊加一個小型的儲存庫特定覆蓋。

## 包含的策略

| 檔案 | 目的 |
| ----------------------- | ------------------------------------------------------------------------------------------------------- |
| `ai-only.json`          | 禁用儲存庫健康標準，使報告專注於 AI 工具就緒度 |
| `repo-health-only.json` | 禁用 AI 工具標準和 `agents-doc` 額外項目，使報告專注於核心儲存庫健康 |
| `strict.json`           | 設置 100% 的通過率門檻並提高所選標準的影響力 |

## 選擇策略

當您想衡量儲存庫對 AI 輔助開發的就緒程度，而不混入一般的工程衛生（Engineering Hygiene）時，請使用 `ai-only.json`。

當您想要進行傳統的儲存庫品質檢查，並忽略 AI 特定設置時，請使用 `repo-health-only.json`。

當您想要預設的就緒度模型，但整體門檻不接受部分分數，且對所選檢查有更強的權重時，請使用 `strict.json`。
