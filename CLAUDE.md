# CLAUDE.md — CareDoc (mediclip) 開發指引

## 專案
醫療照護懶人包 App。拍照上傳醫療單，AI 秒懂、秒整理、秒提醒。

## 開發順序
1. **SNS 試玩版（Web）** ← 目前階段
2. App（Expo React Native）

## SNS 試玩版技術棧
- Next.js + React（部署 Vercel）
- Supabase Auth（email 註冊）+ Edge Function（Claude API 轉接）
- 不需要 expo-camera、expo-sqlite

## SNS 試玩版功能
### 開放
- email 註冊（同一 email 限 1 次 AI 整理）
- 從相簿選照片（最多 3 張，不支援拍照）
- 補充文字說明
- AI 整理（Claude API via Edge Function）
- 結果總覽（用藥、行程、注意事項）
- 藥品識別卡（SVG 外觀圖 + 專業版注意事項）
- 行事曆檢視（僅檢視）

### 鎖住（模糊遮罩 + CTA 導流 App）
- .ics 匯出、白話版注意事項、照護海報、快樂花園、Checklist

## 隱私（最重要的約束）
- 伺服器不碰、不存、不看醫療資料
- Edge Function 不記錄 request body
- SNS 版完全無狀態，session 結束全消失
- Supabase 只存 email + 付費狀態

## 設計系統
- 療癒鼠尾草綠色系
- 主色 #7FB69E / 深綠 #5A9A7D / 背景 #FDFBF7
- 警告 #D4816B / 用藥 #9B8BBF / 行程 #7BA7C9
- 字體 Noto Sans TC / 基礎字級 19px
- 卡片圓角 16-18px / 按鈕圓角 14px

## Claude API System Prompt
見 docs/handoff.md 或 docs/PRD-v0.3.md

## 藥事資料庫（POC 必做）
- A1: 食藥署 InfoId=36（藥品許可證）
- B1: 食藥署 InfoId=39（藥品外觀）
- D1: 食藥署仿單查詢平台（禁忌、注意事項、交互作用）

## 注意事項分級
- 專業版（仿單原文）→ 免費
- 白話版（AI 翻譯）→ 月費 $149 專屬

## 定價
- 免費：2 次照護時段
- 輕量：$30 TWD / 3 時段
- 吃到飽：$149 TWD / 月（15 次上限，含白話版）
- 加購海報：$49 TWD 買斷
- 加購提醒：$29 TWD / 月
- 收費追蹤：RevenueCat

## 完整文件
- docs/PRD-v0.3.md — 完整 PRD
- docs/handoff.md — 開發交接包（含 API prompt、DB schema、所有規格）
