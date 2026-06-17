# Carrius 改版驗收 + UI polish + web 震動提示 LOG — 2026-06-18

## 0. 文件資訊
- **建立時間**：2026-06-18 02:41 GMT+8
- **建立者**：德德（Claude Code / Opus 4.8）
- **Session 日期**：2026-06-17 深夜 → 2026-06-18 凌晨
- **對話串**：德德（Claude Code，本機 Mac）
- **檔案路徑**：docs/LOG德德-260618-改版驗收_UIpolish修正_web震動提示_兩repo部署.md
- **HEAD（兩 repo 同步並驗 SHA）**：`69bc2cd`｜gh-pages：`e0ae92e`
- **Live demo**：https://ionanatw.github.io/mediclip/

### 關聯資源索引
| 資源 | 位置 | 路徑/連結 |
|------|------|------|
| 上一份 LOG（改版實作） | repo | docs/LOG德德-260617-UI改版實作_導覽_花園_首頁_對抗式review.md |
| 互動驗證技法（已更正） | memory | carrius-web-demo-deploy.md |
| 兩 repo 推法 | memory | mediclip-two-github-accounts.md |

---

## 📎 貼進新 Session 的交接文字（複製貼上即用）
```
我是鴿王，你是德德（Claude Code），請先閱讀上一次 Session LOG 延續記憶：
讀取 docs/LOG德德-260618-改版驗收_UIpolish修正_web震動提示_兩repo部署.md

閱讀完畢後，重點交接：
1. 改版已驗收 + 一輪 UI polish 已上線（HEAD 69bc2cd，兩 repo 同步，live: ionanatw.github.io/mediclip）：
   問候依時段(早安/午安/晚安/夜深了)、花園快樂卡右緣漸層(取代硬切)、FAB 不再切內容(checklist 上移/暖泡泡墊底並右側留白給 FAB)、新增 web 限定震動視覺提示(kIsWeb，呼吸/點擊觸發時頂部閃「震動·類型」)。19 測試綠、4 golden 更新。
2. 仍待鴿王拍板：① 樹三版長相(塗鴉風佔位，適合走多代理 workflow 出比較圖) ② 快樂小精靈罐(concept 在 docs/carrius-garden-concept.md) ③ 「記一筆/加提醒」是否做真、AI 整理後端(需 Supabase + ANTHROPIC_API_KEY，金鑰只能鴿王設)。
3. 驗收 Flutter Web live demo 可直接點擊操作了——技法見記憶 [[carrius-web-demo-deploy]]（打 flt-glass-pane）。Alan 是設計北極星。
```

---

## 1. TL;DR
- **做了什麼**：陪鴿王把整套已上線的改版逐頁驗收（本機 build + 截圖，含深淺色），驗收中發現並修掉 3 類 polish 問題，並回答「web 怎麼驗震動」這個盲區、補上 web 震動視覺提示。
- **產出什麼**：1 個 commit（`69bc2cd`，5 檔 lib + golden×4 + .gitignore），推上兩 repo + 重部署 gh-pages，雜湊驗證 live = 新 build。
- **下一步**：鴿王拍板樹三版／小精靈罐／核心做真。

---

## 2. 決策紀錄

### 決策 1：問候改時段化（取代固定「早安」）
- **最終方案**：`HomeScreen` 加 `nowHour` 參數，依時段回早安/午安/晚安/夜深了；`nowHour` 預設 null＝跟系統時鐘。
- **原因**：固定早安在非早上很出戲；參數化是為了讓 golden 保持決定性（測試 pin `nowHour: 9`＝早安，golden 不因實際時間浮動）。
- **替代方案**：直接用 `DateTime.now()`（否決：golden 會 flaky）。

### 決策 2：FAB 重疊用「重排 + 留白」而非「縮間距/隱藏 FAB」
- **最終方案**：① 五分頁底部 padding 120→150（保證捲到底讓得開）② 首頁把 checklist（右側有 3/8 數字）上移、暖陪伴泡泡墊到最底 ③ 泡泡 Row 右側保留 50px 空欄 → FAB 浮在泡泡空白背景上、**不碰任何文字**。
- **原因**：375×812 這種「內容≈一屏、又無真機安全區」的短視窗，最後一列與右下角 FAB 幾何上必然共用底部；padding 只能解決捲動，靜止重疊得靠重排。重排還順帶把結尾收在「我陪你一起顧媽媽」更溫暖。
- **替代方案**：收緊已認可的間距（否決：動到鴿王拍板過的視覺節奏）；FAB 捲動淡出/隱藏（否決：首頁就藏主要動作不合理）。

### 決策 3：web 震動「無法觸感、但可驗時機」→ 加 kIsWeb 視覺提示
- **最終方案**：`haptics.dart` 加 `HapticDebug`（kIsWeb 才 pulse）＋ `main.dart` 用 `MaterialApp.builder` 在所有 route 之上掛 `_HapticDebugOverlay`，震動觸發時頂部閃「📳 震動·類型」650ms。真機（非 web）不掛。
- **原因**：Flutter Web 的 `HapticFeedback` 是 no-op，live demo 永遠摸不到震動；視覺提示讓鴿王在 web 上至少能驗「對的動作觸發對的震動」。觸感本身仍須真機。
- **替代方案**：web 不做（否決：鴿王明確要在 web 驗時機）。

