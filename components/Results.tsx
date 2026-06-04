"use client";
import { useState } from "react";
import type { CareDocResult } from "@/lib/types";
import OverviewCards from "./OverviewCards";
import DrugCard from "./DrugCard";
import CalendarList from "./CalendarList";
import Checklist from "./Checklist";
import HappyGarden from "./HappyGarden";
import LockedFeature from "./LockedFeature";
import FinalCTA from "./FinalCTA";
import { fileToCompressedBase64 } from "@/lib/imageResize";

export default function Results({
  result,
  onRollingUpdate,
}: {
  result: CareDocResult;
  onRollingUpdate: (imgs: { type: string; data: string }[], text: string) => void;
}) {
  const [usedRolling, setUsedRolling] = useState(false);
  const [busy, setBusy] = useState(false);

  async function pickMore(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files || []).slice(0, 3);
    if (!files.length) return;
    setBusy(true);
    const imgs = [];
    for (const f of files) imgs.push(await fileToCompressedBase64(f));
    setUsedRolling(true);
    setBusy(false);
    onRollingUpdate(imgs, "");
    e.target.value = "";
  }

  return (
    <section style={{ paddingTop: 16 }}>
      <h2 className="h2">你的照護懶人包 🌿</h2>
      <OverviewCards r={result} />
      {result.medication.length > 0 && (
        <>
          <div className="h2" style={{ fontSize: 19, margin: "8px 0" }}>💊 藥品識別卡</div>
          {result.medication.map((m, i) => <DrugCard key={i} med={m} />)}
        </>
      )}
      <CalendarList items={result.schedule} />
      <Checklist result={result} />
      <HappyGarden />

      {/* 滾動更新（限 1 次） */}
      {!usedRolling ? (
        <label className="btn-secondary" style={{ display: "block", textAlign: "center", opacity: busy ? 0.6 : 1 }}>
          {busy ? "處理中…" : "＋ 補充新文件（滾動更新，限 1 次）"}
          <input type="file" accept="image/*" multiple hidden disabled={busy} onChange={pickMore} />
        </label>
      ) : (
        <LockedFeature title="🔄 滾動更新" cta="下載 App 無限滾動更新 →" />
      )}

      {/* 鎖住功能 */}
      <LockedFeature title="📲 .ics 行事曆匯出" cta="下載 App 一鍵加入手機行事曆 →" />
      <LockedFeature title="💊 白話版用藥注意事項" cta="下載 App 看白話翻譯 →" />
      <LockedFeature title="📋 照護海報" cta="下載 App 列印海報 →" />

      <FinalCTA />
    </section>
  );
}
