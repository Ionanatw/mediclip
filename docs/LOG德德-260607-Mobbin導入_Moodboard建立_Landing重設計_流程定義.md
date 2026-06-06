# CareDoc UI 重設計 LOG — 2026-06-07

## 0. 文件資訊

- **建立時間**：2026-06-07 02:41 GMT+8
- **建立者**：德德（Claude Code, Opus 4.6）
- **Session 日期**：2026-06-07
- **對話串**：德德（Claude Code）
- **Notion 路徑**：待寫入 Session LOG DB

### 關聯資源索引

| 資源 | 位置 | URL / 路徑 |
|------|------|-----------|
| GitHub Repo | GitHub | https://github.com/Ionanatw/mediclip |
| Figma Moodboard | Figma | https://www.figma.com/design/VV6lNmHlroRbAEc0WwNTsZ |
| HTML Moodboard | 本地 | docs/moodboard.html |
| PRD v0.3 | 本地 | docs/CareDoc-PRD-v0.3.md |

---

## 📎 貼進新 Session 的交接文字（複製貼上即用）

我是鴿王。開始之前，請先閱讀上一次 Session LOG 延續記憶：
{Session LOG DB Notion URL — 待補}

閱讀完畢後，以下是重點交接：
1. CareDoc SNS 版 UI 已完成第一輪重設計：Landing + EmailGate 兩頁已用新風格重寫並 preview 確認
2. 接下來要做：上傳照片頁（先 Mobbin 搜參考 → 再寫 code）、Processing 頁、Results 總覽頁、藥品卡、鎖住功能 CTA，共 4 頁待做
3. 已建立完整工作流程：每頁先 Mobbin 搜 benchmark → 風格對齊 → code 實作 → preview 確認

---

## 1. TL;DR（三句話）
- 導入 Mobbin MCP + Figma MCP，搜尋 10 款健康/醫療 App 建立 moodboard，再聚焦到 Alan / Alma / Ahead / Headspace 四款討論療癒風格方向
- 確定 CareDoc SNS 版設計方向：專業感（MyFitnessPal）+ 療癒留白（Headspace）+ 漸層背景 + 莫蘭迪色點綴 + 無角色無 emoji
- Landing + EmailGate 已用新風格重寫並 preview 驗證通過，定義了後續每頁「Mobbin → code → preview」的開發流程

---

## 2. 決策紀錄

### 決策 1：CareDoc SNS 版設計風格方向
- **最終方案**：「醫院裡的 Headspace」— 專業信任 + 療癒留白
- **組成**：MyFitnessPal 的結構化專業感 + Alan 的自然光暈氛圍 + Headspace 的留白節奏 + Alma 的綠色 CTA
- **原因**：CareDoc 是醫療 App，需同時兼顧「專業信任」和「療癒感」。純 Ahead 太遊戲化，純 Alma 不夠 healing
- **替代方案**：Ahead 糖果色遊戲化風格（否決：太不專業）、純 Alma 大地色（否決：不夠 healing）

### 決策 2：背景處理
- **最終方案**：綠→白漸層背景（#EDF5F0 → #FFFFFF），莫蘭迪色只用在點綴（tag、狀態標籤、icon 底色）
- **原因**：鴿王指示暖米色/莫蘭迪只用點綴不用背景，要有漸層溫度
- **替代方案**：暖米色 #FDFBF7 背景（否決：鴿王指示先不用）

### 決策 3：SNS 版不使用角色/吉祥物
- **最終方案**：SNS 版無角色，用 SVG icon 取代 emoji
- **原因**：鴿王指示 SNS 版先不做角色，且 UI 內不要出現 emoji
- **替代方案**：Alan 式 3D 角色或 Ahead 式 blob（否決：鴿王指示暫不用）

### 決策 4：開發流程定義
- **最終方案**：每頁走「Mobbin 搜 benchmark → 風格對齊 → 直接 code → preview 確認」，不走 Figma 中間層
- **原因**：SNS 版是 Next.js 網頁，code 即設計，Figma 是多餘翻譯層
- **替代方案**：先做 Figma mockup 再翻 code（否決：多一層翻譯，效率低）

### 決策 5：Git merge + push
- **最終方案**：feat/sns-demo 分支 fast-forward merge 進 main 並 push 到 GitHub
- **原因**：鴿王指示先 merge then push
- **Remote URL 修正**：從 IONATW → Ionanatw

---

## 3. 產出清單

