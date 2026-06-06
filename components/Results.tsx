"use client";
import React, { useState } from "react";
import type { CareDocResult } from "@/lib/types";
import OverviewCards from "./OverviewCards";
import DocumentList from "./DocumentList";
import TreatmentList from "./TreatmentList";
import DosingSchedule from "./DosingSchedule";
import DrugCard from "./DrugCard";
import CalendarList from "./CalendarList";
import TodoTab from "./TodoTab";
import HappyGarden from "./HappyGarden";
import LockedFeature from "./LockedFeature";
import FinalCTA from "./FinalCTA";
import { fileToCompressedBase64 } from "@/lib/imageResize";

type Tab = "overview" | "meds" | "calendar" | "todo" | "garden";

const TAB_ICONS: Record<Tab, React.ReactNode> = {
  overview: (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
      <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
    </svg>
  ),
  meds: (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M10.5 20H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3.9a2 2 0 0 1 1.69.9l.81 1.2a2 2 0 0 0 1.67.9H20a2 2 0 0 1 2 2v2.5"/>
      <circle cx="17" cy="17" r="5"/><path d="m15 17 2 2 3-3"/>
    </svg>
  ),
  calendar: (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
      <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
      <line x1="3" y1="10" x2="21" y2="10"/>
    </svg>
  ),
  todo: (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="9 11 12 14 22 4"/>
      <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
    </svg>
  ),
  garden: (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 22V12"/><path d="M5 3a7 7 0 0 0 7 7 7 7 0 0 0-7-7"/>
      <path d="M19 3a7 7 0 0 1-7 7 7 7 0 0 1 7-7"/>
    </svg>
  ),
};

const TABS: { key: Tab; label: string }[] = [
  { key: "overview", label: "總覽" },
  { key: "meds", label: "用藥" },
  { key: "calendar", label: "行事曆" },
  { key: "todo", label: "待辦" },
  { key: "garden", label: "快樂" },
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
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
        <div style={{
          width: 36, height: 36, borderRadius: 10, flexShrink: 0,
          background: "linear-gradient(135deg, #7FB69E, #5A9A7D)",
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: "0 2px 8px rgba(90,154,125,.2)",
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
          </svg>
        </div>
        <h2 className="h2">你的照護懶人包</h2>
      </div>

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
          <DocumentList items={result.documents} />
        </div>
      )}

      {tab === "meds" && (
        <div>
          <TreatmentList items={result.treatments} />
          {result.medication.length > 0 && (
            <>
              <div className="h2" style={{ fontSize: 19, margin: "8px 0" }}>💊 帶回家的藥物</div>
              <DosingSchedule meds={result.medication} />
              {result.medication.map((m, i) => <DrugCard key={i} med={m} />)}
            </>
          )}
          {result.treatments.length === 0 && result.medication.length === 0 && (
            <div className="card muted">此次未擷取到療程或用藥資訊。</div>
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
                  padding: "9px 0 10px", display: "flex", flexDirection: "column",
                  alignItems: "center", gap: 3,
                  color: active ? "var(--greenDk)" : "var(--text3)",
                  fontWeight: active ? 700 : 400,
                }}
              >
                {TAB_ICONS[t.key]}
                <span style={{ fontSize: 11 }}>{t.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </section>
  );
}
