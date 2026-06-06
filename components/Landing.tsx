"use client";

const TILES = [
  {
    color: "#5A9A7D",
    bg: "rgba(90,154,125,0.13)",
    title: "拍照上傳",
    desc: "出院單 / 藥袋",
    icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#5A9A7D" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
        <circle cx="12" cy="13" r="4"/>
      </svg>
    ),
  },
  {
    color: "#4A87B0",
    bg: "rgba(74,135,176,0.13)",
    title: "AI 整理",
    desc: "秒懂所有資訊",
    icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4A87B0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/>
      </svg>
    ),
  },
  {
    color: "#7B6BB0",
    bg: "rgba(123,107,176,0.13)",
    title: "照護指南",
    desc: "家人一起看",
    icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#7B6BB0" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
        <polyline points="14 2 14 8 20 8"/>
        <line x1="16" y1="13" x2="8" y2="13"/>
        <line x1="16" y1="17" x2="8" y2="17"/>
        <line x1="10" y1="9" x2="8" y2="9"/>
      </svg>
    ),
  },
];

export default function Landing({ onStart }: { onStart: () => void }) {
  return (
    <section style={{ flex: 1, display: "flex", flexDirection: "column" }}>

      {/* ── Hero ─────────────────────────────── */}
      <div className="a0" style={{
        background: "linear-gradient(155deg, #2E6B52 0%, #4A8C72 40%, #6FAF92 75%, #9DCDB8 100%)",
        padding: "60px 24px 44px",
        textAlign: "center",
        position: "relative",
        overflow: "hidden",
      }}>
        {/* Decorative blobs */}
        <div style={{ position: "absolute", top: -50, right: -50, width: 180, height: 180, borderRadius: "50%", background: "rgba(255,255,255,0.07)" }} />
        <div style={{ position: "absolute", bottom: -30, left: -30, width: 140, height: 140, borderRadius: "50%", background: "rgba(255,255,255,0.05)" }} />
        <div style={{ position: "absolute", top: 20, left: 40, width: 60, height: 60, borderRadius: "50%", background: "rgba(255,255,255,0.04)" }} />

        {/* Logo */}
        <div style={{
          display: "inline-flex", alignItems: "center", justifyContent: "center",
          width: 70, height: 70, borderRadius: 22,
          background: "rgba(255,255,255,0.18)",
          border: "1.5px solid rgba(255,255,255,0.3)",
          backdropFilter: "blur(12px)",
          marginBottom: 20,
        }}>
          <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
          </svg>
        </div>

        <h1 style={{ fontSize: 34, fontWeight: 800, color: "#fff", letterSpacing: -0.6, marginBottom: 10, textShadow: "0 1px 4px rgba(0,0,0,.12)" }}>
          CareDoc
        </h1>
        <p style={{ fontSize: 15, color: "rgba(255,255,255,0.88)", lineHeight: 1.7, maxWidth: 280, margin: "0 auto" }}>
          上傳醫療單據照片<br />AI 秒整理，家人一看就懂
        </p>
      </div>

      {/* ── Body ─────────────────────────────── */}
      <div className="page-body">

        {/* Section label */}
        <p className="a1" style={{
          fontSize: 11, fontWeight: 700, color: "var(--text3)",
          letterSpacing: 1.6, textTransform: "uppercase", marginBottom: 14,
        }}>
          三步完成
        </p>

        {/* 3-tile grid */}
        <div className="a2" style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: 10, marginBottom: 28 }}>
          {TILES.map((tile) => (
            <div key={tile.title} style={{
              background: "var(--card)", borderRadius: 18, padding: "18px 10px",
              border: "1px solid var(--border)", textAlign: "center",
              boxShadow: "0 2px 8px rgba(0,0,0,.04)",
            }}>
              <div style={{
                width: 48, height: 48, borderRadius: 14,
                background: tile.bg,
                display: "flex", alignItems: "center", justifyContent: "center",
                margin: "0 auto 10px",
              }}>
                {tile.icon}
              </div>
              <p style={{ fontSize: 13, fontWeight: 700, color: "var(--text)", lineHeight: 1.3 }}>{tile.title}</p>
              <p style={{ fontSize: 11, color: "var(--text3)", marginTop: 3, lineHeight: 1.4 }}>{tile.desc}</p>
            </div>
          ))}
        </div>

        {/* Trust badges */}
        <div className="a3" style={{ display: "flex", justifyContent: "center", gap: 7, flexWrap: "wrap", marginBottom: 20 }}>
          {["不儲存醫療資料", "3 分鐘完成", "完全免費"].map((t) => (
            <span key={t} style={{
              padding: "6px 13px", borderRadius: 20,
              background: "var(--greenBg)", border: "1px solid rgba(127,182,158,0.22)",
              fontSize: 12, fontWeight: 500, color: "var(--text2)",
            }}>{t}</span>
          ))}
        </div>

        <div style={{ flex: 1 }} />

        {/* CTA */}
        <button className="btn-primary a4" onClick={onStart} style={{ fontSize: 18, padding: "18px 24px" }}>
          開始整理
        </button>
        <p className="disclaimer a5">SNS 試玩版</p>
      </div>
    </section>
  );
}