| # | 名稱 | 類型 | 連結/路徑 | 狀態 |
|---|------|------|---------|------|
| 1 | HTML Moodboard（10 款 App） | HTML | docs/moodboard.html | ✅ |
| 2 | Figma Moodboard | Figma | https://www.figma.com/design/VV6lNmHlroRbAEc0WwNTsZ | ✅ |
| 3 | Landing 組件重寫 | React | components/Landing.tsx | ✅ |
| 4 | EmailGate 組件重寫 | React | components/EmailGate.tsx | ✅ |
| 5 | 全域 CSS 更新（漸層背景 + 新變數） | CSS | app/globals.css | ✅ |
| 6 | Flow.tsx disclaimer 去 emoji | React | components/Flow.tsx | ✅ |
| 7 | launch.json（dev server 設定） | JSON | .claude/launch.json | ✅ |
| 8 | Git merge feat/sns-demo → main + push | Git | GitHub main branch | ✅ |

---

## 4. 除錯與教訓

### 除錯 1：Mobbin search_screens deep 模式不穩
- **問題**：deep 模式頻繁返回 "Failed to understand query" 或 "Failed to curate results"
- **解法**：改用 fast 模式 + 簡短關鍵字
- **教訓**：Mobbin MCP 的 deep 模式不穩定，建議預設用 fast 模式

### 除錯 2：Figma Plugin API counterAxisSizingMode
- **問題**：`counterAxisSizingMode` 不接受 `"FILL"` 值，只接受 `"FIXED"` 或 `"AUTO"`
- **解法**：用 `layoutAlign = "STRETCH"` + `counterAxisSizingMode = "AUTO"` 取代
- **教訓**：Figma Plugin API 的 fill 行為透過子元素的 layoutAlign 控制，不是父元素的 sizingMode

### 除錯 3：GitHub remote URL 錯誤
- **問題**：原 remote URL 是 `IONATW/mediclip`（大寫），GitHub 找不到
- **解法**：`git remote set-url origin https://github.com/Ionanatw/mediclip.git`
- **教訓**：GitHub username 大小寫敏感，正確是 `Ionanatw`

---

## 5. TODO

### 🙋 鴿王要做

| # | 任務 | 時間 | 解鎖什麼 |
|---|------|------|---------|
| 1 | 確認 Landing + EmailGate 風格是否 OK | 下次 session 開始 | 解鎖後續頁面開發 |

### 🤖 Agent 可自動跑（下一個 session）

| # | 任務 | 誰 | 前置條件 |
|---|------|---|---------|
| 1 | 上傳照片頁重寫（Mobbin 搜 → code） | 德德 | Landing 確認 OK |
| 2 | Processing 頁重寫 | 德德 | 上傳頁完成 |
| 3 | Results 總覽頁重寫 | 德德 | Processing 完成 |
| 4 | 藥品卡重寫 | 德德 | Results 完成 |
| 5 | 鎖住功能 CTA 重寫 | 德德 | Results 完成 |
| 6 | 全部完成後 git commit + push | 德德 | 所有頁面完成 |

---

## 6. 回寫檢查

| 內容 | 應回寫到 | 狀態 |
|------|---------|------|
| 設計風格方向決策 | 本 LOG 已記錄 | ✅ |
| Mobbin MCP 使用經驗 | 不二錯（deep 模式不穩） | ⏳ |
| Living Status Doc | N/A（非模組狀態變更） | N/A |
| Ticket DB | N/A（本次無 Ticket） | N/A |
| Skill 同步鏈路 | N/A（本次無 Skill 改版） | N/A |
| **本次 LOG** | **Session LOG DB** | **⏳** |

---

## 7. HANDOFF 摘要

**狀態**：Landing + EmailGate 已用新風格重寫並 preview 驗證。CSS 全域變數已更新（漸層背景、新色票、去 emoji）。還有 4 頁待做。

**下一步**：
1. 上傳照片頁 — 先 Mobbin 搜 `photo upload medical document scan`
2. Processing 頁 — 搜 `loading processing AI analysis`
3. Results 總覽頁 — 搜 `medical summary dashboard card list`
4. 藥品卡 + 鎖住功能 CTA

**阻塞**：無

**開發流程**：每頁走 Mobbin benchmark → 風格對齊 → code → preview → 確認

**技術備註**：
- Mobbin MCP 用 fast 模式比 deep 穩定
- Figma MCP 可用但目前定義為「最後才用」，不在中間當翻譯層
- Preview server 設定在 .claude/launch.json，`npm run dev` on port 3000

---

## 8. 關鍵觀察

有了 Mobbin MCP 後，設計決策的品質明顯提升。以前是「憑感覺寫 UI」，現在可以先看 10 個真實產品的做法，再做有依據的選擇。特別是「四款 App 風格比較」的討論方式（Alan vs Alma vs Ahead vs Headspace），讓鴿王能精確表達「要什麼不要什麼」，大幅減少來回修改。

**最有價值的洞察**：「不需要 Figma 中間層」— 當最終產出就是 code 時，直接在 code 裡做設計反而更快更準確。Figma 應該留給「需要交給其他設計師」或「App 版本規格書」的場景。
