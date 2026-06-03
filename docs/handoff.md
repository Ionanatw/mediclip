# CareDoc — Claude Code 開發交接包

> 這份文件包含所有在 Claude.ai 對話中做出的設計決策、技術規格、API 設定。
> Claude Code 拿到這份就能直接開工，不需要重新問任何問題。
> 
> 完整 PRD：CareDoc-PRD-v0.3.md
> 完整技術棧：CareDoc-技術棧建議書.md

---

## 0. 一句話

拍照上傳醫療單，AI 幫你秒懂、秒整理、秒提醒。開源照護懶人包 App。

---

## 1. 開發順序

**Phase 1：SNS 試玩版（Web）** ← 先做這個
**Phase 2：App（Expo React Native）**

---

## 2. SNS 試玩版規格

### 技術選型
- 純 HTML/React 單頁應用（或 Expo Web）
- 部署到 Vercel
- 後端：Supabase Edge Function 轉接 Claude API
- 不需要 expo-camera、expo-sqlite 等原生模組

### 使用流程
```
使用者從 SNS 貼文點連結
  → 輸入 email 註冊（同一 email 限 1 次 AI 整理）
  → 從相簿選擇照片（最多 3 張，不支援拍照）
  → 可選：補充文字說明
  → 點「開始 AI 整理」
  → 等待 10-20 秒（顯示步驟進度）
  → 結果頁：總覽 + 藥品識別卡（含 SVG + 專業版注意事項）+ 行事曆（僅檢視）
  → 鎖住功能顯示導流 CTA → 下載 App
```

### 開放功能
- ✅ email 註冊（Supabase Auth）
- ✅ 從相簿選擇照片上傳（`<input type="file" accept="image/*">`）
- ✅ 補充文字說明欄位
- ✅ AI 整理（Claude API via Edge Function）
- ✅ 結果總覽（用藥、行程、注意事項、症狀、檢驗）
- ✅ 藥品識別卡（SVG 外觀圖 + 食藥署資料 + 專業版注意事項）
- ✅ 行事曆檢視（列表格式）

### 鎖住功能（顯示模糊遮罩 + CTA）
- 🔒 .ics 行事曆匯出 →「下載 App 一鍵加入手機行事曆」
- 🔒 白話版注意事項 → 模糊遮罩 +「下載 App 看白話翻譯」
- 🔒 照護海報 → 預覽模糊 +「下載 App 列印海報」
- ❌ 快樂花園、Checklist、滾動更新、歷史紀錄 → 不出現

### 隱私
- 照片不上傳到任何 Storage，只在瀏覽器記憶體中處理
- Edge Function 不記錄 request body
- Session 結束全部消失，不儲存任何醫療資料
- Supabase 只存 email（Auth 表）

---

## 3. 設計系統

### 色彩（療癒鼠尾草綠系）
```css
--bg: #FDFBF7;        /* 主背景：暖奶油 */
--bg2: #F5F1EA;       /* 次背景 */
--bg3: #EDE9E0;       /* 邊框、分隔線 */
--card: #FFFFFF;      /* 卡片 */
--text: #3D3530;      /* 主文字 */
--text2: #706860;     /* 次文字 */
--text3: #A09890;     /* 輔助文字 */
--green: #7FB69E;     /* 主色：鼠尾草綠 */
--greenBg: #EDF5F0;   /* 綠底 */
--greenDk: #5A9A7D;   /* 深綠（CTA、標題） */
--coral: #D4816B;     /* 警告色 */
--coralBg: #FDF0EC;   /* 警告底 */
--blue: #7BA7C9;      /* 行程色 */
--blueBg: #EDF3F9;
--amber: #C9A862;     /* 提示色 */
--amberBg: #FDF8EC;
--purple: #9B8BBF;    /* 用藥色 */
--purpleBg: #F3F0F8;
```

### 字體
- 主字體：Noto Sans TC（400, 500, 600, 700, 900）
- 基礎字級：19px（比一般 App 大，照護者友善）
- 標題：22-28px
- 按鈕：18-20px

### 元件規格
- 卡片圓角：16-18px
- 按鈕圓角：14px
- 陰影：`0 2px 12px rgba(120,100,80,0.07)`
- 主按鈕：`linear-gradient(135deg, #7FB69E, #5A9A7D)` + `box-shadow: 0 4px 16px rgba(90,154,125,0.3)`

