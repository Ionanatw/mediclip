# Carrius 藥品圖鑑 × 資料源評比 × 開發稽核 LOG — 2026-06-16

## 0. 文件資訊

- **建立時間**：2026-06-16 02:42 GMT+8
- **建立者**：德德（Claude Code / Opus 4.8）
- **Session 日期**：2026-06-15 ~ 06-16
- **對話串**：德德（本機 Mac，mediclip repo）
- **檔案路徑**：docs/LOG德德-260616-藥品圖鑑KSPH標準表_資料源評比_GitHub推送_開發缺漏稽核.md

### 關聯資源索引

| 資源 | 位置 | 路徑 / URL |
|------|------|------|
| 藥品圖鑑分頁 | repo | flutter/carrius/lib/screens/drug_atlas_screen.dart、models/drug_atlas.dart、models/drug_atlas_data.dart |
| 藥品外觀誠實稽核頁 | repo | docs/drug-appearance-check.html |
| 藥品即時 POC（API+代理）| repo | docs/drug-live-poc.html、docs/drug_live_poc_server.py |
| 看圖驗收圖庫（自包含）| repo | docs/carrius-morning-review.html |
| 資料源記憶 | memory | carrius-drug-data-sources.md |
| 兩同名 repo 記憶 | memory | mediclip-two-github-accounts.md |
| Notion 票（藥品圖鑑）| Notion | https://app.notion.com/p/3806fedce91a81f9b33cce30e426d0c7 |
| 正式 repo（public）| GitHub | https://github.com/Ionanatw/mediclip |

---

## 📎 貼進新 Session 的交接文字（複製貼上即用）

> ⚠️ 新 Session 必須先閱讀上一次 LOG 才能延續記憶。

```
我是鴿王，你是德德（Claude Code），請先閱讀上一次 Session LOG 延續記憶：
讀取 docs/LOG德德-260616-藥品圖鑑KSPH標準表_資料源評比_GitHub推送_開發缺漏稽核.md

閱讀完畢後，以下是重點交接：
1. 完成藥品圖鑑分頁（四病分組、收合/一鍵展開、實拍圖＋完整說明）；高血壓群接高雄聯醫 KSPH 靜態頁完整標準表（＝鴿王參考卡本尊，含料號）。全部已推上 Ionanatw/mediclip（public）+ IONATW（private 備份），HEAD e294775。
2. 待決策：櫻花樹改版概念（已看樂高 vs 抽象兩版草圖，鴿王偏「抽象色塊風」但未拍板，暫緩）；開發缺漏清單（46 項）怎麼推進（先死按鈕快修 / 挑核心做真 / 收 backlog）。
3. 阻塞/教訓：醫療欄位只能 deterministic 解析權威靜態源，LLM 萃取會捏造（對抗式驗證抓到健保碼臆造、外觀亂填、藥名混淆）；專科藥（PPI/狼瘡/肝癌）無乾淨來源（醫學中心藥庫被 Cloudflare/CAPTCHA 擋）。
```

---

## 1. TL;DR（三句話）
- **做了什麼**：完成 Carrius 藥品圖鑑分頁（四病各 6 藥、收合/一鍵展開、實拍外觀圖＋完整說明），高血壓群接高雄聯醫 KSPH 靜態頁的完整標準表；過程做了藥品資料源評比與「不捏造」誠實稽核；最後做了一輪 App 開發完整性稽核（46 項缺漏）。
- **產出什麼**：藥品圖鑑（screen/model/data＋24 張實拍圖）、藥品外觀誠實稽核 HTML、藥品即時查詢 POC（drugtw API＋本機代理）、自包含看圖驗收圖庫；全推上 GitHub（Ionanatw public）。
- **下一步**：鴿王拍板櫻花樹概念 + 決定開發缺漏（46 項）怎麼推進。

---

## 2. 決策紀錄

### 決策 1：藥品圖鑑＝新增第 5 分頁，四病分組，預設收合
- **最終方案**：底部 TabBar 加 `AppTab.atlas`（首頁/行事曆/[+]/文件/圖鑑/花園）。四病各 5-7 藥，預設收合（乾淨），頂部「展開所有藥物外觀與說明」開關＋單列點開；展開＝實拍圖＋label/value 完整說明卡（對齊鴿王參考卡）。
- **原因**：鴿王指定「新增分頁」「展開時也要呈現完整說明如參考圖」。
- **替代**：沿用「用藥」清單（否決：四病混在一個病人不合理）。

### 決策 2：藥品圖呈現走「實拍照」方向
- **最終方案**：醫卡/圖鑑顯示真實藥品照片，非手繪向量。
- **原因**：鴿王在「實拍照 vs 手繪向量」選了實拍照（最準）。

