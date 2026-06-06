"use client";
import { useEffect, useState } from "react";

const STEPS = [
  { text: "辨識文件中", sub: "掃描醫療單據內容" },
  { text: "提取醫療資訊", sub: "整理用藥、行程、注意事項" },
  { text: "整理成懶人包", sub: "生成你專屬的照護指南" },
];

export default function Processing() {
  const [i, setI] = useState(0);
  const [visible, setVisible] = useState(true);
  const [done, setDone] = useState<boolean[]>([false, false, false]);

  useEffect(() => {
    const t = setInterval(() => {
      setVisible(false);
      setTimeout(() => {
        setI((p) => {
          const next = (p + 1) % STEPS.length;
          if (p < STEPS.length - 1) {
            setDone((d) => { const n = [...d]; n[p] = true; return n; });
          }
          return next;
        });
        setVisible(true);
      }, 300);
    }, 2600);
    return () => clearInterval(t);
  }, []);

  return (
    <section style={{ flex: 1, display: "flex", flexDirection: "column" }}>

      {/* ── Orb hero ─────────────────────────── */}
      <div style={{
        background: "linear-gradient(155deg, #2E6B52 0%, #4A8C72 45%, #9DCDB8 100%)",
        flex: "0 0 52vh",
        display: "flex", flexDirection: "column",
        alignItems: "center", justifyContent: "center",
        position: "relative", overflow: "hidden",
      }}>
        {/* Orb */}
        <div className="orb-glow" style={{
          width: 200, height: 200, borderRadius: "50%",
          background: "radial-gradient(circle at 40% 38%, rgba(200,240,220,0.55) 0%, rgba(160,210,190,0.35) 35%, rgba(120,180,160,0.18) 65%, transparent 100%)",
          filter: "blur(16px)",
          position: "absolute",
        }} />
        {/* Brand icon inside orb */}
        <div style={{
          width: 72, height: 72, borderRadius: 22,
          background: "rgba(255,255,255,0.2)",
          border: "1.5px solid rgba(255,255,255,0.35)",
          backdropFilter: "blur(12px)",
          display: "flex", alignItems: "center", justifyContent: "center",
          zIndex: 1,
        }}>
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
          </svg>
        </div>

        {/* Step text */}
        <div style={{
          position: "absolute", bottom: 36,
          opacity: visible ? 1 : 0,
          transition: "opacity 0.3s ease",
          textAlign: "center",
        }}>
          <p style={{ fontSize: 18, fontWeight: 700, color: "#fff", marginBottom: 4 }}>{STEPS[i].text}</p>
          <p style={{ fontSize: 13, color: "rgba(255,255,255,0.75)" }}>{STEPS[i].sub}</p>
        </div>

        {/* Step dots */}
        <div style={{ position: "absolute", bottom: 14, display: "flex", gap: 7 }}>
          {STEPS.map((_, idx) => (
            <div key={idx} style={{
              width: idx === i ? 22 : 6, height: 6, borderRadius: 3,
              background: idx === i ? "rgba(255,255,255,0.9)" : "rgba(255,255,255,0.35)",
              transition: "all 0.35s ease",
            }} />
          ))}
        </div>
      </div>

      {/* ── Step checklist ─────────────────────── */}
      <div className="page-body" style={{ paddingTop: 24 }}>
        <p style={{ fontSize: 12, fontWeight: 700, color: "var(--text3)", letterSpacing: 1.5, textTransform: "uppercase", marginBottom: 16 }}>
          進度
        </p>

        {STEPS.map((step, idx) => {
          const isActive = idx === i;
          const isDone = done[idx];
          return (
            <div key={idx} style={{
              display: "flex", alignItems: "center", gap: 14,
              padding: "14px 16px", borderRadius: 14,
              marginBottom: 10,
              background: isActive ? "var(--greenBg)" : "var(--card)",
              border: `1px solid ${isActive ? "rgba(127,182,158,0.3)" : "var(--border)"}`,
              transition: "all 0.4s ease",
            }}>
              <div style={{
                width: 28, height: 28, borderRadius: "50%", flexShrink: 0,
                display: "flex", alignItems: "center", justifyContent: "center",
                background: isDone ? "var(--greenDk)" : isActive ? "var(--green)" : "var(--bg3)",
                transition: "background 0.4s ease",
              }}>
                {isDone ? (
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="20 6 9 17 4 12"/>
                  </svg>
                ) : isActive ? (
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#fff" }} />
                ) : (
                  <div style={{ width: 8, height: 8, borderRadius: "50%", background: "var(--text3)" }} />
                )}
              </div>
              <div>
                <p style={{ fontSize: 15, fontWeight: isActive ? 700 : 500, color: isActive ? "var(--greenDk)" : "var(--text2)" }}>
                  {step.text}
                </p>
                <p style={{ fontSize: 12, color: "var(--text3)", marginTop: 1 }}>{step.sub}</p>
              </div>
            </div>
          );
        })}

        <p style={{ textAlign: "center", fontSize: 13, color: "var(--text3)", marginTop: 8 }}>
          約需 10–20 秒 · 照片不會被儲存
        </p>
      </div>
    </section>
  );
}