---

## 4. AI System Prompt

用於 Claude API 的 system prompt，SNS 版和 App 版共用：

```
你是 CareDoc 醫療文件結構化助手。使用者會上傳醫療文件（衛教單、處方箋、回診單、手寫筆記等），也可能附上語音轉文字內容。

任務：
1. 辨識文件內容，提取所有醫療資訊
2. 結構化為以下 JSON 格式
3. 資訊不完整時在 followup_questions 列出補充問題（最多3題），每題附2-4個選項

請只回傳 JSON，不要其他文字或 markdown。

{
  "document_type": "衛教單|處方箋|回診單|檢驗單|手寫筆記|轉診單|語音紀錄|其他",
  "summary": "一句話摘要",
  "medication": [{
    "name_zh": "中文藥名",
    "name_en": "英文藥名",
    "dosage": "劑量",
    "frequency": "頻率",
    "duration": "天數",
    "route": "口服|注射|外用",
    "notes": "注意事項"
  }],
  "schedule": [{
    "date": "YYYY-MM-DD",
    "time": "HH:MM",
    "event": "事件描述",
    "location": "地點",
    "notes": "備註"
  }],
  "precautions": [{
    "category": "飲食|活動|傷口|用藥|其他",
    "description": "描述",
    "severity": "必做|注意|知道就好"
  }],
  "lab_tests": [{
    "name": "檢驗項目",
    "name_en": "英文名",
    "date": "YYYY-MM-DD",
    "fasting": true|false
  }],
  "symptoms": [{
    "description": "症狀描述",
    "category": "分類"
  }],
  "doctor_responses": [{
    "question": "問題",
    "answer": "醫師回覆",
    "status": "已解決|待觀察|待確認"
  }],
  "followup_questions": [{
    "question": "需要補充的問題",
    "options": ["選項1", "選項2", "選項3"]
  }],
  "lifestyle_notes": [{
    "icon": "emoji",
    "title": "標題",
    "description": "說明"
  }],
  "warnings": ["重要警示訊息"]
}
```

### Claude API 呼叫方式
```javascript
const response = await fetch("https://api.anthropic.com/v1/messages", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    model: "claude-sonnet-4-20250514",
    max_tokens: 4000,
    system: SYSTEM_PROMPT,
    messages: [{
      role: "user",
      content: [
        // 圖片（base64）
        { type: "image", source: { type: "base64", media_type: "image/jpeg", data: base64Data } },
        // 補充文字
        { type: "text", text: "照護者補充：..." },
        // 指令
        { type: "text", text: "請辨識並結構化以上所有醫療文件內容。" }
      ]
    }]
  })
});
```

---

## 5. 藥品識別卡 — 藥事資料庫串接

### POC 必做的 3 個資料庫

**A1: 藥品許可證**
```
GET https://data.fda.gov.tw/opendata/exportDataList.do?method=ExportData&InfoId=36&logType=3
```
用途：藥名 → 成分、適應症、許可證字號

**B1: 藥品外觀**
```
GET https://data.fda.gov.tw/opendata/exportDataList.do?method=ExportData&InfoId=39&logType=3
```
用途：藥名 → 顏色、形狀、尺寸、刻痕 → 自動生成 SVG

**D1: 藥品仿單查詢**
```
https://mcp.fda.gov.tw/
```
用途：取得 4.3 禁忌 + 4.4 注意事項 + 4.5 交互作用 → 專業版免費顯示

### SVG 藥品外觀繪製規則

根據 B1 資料的顏色和形狀，自動生成 SVG：

| 形狀 | SVG 元素 |
|------|---------|
| 圓形錠 | `<circle>` |
| 橢圓形膜衣錠 | `<ellipse>` |
| 膠囊 | `<rect rx="50%">` 兩色 |
| 粉包 | `<rect>` + 虛線 |

| 顏色描述 | fill 值 |
|---------|---------|
| 白色 | #F8F8F5 |
| 粉紅色 | #F5D0C8 |
| 黃色 | #FDF8EC |
| 綠色 | #D0E8D4 |
| 膚色 | #F0E8D8 |