### 決策 3：醫療資料只用 deterministic 解析權威靜態源，不信 LLM 萃取
- **最終方案**：外觀標記用食藥署官方外觀頁解析；完整標準表用 KSPH 靜態 .htm（Big5）解析；只回填「查得到、驗證過」欄位，捨棄 LLM 萃取的健保碼/外觀。
- **原因**：跑 24 藥萃取＋對抗式驗證 workflow，**驗證關卡抓到萃取 agent 系統性捏造**（健保碼用許可證號臆造、外觀憑記憶亂填、olmesartan↔losartan 混淆）。醫療 App 不能容忍。
- **替代**：直接用 LLM 萃取結果（否決：會捏造、危險）。

### 決策 4：資料源評比結論
- **KSPH 高雄聯醫靜態 .htm（Big5）**＝完整標準表最乾淨來源（含料號/實拍圖/仿單PDF），但市立醫院只有慢性病藥（高血壓全套有，PPI/狼瘡/肝癌＝0）。
- **drugtw.com `/api/drugs`**＝乾淨 JSON 基本資料＋圖片 URL（無 CORS header → 瀏覽器要代理）。
- **食藥署 mcp.fda.gov.tw**＝官方外觀＋仿單，圖片可直連但搜尋有 CAPTCHA、內容版權限制。
- **榮總/三總**＝Cloudflare 403，抓不到。
- 詳見記憶 [[carrius-drug-data-sources]]。

### 決策 5：櫻花樹改版暫緩
- **最終方案**：給看了樂高積木風 vs 抽象色塊風兩版概念草圖（含細修版，用 visualize SVG）。鴿王原則上偏「抽象色塊風」但未最終拍板 → 暫緩，先做其他。

### 決策 6：正式 repo＝Ionanatw/mediclip（public）
- **最終方案**：鴿王更正正式 repo 為 Ionanatw（public），非 IONATW（private）。已推 Ionanatw public（含食藥署/醫院版權藥品資料，鴿王知情同意公開）＋ IONATW private 備份。
- **驗證法**：`gh api repos/<owner>/mediclip/commits/main --jq .sha` 逐 repo 比對（ls-remote 會跟轉址，不可靠）。

---

## 3. 產出清單

