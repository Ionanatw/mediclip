"use client";
import { useState } from "react";
import type { FollowupQuestion } from "@/lib/types";

const BackIcon = (c: string) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const CheckSmall = (c: string) => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4L19 7" stroke={c} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round" /></svg>;

export default function Followup({
  questions,
  onSubmit,
  onSkip,
}: {
  questions: FollowupQuestion[];
  onSubmit: (answers: Record<number, string>) => void;
  onSkip: () => void;
}) {
  const [answers, setAnswers] = useState<Record<number, number | null>>({});
  const [customInputs, setCustomInputs] = useState<Record<number, string>>({});

  function selectOption(qi: number, oi: number) {
    setAnswers((prev) => ({ ...prev, [qi]: oi }));
  }

  const answered = Object.values(answers).filter((v) => v !== null && v !== undefined).length;
  const canSubmit = answered >= 1;

  function handleSubmit() {
    const result: Record<number, string> = {};
    for (const [qi, oi] of Object.entries(answers)) {
      if (oi === null || oi === undefined) continue;
      const q = questions[Number(qi)];
      const opts = q.options || [];
      if (opts[oi] === "自己輸入") {
        result[Number(qi)] = customInputs[Number(qi)] || "";
      } else {
        result[Number(qi)] = opts[oi];
      }
    }
    onSubmit(result);
  }

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column", alignItems: "center",
      background: "var(--bg)", minHeight: "100dvh", paddingTop: 12,
    }}>
      {/* Nav */}
      <div style={{ width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", display: "flex", alignItems: "center", height: 50, flexShrink: 0, position: "relative" }}>
        <div style={{ width: 38, height: 38, borderRadius: "50%", background: "rgba(127,182,158,0.12)", display: "flex", alignItems: "center", justifyContent: "center" }}>
          {BackIcon("#5A9A7D")}
        </div>
        <div style={{ position: "absolute", left: 0, right: 0, textAlign: "center", fontWeight: 700, fontSize: 18, pointerEvents: "none" }}>AI 需要你補充</div>
        <div onClick={onSkip} style={{ marginLeft: "auto", fontWeight: 600, fontSize: 15, color: "var(--brand-dk)", cursor: "pointer", whiteSpace: "nowrap", position: "relative", zIndex: 1 }}>略過</div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, width: "100%", maxWidth: 480, padding: "0 24px", boxSizing: "border-box", overflow: "auto", display: "flex", flexDirection: "column", gap: 14, paddingTop: 4, paddingBottom: 90 }}>

        {/* Emoji + desc */}
        <div style={{ textAlign: "center", padding: "4px 0 0" }}>
          <div style={{ fontSize: 36, marginBottom: 6 }}>🤔</div>
          <div style={{ fontSize: 14, color: "var(--text2)", lineHeight: 1.55 }}>
            AI 辨識到一些缺少的資訊，選擇答案幫助整理更完整
          </div>
        </div>

        {/* Progress */}
        <div style={{ display: "flex", gap: 6, justifyContent: "center" }}>
          {questions.map((_, i) => (
            <div key={i} style={{
              width: 40, height: 4, borderRadius: 2,
              background: answers[i] !== null && answers[i] !== undefined ? "var(--brand)" : "var(--surface3)",
              transition: "background .3s",
            }} />
          ))}
        </div>

        {/* Question cards */}
        {questions.map((q, qi) => {
          const isFirst = qi === 0;
          const selected = answers[qi] ?? null;
          const opts = q.options || [];
          const isCustom = opts[selected ?? -1] === "自己輸入";

          return (
            <div key={qi} style={{
              background: isFirst && selected === null ? "var(--amber-bg)" : "var(--card)",
              border: `1.5px solid ${isFirst && selected === null ? "#E2D5A8" : "var(--surface3)"}`,
              borderRadius: 16, padding: "16px 16px",
            }}>
              <div style={{ fontWeight: 800, fontSize: 16, marginBottom: 10, lineHeight: 1.4 }}>{q.question}</div>
              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                {opts.map((opt, oi) => {
                  const isSel = selected === oi;
                  return (
                    <div key={oi} onClick={() => selectOption(qi, oi)} style={{
                      display: "flex", alignItems: "center", gap: 10,
                      padding: "12px 14px", borderRadius: 12,
                      background: isSel ? "var(--brand-bg)" : "var(--surface2)",
                      border: `1.5px solid ${isSel ? "var(--brand)" : "var(--surface3)"}`,
                      cursor: "pointer", transition: "all .15s",
                    }}>
                      {isSel && CheckSmall("var(--brand-dk)")}
                      <span style={{ fontSize: 15, fontWeight: isSel ? 600 : 400, color: isSel ? "var(--brand-dk)" : "var(--text)" }}>{opt}</span>
                    </div>
                  );
                })}
                {isCustom && (
                  <input
                    type="text"
                    value={customInputs[qi] || ""}
                    onChange={(e) => setCustomInputs((p) => ({ ...p, [qi]: e.target.value }))}
                    placeholder="請輸入…"
                    style={{
                      width: "100%", height: 44, boxSizing: "border-box",
                      border: "1.5px solid var(--brand)", borderRadius: 12,
                      background: "var(--brand-bg)", padding: "0 14px",
                      fontFamily: "inherit", fontSize: 15, color: "var(--text)",
                      outline: "none", marginTop: 2,
                    }}
                  />
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Fixed bottom CTA */}
      <div style={{
        position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 10,
        display: "flex", justifyContent: "center",
        padding: "12px 0 28px", background: "linear-gradient(transparent, var(--bg) 30%)",
      }}>
        <button disabled={!canSubmit} onClick={handleSubmit} style={{
          width: "calc(100% - 48px)", maxWidth: 432,
          height: 52, borderRadius: 14, border: "none",
          background: "var(--brand)", color: "#fff", fontFamily: "inherit",
          fontWeight: 700, fontSize: 16, letterSpacing: 0.5,
          cursor: canSubmit ? "pointer" : "not-allowed",
          opacity: canSubmit ? 1 : 0.45,
          boxShadow: canSubmit ? "0 8px 20px rgba(127,182,158,0.35)" : "none",
        }}>完成補充，生成懶人包 →</button>
      </div>
    </section>
  );
}
