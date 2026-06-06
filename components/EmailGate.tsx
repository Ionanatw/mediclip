"use client";
import { useState } from "react";

export default function EmailGate({ onPass }: { onPass: () => void }) {
  const [email, setEmail] = useState("");
  const [msg, setMsg] = useState("");
  const [loading, setLoading] = useState(false);

  async function submit() {
    setLoading(true);
    setMsg("");
    try {
      const res = await fetch("/api/check-email", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ email }),
      });
      const data = await res.json();
      if (!res.ok) { setMsg(data.error || "請輸入正確 email"); return; }
      if (data.allowed) onPass();
      else setMsg("這個 email 已體驗過囉，下載 App 可無限使用");
    } catch {
      setMsg("連線失敗，請稍後再試");
    } finally {
      setLoading(false);
    }
  }

  return (
    <section style={{ flex: 1, display: "flex", flexDirection: "column" }}>

      {/* ── Mini hero ─────────────────────────── */}
      <div className="a0" style={{
        background: "linear-gradient(155deg, #2E6B52 0%, #4A8C72 45%, #7FB69E 100%)",
        padding: "52px 24px 36px",
        textAlign: "center",
        position: "relative", overflow: "hidden",
      }}>
        <div style={{ position: "absolute", top: -40, right: -40, width: 140, height: 140, borderRadius: "50%", background: "rgba(255,255,255,0.07)" }} />

        {/* Step dots */}
        <div style={{ display: "flex", justifyContent: "center", gap: 6, marginBottom: 24 }}>
          {[1, 2, 3].map((n) => (
            <div key={n} style={{
              width: n === 1 ? 20 : 6, height: 6, borderRadius: 3,
              background: n === 1 ? "rgba(255,255,255,0.9)" : "rgba(255,255,255,0.3)",
              transition: "width .3s",
            }} />
          ))}
        </div>

        {/* Icon */}
        <div style={{
          display: "inline-flex", alignItems: "center", justifyContent: "center",
          width: 64, height: 64, borderRadius: 20,
          background: "rgba(255,255,255,0.18)",
          border: "1.5px solid rgba(255,255,255,0.28)",
          backdropFilter: "blur(10px)",
          marginBottom: 18,
        }}>
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
            <polyline points="22,6 12,13 2,6"/>
          </svg>
        </div>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: "#fff", letterSpacing: -0.4, marginBottom: 8 }}>
          輸入 Email 開始
        </h1>
        <p style={{ fontSize: 14, color: "rgba(255,255,255,0.82)", lineHeight: 1.6 }}>
          每組 Email 可免費體驗一次
        </p>
      </div>

      {/* ── Body ─────────────────────────────── */}
      <div className="page-body">

        {/* Email input */}
        <div className="a1" style={{ marginBottom: 14 }}>
          <label style={{ display: "block", fontSize: 13, fontWeight: 600, color: "var(--text2)", marginBottom: 8 }}>
            Email
          </label>
          <input
            type="email"
            value={email}
            placeholder="you@example.com"
            onChange={(e) => setEmail(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && email && submit()}
            style={{
              width: "100%", fontSize: 17, padding: "15px 16px",
              border: "1.5px solid var(--border)", borderRadius: 16,
              background: "var(--card)", color: "var(--text)",
              outline: "none", transition: "border-color .2s",
              boxShadow: "0 1px 4px rgba(0,0,0,.04)",
            }}
            onFocus={(e) => (e.target.style.borderColor = "var(--greenDk)")}
            onBlur={(e) => (e.target.style.borderColor = "var(--border)")}
          />
          {msg && (
            <p style={{ color: "var(--coral)", marginTop: 10, fontSize: 14, lineHeight: 1.5 }}>
              {msg}
            </p>
          )}
        </div>

        {/* Privacy note */}
        <div className="a2" style={{
          display: "flex", alignItems: "flex-start", gap: 10,
          padding: "14px 16px", borderRadius: 14,
          background: "var(--greenBg)",
          border: "1px solid rgba(127,182,158,0.18)",
          marginBottom: 28,
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--greenDk)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
          </svg>
          <p style={{ fontSize: 13, color: "var(--text2)", lineHeight: 1.6 }}>
            只用 Email 確認體驗次數，不儲存任何醫療資料。AI 處理全程不落地。
          </p>
        </div>

        <div style={{ flex: 1 }} />

        <button className="btn-primary a3" disabled={loading || !email} onClick={submit} style={{ fontSize: 18, padding: "18px 24px" }}>
          {loading ? "確認中…" : "繼續"}
        </button>
      </div>
    </section>
  );
}
