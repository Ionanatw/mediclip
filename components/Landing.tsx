"use client";
import { useState, useRef } from "react";
import ToastMascot from "./ToastMascot";

const FeatMeds = ({ c }: { c: string }) => <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><rect x="6" y="2" width="12" height="20" rx="6" stroke={c} strokeWidth="1.8" /><line x1="6" y1="12" x2="18" y2="12" stroke={c} strokeWidth="1.5" /><circle cx="12" cy="7" r="1.5" fill={c} opacity="0.3" /></svg>;
const FeatCalendar = ({ c }: { c: string }) => <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="18" height="17" rx="3" stroke={c} strokeWidth="1.8" /><path d="M3 10h18M8 2v4M16 2v4" stroke={c} strokeWidth="1.8" strokeLinecap="round" /><circle cx="8" cy="15" r="1.5" fill={c} /><circle cx="12" cy="15" r="1.5" fill={c} opacity="0.3" /></svg>;
const FeatSummary = ({ c }: { c: string }) => <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="2.5" stroke={c} strokeWidth="1.8" /><path d="M8 7h8M8 11h6M8 15h8" stroke={c} strokeWidth="1.5" strokeLinecap="round" /></svg>;
const MailIcon = ({ c }: { c: string }) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" stroke={c} strokeWidth="1.8" /><path d="M3 7l9 6 9-6" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const CheckIcon = ({ c }: { c: string }) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4L19 7" stroke={c} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const LockIcon = ({ c }: { c: string }) => <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><rect x="5" y="11" width="14" height="10" rx="2.5" stroke={c} strokeWidth="2" /><path d="M8 11V8a4 4 0 118 0v3" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
const SpinnerIcon = ({ c }: { c: string }) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none" style={{ animation: "cdSpin 0.8s linear infinite" }}><circle cx="12" cy="12" r="9" stroke={c} strokeOpacity="0.25" strokeWidth="3" /><path d="M12 3a9 9 0 016.364 2.636" stroke={c} strokeWidth="3" strokeLinecap="round" /></svg>;

const FEATURES = [
  { icon: FeatMeds, title: "用藥識別卡", desc: "AI 辨識藥品外觀和注意事項" },
  { icon: FeatCalendar, title: "照護行事曆", desc: "回診、用藥時間一目瞭然" },
  { icon: FeatSummary, title: "結構化摘要", desc: "複雜衛教單變成簡單重點" },
];