### 注意事項分級

| 版本 | 來源 | 付費 |
|------|------|------|
| 專業版 | 仿單原文 4.3+4.4+4.5 | 免費 |
| 白話版 | AI 翻譯 + 🔴🟡🟢 嚴重度 | 月費 $149 專屬 |

---

## 6. Supabase 設定

### 用途（僅限）
- Auth：email 登入
- Edge Functions：Claude API 轉接站
- Database：帳號 + 付費狀態（不存醫療資料）

### Edge Function: ai-process

```typescript
// supabase/functions/ai-process/index.ts
// 接收前端的圖片 + 文字，轉發給 Claude API，回傳結果
// 不記錄 request body，不儲存任何內容

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { images, text, voice } = await req.json()
  
  const content = []
  images?.forEach(img => {
    content.push({ type: "image", source: { type: "base64", media_type: img.type, data: img.data } })
  })
  if (text) content.push({ type: "text", text: `照護者補充：${text}` })
  if (voice) content.push({ type: "text", text: `語音紀錄：${voice}` })
  content.push({ type: "text", text: "請辨識並結構化以上所有醫療文件內容。" })

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": Deno.env.get("ANTHROPIC_API_KEY"),
      "anthropic-version": "2023-06-01"
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4000,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content }]
    })
  })

  const data = await response.json()
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" }
  })
})
```

### Database Tables（Supabase）

