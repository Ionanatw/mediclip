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
    <section style={{ paddingTop: 24 }}>
      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 6 }}>
        <div style={{
          width: 36, height: 36, borderRadius: 10,
          background: "linear-gradient(135deg, #7FB69E, #5A9A7D)",
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: "0 2px 8px rgba(90,154,125,.2)",
          flexShrink: 0,
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
            <circle cx="8.5" cy="8.5" r="1.5"/>
            <polyline points="21 15 16 10 5 21"/>
          </svg>
        </div>
        <h2 className="h2">上傳醫療文件</h2>
      </div>
      <p className="muted" style={{ margin: "0 0 16px", fontSize: 15 }}>最多 8 張，從相簿選擇</p>

      {/* Tips */}
      <div className="card" style={{ background: "var(--amberBg)", borderLeft: "4px solid var(--amber)", fontSize: 14, padding: "14px 16px", marginBottom: 10 }}>
        <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--amber)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>體驗版只能上傳一次，建議在看診結束後把所有單據一併上傳，效果最佳</span>
        </div>
      </div>
      <div className="card" style={{ background: "var(--greenBg)", borderLeft: "4px solid var(--green)", fontSize: 14, padding: "14px 16px" }}>
        <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--greenDk)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
            <path d="M12 20h9"/>
            <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
          </svg>
          <span>現正測試手寫辨識：手寫筆記也可以拍照上傳，書寫時請盡量以<strong>正楷</strong>為主</span>
        </div>
      </div>

      {error && (
        <div className="card" style={{ color: "var(--coral)", fontSize: 14, marginTop: 8 }}>{error}</div>
      )}

      {/* Upload area */}
      <div className="card" style={{ marginTop: 4 }}>
        {previews.length > 0 && (
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 14 }}>
            {previews.map((src, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img key={i} src={src} alt="" style={{ width: 84, height: 84, objectFit: "cover", borderRadius: 10, border: "1px solid var(--border)" }} />
            ))}
          </div>
        )}

        {imgs.length < 8 && (
          <label style={{
            display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
            gap: 10, padding: "22px 16px",
            border: "1.5px dashed var(--border)", borderRadius: 12,
            cursor: "pointer", background: "var(--bg2)",
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: 12,
              background: "var(--card)", border: "1px solid var(--border)",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--green)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="17 8 12 3 7 8"/>
                <line x1="12" y1="3" x2="12" y2="15"/>
              </svg>
            </div>
            <div style={{ textAlign: "center" }}>
              <p style={{ fontSize: 15, fontWeight: 600, color: "var(--text)" }}>選擇照片</p>
              <p style={{ fontSize: 13, color: "var(--text3)", marginTop: 2 }}>{imgs.length}/8 · 從相簿選擇</p>
            </div>
            <input type="file" accept="image/*" multiple hidden onChange={onPick} />
          </label>
        )}

        <textarea
          value={text}
          placeholder="補充說明（選填）：護理站口頭交代、想問的問題…"
          onChange={(e) => setText(e.target.value)}
          style={{
            width: "100%", minHeight: 80, fontSize: 15, padding: "12px 14px", marginTop: 12,
            border: "1px solid var(--border)", borderRadius: 12, fontFamily: "inherit",
            background: "var(--bg2)", color: "var(--text)", resize: "none", outline: "none",
          }}
        />
      </div>

      <button
        className="btn-primary"
        disabled={busy || (!imgs.length && !text)}
        onClick={() => onSubmit(imgs, text)}
      >
        {busy ? "處理圖片中…" : "開始 AI 整理"}
      </button>
    </section>
  );
}
