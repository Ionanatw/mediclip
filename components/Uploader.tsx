"use client";
import { useState } from "react";
import { fileToCompressedBase64 } from "@/lib/imageResize";

export default function Uploader({
  error,
  onSubmit,
}: {
  error?: string;
  onSubmit: (imgs: { type: string; data: string }[], text: string) => void;
}) {
  const [previews, setPreviews] = useState<string[]>([]);
  const [imgs, setImgs] = useState<{ type: string; data: string }[]>([]);
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);

  async function onPick(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files || []).slice(0, 8 - imgs.length);
    setBusy(true);
    for (const f of files) {
      const c = await fileToCompressedBase64(f);
      setImgs((p) => [...p, c]);
      setPreviews((p) => [...p, `data:${c.type};base64,${c.data}`]);
    }
    setBusy(false);
    e.target.value = "";
  }

  return (
    <section style={{ flex: 1, display: "flex", flexDirection: "column" }}>

      {/* ── Mini hero ─────────────────────────── */}
      <div className="a0" style={{
        background: "linear-gradient(155deg, #2E6B52 0%, #4A8C72 45%, #7FB69E 100%)",
        padding: "48px 24px 32px",
        position: "relative", overflow: "hidden",
      }}>
        <div style={{ position: "absolute", top: -40, right: -40, width: 130, height: 130, borderRadius: "50%", background: "rgba(255,255,255,0.07)" }} />

        {/* Step dots */}
        <div style={{ display: "flex", justifyContent: "center", gap: 6, marginBottom: 20 }}>
          {[1, 2, 3].map((n) => (
            <div key={n} style={{
              width: n === 2 ? 20 : 6, height: 6, borderRadius: 3,
              background: n <= 2 ? "rgba(255,255,255,0.9)" : "rgba(255,255,255,0.3)",
            }} />
          ))}
        </div>

        <div style={{ textAlign: "center" }}>
          <div style={{
            display: "inline-flex", alignItems: "center", justifyContent: "center",
            width: 56, height: 56, borderRadius: 18,
            background: "rgba(255,255,255,0.18)",
            border: "1.5px solid rgba(255,255,255,0.28)",
            backdropFilter: "blur(10px)",
            marginBottom: 14,
          }}>
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
              <circle cx="12" cy="13" r="4"/>
            </svg>
          </div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: "#fff", letterSpacing: -0.3, marginBottom: 6 }}>
            上傳醫療文件
          </h1>
          <p style={{ fontSize: 14, color: "rgba(255,255,255,0.82)" }}>
            最多 8 張，從相簿選擇
          </p>
        </div>
      </div>

      {/* ── Body ─────────────────────────────── */}
      <div className="page-body">

        {/* Upload zone */}
        <div className="a1" style={{ marginBottom: 14 }}>
          {previews.length > 0 ? (
            /* Photo grid */
            <div style={{
              display: "grid",
              gridTemplateColumns: "repeat(4, 1fr)",
              gap: 8, marginBottom: 10,
            }}>
              {previews.map((src, i) => (
                // eslint-disable-next-line @next/next/no-img-element
                <img key={i} src={src} alt="" style={{
                  width: "100%", aspectRatio: "1", objectFit: "cover",
                  borderRadius: 12, border: "1px solid var(--border)",
                }} />
              ))}
              {imgs.length < 8 && (
                <label style={{
                  display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
                  aspectRatio: "1", borderRadius: 12,
                  border: "1.5px dashed var(--border)", background: "var(--bg2)",
                  cursor: "pointer", gap: 4,
                }}>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--text3)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                  </svg>
                  <span style={{ fontSize: 10, color: "var(--text3)" }}>{imgs.length}/8</span>
                  <input type="file" accept="image/*" multiple hidden onChange={onPick} />
                </label>
              )}
            </div>
          ) : (
            /* Empty upload zone */
            <label style={{
              display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
              gap: 14, padding: "40px 20px",
              border: "1.5px dashed rgba(127,182,158,0.45)", borderRadius: 20,
              cursor: "pointer", background: "var(--greenBg)",
              transition: "background .2s",
            }}>
              <div style={{
                width: 60, height: 60, borderRadius: 18,
                background: "rgba(90,154,125,0.12)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--greenDk)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                  <polyline points="17 8 12 3 7 8"/>
                  <line x1="12" y1="3" x2="12" y2="15"/>
                </svg>
              </div>
              <div style={{ textAlign: "center" }}>
                <p style={{ fontSize: 16, fontWeight: 700, color: "var(--greenDk)" }}>選擇照片</p>
                <p style={{ fontSize: 13, color: "var(--text3)", marginTop: 4 }}>從相簿選擇 · 最多 8 張</p>
              </div>
              <input type="file" accept="image/*" multiple hidden onChange={onPick} />
            </label>
          )}
        </div>

        {error && (
          <div className="a2" style={{ padding: "12px 14px", borderRadius: 12, background: "var(--coralBg)", border: "1px solid rgba(212,129,107,0.2)", marginBottom: 12 }}>
            <p style={{ fontSize: 14, color: "var(--coral)" }}>{error}</p>
          </div>
        )}

        {/* Inline tip chips */}
        <div className="a2" style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 16 }}>
          <span style={{
            display: "flex", alignItems: "center", gap: 6,
            padding: "7px 12px", borderRadius: 20,
            background: "var(--amberBg)", border: "1px solid rgba(201,168,98,0.2)",
            fontSize: 12, color: "var(--text2)",
          }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            體驗版限上傳一次，建議看診結束後再上傳
          </span>
          <span style={{
            display: "flex", alignItems: "center", gap: 6,
            padding: "7px 12px", borderRadius: 20,
            background: "var(--greenBg)", border: "1px solid rgba(127,182,158,0.2)",
            fontSize: 12, color: "var(--text2)",
          }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="var(--greenDk)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
            </svg>
            支援手寫正楷筆記辨識
          </span>
        </div>

        {/* Note textarea */}
        <textarea
          className="a3"
          value={text}
          placeholder="補充說明（選填）：護理站口頭交代、想問的問題…"
          onChange={(e) => setText(e.target.value)}
          style={{
            width: "100%", minHeight: 80, fontSize: 15, padding: "14px 16px",
            border: "1.5px solid var(--border)", borderRadius: 16,
            fontFamily: "inherit", background: "var(--card)", color: "var(--text)",
            resize: "none", outline: "none", marginBottom: 20,
            boxShadow: "0 1px 4px rgba(0,0,0,.04)",
          }}
          onFocus={(e) => (e.target.style.borderColor = "var(--greenDk)")}
          onBlur={(e) => (e.target.style.borderColor = "var(--border)")}
        />

        <div style={{ flex: 1 }} />

        <button
          className="btn-primary a4"
          disabled={busy || (!imgs.length && !text)}
          onClick={() => onSubmit(imgs, text)}
          style={{ fontSize: 18, padding: "18px 24px" }}
        >
          {busy ? "處理圖片中…" : "開始 AI 整理"}
        </button>
      </div>
    </section>
  );
}
