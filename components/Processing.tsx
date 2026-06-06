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

  useEffect(() => {
    const t = setInterval(() => {
      setVisible(false);
      setTimeout(() => {
        setI((p) => (p + 1) % STEPS.length);
        setVisible(true);
      }, 300);
    }, 2400);
    return () => clearInterval(t);
  }, []);

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center",
      paddingTop: 40, paddingBottom: 60, minHeight: "60vh",
      textAlign: "center",
    }}>
      {/* Soft glow orb — ABY Journal inspired */}
      <div style={{ position: "relative", width: 180, height: 180, marginBottom: 36 }}>
        <div className="orb-glow" style={{
          position: "absolute", inset: 0, borderRadius: "50%",
          background: "radial-gradient(circle at 42% 38%, rgba(127,182,158,0.5) 0%, rgba(123,167,201,0.28) 38%, rgba(155,139,191,0.18) 65%, transparent 100%)",
          filter: "blur(14px)",
        }} />
        <div style={{
          position: "absolute", inset: 0,
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="var(--greenDk)" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: 0.75 }}>
            <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
          </svg>
        </div>
      </div>

      {/* Step text */}
      <div style={{
        opacity: visible ? 1 : 0,
        transition: "opacity 0.3s ease",
        minHeight: 56,
      }}>
        <p className="h2" style={{ fontSize: 20, marginBottom: 6 }}>{STEPS[i].text}</p>
        <p style={{ fontSize: 14, color: "var(--text3)" }}>{STEPS[i].sub}</p>
      </div>

      {/* Progress dots */}
      <div style={{ display: "flex", gap: 7, marginTop: 28 }}>
        {STEPS.map((_, idx) => (
          <div key={idx} style={{
            width: idx === i ? 22 : 6,
            height: 6, borderRadius: 3,
            background: idx === i ? "var(--green)" : "var(--bg3)",
            transition: "all 0.35s ease",
          }} />
        ))}
      </div>

      <p style={{ fontSize: 13, color: "var(--text3)", marginTop: 24 }}>
        約需 10–20 秒 · 照片不會被儲存
      </p>
    </section>
  );
}
