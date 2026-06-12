# CareDoc iOS App — Phantom 設計系統與設計規格

> 狀態：待鴿王審核 ｜ 日期：2026-06-13 ｜ 來源 PRD：CareDoc PRD v0.3
> Mockup：`docs/mockup-phantom-app.html`（5 畫面）、`docs/mockup-tree-styles.html`（插畫風格試畫）

## 0. 已確認決策

| 項目 | 決策 |
|------|------|
| 技術棧 | SwiftUI 原生（iOS 17+），零第三方依賴 |
| 專案位置 | `mediclip/ios/CareDoc/`（含 .xcodeproj） |
| 範圍 | PRD 全部 12+1 個畫面 |
| 資料 | 全部 Mock（一份擬真化療出院衛教單整理結果），API 之後接 |
| 設計語言 | 完全採用 phantom.com（取代鼠尾草綠系統） |
| 深淺色 | 都支援，跟隨系統；兩套色值皆取自 Phantom 官網原生定義 |
| Emoji | 全 App 禁用 emoji 與裝飾性字符；所有圖案為手繪向量 |
| 插畫風格 | A 描邊錯位塗鴉風＝主風格（花園的樹、藥丸、UI 插圖）；B 霧面光暈漸層風＝呼吸練習頁背景；C 有機色塊拼貼風＝心情小卡、照護海報 |
| 藥品插畫 | 依藥品真實外觀繪製（形狀、顏色、刻痕，對應食藥署外觀資料欄位），用 A 風格的描邊與錯位上色 |
| Tab Bar | 懸浮膠囊毛玻璃：首頁／行事曆／中央上傳圓鈕／文件／花園；花園 icon＝小樹苗 |

## 1. Design Tokens（取自 phantom.com production CSS）

### 1.1 色彩

| Token | Dark | Light | 用途 |
|-------|------|-------|------|
| `bg` | `#1C1C1C` | `#FFFDF8` | 畫面背景 |
| `surface` | `#28282C` | `#FDFCFE` | 卡片 |
| `surface2` | `#34343A` | `#F4F2F4` | 次卡片、輸入框 |
| `surface3` | `#2E2E32` | `#EDEDEF` | 進度條軌道等 |
| `textPrimary` | `#FFFDF8` | `#3C315B` | 主文字 |
| `textSecondary` | `#A09FA6` | `#86848D` | 次文字 |
| `textTertiary` | `#86848D` | `#A09FA6` | 弱化文字 |
| `accent` | `#AB9FF2` | `#AB9FF2` | 品牌薰衣草紫 |
| `accentSoft` | `#E2DFFE` | `#E2DFFE` | 淺紫 |
| `plum` | `#3C315B` | `#3C315B` | 深茄紫（插畫輪廓、按鈕文字） |
| `plumDeep` | `#2C2250` | `#2C2250` | 更深紫 |
| `lemon` | `#F1FF52` | `#F1FF52` | 主 CTA、陽光值 |

機能色（兩模式同值）：成功 `#45E863`、警告 `#FF0037`、注意 `#FFD600`、資訊 `#6CA0FB`。

語意映射：用藥＝accent 紫、行程＝資訊藍、禁忌＝警告紅、完成＝成功綠、陽光值＝lemon、空腹/提醒＝注意黃。

### 1.2 字體

- 標題／數字：**SF Pro Rounded**（`.rounded` design），字重 Heavy/Bold，tracking 約 -0.5（對應 Phantom `-0.025em`）
- 內文：系統字體（中文自動蘋方），Regular/Medium
- 字級階：大標 28／頁標 21／區塊標 17／卡片標 15／內文 13.5／輔助 11.5／tab 標籤 10

### 1.3 造型

- 卡片圓角 18（大卡 24）、列表項 14、icon 容器 11
- 按鈕一律膠囊形（Capsule）
- 卡片 1px 邊框：dark `white 7%`、light `plum 8%`
- Tab Bar：懸浮膠囊、`.ultraThinMaterial`（對應 blur 40）、底部 margin 12
- 紫色 glow 陰影：`#AB9FF2` 35% blur 44（dark）；light 改深紫低透明陰影

### 1.4 動效

- 主 easing：`cubic-bezier(0.22, 1, 0.36, 1)` 0.4s（SwiftUI 以 `.timingCurve(0.22, 1, 0.36, 1, duration: 0.4)` 或近似 spring）
- 進場：卡片由下 24pt 淡入，stagger 0.08s
- 按鈕按下：scale 0.96
- 呼吸圓：依呼吸法秒數縮放（478：4s 放大、7s 保持、8s 縮小）

### 1.5 插畫規則（A 主風格）

