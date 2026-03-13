---
name: review
description: 執行三個平行的程式碼審查 (Opus、Gemini、Codex)，並將發現結果綜合成優先排序的修正列表
---

執行多模型程式碼審查：

1. 作為三個平行子代理程式，呼叫 `code-review-opus`、`code-review-gemini` 和 `code-review-codex`
2. 交叉評分：讓每位審查者評估其他兩項審查的偽陽性 (false positives) 和遺漏的問題
3. 綜合一份去重後的發現結果列表，按嚴重程度排序（Critical > Major > Minor > Nit）
4. 輸出一個最終的修正列表，包含每個項目的檔案、行號和建議變更
