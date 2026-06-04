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
      if (!res.ok) {
        setMsg(data.error || "請輸入正確 email");
        return;
      }
      if (data.allowed) onPass();
      else setMsg("這個 email 已體驗過囉～下載 App 可無限使用 🌿");
    } catch {
      setMsg("連線失敗，請稍後再試");
    } finally {
      setLoading(false);
    }
  }

  return (
    <section style={{ paddingTop: 32 }}>
      <h2 className="h2">輸入 email 開始體驗</h2>
      <p className="muted" style={{ margin: "8px 0 20px", fontSize: 16 }}>
        每個 email 可免費體驗 1 次。我們只存 email，不存任何醫療資料。
      </p>
      <div className="card">
        <input
          type="email"
          value={email}
          placeholder="you@example.com"
          onChange={(e) => setEmail(e.target.value)}
          style={{ width: "100%", fontSize: 19, padding: 12, border: "1px solid var(--bg3)", borderRadius: 12 }}
        />
        {msg && <p style={{ color: "var(--coral)", marginTop: 12, fontSize: 16 }}>{msg}</p>}
      </div>
      <button className="btn-primary" disabled={loading} onClick={submit}>
        {loading ? "確認中…" : "繼續 →"}
      </button>
    </section>
  );
}
