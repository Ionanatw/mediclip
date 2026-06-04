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
      <h2 className="h2">上傳醫療文件</h2>
      <p className="muted" style={{ margin: "6px 0 12px", fontSize: 16 }}>最多 8 張，從相簿選擇。</p>
      <div className="card" style={{ background: "var(--amberBg)", borderLeft: "4px solid var(--amber)", fontSize: 15 }}>
        💡 體驗版只能上傳一次，建議在看診結束後把所有單據一併上傳，效果最佳。
      </div>
      <div className="card" style={{ background: "var(--greenBg)", borderLeft: "4px solid var(--green)", fontSize: 15 }}>
        ✍️ 現正測試手寫辨識：寫在紙上的手寫筆記也可以一併拍照上傳。為確保辨識正確，書寫時請盡量以<strong>正楷</strong>為主。
      </div>
      {error && <div className="card" style={{ color: "var(--coral)" }}>{error}</div>}
      <div className="card">
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
          {previews.map((src, i) => (
            // eslint-disable-next-line @next/next/no-img-element
            <img key={i} src={src} alt="" style={{ width: 88, height: 88, objectFit: "cover", borderRadius: 12 }} />
          ))}
        </div>
        {imgs.length < 8 && (
          <label className="btn-secondary" style={{ display: "block", textAlign: "center" }}>
            🖼️ 從相簿選擇（{imgs.length}/8）
            <input type="file" accept="image/*" multiple hidden onChange={onPick} />
          </label>
        )}
        <textarea
          value={text}
          placeholder="補充說明（選填）：護理站口頭交代、想問的問題…"
          onChange={(e) => setText(e.target.value)}
          style={{
            width: "100%", minHeight: 80, fontSize: 17, padding: 12, marginTop: 12,
            border: "1px solid var(--bg3)", borderRadius: 12, fontFamily: "inherit",
          }}
        />
      </div>
      <button
        className="btn-primary"
        disabled={busy || (!imgs.length && !text)}
        onClick={() => onSubmit(imgs, text)}
      >
        {busy ? "處理圖片中…" : "開始 AI 整理 →"}
      </button>
    </section>
  );
}