| # | 名稱 | 類型 | 路徑 | 狀態 |
|---|------|------|------|------|
| 1 | 藥品圖鑑分頁 | Flutter | lib/screens/drug_atlas_screen.dart + models/drug_atlas{,_data}.dart | ✅ |
| 2 | 24 藥實拍圖 | assets | flutter/carrius/assets/drugs/*.jpg | ✅ |
| 3 | 高血壓群 KSPH 完整標準表 | 資料 | drug_atlas_data.dart（6 藥 12 欄＋圖） | ✅ |
| 4 | 藥品外觀誠實稽核頁 | HTML | docs/drug-appearance-check.html | ✅ |
| 5 | 藥品即時查詢 POC ＋本機代理 | HTML+Py | docs/drug-live-poc.html、drug_live_poc_server.py | ✅ |
| 6 | 看圖驗收圖庫（base64 自包含） | HTML | docs/carrius-morning-review.html | ✅ |
| 7 | 看圖驗收三修（字體/＋鈕/安全區） | Flutter | tokens/carrius_tab_bar/golden_test | ✅ |
| 8 | 開發完整性稽核報告（46 項） | 稽核 | 本 LOG §5 + workflow 結果 | ✅ |
| 9 | 櫻花樹兩版概念草圖 | SVG | （對話內 visualize，未落檔） | ⏳ 待拍板 |

---

## 4. 除錯與教訓

### 除錯 1：LLM 萃取醫療欄位會捏造
- **問題**：24 藥萃取 workflow，多筆健保碼/外觀是假的。
- **根因**：agent 在找不到時憑規則/記憶編造（健保碼＝BC＋許可證號＋100；Plaquenil 填成橢圓但官方是圓形；可悅您把 olmesartan 當 losartan）。
- **解法**：對抗式驗證關卡攔截；只採 deterministic 解析權威靜態源（食藥署外觀頁、KSPH .htm）。
- **教訓**：醫療 App 的臨床/代碼/外觀欄位禁用 LLM 萃取，對抗式驗證必做。
- **🔁 寫進不二錯？**：是（分類：AI幻覺/醫療資料）。已寫入記憶 carrius-drug-data-sources。

### 除錯 2：git push 推到同名 repo + 分歧
- **問題**：push origin(IONATW) 被擋（遠端有別處推的 commit）；且兩個同名 repo 易推錯。
- **根因**：遠端 main 有他處推的 CLAUDE.md 更新；本機認證 Ionanatw＋IONATW 雙帳號。
- **解法**：fetch → rebase（零衝突，沒 force push）→ push；用 gh API 逐 repo 驗證 SHA（非 ls-remote）。
- **教訓**：推前先問鴿王哪個 repo（他前後說反覆）；驗證用 gh API。已更新記憶 mediclip-two-github-accounts。

### 除錯 3：urllib 對 URL 內中文失敗 / KSPH Big5
- **問題**：食藥署 im_shape_detail URL 含中文，urllib 抓到空檔；KSPH .htm 是 Big5 顯示亂碼。
- **解法**：改用 curl（自動處理中文 URL）；KSPH 用 `decode('big5')`。
- **教訓**：非 UTF-8 來源先驗編碼；中文 URL 用 curl 或先 quote。

---

## 5. TODO

### 🙋 鴿王要做

| # | 任務 | 解鎖什麼 |
|---|------|---------|
| 1 | 拍板櫻花樹改版概念（樂高 vs 抽象，傾向抽象） | 才能做成真的 Flutter 樹（5 階段） |
| 2 | 決定 46 項開發缺漏怎麼推進 | 死按鈕快修 / 挑核心做真 / 收 backlog |
| 3 | 是否補專科藥（PPI/狼瘡/肝癌）完整表 | 需醫學中心藥庫（多被擋）或授權資料源 |
| 4 | 是否要付費/真後端（核心 AI 流程目前是 demo 殼） | App 從「能看」走向「能用」 |

### 🤖 Agent 可自動跑（待鴿王指示）

| # | 任務 | 前置條件 |
|---|------|---------|
| 1 | B 類死按鈕快修（.ics/分享/PDF/導覽/隱私政策）+ E 類死碼清理 | 鴿王指示「先清死按鈕」 |
| 2 | 澳花記憶遊戲（WateringGame）搬進 Flutter | 鴿王指示優先做花園遊戲 |

### 開發缺漏稽核摘要（46 項，8 high）
- **A 核心是假的**：拍照→AI整理無後端（核心價值是 demo 殼）；上傳是計數器；無本地持久化（重啟歸零）；付費/RevenueCat 全缺；AI追問作答被丟棄。
- **B 死按鈕**：.ics 匯出、心情卡分享、仿單PDF、home/results 識別卡、documents 列、settings 全列（含隱私政策/同意書）、海報加購、upload 來源 chip。
- **C 花園離 PRD 遠**：只 1 棵樹（缺三棵樹養成）、缺快樂森林、缺荒廢機制、微運動/挑戰/里程碑無真畫面、澆花記憶遊戲沒搬。
- **D 舊版漏搬小功能**：AI追問自由輸入/略過、Checklist 自訂項、結果頁檢驗/醫囑Q&A、服用時段彙整、Processing 錯誤重試。
- **E 死碼/品質**：Medication.photoAsset/appearanceSource/TreeStageRef 零引用；noteText/gratitudeText 孤兒；深色模式只測 2 張；analyze 全綠、test 全過（健康）。

---

## 6. 回寫檢查

| 內容 | 應回寫到 | Notion 已同步？ | 狀態 |
|------|---------|---------------|------|
| 藥品圖鑑＋資料源決策 | Notion Ticket | ✅（票 3806fedc…） | ✅ |
| LLM 萃取捏造教訓 | 記憶 carrius-drug-data-sources | — | ✅ |
| 兩同名 repo + gh API 驗證法 | 記憶 mediclip-two-github-accounts | — | ✅ |
| 櫻花樹暫緩傾向 | 記憶 caredoc-ios-phantom-decisions | — | ✅ |
| Session LOG 本身 | Notion Session LOG DB | ⏳ | ⏳ |

---

## 7. HANDOFF 摘要

**狀態**：藥品圖鑑分頁完成並推上 GitHub（Ionanatw public，HEAD e294775）；藥品資料源評比與誠實稽核完成；App 開發完整性稽核完成（46 項缺漏盤點）。
**下一步**：鴿王拍板櫻花樹概念 + 決定 46 項缺漏怎麼推進。
**阻塞**：櫻花樹未拍板；專科藥無乾淨資料源；核心 AI 流程目前是 demo 殼（要不要做真需鴿王決定）。

---

## 8. 關鍵觀察

這支 App「外觀完整度」與「功能真實度」落差很大——畫面/設計/動效都很細，但核心價值（AI 整理、上傳、持久化、金流、花園養成）大多是 mock。對 demo/看圖驗收沒問題，但要往「能用」走，得先逐項決定「demo 假的就好」vs「一定要真」。誠實稽核（不捏造醫療資料、明標 POC/版權/待授權）是這支醫療 App 的信任底線，本 session 全程貫徹。