export default function Landing({ onStart }: { onStart: (email: string) => void }) {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"empty" | "focus" | "error" | "success" | "loading">("empty");
  const [errorMsg, setErrorMsg] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  const borderColor = status === "error" ? "#D97757" : status === "focus" || status === "success" ? "#7FB69E" : "#D8D2C8";

  function handleFocus() { setStatus("focus"); }
  function handleBlur() {
    if (!email) setStatus("empty");
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) setStatus("error");
    else setStatus("success");
  }

  async function handleSubmit() {
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setStatus("error");
      setErrorMsg("請輸入有效的 Email 地址");
      return;
    }
    setStatus("loading");
    setErrorMsg("");
    try {
      const res = await fetch("/api/check-email", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ email }),
      });
      const data = await res.json();
      if (!res.ok) { setStatus("error"); setErrorMsg(data.error || "請輸入正確 email"); return; }
      if (data.allowed) { setStatus("success"); onStart(email); }
      else { setStatus("error"); setErrorMsg("這個 Email 已體驗過囉，下載 App 可無限使用"); }
    } catch {
      setStatus("error");
      setErrorMsg("連線失敗，請稍後再試");
    }
  }

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column", alignItems: "center",
      background: "linear-gradient(175deg, #FDFBF7 0%, #EDF5F0 100%)",
      minHeight: "100dvh",
    }}>
      <div style={{ width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", display: "flex", flexDirection: "column", height: "100%" }}>

        {/* Brand */}
        <div className="a0" style={{ paddingTop: 44, paddingBottom: 4, flexShrink: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <ToastMascot size={40} />
            <span style={{ fontWeight: 800, fontSize: 20, color: "#5A9A7D", letterSpacing: 0.5 }}>吐司麥麥</span>
          </div>
        </div>

        {/* Value proposition */}
        <div className="a1" style={{ paddingTop: 20, paddingBottom: 4, flexShrink: 0 }}>
          <h1 style={{ margin: 0, fontWeight: 900, fontSize: 28, lineHeight: 1.4, letterSpacing: 0.3 }}>
            請餵吐司麥麥你的<br />
            <span style={{ color: "#5A9A7D" }}>醫療相關文件</span>
          </h1>
          <p style={{ margin: "10px 0 0", fontSize: 15, fontWeight: 400, lineHeight: 1.65, color: "#6E6A62" }}>
            手寫文字、打字，讓他來幫你換句話說
          </p>
          <p style={{ margin: "6px 0 0", fontSize: 17, fontWeight: 700, lineHeight: 1.5, color: "#5A9A7D" }}>
            安心治療，放心陪伴
          </p>
        </div>

        {/* Center — breathing orb + features */}
        <div className="a2" style={{ flex: "1 1 0", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", minHeight: 240, gap: 16, marginTop: -12 }}>
          <div style={{
            width: 110, height: 110, borderRadius: "50%",
            background: "radial-gradient(circle at 40% 40%, rgba(90,154,125,0.35), rgba(91,143,201,0.25) 60%, rgba(127,182,158,0.08) 100%)",
            animation: "cdBreathe 4s ease-in-out infinite",
            display: "flex", alignItems: "center", justifyContent: "center",
            boxShadow: "0 0 40px rgba(90,154,125,0.15)",
          }}>
            <ToastMascot size={60} />
          </div>

          <div style={{ display: "flex", gap: 12, width: "100%", justifyContent: "center" }}>
            {FEATURES.map((f) => (
              <div key={f.title} style={{ flex: "1 1 0", minWidth: 0, textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
                <div style={{ width: 48, height: 48, borderRadius: 14, background: "#EDF5F0", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  <f.icon c="#5A9A7D" />
                </div>
                <div style={{ fontWeight: 700, fontSize: 13.5, lineHeight: 1.3, whiteSpace: "nowrap" }}>{f.title}</div>
                <div style={{ fontSize: 12, color: "#A09890", lineHeight: 1.45 }}>{f.desc}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Email CTA */}
        <div className="a3" style={{ paddingBottom: 8, flexShrink: 0 }}>
          <div style={{
            display: "flex", gap: 0, borderRadius: 14, overflow: "hidden",
            border: `1.5px solid ${borderColor}`,
            background: "#fff",
            boxShadow: status === "focus" ? "0 0 0 3px rgba(127,182,158,0.13)" : "none",
            transition: "border-color 0.2s, box-shadow 0.2s",
            transform: status === "focus" ? "scale(1.01)" : "none",
          }}>
            <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 10, padding: "0 14px", minWidth: 0 }}>
              <MailIcon c="#A09890" />
              <input
                ref={inputRef} type="email"
                placeholder="輸入 Email 開始免費體驗"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                onFocus={handleFocus}
                onBlur={handleBlur}
                onKeyDown={(e) => e.key === "Enter" && handleSubmit()}
                style={{ flex: 1, border: "none", outline: "none", background: "transparent", fontFamily: "inherit", fontSize: 15, fontWeight: 400, color: "#3A4642", height: 50, minWidth: 0 }}
              />
              {status === "success" && <CheckIcon c="#5A9A7D" />}
            </div>
            <button onClick={handleSubmit} disabled={status === "loading"} style={{
              flexShrink: 0, height: 50, padding: "0 18px", border: "none",
              background: "#7FB69E", color: "#fff", fontFamily: "inherit",
              fontWeight: 700, fontSize: 15, cursor: status === "loading" ? "default" : "pointer",
              display: "flex", alignItems: "center", gap: 6, whiteSpace: "nowrap",
            }}>
              {status === "loading" ? <SpinnerIcon c="#fff" /> : "開始 →"}
            </button>
          </div>
          {errorMsg && <div style={{ fontSize: 13, color: "#D97757", marginTop: 8, paddingLeft: 2 }}>{errorMsg}</div>}
          <div style={{ fontSize: 12, color: "#A09890", marginTop: 10, textAlign: "center", lineHeight: 1.5 }}>
            免費體驗一次完整 AI 整理，不需要下載 App
          </div>
        </div>

        {/* Trust */}
        <div className="a4" style={{ paddingBottom: 18, paddingTop: 4, textAlign: "center", flexShrink: 0 }}>
          <div style={{ fontSize: 13, color: "#A09890", display: "inline-flex", alignItems: "center", gap: 6 }}>
            <LockIcon c="#A09890" />
            你的醫療文件不會被儲存，處理完即刪除
          </div>
        </div>
      </div>
    </section>
  );
}