```sql
-- 只存帳號和付費，不存醫療資料
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT,
  plan TEXT DEFAULT 'free', -- free | light | unlimited
  sessions_remaining INT DEFAULT 2,
  poster_unlocked BOOLEAN DEFAULT FALSE,
  reminder_subscribed BOOLEAN DEFAULT FALSE,
  is_charity BOOLEAN DEFAULT FALSE,
  charity_sessions INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SNS 試玩版用量追蹤
CREATE TABLE sns_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE,
  used_at TIMESTAMPTZ DEFAULT NOW()
);

-- RevenueCat webhook 紀錄
CREATE TABLE revenue_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  event_type TEXT, -- purchase | renewal | cancellation
  product_id TEXT,
  price DECIMAL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 7. 定價與 RevenueCat

### 三層定價

| | 免費 | 輕量 $30/3 時段 | 吃到飽 $149/月 |
|---|---|---|---|
| AI 整理 | 2 次 | 3 次 | 15 次/月 |
| 藥品識別卡 | ✅ | ✅ | ✅ |
| 專業版注意事項 | ✅ | ✅ | ✅ |
| 白話版注意事項 | 🔒 模糊 | 🔒 模糊 | ✅ 月費專屬 |
| 滾動更新 | ❌ | ✅ | ✅ |
| 快樂花園 | ✅ | ✅ | ✅ |

### 加購

| 產品 | RevenueCat 類型 | 價格 |
|------|----------------|------|
| 儲值包 3 時段 | Consumable | $30 TWD |
| 月費吃到飽 | Auto-renewable | $149 TWD/月 |
| 照護海報 | Non-consumable | $49 TWD |
| 推播提醒 | Auto-renewable | $29 TWD/月 |

### 照護時段計費邏輯

```javascript
// 24 小時內算同一時段，不重複扣次
function shouldDeductSession(lastSessionStart) {
  if (!lastSessionStart) return true;
  const hoursSince = (Date.now() - lastSessionStart) / (1000 * 60 * 60);
  return hoursSince >= 24;
}
```

---

## 8. .ics 行事曆生成

```javascript
function generateICS(events) {
  let ics = "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CareDoc//POC//ZH-TW\nCALSCALE:GREGORIAN\n";
  events.forEach((e, i) => {
    if (!e.date) return;
    const d = e.date.replace(/-/g, "");
    const t = e.time ? e.time.replace(":", "") + "00" : "120000";
    ics += `BEGIN:VEVENT\nUID:caredoc-${i}-${d}@app\n`;
    ics += `DTSTART;TZID=Asia/Taipei:${d}T${t}\n`;
    ics += `SUMMARY:🏥 ${e.event}\n`;
    ics += `DESCRIPTION:${e.location || ""}\\n${e.notes || ""}\n`;
    ics += `LOCATION:${e.location || ""}\n`;
    ics += `BEGIN:VALARM\nTRIGGER:-PT60M\nACTION:DISPLAY\nDESCRIPTION:1hr: ${e.event}\nEND:VALARM\n`;
    ics += `BEGIN:VALARM\nTRIGGER:-P1D\nACTION:DISPLAY\nDESCRIPTION:明天: ${e.event}\nEND:VALARM\n`;
    ics += "END:VEVENT\n";
  });
  return ics + "END:VCALENDAR";
}
```

---

## 9. 快樂花園系統（App 獨佔，SNS 版不含）

### 三棵樹

| # | 品種 | 解鎖條件 |
|---|------|---------|
| 1 | 🌸 櫻花樹 | 註冊即可 |
| 2 | 🌿 茶樹 | 第 1 棵長成 |
| 3 | 🍊 橘子樹 | 第 2 棵長成 |

### 成長：200 陽光 = 大樹（約 40-50 天）
### 每日上限：15 陽光
### 永遠不會死亡

### 品種 config 格式
```json
{
  "id": "sakura",
  "name_zh": "櫻花樹",
  "unlock_condition": "register",
  "stages": {
    "seed": { "emoji": "🌰", "svg": "sakura_seed.svg", "threshold": 0 },
    "sprout": { "emoji": "🌱", "svg": "sakura_sprout.svg", "threshold": 20 },
    "sapling": { "emoji": "🌿", "svg": "sakura_sapling.svg", "threshold": 60 },
    "growing": { "emoji": "🪴", "svg": "sakura_growing.svg", "threshold": 120 },
    "tree": { "emoji": "🌸", "svg": "sakura_tree.svg", "threshold": 200 }
  }
}
```

---

## 10. 關鍵約束（開發時必須遵守）

1. **隱私**：伺服器不碰、不存、不看醫療資料。所有醫療資料僅存手機本地
2. **安全**：每個輸出頁底部必須有「⚠️ AI 輔助整理，請與原始醫療文件核對」
3. **專業版注意事項免費**：用藥安全資訊不放付費牆後
4. **白話版注意事項**：月費 $149 專屬，其他方案顯示模糊遮罩
5. **海報生圖**：加購 $49 才能使用，DALL-E 成本獨立
6. **快樂花園**：完全免費，完全離線，不耗 API
7. **SNS 版**：不支援拍照，只能相簿選擇；需 email 註冊；每 email 限 1 次
8. **植物不會死**：荒廢只會垂頭/打瞌睡，永不消失

---

## 11. 參考檔案清單

| 檔案 | 內容 |
|------|------|
| CareDoc-PRD-v0.3.md | 完整 PRD（618 行） |
| CareDoc-技術棧建議書.md | 技術選型 + 定價 + 開發流程 |
| CareDoc-App-Prototype.html | 13 個畫面原型圖 |
| CareDoc-App-Description.md | App 產品描述 |
| CareDoc.jsx | Web App React 原始碼（可當 SNS 版起點） |
| CareDoc-化療流程說明-v2.html | 實際產出範例（化療流程） |
| CareDoc-用藥識別卡.html | SVG 藥品外觀圖範例 |
| caredoc-回診行事曆-v2.ics | .ics 輸出範例 |
| caredoc-test-data-v2.json | 結構化資料 JSON 範例 |
| caredoc-poc-architecture.html | 架構圖 |

---

## 12. 開工指令

SNS 試玩版的開發步驟：

```bash
# 1. 建立專案
mkdir caredoc-sns && cd caredoc-sns
npm init -y
npm install next react react-dom @supabase/supabase-js

# 2. 建立 Supabase 專案
npx supabase init
# 設定 Edge Function: ai-process

# 3. 環境變數
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
ANTHROPIC_API_KEY=your_key

# 4. 核心頁面
# pages/index.tsx — 首頁 + email 註冊
# pages/upload.tsx — 上傳 + AI 整理
# pages/results.tsx — 結果 + 藥品卡 + 行事曆
# pages/cta.tsx — 導流下載 App

# 5. 部署
npx vercel
```

---

*CareDoc 開發交接包 ｜ 2026-06-01 ｜ 從 Claude.ai 交接到 Claude Code*
