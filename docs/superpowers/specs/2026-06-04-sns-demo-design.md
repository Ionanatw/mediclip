# CareDoc SNS 試玩版 — 設計 Spec

> 日期：2026-06-04 ｜ 狀態：APPROVED（憑證已提供）
> 來源決策：CLAUDE.md、docs/handoff.md、docs/CareDoc-PRD-v0.3.md + 本次 brainstorming

## 1. 目標

讓人在社群點連結後，3 分鐘體驗 CareDoc 核心價值（上傳醫療單 → AI 整理 → 結果總覽 + 藥品卡 + 行事曆），並把進階功能鎖住導流到 App 下載。

## 2. 已拍板決策

| 決策 | 選擇 | 理由 |
|------|------|------|
| 技術棧 | **Next.js（App Router）+ Vercel** | API route 內建後端代理，藏 Claude key；符合 CLAUDE.md |
| 服務 | **接真實服務** | 真 Claude API + Supabase（已提供憑證） |
| Email gate | **輕量捕獲** | 輸入 email → 後端查 `sns_usage` 限 1 次，零摩擦衝轉換 |
| 藥品卡 | **Claude 輸出 + 前端生 SVG** | 食藥署即時串接列為下一輪 |

## 3. 架構（4 個單元）

### 3.1 前端（Next.js client，單頁步驟流）
狀態機：`landing → gate → upload → processing → results`
- **Landing**：Hero 價值主張 + 「開始整理」
- **EmailGate**：email 輸入 → 呼叫 `/api/check-email`
- **Uploader**：相簿選圖（≤3 張，`accept="image/*"`，不支援拍照）+ 補充文字欄；前端壓縮縮放圖片
- **Processing**：步驟進度動畫（辨識中 → 結構化 → 整理完成）
- **Results**：結果總覽 + 藥品識別卡（SVG + 專業版注意事項）+ 行事曆列表（僅檢視）+ 鎖住功能遮罩 + 最後 CTA
- 全域：底部固定免責聲明「⚠️ AI 輔助整理，請與原始醫療文件核對」

### 3.2 API routes（Next.js server，取代 Supabase Edge Function）
- `POST /api/check-email`
  - 入：`{ email }`
  - 用 `SUPABASE_SERVICE_ROLE_KEY`（僅伺服器端）查 `sns_usage`
  - email 沒用過 → 寫入並回 `{ allowed: true }`；用過 → `{ allowed: false }`
- `POST /api/process`
  - 入：`{ images: [{type, data(base64)}], text }`
  - 伺服器端帶 `ANTHROPIC_API_KEY` + `anthropic-version: 2023-06-01` 呼叫 Claude（model `claude-sonnet-4-20250514`，max_tokens 4000）
  - **不記錄 request body**；解析 Claude 回傳 → 抽出 JSON → 回前端
  - 非 JSON / 失敗 → 重試 1 次 → 回友善錯誤

### 3.3 Supabase（只做一件事）
只用 Postgres 存 `sns_usage`。不碰醫療資料、不碰照片。
```sql
create table if not exists sns_usage (
  id uuid default gen_random_uuid() primary key,
  email text unique not null,
  used_at timestamptz default now()
);
```
> 此表需在 Supabase SQL Editor 執行一次（唯一手動步驟）。

### 3.4 SVG 藥品卡產生器（前端 util）
依 Claude 輸出的 `shape` / `color` 對照 handoff §5 規則表生 SVG：
- 形狀：圓形→`<circle>`、橢圓→`<ellipse>`、膠囊→雙色`<rect rx>`、粉包→`<rect>`+虛線
- 顏色：白 `#F8F8F5`、粉紅 `#F5D0C8`、黃 `#FDF8EC`、綠 `#D0E8D4`、膚 `#F0E8D8`

## 4. Claude 輸出契約

沿用 handoff §4 JSON schema，**medication 內新增** `shape`、`color` 兩欄供生 SVG。System prompt 要求只回 JSON。其餘欄位（schedule / precautions / lab_tests / symptoms / doctor_responses / followup_questions / lifestyle_notes / warnings）照舊。

`followup_questions` 這一輪**只顯示為提示**（「可在 App 補完」），不做互動補完迴圈，控制範圍。

## 5. 資料流與隱私

照片只在瀏覽器記憶體 → base64 經 API route 過路給 Claude → 結構化 JSON 回前端渲染 → session 結束全消失。
- 照片不進任何 Storage
- `/api/process` 不 log request body
- Supabase 只存 email
- Claude API 處理過路不留（Anthropic API 政策不拿 API 輸入訓練）

## 6. 設計系統（handoff §3）

- 色彩：鼠尾草綠系 CSS 變數（主色 `#7FB69E` / 深綠 `#5A9A7D` / 背景 `#FDFBF7` / 警告 `#D4816B` / 用藥 `#9B8BBF` / 行程 `#7BA7C9`）
- 字體：Noto Sans TC，基礎字級 19px
- 卡片圓角 16–18px、按鈕圓角 14px、陰影 `0 2px 12px rgba(120,100,80,0.07)`
- 主按鈕漸層 `linear-gradient(135deg,#7FB69E,#5A9A7D)`

## 7. 錯誤處理

| 情境 | 行為 |
|------|------|
| email 已用過 | 溫暖訊息 + 導流下載 App |
| Claude 非 JSON / 失敗 | 重試 1 次 → 友善錯誤頁 |
| 圖片過大 / >3 張 | 前端壓縮縮放 + 擋第 4 張 |
| 網路逾時 | 顯示重試 |

## 8. 範圍（YAGNI）

**做**：landing、email gate、upload、processing、結果總覽、藥品卡（SVG + 專業版）、行事曆列表（僅檢視）、鎖住功能遮罩（.ics/白話版/海報）、最後 CTA、免責聲明。

**延後**：真實食藥署 API、實際 .ics 匯出、白話版翻譯、海報生圖、快樂花園、Checklist、歷史、滾動更新、RevenueCat、付費。

## 9. 測試

- `/api/process` 的 JSON 抽取 / 重試邏輯：單元測試（mock Claude 回應）
- `/api/check-email` 的限 1 次邏輯：單元測試（mock Supabase）
- SVG 產生器：對各形狀/顏色 snapshot
- 端對端：用真 key 手動跑一次完整流程驗證

## 10. 環境變數（`.env.local`，已 gitignore）

```
ANTHROPIC_API_KEY=...
SUPABASE_URL=https://camebgyifszoroqfulkp.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
```
Supabase 專案：`mediclip`（ref `camebgyifszoroqfulkp`，Sydney）。
