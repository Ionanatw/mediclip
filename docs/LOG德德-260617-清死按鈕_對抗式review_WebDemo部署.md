# Carrius 清死按鈕 × 對抗式 Review × Web Demo 部署 LOG — 2026-06-17

## 0. 文件資訊

- **建立時間**：2026-06-17 00:20 GMT+8
- **建立者**：德德（Claude Code / Opus 4.8）
- **Session 日期**：2026-06-16 ~ 06-17
- **對話串**：德德（本機 Mac，mediclip repo）
- **檔案路徑**：docs/LOG德德-260617-清死按鈕_對抗式review_WebDemo部署.md
- **模式**：鴿王晚安授權「自行完成，明早看 demo」→ Ultracode 全自動

### 關聯資源索引

| 資源 | 位置 | 路徑 / URL |
|------|------|------|
| 🌟 Live Demo（可點） | GitHub Pages | https://ionanatw.github.io/mediclip/ |
| 死按鈕/死碼修復 | repo | flutter/carrius/lib/（components + 8 screens + models + app_state） |
| 互動回歸測試（新） | repo | flutter/carrius/test/interactions_test.dart（9 條） |
| Web 平台 scaffold（新） | repo | flutter/carrius/web/ |
| 對抗式 review workflow | session | task wde7js2of（10 代理、12 findings） |
| 正式 repo（public, source of truth）| GitHub | https://github.com/Ionanatw/mediclip （main + gh-pages） |
| 私有備份 repo | GitHub | https://github.com/IONATW/mediclip （main） |
| 上一次 LOG | repo | docs/LOG德德-260616-藥品圖鑑KSPH標準表_資料源評比_GitHub推送_開發缺漏稽核.md |

---

## 📎 貼進新 Session 的交接文字（複製貼上即用）

> ⚠️ 新 Session 必須先閱讀上一次 LOG 才能延續記憶。

```
我是鴿王，你是德德（Claude Code），請先閱讀上一次 Session LOG 延續記憶：
讀取 docs/LOG德德-260617-清死按鈕_對抗式review_WebDemo部署.md

閱讀完畢後，以下是重點交接：
1. 「清死按鈕（B+E類）」已完成並通過對抗式多代理 review：7 個死按鈕做真/誠實 Coming Soon、5 個死碼移除、外加 review 抓到的 BlurLock 付費鎖死按鈕＋home/results 兩個漏網 SectionHeader 死按鈕＋5 個 nits 全修。零依賴、零簡體、零 error/warning、12 測試全綠（3 golden 組 + 9 互動）。
2. 已 build Flutter Web 並部署 GitHub Pages live demo：https://ionanatw.github.io/mediclip/（可點，已驗證渲染正常）。code 已推 Ionanatw(public, HEAD 318540f) + IONATW(private 備份)，gh-pages 分支在 public。
3. 仍待決策：櫻花樹改版（樂高 vs 抽象，暫緩中）；46 缺漏裡的大塊（A 核心是假的＝拍照→AI整理無後端；C 花園離 PRD 遠）要不要做真。海報加購/白話版/語音/.ics 真正落地需金流(RevenueCat)或套件，目前是誠實 Coming Soon。
```

---

## 1. TL;DR（三句話）
- **做了什麼**：把 App 裡點了沒反應的死按鈕全清掉——能零依賴做真的做真（隱私/同意/方案/關於/文件詳情），需金流或套件的改成誠實「即將開放」；移除 5 個死碼；跑對抗式多代理 review 抓出並修掉自己漏的 3 個同類死按鈕＋5 nits。
- **產出什麼**：10 個 source 檔改動 + 9 條互動回歸測試 + Flutter Web 平台支援 + **可點的 live demo（GitHub Pages）**；全推上兩個 repo。
- **下一步**：鴿王晨起開 live URL 點一點驗收；再決定櫻花樹改版與「核心做真」要不要動。

---

## 2. 決策紀錄

### 決策 1：本次方向＝清死按鈕（B+E 類）
- **最終方案**：鴿王在四選項（清死按鈕 / 挑核心做真 / 櫻花樹拍板 / 收 backlog）中選「清死按鈕」。
- **原因**：低風險、見效快，先讓 demo 不再「點了沒反應」。

### 決策 2：零依賴・誠實 Coming Soon
- **最終方案**：不新增任何套件（維持專案零外部依賴）。能免費做真的做真；需 share_plus/url_launcher/path_provider/RevenueCat 的（.ics/分享/仿單PDF/海報加購/語音）一律改成 house-styled「即將在正式版開放」。
- **原因**：鴿王選此；符合 YAGNI；誠實標示是醫療 App 信任底線。
- **替代**：加輕量套件做真（否決：仿單 PDF 連結是相對路徑只有 6 藥、.ics 仍複雜、海報仍要金流，CP 值低）。