- 輪廓：`plum` 粗描邊（約畫布寬度 1.7%），圓頭圓角
- 填色：故意往右上錯位（約 3%）的高飽和色塊
- 點綴：薰衣草紫星芒、檸檬花蕊、白色輪廓小花、飄落花瓣
- 藥品：照真實外觀畫（膠囊／錠劑／圓片，真實配色＋刻痕文字），同樣粗描邊＋錯位高光
- B 風格（僅呼吸練習背景）：無輪廓徑向漸層光暈、黃昏紫粉天空
- C 風格（僅心情小卡／海報）：無輪廓有機色塊疊加＋點/線紋理

## 2. App 架構

```
ios/CareDoc/
├── CareDoc.xcodeproj
└── CareDoc/
    ├── CareDocApp.swift          // App 入口、TabBar 容器
    ├── DesignSystem/
    │   ├── Tokens.swift          // 色彩(light:dark)、字體、圓角、動效
    │   ├── Components/           // PillButton, Card, ListRow, Tag, TabBar,
    │   │                         // ProgressBar, SectionHeader, BlurLock(模糊遮罩)
    │   └── Illustrations/        // SakuraTree(5階段), PillShape, Sprout,
    │                             // BreathOrb(B風格), MoodBlob(C風格), EmptyState
    ├── Models/                   // Medication, ScheduleEvent, CareSession,
    │                             // ChecklistItem, TreeState, Document
    ├── MockData/                 // MockCareSession.swift（化療衛教單範例）
    └── Features/
        ├── Welcome/  ├── Home/  ├── Upload/  ├── Processing/
        ├── FollowUp/ ├── Results/ ├── MedicationCard/ ├── Calendar/
        ├── Checklist/ ├── Poster/ ├── Documents/ ├── Settings/
        └── Garden/               // 花園 + 呼吸練習 + 感恩日記 + 小挑戰
```

- 狀態：`@Observable` AppState（目前 session、花園進度、checklist 勾選），單向資料流
- 導航：`TabView`（自訂懸浮 TabBar overlay）＋各 tab 內 `NavigationStack`
- 本地儲存：POC 先 in-memory（mock），以 protocol 抽象，之後換 SwiftData 不動 UI
- 無網路、無 API key、無帳號 — 純 UI 殼跑通全流程

## 3. 畫面規格（13）

| # | 畫面 | 重點 |
|---|------|------|
| 1 | 歡迎頁 | A 風格品牌插畫、檸檬膠囊「開始」、隱私一句話聲明 |
| 2 | 首頁 | 問候語、3 統計卡（照護天數/今日用藥/天後回診）、即將到來、今日用藥、今日快樂卡 |
| 3 | 上傳 | 紫虛線拍照區、PDF/網頁/語音(soon)三入口、縮圖列、補充說明、檸檬 CTA |
| 4 | AI 處理中 | 步驟進度動畫（辨識→結構化→比對藥品庫→產出），A 風格插圖輪播 |
| 5 | AI 追問 | 選擇題卡片（如「一天三次是飯前還飯後？」），膠囊選項 |
| 6 | 結果總覽 | 摘要卡＋用藥/行程/注意事項分區預覽，免責聲明固定底部 |
| 7 | 藥品識別卡 | 真實外觀插畫、劑量標籤、禁忌紅卡、專業版(免費)、白話版(模糊遮罩+解鎖CTA) |
| 8 | 行事曆 | 月曆(藍點行程/紫點用藥)＋事件列表＋.ics 匯出膠囊鈕 |
| 9 | 每日待辦 | 進度條＋分類 checklist（用藥/傷口/飲食），勾選慶祝微動畫 |
| 10 | 照護海報 | C 風格海報預覽、A3/A4 切換、分享（POC：假按鈕） |
| 11 | 文件紀錄 | 時間軸＋版本標記（術後第1週…），對應 tab「文件」 |
| 12 | 設定 | 通知開關、帳號區（mock）、隱私政策、關於 |
| 13 | 花園 | 櫻花樹(5成長階段 A 風格)、陽光值進度、快樂任務列表、呼吸練習(B 背景)、感恩日記、小挑戰卡、心情小卡(C 風格) |

Tab 對應：首頁=2、行事曆=8、上傳=3(中央鈕，modal 流程 3→4→5→6→7)、文件=11、花園=13。9/10/12 從首頁與設定入口進入。

## 4. 錯誤處理與測試

- POC 無網路呼叫；唯一失敗路徑是相簿權限拒絕 → 顯示 A 風格空狀態插圖＋引導文案
- 文案全繁體中文，產出後執行錯字自檢（高頻錯字前 5 名＋簡繁掃描）
- 驗證：Xcode 編譯 0 error、SwiftUI Preview 每畫面、深淺色雙截圖、Dynamic Type 一級放大不破版

## 5. 明確不做（本次）

真 Claude API、Supabase、RevenueCat、推播、.ics 實際產檔、DALL-E 海報、Whisper、Android。
