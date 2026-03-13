# AgentRC 外掛程式系統

統一的外掛程式政策系統允許命令式（程式碼）外掛程式和宣告式（JSON）政策透過同一個引擎執行。

## 架構

```
政策配置 (JSON) ──┐
                  ├─→ compilePolicyConfig() ──→ 政策外掛 (PolicyPlugin)
模組政策 (.ts) ──┘

內建準則 ──→ buildBuiltinPlugin() ──→ 政策外掛 (PolicyPlugin)

PolicyPlugin[] ──→ executePlugins() ──→ 引擎報告 (EngineReport)
                                          └─→ engineReportToReadiness() ──→ 就緒性報告 (ReadinessReport)
```

### 管道階段 (Pipeline Stages)

引擎透過 5 個確定性階段執行外掛程式：

1. **偵測 (Detect)** — 所有偵測器發出關於儲存庫狀態的信號
2. **偵測後 (afterDetect)** — 鉤子（Hooks）可以透過修補程式（patches）修改/增加/刪除信號
3. **建議前 (beforeRecommend)** — 在提出建議之前調整信號的最後機會
4. **建議 (Recommend)** — 建議器根據信號發出可執行的建議
5. **建議後 (afterRecommend)** — 鉤子可以透過修補程式修改/增加/刪除建議

鉤子完成後，引擎會解決 `supersedes`（取代）衝突並計算分數。

## 外掛程式合約

```typescript
type PolicyPlugin = {
  meta: PluginMeta;
  detectors?: Detector[];
  afterDetect?: (signals, ctx) => Promise<SignalPatch | undefined>;
  beforeRecommend?: (signals, ctx) => Promise<SignalPatch | undefined>;
  recommenders?: Recommender[];
  afterRecommend?: (recs, signals, ctx) => Promise<RecommendationPatch | undefined>;
  onError?: (error, stage, ctx) => boolean;
};
```

### 信任模型

| 信任層級           | 來源                           | 能力                                         |
| ------------------ | ------------------------------ | -------------------------------------------- |
| `trusted-code`     | `.ts`/`.js` 模組或內建功能     | 完整生命週期鉤子，執行任意程式碼             |
| `safe-declarative` | `.json` 政策檔案               | 禁用、覆寫元數據，僅限靜態檢查               |

### 不可變修補程式 (Immutable Patches)

所有鉤子階段都回傳修補程式物件，而不是直接變更陣列：

```typescript
type SignalPatch = {
  add?: Signal[];
  remove?: string[]; // 要刪除的 ID
  modify?: Array<{ id: string; changes: Partial<Signal> }>;
};
```

引擎會套用修補程式並自動記錄來源（`origin.modifiedBy`）。

### 衝突解決

在建議上使用 `supersedes` 進行顯式衝突解決：

```typescript
const rec: Recommendation = {
  id: "strict-lint-fix",
  signalId: "lint-config",
  impact: "high",
  message: "使用更嚴格的 lint 規則",
  supersedes: ["basic-lint-fix"], // 取代此建議
  origin: { addedBy: "strict-policy" }
};
```

循環取代鏈將刪除所有涉及的建議。

## 編寫外掛程式

有兩種編寫 API：

- **`PolicyConfig`** — 高階編寫 API。您編寫一個包含 `criteria`/`extras`/`thresholds` 的配置物件，引擎會在幕後將其編譯為 `PolicyPlugin`。這是大多數案例推薦的方法。
- **`PolicyPlugin`** — 低階基於鉤子的 API（如上面的外掛程式合約部分所示）。僅當您需要直接控制 5 階段管道鉤子時才使用此方法。

### 命令式外掛程式 (透過 PolicyConfig 使用 TypeScript)

```typescript
// my-policy.ts
import type { PolicyConfig } from "agentrc/services/policy";

const policy: PolicyConfig = {
  name: "my-custom-policy",
  criteria: {
    disable: ["env-example"], // 跳過此檢查
    override: {
      "lint-config": { title: "自定義 Lint 標題", impact: "medium" }
    },
    add: [
      {
        id: "custom-check",
        title: "我的自定義檢查",
        pillar: "code-quality",
        level: 2,
        scope: "repo",
        impact: "high",
        effort: "low",
        check: async (ctx) => {
          // 您的檢查邏輯
          return { status: "pass", reason: "一切正常" };
        }
      }
    ]
  }
};

export default policy;
```

### 宣告式政策 (JSON)

```json
{
  "name": "strict-policy",
  "criteria": {
    "disable": ["env-example"],
    "override": {
      "lint-config": { "impact": "high" }
    }
  },
  "thresholds": {
    "passRate": 0.9
  }
}
```

## 使用政策

### CLI

```bash
# 單個政策
agentrc readiness --policy ./my-policy.json

# 多個政策（逗號分隔）
agentrc readiness --policy ./base.json,./strict.json

# npm 套件政策
agentrc readiness --policy @org/agentrc-policy-strict
```

### 配置檔案

在 `agentrc.config.json` 中：

```json
{
  "policies": ["./policies/strict.json"]
}
```

配置檔案還支援單一儲存庫（monorepo）配置的 `areas` 和 `workspaces` —— 參見 [examples/agentrc.config.json](../examples/agentrc.config.json_zh_TW.json) 以取得完整範例。

基於安全考量，從配置檔案來源的政策僅限於 JSON。

## 評分

引擎根據最終建議計算分數：

- 每個建議都有一個 `impact`（影響力）：critical (5), high (4), medium (3), low (2), info (0)
- 分數 = 1 - (總扣分 / 最大可能權重)
- 最大權重 = 偵測到的信號數量 × 5（狀態為 "not-detected" 的信號不計入）
- 等級：A ≥ 0.9, B ≥ 0.8, C ≥ 0.7, D ≥ 0.6, F < 0.6

## 影子模式 (Shadow Mode)

> **狀態：開發中。** 影子模式基礎設施（`compareShadow`, `writeShadowLog`）已實作，但尚未接入正式生產就緒路徑。`.agentrc-cache/shadow-mode.log` 檔案在正常的 `agentrc readiness` 執行期間**不會**被寫入。

影子模式旨在預設啟用之前，針對舊系統驗證新的外掛程式引擎。接入後，它將並行執行兩條路徑並記錄差異：

```typescript
import { compareShadow, writeShadowLog } from "agentrc/services/policy/shadow";

// 比較舊版 ReadinessReport 與新的 EngineReport
const result = compareShadow(legacyReport, engineReport, {
  repoPath: "/path/to/repo",
  useNewEngine: false // 預設使用舊版輸出
});

// 將任何差異寫入 .agentrc-cache/shadow-mode.log
if (result.discrepancies.length > 0) {
  await writeShadowLog(repoPath, result.discrepancies);
}
```

若要立即與舊版路徑並行執行外掛程式引擎，請將 `shadow: true` 傳遞給 `runReadinessReport`。這會將引擎信號、建議和分數填入 `report.engine`，但不會取代舊版輸出：

```typescript
const report = await runReadinessReport({ repoPath, shadow: true });
// report.engine 包含：signals, recommendations, policyWarnings, score, grade
```