### 決策 3：隱私/同意/方案頁草擬真內容
- **最終方案**：鴿王選「草擬真內容」。依 CLAUDE.md 隱私原則寫隱私政策、同意書，方案頁用三層定價，關於頁含資料來源致謝；隱私/同意標「v0.1 草稿，正式版前送法務複核」。
- **原因**：醫療 App 本該有這些；草稿明標待法務＝誠實不過度承諾。

### 決策 4：自主完成 + 部署 live web demo
- **最終方案**：鴿王晚安說「自行完成，明早看 demo」→ 我 build Flutter Web 部署 GitHub Pages，讓鴿王能實際點按鈕（清死按鈕的重點就是「按了有反應」）。
- **原因**：static 截圖證明不了互動；live demo 最能驗收。
- **CF 為何沒走**：cf-deploy 需 Infisical 取 CF token，但 Infisical 未登入（要互動式選 region）→ 過夜無法自動，改用已認證的 GitHub Pages（public repo）。

### 決策 5：對抗式多代理 review 當品質閘
- **最終方案**：commit 前跑 10 代理 review workflow（正確性/文案醫療誠實/設計三維度 → 逐項對抗式驗證）。抓到 1 must-fix（BlurLock 死按鈕）+ 2 should-fix（漏網 SectionHeader）+ 5 nits，全修後才 commit。
- **原因**：Ultracode；醫療 App + demo-bound，獨立眼睛值得。實證有效（抓到我自己造成的同頁不一致）。

---

## 3. 產出清單

| # | 名稱 | 類型 | 路徑 | 狀態 |
|---|------|------|------|------|
| 1 | showComingSoon / showCDSheet + Sheet 內文元件 | Flutter | lib/design/components.dart | ✅ |
| 2 | settings 隱私/同意/方案/關於 真內容頁 + email 純資訊 | Flutter | lib/screens/settings_screen.dart | ✅ |
| 3 | documents 文件詳情 sheet | Flutter | lib/screens/documents_screen.dart | ✅ |
| 4 | .ics/分享/海報/仿單PDF/語音 誠實 Coming Soon | Flutter | calendar/garden/poster/drug_atlas/upload_screen | ✅ |
| 5 | BlurLock 付費鎖 onTap（review must-fix） | Flutter | components + med_card + poster | ✅ |
| 6 | home/results「識別卡」SectionHeader 死按鈕（review should-fix） | Flutter | home_screen / results_screen | ✅ |
| 7 | 移除 5 個死碼 | Flutter | models.dart / app_state.dart | ✅ |
| 8 | 互動回歸測試 9 條 | test | test/interactions_test.dart | ✅ |
| 9 | Flutter Web 平台支援 | scaffold | flutter/carrius/web/ | ✅ |
| 10 | **Live Demo** | 部署 | https://ionanatw.github.io/mediclip/ | ✅ |
| 11 | 6 張 golden 更新 | assets | test/goldens/{04,06,08,10,12,17} | ✅ |

死碼清單：`Medication.photoAsset`/`appearanceSource`/`appearanceVerified`、`TreeStageRef` enum、`AppState.noteText`/`gratitudeText`（圖鑑 `DrugFull` 同名欄位保留）。

---

## 4. 除錯與教訓

### 教訓 1：`flutter create --platforms web .` 會塞預設 widget_test.dart 模板
- **問題**：補 web 平台後 `flutter test` 爆——多了引用不存在 `MyApp` 的模板 test。
- **解法**：刪 test/widget_test.dart（原專案 test/ 只有 golden_test）。
- **教訓**：flutter create 補平台會順手加模板檔，跑測試前先清。

### 教訓 2：對抗式 review 抓到「自己造成的同頁不一致」
- **問題**：poster 頁底部「加購海報 $49」接了 Coming Soon，但同頁上方 BlurLock「加購 $49 解鎖列印」還是死的（只震動）→ 同頁兩購買入口一個有反應一個沒。
- **解法**：BlurLock 加 onTap 參數走 showComingSoon；med_card 同類一起修。
- **教訓**：改 A 沒檢查同頁同義的 B，最容易在 demo 露餡。多代理 review 是有效的安全網。

### 教訓 3：Infisical 未登入 → CF 部署不能過夜自動
- **問題**：cf-deploy 走 `infisical run --env=prod` 取 CF token，但 infisical 未登入（要互動式選 region + 開瀏覽器）。skill 寫的路徑 `~/Claude/cosmate-ai-nexus` 也過時（實際 `~/Documents/Claude/cosmate-ai-nexus`）。
- **解法**：改用已認證的 GitHub Pages（public repo gh-pages 分支）。
- **教訓**：過夜自動部署優先選「已認證、零互動」的通道；cf-deploy skill 的 Infisical 路徑需更新。

