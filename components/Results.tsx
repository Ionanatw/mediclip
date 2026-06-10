"use client";
import { useState } from "react";
import type { CareDocResult } from "@/lib/types";
import LockedFeature from "./LockedFeature";
import { fileToCompressedBase64 } from "@/lib/imageResize";

const Ic = {
  back: (c: string) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>,
  share: (c: string) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 12v7a2 2 0 002 2h12a2 2 0 002-2v-7M16 6l-4-4-4 4M12 2v13" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>,
  tabMeds: (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="6" y="2" width="12" height="20" rx="6" stroke={c} strokeWidth="2" /><line x1="6" y1="12" x2="18" y2="12" stroke={c} strokeWidth="1.5" /></svg>,
  tabSchedule: (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="17" rx="3" stroke={c} strokeWidth="2" /><path d="M3 10h18M8 2v4M16 2v4" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>,
  tabWarn: (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 20h20L12 2z" stroke={c} strokeWidth="2" strokeLinejoin="round" /><path d="M12 10v4M12 16.5v.5" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>,
  tabLabs: (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 3v6l-4 8a2 2 0 001.8 3h10.4a2 2 0 001.8-3l-4-8V3" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /><path d="M9 3h6" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>,
  tabNotes: (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2v10z" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>,
  warnTri: (c: string) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 20h20L12 2z" fill={c} fillOpacity="0.15" stroke={c} strokeWidth="1.8" strokeLinejoin="round" /><path d="M12 10v4" stroke={c} strokeWidth="2" strokeLinecap="round" /><circle cx="12" cy="17" r="1" fill={c} /></svg>,
  download: (c: string) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 3v12m0 0l-4-4m4 4l4-4M4 17v2a2 2 0 002 2h12a2 2 0 002-2v-2" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>,
  calendar: (c: string) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="17" rx="3" stroke={c} strokeWidth="2" /><path d="M3 10h18M8 2v4M16 2v4M8 14h2M14 14h2M8 18h2" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>,
};

function Pill({ label, color, bg }: { label: string; color: string; bg: string }) {
  return <span style={{ fontSize: 11.5, fontWeight: 600, color, background: bg, padding: "3px 8px", borderRadius: 6, whiteSpace: "nowrap" }}>{label}</span>;
}

function SevDot({ color }: { color: string }) {
  return <svg width="12" height="12" viewBox="0 0 12 12"><circle cx="6" cy="6" r="5" fill={color} /></svg>;
}

function DrugCapsule({ c1, c2 }: { c1: string; c2: string }) {
  return <svg width="44" height="44" viewBox="0 0 44 44" fill="none"><rect x="8" y="12" width="28" height="20" rx="10" fill={c1} /><rect x="8" y="12" width="14" height="20" rx="10" fill={c2} /></svg>;
}
function DrugTablet({ c1 }: { c1: string }) {
  return <svg width="44" height="44" viewBox="0 0 44 44" fill="none"><circle cx="22" cy="22" r="14" fill={c1} /><line x1="10" y1="22" x2="34" y2="22" stroke="#fff" strokeWidth="1.5" strokeOpacity="0.5" /></svg>;
}
function DrugPowder({ c1 }: { c1: string }) {
  return <svg width="44" height="44" viewBox="0 0 44 44" fill="none"><path d="M10 14h24l-3 20H13L10 14z" fill={c1} /><path d="M8 14h28" stroke={c1} strokeWidth="2.5" strokeLinecap="round" /><circle cx="18" cy="24" r="1.5" fill="#fff" fillOpacity="0.4" /><circle cx="24" cy="22" r="1" fill="#fff" fillOpacity="0.4" /><circle cx="22" cy="28" r="1.5" fill="#fff" fillOpacity="0.4" /></svg>;
}

type Tab = "meds" | "schedule" | "warnings" | "labs" | "notes";
const TABS: { key: Tab; label: string; icon: (c: string) => React.ReactNode }[] = [
  { key: "meds", label: "用藥", icon: Ic.tabMeds },
  { key: "schedule", label: "行程", icon: Ic.tabSchedule },
  { key: "warnings", label: "注意", icon: Ic.tabWarn },
  { key: "labs", label: "檢驗", icon: Ic.tabLabs },
  { key: "notes", label: "醫囑", icon: Ic.tabNotes },
];

function getShapeComponent(shape?: string) {
  if (!shape) return DrugTablet;
  if (shape.includes("膠囊")) return DrugCapsule;
  if (shape.includes("粉")) return DrugPowder;
  return DrugTablet;
}

export default function Results({
  result,
  onRollingUpdate,
}: {
  result: CareDocResult;
  onRollingUpdate: (imgs: { type: string; data: string }[], text: string) => void;
}) {
  const [tab, setTab] = useState<Tab>("meds");

  const tabCounts: Record<Tab, number> = {
    meds: result.medication.length + result.treatments.length,
    schedule: result.schedule.length,
    warnings: result.precautions.length + result.warnings.length,
    labs: result.lab_tests.length,
    notes: result.doctor_responses.length,
  };

  const divider = "1px solid rgba(120,100,80,0.08)";

  return (
    <section style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", background: "var(--bg)", minHeight: "100dvh", paddingTop: 12 }}>

      {/* Nav */}
      <div style={{ width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", display: "flex", alignItems: "center", height: 50, flexShrink: 0, position: "relative" }}>
        <div style={{ width: 38, height: 38, borderRadius: "50%", background: "rgba(127,182,158,0.12)", display: "flex", alignItems: "center", justifyContent: "center" }}>
          {Ic.back("var(--brand-dk)")}
        </div>
        <div style={{ position: "absolute", left: 0, right: 0, textAlign: "center", fontWeight: 700, fontSize: 18, pointerEvents: "none" }}>整理結果</div>
        <div style={{ marginLeft: "auto", width: 38, height: 38, borderRadius: "50%", background: "rgba(127,182,158,0.12)", display: "flex", alignItems: "center", justifyContent: "center" }}>
          {Ic.share("var(--text3)")}
        </div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", overflow: "auto", display: "flex", flexDirection: "column", gap: 14, paddingTop: 4, paddingBottom: 140 }}>

        {/* Summary — left accent bar */}
        <div className="a0" style={{ paddingLeft: 14, borderLeft: "4px solid var(--brand)" }}>
          <div style={{ fontWeight: 900, fontSize: 18, lineHeight: 1.35 }}>{result.summary || "照護懶人包"}</div>
          {(result.patient_name || result.doctor_name) && (
            <div style={{ fontWeight: 700, fontSize: 15, color: "var(--brand-dk)", marginTop: 2 }}>
              {[result.patient_name && `病人：${result.patient_name}`, result.doctor_name && `醫師：${result.doctor_name}`].filter(Boolean).join("　")}
            </div>
          )}
          <div style={{ fontSize: 12, color: "var(--text3)", marginTop: 4 }}>
            {[
              result.documents.length > 0 && `${result.documents.length} 文件`,
              result.medication.length > 0 && `${result.medication.length} 藥物`,
              result.schedule.length > 0 && `${result.schedule.length} 行程`,
              result.precautions.length > 0 && `${result.precautions.length} 注意事項`,
            ].filter(Boolean).join(" ｜ ")}
          </div>
        </div>

        {/* Warning banner */}
        {result.warnings.length > 0 && (
          <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 14px", borderRadius: 12, background: "var(--warning-bg)" }}>
            {Ic.warnTri("var(--warning)")}
            <div style={{ fontSize: 13, color: "var(--warning)", lineHeight: 1.4, fontWeight: 500 }}>{result.warnings[0]}</div>
          </div>
        )}

        {/* Tab bar */}
        <div className="a1" style={{ display: "flex", gap: 8, overflow: "auto", flexShrink: 0, padding: "4px 0" }}>
          {TABS.map((t) => {
            const on = t.key === tab;
            const count = tabCounts[t.key];
            return (
              <div key={t.key} onClick={() => setTab(t.key)} style={{
                display: "flex", alignItems: "center", gap: 5, padding: "8px 14px", borderRadius: 999,
                background: on ? "var(--brand)" : "var(--surface2)",
                color: on ? "#fff" : "var(--text2)",
                fontWeight: 600, fontSize: 13.5, whiteSpace: "nowrap", cursor: "pointer", flexShrink: 0,
              }}>
                {t.icon(on ? "#fff" : "var(--text3)")}
                {t.label}
                <span style={{ fontSize: 11, fontWeight: 700, background: on ? "rgba(255,255,255,0.25)" : "var(--surface3)", color: on ? "#fff" : "var(--text3)", borderRadius: 8, padding: "1px 6px", minWidth: 16, textAlign: "center" }}>{count}</span>
              </div>
            );
          })}
        </div>

        {/* Tab content */}
        <div className="a2" style={{ background: "var(--card)", borderRadius: 16, padding: "16px 14px", display: "flex", flexDirection: "column", gap: 14 }}>
          {tab === "meds" && (
            <>
              {result.treatments.map((t, i) => (
                <div key={`t${i}`} style={{ paddingBottom: 14, borderBottom: divider }}>
                  <div style={{ fontWeight: 700, fontSize: 16 }}>{t.name}</div>
                  {t.schedule && <div style={{ fontSize: 13, color: "var(--text3)", marginTop: 2 }}>{t.schedule}</div>}
                  {t.notes && <div style={{ fontSize: 13, color: "var(--text2)", marginTop: 4 }}>{t.notes}</div>}
                </div>
              ))}
              {result.medication.map((m, i) => {
                const Shape = getShapeComponent(m.shape);
                return (
                  <div key={`m${i}`} style={{ paddingBottom: 14, borderBottom: i < result.medication.length - 1 ? divider : "none" }}>
                    <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
                      <div style={{ width: 52, height: 52, borderRadius: 12, background: "var(--surface2)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                        <Shape c1={m.color?.includes("紅") || m.color?.includes("橘") ? "#E8D5A8" : "#E0D8CC"} c2={m.color?.includes("紅") ? "#D97757" : "#B8C9D6"} />
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontWeight: 700, fontSize: 16 }}>{m.name_zh}</div>
                        {m.name_en && <div style={{ fontSize: 12, color: "var(--text3)", marginBottom: 6 }}>{m.name_en} {m.dosage || ""}</div>}
                        <div style={{ display: "flex", gap: 5, flexWrap: "wrap" }}>
                          {m.frequency && <Pill label={m.frequency} color="var(--brand-dk)" bg="var(--brand-bg)" />}
                          {m.meal_relation && <Pill label={m.meal_relation} color="var(--brand-dk)" bg="var(--brand-bg)" />}
                          {m.duration && <Pill label={m.duration} color="var(--brand-dk)" bg="var(--brand-bg)" />}
                        </div>
                        {m.route && <div style={{ fontSize: 13, color: "var(--text2)", marginTop: 6 }}>{m.route}</div>}
                      </div>
                    </div>
                    {m.notes && (
                      <div style={{ marginTop: 10, marginLeft: 64, display: "flex", alignItems: "center", gap: 6, fontSize: 13, color: "var(--warning)", fontWeight: 500 }}>
                        {Ic.warnTri("var(--warning)")}
                        <span>{m.notes}</span>
                      </div>
                    )}
                  </div>
                );
              })}
              {result.medication.length === 0 && result.treatments.length === 0 && (
                <div style={{ color: "var(--text3)", fontSize: 14, textAlign: "center", padding: 20 }}>此次未擷取到用藥資訊</div>
              )}
            </>
          )}

          {tab === "schedule" && (
            <>
              {result.schedule.map((e, i) => {
                const day = e.date?.match(/(\d+)日?$/)?.[1] || e.date?.slice(-2) || "—";
                return (
                  <div key={i} style={{ display: "flex", gap: 14, alignItems: "flex-start", paddingBottom: 14, borderBottom: i < result.schedule.length - 1 ? divider : "none" }}>
                    <div style={{ width: 42, height: 42, borderRadius: "50%", background: "var(--brand)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: 800, fontSize: 17, flexShrink: 0 }}>{day}</div>
                    <div style={{ flex: 1, paddingTop: 2 }}>
                      <div style={{ fontWeight: 700, fontSize: 15 }}>{e.event}</div>
                      {e.date && <div style={{ fontSize: 13, color: "var(--text3)", marginTop: 2 }}>{e.date} {e.time || ""}</div>}
                      {e.location && <div style={{ fontSize: 12, color: "var(--text3)", marginTop: 2 }}>{e.location}</div>}
                      {e.notes && <div style={{ fontSize: 12, color: "var(--text3)", marginTop: 4 }}>{e.notes}</div>}
                    </div>
                  </div>
                );
              })}
              {result.schedule.length === 0 && (
                <div style={{ color: "var(--text3)", fontSize: 14, textAlign: "center", padding: 20 }}>此次未擷取到行程</div>
              )}
            </>
          )}

          {tab === "warnings" && (
            <>
              {[...result.precautions]
                .sort((a, b) => {
                  const order: Record<string, number> = { "知道就好": 0, "注意": 1, "必做": 2 };
                  return (order[a.severity] ?? 1) - (order[b.severity] ?? 1);
                })
                .map((w, i) => {
                  const sevColor = w.severity === "必做" ? "var(--warning)" : w.severity === "注意" ? "var(--amber)" : "var(--brand)";
                  const dotColor = w.severity === "必做" ? "#D97757" : w.severity === "注意" ? "#C9A862" : "#5A9A7D";
                  const sevLabel = w.severity === "必做" ? "必遵守" : w.severity;
                  return (
                    <div key={i} style={{ display: "flex", gap: 12, alignItems: "flex-start", paddingBottom: 14, borderBottom: i < result.precautions.length - 1 ? divider : "none" }}>
                      <div style={{ paddingTop: 3, flexShrink: 0 }}><SevDot color={dotColor} /></div>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 4 }}>
                          <span style={{ fontSize: 12, fontWeight: 600, color: sevColor }}>{sevLabel}</span>
                          <span style={{ fontSize: 11.5, color: "var(--text3)" }}>·</span>
                          <span style={{ fontSize: 12, color: "var(--text3)" }}>{w.category}</span>
                        </div>
                        <div style={{ fontSize: 14, lineHeight: 1.5 }}>{w.description}</div>
                      </div>
                    </div>
                  );
                })}
              {result.precautions.length === 0 && (
                <div style={{ color: "var(--text3)", fontSize: 14, textAlign: "center", padding: 20 }}>此次未擷取到注意事項</div>
              )}
            </>
          )}

          {tab === "labs" && (
            <>
              {result.lab_tests.map((l, i) => (
                <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingBottom: 14, borderBottom: i < result.lab_tests.length - 1 ? divider : "none" }}>
                  <div>
                    <div style={{ fontWeight: 700, fontSize: 15 }}>{l.name}</div>
                    {l.name_en && <div style={{ fontSize: 12, color: "var(--text3)", marginTop: 2 }}>{l.name_en}</div>}
                  </div>
                  <div style={{ display: "flex", gap: 6, flexShrink: 0 }}>
                    {l.date && <Pill label={l.date} color="var(--text2)" bg="var(--surface2)" />}
                    {l.fasting && <Pill label="需空腹" color="var(--warning)" bg="var(--warning-bg)" />}
                  </div>
                </div>
              ))}
              {result.lab_tests.length === 0 && (
                <div style={{ color: "var(--text3)", fontSize: 14, textAlign: "center", padding: 20 }}>此次未擷取到檢驗項目</div>
              )}
            </>
          )}

          {tab === "notes" && (
            <>
              {result.doctor_responses.map((n, i) => {
                const statusColor = n.status === "已解決" ? "var(--brand)" : n.status === "待觀察" ? "var(--amber)" : "var(--warning)";
                return (
                  <div key={i} style={{ paddingBottom: 14, borderBottom: i < result.doctor_responses.length - 1 ? divider : "none" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
                      <div style={{ fontWeight: 700, fontSize: 15, flex: 1 }}>{n.question}</div>
                      {n.status && <Pill label={n.status} color={statusColor} bg={`${statusColor}18`} />}
                    </div>
                    <div style={{ fontSize: 14, color: "var(--text2)", lineHeight: 1.5 }}>{n.answer}</div>
                  </div>
                );
              })}
              {result.doctor_responses.length === 0 && (
                <div style={{ color: "var(--text3)", fontSize: 14, textAlign: "center", padding: 20 }}>此次未擷取到醫囑</div>
              )}
            </>
          )}
        </div>

        {/* Action cards */}
        <div style={{ display: "flex", gap: 10, marginTop: 4 }}>
          {[
            { icon: Ic.download, label: "下載海報" },
            { icon: Ic.calendar, label: "加入行事曆" },
          ].map((item) => (
            <div key={item.label} style={{ flex: 1, background: "var(--card)", border: "1.5px solid var(--surface3)", borderRadius: 14, padding: "14px 12px", textAlign: "center", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
              {item.icon("var(--text3)")}
              <div style={{ fontSize: 13, fontWeight: 600, color: "var(--text2)" }}>{item.label}</div>
            </div>
          ))}
        </div>

        <LockedFeature title="白話版注意事項" cta="下載 App 看白話翻譯 →" />
      </div>

      {/* Fixed bottom banner */}
      <div style={{ position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 10, background: "var(--brand-dk)", display: "flex", alignItems: "center", justifyContent: "center", gap: 12, padding: "14px 20px 28px" }}>
        <div style={{ fontSize: 14, color: "#fff", fontWeight: 500, flex: 1 }}>想要推播提醒、白話翻譯？</div>
        <button style={{ height: 36, padding: "0 16px", borderRadius: 999, border: "none", background: "#fff", color: "var(--brand-dk)", fontFamily: "inherit", fontWeight: 700, fontSize: 13, cursor: "pointer", whiteSpace: "nowrap", flexShrink: 0 }}>下載 App →</button>
      </div>
    </section>
  );
}
