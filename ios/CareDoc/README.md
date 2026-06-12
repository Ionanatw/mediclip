# Carrius（CareDoc iOS App）

Phantom 設計語言 × 醫療照護懶人包。SwiftUI 原生、零依賴、mock 資料 POC。
設計 spec：`docs/superpowers/specs/2026-06-13-caredoc-ios-phantom-design.md`

## 在這台 Mac 驗證（不需要 Xcode）

CLT 的 SwiftPM 損壞（manifest dylib 版本不符），請用 swiftc 直接編譯跑 macOS 驗證視窗（iPhone 15 Pro 尺寸）：

```bash
cd ios/CareDoc
./build.sh        # 編譯 + 啟動 .build/Carrius
```

macOS 視窗模式下震動自動停用，其餘互動完全一致。

## 有 Xcode 的機器（出真正的 iOS App）

1. 開 `CareDoc.xcodeproj`（需 Xcode 16+）
2. 選 iPhone 模擬器或實機，Run
3. Bundle ID `com.ionachen.carrius`，display name **Carrius**，iOS 17+，iPhone 直向

## 結構

```
Sources/CareDoc/
├── CareDocApp.swift        App 入口 + RootView + 上傳 modal 流程
├── AppState.swift          @Observable 全域狀態（tab、花園、checklist）
├── DesignSystem/
│   ├── Tokens.swift        Phantom 色彩（深淺雙主題）/字體/圓角/動效
│   ├── Components.swift    PillButton、Card、ListRow、Tag、BlurLock…
│   ├── TabBarView.swift    懸浮膠囊 TabBar + 小樹苗 icon
│   ├── Haptics.swift       震動引擎（呼吸節奏/拉回注意力/回饋）
│   └── Illustrations/      櫻花樹 5 階段(A)、藥丸真實外觀(A)、呼吸背景(B)、色塊(C)
├── Models/                 Medication、ScheduleEvent、TreeStage…+ MockData
└── Features/               13 個畫面
```

## 震動設計（iPhone 實機才有感）

- 呼吸練習：吸氣漸強 → 屏息心跳點 → 吐氣漸弱（CoreHaptics 連續曲線）
- AI 完成／久坐：兩短一長「拉回注意力」
- 勾選完成 success、樹升級漸強三連震、tab 輕點、鎖定功能 soft 警示