### 教訓 4：雙同名 repo push 認證陷阱（呼應記憶 mediclip-two-github-accounts）
- **問題**：remote URL 帶 `IONATW@` 對「非 active」帳號會觸發互動式密碼而失敗；`Ionanatw@`（active）則可。
- **解法**：推 public 直接成功（active=Ionanatw）；推 private 用 `gh auth switch --user IONATW` 切 active 再推、推完切回。逐 repo 用 `gh api .../commits/main --jq .sha` 驗 SHA（非 ls-remote）。
- **教訓**：多帳號 push 用 gh auth switch 對齊 active 帳號最穩；驗證用 gh API。

### 教訓 5：canvas 渲染的 Flutter Web 無法用 DOM 合成事件驅動
- **問題**：headless 用 PointerEvent 合成點擊「開始使用」推不動畫面（Flutter gesture arena 不吃合成事件；widget 畫在 canvas 上 DOM 也選不到）。
- **解法**：互動「行為」一律靠 widget test 驗（against 真 widget tree）；live 只驗開機+渲染。
- **教訓**：Flutter Web 的互動驗證信 widget test，不要硬戳 canvas。

---

## 5. TODO

### 🙋 鴿王要做（晨起）
| # | 任務 | 怎麼做 |
|---|------|--------|
| 1 | 開 live demo 驗收清死按鈕 | https://ionanatw.github.io/mediclip/ ；建議點：設定→隱私政策/方案、行事曆→.ics 鈕、海報→加購、文件列、首頁「今日用藥 · 識別卡」、整理結果頁 |
| 2 | 拍板櫻花樹改版概念（樂高 vs 抽象，傾向抽象） | 暫緩中，要做才能變成真的 5 階段 Flutter 樹 |
| 3 | 決定「核心做真」要不要動 | 46 缺漏裡 A(拍照→AI整理無後端) / C(花園離 PRD 遠) 是大塊，需另起 session |

### 🤖 Agent 可自動跑（待鴿王指示）
| # | 任務 | 前置 |
|---|------|------|
| 1 | 把 .ics/分享/仿單PDF 從 Coming Soon 變真（加 url_launcher/share_plus） | 鴿王同意加套件 |
| 2 | 海報加購/白話版接 RevenueCat 真金流 | 鴿王決定上付費 |
| 3 | 澆花記憶遊戲 + 三棵樹養成搬進 Flutter | 鴿王指示做花園 |

---

## 6. 回寫檢查

| 內容 | 應回寫到 | 狀態 |
|------|---------|------|
| 清死按鈕 + 對抗式 review 決策 | 本 LOG §2 | ✅ |
| flutter create 塞模板 / Infisical 未登入 / 雙 repo push / canvas 不可合成事件 | 本 LOG §4（可升不二錯） | ✅ |
| cf-deploy skill Infisical 路徑過時 | 待更新 skill 或記 NEXUS | ⏳ |
| Notion Ticket 狀態 | Notion Ticket DB | ⏳（德德接續處理） |
| 本 Session LOG | Notion Session LOG DB | ⏳（德德接續處理） |

---

## 7. HANDOFF 摘要

**狀態**：清死按鈕（B+E類）完成、對抗式 review 過、12 測試全綠；Flutter Web live demo 已部署並驗證渲染正常；code 推上 public(318540f)+private 備份；gh-pages 在 public。
**下一步**：鴿王晨起開 live URL 驗收 → 決定櫻花樹改版與核心做真。
**阻塞**：.ics/分享/仿單PDF/海報/白話版/語音 真正落地需套件或金流（目前誠實 Coming Soon）；CF 自動部署需 Infisical 先登入。

---

## 8. 關鍵觀察

這次把「外觀完整、互動是空殼」的落差補上了一層：使用者點任何看起來可點的東西，現在都有誠實回應（做真或明說即將開放），沒有「點了沒反應」的尷尬。對抗式 review 的價值在於抓到我自己改 A 漏改同頁 B 的不一致——這是單人改動最常見的盲點。但要注意：**這仍是「互動誠實」層的修補，核心價值（拍照→AI 整理、持久化、金流、花園養成）大多還是 mock**。demo 能點得很順，但離「能用」還有 A/C 兩大塊要鴿王拍板。誠實標示（Coming Soon、v0.1 草稿待法務、POC 版權待授權）全程貫徹，維持醫療 App 的信任底線。
