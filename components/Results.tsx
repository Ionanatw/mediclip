"use client";
import { useState } from "react";
import type { CareDocResult } from "@/lib/types";
import OverviewCards from "./OverviewCards";
import DosingSchedule from "./DosingSchedule";
import DrugCard from "./DrugCard";
import CalendarList from "./CalendarList";
import TodoTab from "./TodoTab";
import HappyGarden from "./HappyGarden";
import LockedFeature from "./LockedFeature";
import FinalCTA from "./FinalCTA";
import { fileToCompressedBase64 } from "@/lib/imageResize";

type Tab = "overview" | "meds" | "calendar" | "todo" | "garden";

const TABS: { key: Tab; icon: string; label: string }[] = [
  { key: "overview", icon: "📋", label: "總覽" },
  { key: "meds", icon: "💊", label: "用藥" },
  { key: "calendar", icon: "📅", label: "行事曆" },
  { key: "todo", icon: "✅", label: "待辦" },
  { key: "garden", icon: "🌿", label: "快樂" },
];

export default function Results({
  result,
  onRollingUpdate,
}: {
  result: CareDocResult;
  onRollingUpdate: (imgs: { type: string; data: string }[], text: string) => void;
}) {
  const [tab, setTab] = useState<Tab>("overview");
  const [usedRolling, setUsedRolling] = useState(false);
  const [busy, setBusy] = useState(false);

  async function pickMore(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files || []).slice(0, 8);
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
    <section style={{ paddingBottom: 88 }}>
      <h2 className="h2" style={{ marginBottom: 12 }}>你的照護懶人包 🌿</h2>

      {/* 病人 / 醫師 名牌（總是顯示，方便核對） */}
      {(result.patient_name || result.doctor_name) && (
        <div className="card" style={{ display: "flex", gap: 20, fontSize: 16 }}>
          {result.patient_name && <div><span className="muted">病人</span><br /><strong>{result.patient_name}</strong></div>}
          {result.doctor_name && <div><span className="muted">主治醫師</span><br /><strong>{result.doctor_name}</strong></div>}
        </div>
      )}

      {tab === "overview" && (
        <div>
          <OverviewCards r={result} />
          {!usedRolling ? (
            <label className="btn-secondary" style={{ display: "block", textAlign: "center", opacity: busy ? 0.6 : 1 }}>
              {busy ? "處理中…" : "＋ 補充新文件（滾動更新，限 1 次）"}
              <input type="file" accept="image/*" multiple hidden disabled={busy} onChange={pickMore} />
            </label>
          ) : (
            <LockedFeature title="🔄 滾動更新" cta="下載 App 無限滾動更新 →" />
          )}
          <LockedFeature title="📋 照護海報" cta="下載 App 列印海報 →" />
          <FinalCTA />
        </div>
      )}

      {tab === "meds" && (
        <div>
          {result.medication.length > 0 ? (
            <>
              <DosingSchedule meds={result.medication} />
              {result.medication.map((m, i) => <DrugCard key={i} med={m} />)}
            </>
          ) : (
            <div className="card muted">此次未擷取到用藥資訊。</div>
          )}
          <LockedFeature title="💊 白話版用藥注意事項" cta="下載 App 看白話翻譯 →" />
        </div>
      )}

      {tab === "calendar" && (
        <div>
          {result.schedule.length > 0 ? (
            <CalendarList items={result.schedule} />
          ) : (
            <div className="card muted">此次未擷取到行程。</div>
          )}
          <LockedFeature title="📲 .ics 行事曆匯出" cta="下載 App 一鍵加入手機行事曆 →" />
        </div>
      )}

      {tab === "todo" && <TodoTab result={result} />}

      {tab === "garden" && <HappyGarden />}

      {/* 底部固定功能列 */}
      <nav
        style={{
          position: "fixed", left: 0, right: 0, bottom: 0, zIndex: 50,
          background: "var(--card)", borderTop: "1px solid var(--bg3)",
          boxShadow: "0 -2px 12px rgba(120,100,80,.06)",
        }}
      >
        <div style={{ maxWidth: 560, margin: "0 auto", display: "flex" }}>
          {TABS.map((t) => {
            const active = t.key === tab;
            return (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                style={{
                  flex: 1, border: 0, cursor: "pointer", background: "transparent",
                  padding: "8px 0 10px", display: "flex", flexDirection: "column",
                  alignItems: "center", gap: 2,
                  color: active ? "var(--greenDk)" : "var(--text3)",
                  fontWeight: active ? 700 : 400,
                }}
              >
                <span style={{ fontSize: 22, filter: active ? "none" : "grayscale(.4)" }}>{t.icon}</span>
                <span style={{ fontSize: 13 }}>{t.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </section>
  );
}
