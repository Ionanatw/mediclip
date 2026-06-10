"use client";
import { useState } from "react";
import { fileToCompressedBase64 } from "@/lib/imageResize";

const IcBack = (c: string) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const IcPlus = (c: string, s = 20) => <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={c} strokeWidth="1.8" strokeLinecap="round" /></svg>;
const IcClose = (c: string) => <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M3 3l8 8M11 3l-8 8" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
const IcCheck = (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" fill={c} /><path d="M7 12.5l3 3 7-7" stroke="#fff" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const IcDoc = (c: string) => <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="2.5" stroke={c} strokeWidth="1.8" /><path d="M8 7h8M8 11h6M8 15h8" stroke={c} strokeWidth="1.5" strokeLinecap="round" /></svg>;
const IcChat = (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2v10z" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const IcMic = (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="8" y="2" width="8" height="13" rx="4" stroke={c} strokeWidth="2" /><path d="M5 11a7 7 0 0014 0M12 18v4M9 22h6" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
const IcBulb = (c: string) => <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M12 2a7 7 0 00-3 13.3V18h6v-2.7A7 7 0 0012 2z" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" /><path d="M9 22h6" stroke={c} strokeWidth="1.8" strokeLinecap="round" /></svg>;
const IcLeaf = (c: string) => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M6 21c3-3 2-9 6-12s9-3 9-3-1 6-5 9-7 3-10 6z" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /><path d="M6 21c0-5 4-9 8-12" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
const IcSpin = (c: string) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none" style={{ animation: "cdSpin .8s linear infinite" }}><circle cx="12" cy="12" r="9" stroke={c} strokeOpacity=".25" strokeWidth="3" /><path d="M12 3a9 9 0 016.364 2.636" stroke={c} strokeWidth="3" strokeLinecap="round" /></svg>;

const PHOTO_COLORS = ["#C4D8CC", "#D6C9A8", "#B8C9D6", "#D4C4D8", "#C8D4C4", "#D8C8B8"];
const TOTAL_SLOTS = 6;

function Badge({ label, color, bg }: { label: string; color: string; bg: string }) {
  return <span style={{ display: "inline-flex", alignItems: "center", gap: 4, fontSize: 11.5, fontWeight: 700, color, background: bg, padding: "2px 8px", borderRadius: 6, marginLeft: 8 }}>{label}</span>;
}

export default function Uploader({
  error,
  onSubmit,
  onBack,
}: {
  error?: string;
  onSubmit: (imgs: { type: string; data: string }[], text: string) => void;
  onBack?: () => void;
}) {
  const [previews, setPreviews] = useState<string[]>([]);
  const [imgs, setImgs] = useState<{ type: string; data: string }[]>([]);
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);

  async function onPick(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files || []).slice(0, TOTAL_SLOTS - imgs.length);
    setBusy(true);
    for (const f of files) {
      const c = await fileToCompressedBase64(f);
      setImgs((p) => [...p, c]);
      setPreviews((p) => [...p, `data:${c.type};base64,${c.data}`]);
    }
    setBusy(false);
    e.target.value = "";
  }

  function removePhoto(idx: number) {
    setImgs((p) => p.filter((_, i) => i !== idx));
    setPreviews((p) => p.filter((_, i) => i !== idx));
  }

  const canStart = imgs.length > 0 && !busy;

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column", alignItems: "center",
      background: "var(--bg)", minHeight: "100dvh", paddingTop: 12,
    }}>
      {/* Nav */}
      <div style={{ width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", display: "flex", alignItems: "center", height: 50, flexShrink: 0, position: "relative" }}>
        <div onClick={onBack} style={{ width: 38, height: 38, borderRadius: "50%", background: "rgba(127,182,158,0.12)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
          {IcBack("#5A9A7D")}
        </div>
        <div style={{ position: "absolute", left: 0, right: 0, textAlign: "center", fontWeight: 700, fontSize: 18, pointerEvents: "none" }}>上傳醫療文件</div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", overflow: "auto", display: "flex", flexDirection: "column", gap: 16, paddingTop: 8, paddingBottom: 96 }}>

        {/* Photo grid card */}
        <div className="a0" style={{ background: "var(--card)", borderRadius: 20, padding: "16px 18px 18px", border: "1px solid var(--card-border)" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
              {IcDoc("var(--text2)")}
              <span style={{ fontWeight: 700, fontSize: 16 }}>照片與文件</span>
              {imgs.length > 0 && <span style={{ fontSize: 12, color: "var(--text3)" }}>{imgs.length}/{TOTAL_SLOTS}</span>}
            </div>
            <div style={{ fontSize: 12, color: "var(--text3)", whiteSpace: "nowrap", flexShrink: 0 }}>最多 {TOTAL_SLOTS} 張</div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 10, padding: "4px 0" }}>
            {Array.from({ length: TOTAL_SLOTS }).map((_, i) => {
              if (i < previews.length) {
                return (
                  <div key={i} style={{ position: "relative", aspectRatio: "1", borderRadius: 14, overflow: "hidden" }}>
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img src={previews[i]} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                    <div onClick={() => removePhoto(i)} style={{ position: "absolute", top: 4, right: 4, width: 22, height: 22, borderRadius: "50%", background: "rgba(0,0,0,0.35)", backdropFilter: "blur(4px)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                      {IcClose("#fff")}
                    </div>
                  </div>
                );
              }
              if (i === previews.length && imgs.length < TOTAL_SLOTS) {
                return (
                  <label key={i} style={{ aspectRatio: "1", borderRadius: 14, border: "2px dashed var(--surface3)", background: "transparent", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
                    {IcPlus("var(--surface3)", 24)}
                    <input type="file" accept="image/*,.pdf" multiple hidden onChange={onPick} />
                  </label>
                );
              }
              return (
                <div key={i} style={{ aspectRatio: "1", borderRadius: 14, border: "2px dashed var(--surface3)", background: "transparent", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {IcPlus("var(--surface3)", 24)}
                </div>
              );
            })}
          </div>

          {imgs.length > 0 && (
            <div style={{ marginTop: 14, display: "flex", alignItems: "center", justifyContent: "center", gap: 6, padding: "10px 16px", borderRadius: 999, background: "var(--brand-bg)" }}>
              {IcCheck("var(--brand)")}
              <span style={{ fontSize: 14, fontWeight: 600, color: "var(--brand-dk)" }}>已選擇 {imgs.length} 張文件</span>
            </div>
          )}
        </div>

        {error && (
          <div style={{ padding: "12px 14px", borderRadius: 12, background: "var(--warning-bg)", marginBottom: 0 }}>
            <p style={{ fontSize: 14, color: "var(--warning)" }}>{error}</p>
          </div>
        )}

        {/* Supplementary text */}
        <div className="a1">
          <div style={{ display: "flex", alignItems: "center", marginBottom: 10 }}>
            {IcChat("var(--text2)")}
            <span style={{ fontSize: 15, fontWeight: 700, marginLeft: 6 }}>補充說明</span>
            <Badge label="選填" color="var(--brand-dk)" bg="var(--brand-bg)" />
          </div>
          <textarea
            placeholder="護理師口頭交代的重點、醫師的回覆…"
            value={text}
            onChange={(e) => setText(e.target.value)}
            style={{
              width: "100%", height: 72, resize: "none", boxSizing: "border-box",
              background: "var(--surface2)", border: "1.5px solid var(--surface3)", borderRadius: 14,
              padding: "12px 14px", fontFamily: "inherit", fontSize: 15, color: "var(--text)",
              lineHeight: 1.5, outline: "none",
            }}
          />
          <div style={{ fontSize: 12, color: "var(--text3)", marginTop: 6, display: "flex", alignItems: "center", gap: 4 }}>
            {IcBulb("var(--text3)")} 補充越詳細，AI 整理越完整
          </div>
        </div>

        {/* Voice section */}
        <div className="a2">
          <div style={{ display: "flex", alignItems: "center", marginBottom: 10 }}>
            {IcMic("var(--text2)")}
            <span style={{ fontSize: 15, fontWeight: 700, marginLeft: 6 }}>錄音紀錄</span>
            <Badge label="Coming Soon" color="var(--text3)" bg="#EFEBE3" />
          </div>
          <button disabled style={{
            width: "100%", height: 44, borderRadius: 12, border: "1.5px solid var(--surface3)",
            background: "var(--surface2)", color: "var(--text3)", fontFamily: "inherit", fontWeight: 600,
            fontSize: 14, opacity: 0.5, cursor: "not-allowed", marginBottom: 10,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
          }}>{IcMic("var(--text3)")} 上傳錄音檔（即將推出）</button>
          <textarea
            placeholder="或直接貼上語音轉文字的內容…"
            style={{
              width: "100%", height: 56, resize: "none", boxSizing: "border-box",
              background: "var(--surface2)", border: "1.5px solid var(--surface3)", borderRadius: 14,
              padding: "12px 14px", fontFamily: "inherit", fontSize: 14, color: "var(--text)",
              lineHeight: 1.5, outline: "none",
            }}
          />
        </div>
      </div>

      {/* Fixed bottom CTA */}
      <div style={{
        position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 10,
        display: "flex", justifyContent: "center",
        padding: "12px 0 28px", background: "linear-gradient(transparent, var(--bg) 30%)",
      }}>
        <button
          disabled={!canStart}
          onClick={() => onSubmit(imgs, text)}
          style={{
            width: "calc(100% - 48px)", maxWidth: 432,
            height: 52, borderRadius: 14, border: "none",
            background: "var(--brand)", color: "#fff", fontFamily: "inherit",
            fontWeight: 700, fontSize: 17, letterSpacing: 1,
            cursor: canStart ? "pointer" : "not-allowed",
            opacity: canStart ? 1 : 0.45,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            boxShadow: canStart ? "0 8px 20px rgba(127,182,158,0.35)" : "none",
          }}
        >
          {busy ? IcSpin("#fff") : <>{IcLeaf("#fff")} 開始 AI 整理</>}
        </button>
      </div>
    </section>
  );
}
