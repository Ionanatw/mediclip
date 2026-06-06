"use client";
import { useState } from "react";
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

const TABS: { key: Tab; label: string }[] = [
  { key: "overview", label: "總覽" },
  { key: "meds", label: "用藥" },
  { key: "calendar", label: "行事曆" },
  { key: "todo", label: "待辦" },
  { key: "garden", label: "快樂" },
];

function TabIcon({ tabKey }: { tabKey: Tab }) {
  const base = { width: 20, height: 20, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: "1.8", strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  if (tabKey === "overview") return <svg {...base}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>;
  if (tabKey === "meds") return <svg {...base}><circle cx="12" cy="12" r="7"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>;
  if (tabKey === "calendar") return <svg {...base}><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>;
  if (tabKey === "todo") return <svg {...base}><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>;
  return <svg {...base}><line x1="12" y1="20" x2="12" y2="10"/><path d="M6 4h3a3 3 0 0 1 6 0h3"/></svg>;
}

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
    <section style={{ flex: 1, display: "flex", flexDirection: "column" }}>

      {/* ── Hero ─────────────────────────────── */}
      <div className="a0" style={{
        background: "linear-gradient(155deg, #2E6B52 0%, #4A8C72 45%, #7FB69E 100%)",
        padding: "44px 24px 28px",
        position: "relative", overflow: "hidden",
      }}>
        <div style={{ position: "absolute", top: -40, right: -40, width: 130, height: 130, borderRadius: "50%", background: "rgba(255,255,255,0.07)" }} />
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{
            width: 52, height: 52, borderRadius: 16, flexShrink: 0,
            background: "rgba(255,255,255,0.18)",
            border: "1.5px solid rgba(255,255,255,0.28)",
            backdropFilter: "blur(10px)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
          </div>
          <div>
            <h2 style={{ fontSize: 22, fontWeight: 800, color: "#fff", letterSpacing: -0.3 }}>照護懶人包</h2>
            {(result.patient_name || result.doctor_name) && (
              <p style={{ fontSize: 13, color: "rgba(255,255,255,0.8)", marginTop: 3 }}>
                {[
                  result.patient_name ? `病人：${result.patient_name}` : null,
                  result.doctor_name ? `醫師：${result.doctor_name}` : null,
                ].filter(Boolean).join("　")}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* ── Tab content ─────────────────────── */}
      <div className="page-body a1" style={{ paddingBottom: 100 }}>

        {tab === "overview" && (
          <div>
            <OverviewCards r={result} />
            {!usedRolling ? (
              <label className="btn-secondary" style={{ display: "block", textAlign: "center", opacity: busy ? 0.6 : 1 }}>
                {busy ? "處理中…" : "＋ 補充新文件（滾動更新，限 1 次）"}
                <input type="file" accept="image/*" multiple hidden disabled={busy} onChange={pickMore} />
              </label>
            ) : (
              <LockedFeature title="滾動更新" cta="下載 App 無限滾動更新 →" />
            )}
            <LockedFeature title="照護海報" cta="下載 App 列印海報 →" />
            <FinalCTA />
            <DocumentList items={result.documents} />
          </div>
        )}

        {tab === "meds" && (
          <div>
            <TreatmentList items={result.treatments} />
            {result.medication.length > 0 && (
              <>
                <div className="h2" style={{ fontSize: 17, margin: "8px 0 12px", color: "var(--text2)" }}>帶回家的藥物</div>
                <DosingSchedule meds={result.medication} />
                {result.medication.map((m, i) => <DrugCard key={i} med={m} />)}
              </>
            )}
            {result.treatments.length === 0 && result.medication.length === 0 && (
              <div className="card muted">此次未擷取到療程或用藥資訊。</div>
            )}
            <LockedFeature title="白話版用藥注意事項" cta="下載 App 看白話翻譯 →" />
          </div>
        )}

        {tab === "calendar" && (
          <div>
            {result.schedule.length > 0 ? (
              <CalendarList items={result.schedule} />
            ) : (
              <div className="card muted">此次未擷取到行程。</div>
            )}
            <LockedFeature title=".ics 行事曆匯出" cta="下載 App 一鍵加入手機行事曆 →" />
          </div>
        )}

        {tab === "todo" && <TodoTab result={result} />}
        {tab === "garden" && <HappyGarden />}

      </div>

      {/* ── 底部固定功能列 ─────────────────────── */}
      <nav style={{
        position: "fixed", left: 0, right: 0, bottom: 0, zIndex: 50,
        background: "var(--card)", borderTop: "1px solid var(--bg3)",
        boxShadow: "0 -2px 16px rgba(0,0,0,.07)",
      }}>
        <div style={{ maxWidth: 560, margin: "0 auto", display: "flex" }}>
          {TABS.map((t) => {
            const active = t.key === tab;
            return (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                style={{
                  flex: 1, border: 0, cursor: "pointer", background: "transparent",
                  padding: "10px 0 11px", display: "flex", flexDirection: "column",
                  alignItems: "center", gap: 3,
                  color: active ? "var(--greenDk)" : "var(--text3)",
                  fontWeight: active ? 700 : 400,
                }}
              >
                <TabIcon tabKey={t.key} />
                <span style={{ fontSize: 11 }}>{t.label}</span>
                {active && (
                  <div style={{ width: 18, height: 3, borderRadius: 2, background: "var(--greenDk)", marginTop: 1 }} />
                )}
              </button>
            );
          })}
        </div>
      </nav>
    </section>
  );
}