---

## 3. 產出清單
| # | 名稱 | 類型 | 路徑 | 狀態 |
|---|------|------|------|------|
| 1 | 問候時段化 | code | lib/screens/home_screen.dart | ✅ |
| 2 | FAB 不切內容（重排+留白+padding） | code | home_screen.dart + 4 分頁 | ✅ |
| 3 | 花園快樂卡右緣漸層 ShaderMask | code | lib/screens/garden_screen.dart | ✅ |
| 4 | web 震動視覺提示 | code | lib/design/haptics.dart, lib/main.dart | ✅ |
| 5 | golden 更新（home×2 / garden×2） | test | test/goldens/ | ✅ |
| 6 | commit + 兩 repo push + gh-pages 部署 | ops | HEAD 69bc2cd / gh-pages e0ae92e | ✅ |

驗證：`flutter analyze` 零 error/warning；`flutter test` **19 全綠**；live demo `main.dart.js` sha256 與本地 build 一致（`b98fcc5…`）、HTTP 200。

---

## 4. 除錯與教訓

### 除錯 1：合成 PointerEvent 驅動不了 Flutter Web → 其實是打錯層
- **問題**：對 `flutter-view` 派 PointerEvent，tap 沒反應，無法走 onboarding。
- **根因**：Flutter 的 pointer listener 在子層 `flt-glass-pane`，事件派到父層 `flutter-view` 只會往上冒泡、不會往下傳到 glass-pane。
- **解法**：改派到 `document.querySelector('flt-glass-pane')`，序列 `pointerdown→pointermove→pointerup`（composed:true）；TextField 則先 tap 聚焦、下一個 eval 用 input value setter 塞值＋派 InputEvent。
- **教訓**：舊記憶說「合成事件驅動不了 gesture arena」是錯的——是目標層錯。已更正 [[carrius-web-demo-deploy]]。
- **🔁 寫進不二錯？**：否（屬技法更正，已寫進記憶；非鴿舍跨串通用錯誤）。

### 除錯 2：底部 padding 加大無法消除「靜止時」重疊
- **問題**：以為 120→150 能修 FAB 切 checklist。
- **根因**：padding 在內容尾端，不改變 top-rest 時各列位置；短視窗下最後一列仍落在 FAB 帶。
- **解法**：改用「重排底部兩元件 + 泡泡右側留白」。
- **教訓**：固定浮層 FAB 與捲動內容的「靜止重疊」要靠版位，不是 padding。

---

## 5. TODO

### 🙋 鴿王要做
| # | 任務 | 時間 | 解鎖什麼 |
|---|------|------|---------|
| 1 | 重整 live demo 驗收這批 polish | 隨時 | 確認上線品質 |
| 2 | 拍板**樹三版長相**（塗鴉風佔位） | 待做比較圖 | 花園主角定裝 |
| 3 | 決定**快樂小精靈罐**（concept 已存） | — | 樹的替代/夥伴 |
| 4 | 決定「記一筆/加提醒」是否做真、AI 後端金鑰 | 阻塞 | 從「能看」走向「能用」 |

### 🤖 Agent 可自動跑
| # | 任務 | 誰 | 票號 | 前置條件 |
|---|------|---|------|---------|
| 1 | 樹三版設計：多代理 workflow 出比較圖 | 德德 | 本輪新票 | 鴿王說 go |

---

## 6. 回寫檢查
| 內容 | 應回寫到 | Notion 已同步？ | 狀態 |
|------|---------|---------------|------|
| 互動驗證技法更正 | memory carrius-web-demo-deploy | —（本地 memory） | ✅ |
| 本輪工作新票 | Notion Ticket DB | ⏳ | ⏳（本 session 開立） |
| Session LOG 本身 | Notion Session LOG DB | ⏳ | ⏳（Step 4 同步中） |

---

## 7. HANDOFF 摘要
**狀態**：改版已驗收，一輪 UI polish 上線（HEAD 69bc2cd，兩 repo + live 同步，19 測試綠）。
**下一步**：鴿王拍板樹三版（建議走 workflow）／小精靈罐／核心做真。
**阻塞**：樹長相與小精靈罐待鴿王；AI 後端需鴿王設 ANTHROPIC_API_KEY。

---

## 8. 關鍵觀察
這輪從「驗收」自然長出「polish」：逐頁看反而逼出 FAB 重疊、問候出戲、花園硬切這些「實作完才看得到」的細節。最有價值的副產物是**打通了 Flutter Web 的互動驗收**——以後 live demo 能直接點，不必每件事都回頭寫 widget test。app 的「視覺溫度＋互動誠實」層已很完整，剩下的全是鴿王的設計/產品拍板（樹、罐、做真）。
