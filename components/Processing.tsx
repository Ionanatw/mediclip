"use client";
import { useEffect, useState } from "react";
import ToastMascot from "./ToastMascot";

const STEPS = [
  "辨識文件內容",
  "提取用藥資訊",
  "整理注意事項與行程",
  "生成照護懶人包",
];

function DoneIcon({ c }: { c: string }) {
  return (
    <div style={{ width: 26, height: 26, borderRadius: "50%", background: c, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4L19 7" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" /></svg>
    </div>
  );
}
function SpinnerIcon({ c }: { c: string }) {
  return (
    <div style={{ width: 26, height: 26, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" style={{ animation: "cdSpin .8s linear infinite" }}>
        <circle cx="12" cy="12" r="9" stroke={c} strokeOpacity=".2" strokeWidth="3" />
        <path d="M12 3a9 9 0 016.364 2.636" stroke={c} strokeWidth="3" strokeLinecap="round" />
      </svg>
    </div>
  );
}
function PendingIcon({ c }: { c: string }) {
  return <div style={{ width: 26, height: 26, borderRadius: "50%", border: `2px solid ${c}`, flexShrink: 0 }} />;
}
function ErrorIcon() {
  return (
    <div style={{ width: 26, height: 26, borderRadius: "50%", background: "#D97757", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
      <svg width="12" height="12" viewBox="0 0 12 12"><path d="M3 3l6 6M9 3l-6 6" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" /></svg>
    </div>
  );
}

export default function Processing({ error, onRetry }: { error?: string; onRetry?: () => void }) {
  const [step, setStep] = useState(0);

  useEffect(() => {
    if (error) return;
    const timers = [
      setTimeout(() => setStep(1), 3000),
      setTimeout(() => setStep(2), 7000),
    ];
    return () => timers.forEach(clearTimeout);
  }, [error]);

  const isError = !!error;
  const progress = isError ? (step / 4) : Math.min(step / 4, 1);

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      background: "var(--bg)", minHeight: "100dvh",
    }}>
      <div style={{ width: "100%", maxWidth: 420, padding: "0 32px", boxSizing: "border-box", display: "flex", flexDirection: "column", alignItems: "center", gap: 24 }}>

        {/* Toast MaiMai */}
        <div style={{ animation: "cdFloat 2.5s ease-in-out infinite" }}>
          <ToastMascot size={64} />
        </div>

        {/* Title */}
        <div style={{ fontWeight: 900, fontSize: 22, textAlign: "center", letterSpacing: 0.5, whiteSpace: "nowrap" }}>
          {isError ? "處理時發生問題" : step >= 4 ? "整理完成！" : "AI 正在整理你的文件"}
        </div>

        {/* Pulsing dots */}
        {!isError && step < 4 && (
          <div style={{ display: "flex", gap: 8, marginTop: -12 }}>
            {[0, 1, 2].map((i) => (
              <div key={i} style={{
                width: 10, height: 10, borderRadius: "50%", background: "var(--brand)",
                animation: "cdPulse 1.2s ease-in-out infinite",
                animationDelay: `${i * 0.2}s`,
              }} />
            ))}
          </div>
        )}

        {/* Step list */}
        <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: 14 }}>
          {STEPS.map((label, i) => {
            const idx = i + 1;
            const isDone = idx <= step;
            const isActive = idx === step + 1 && !isError && step < 4;
            const isStepError = isError && idx === step + 1;
            const textColor = isDone ? "var(--brand-dk)" : isActive ? "var(--text)" : isStepError ? "var(--warning)" : "var(--text3)";
            const icon = isDone ? <DoneIcon c="var(--brand)" />
              : isActive ? <SpinnerIcon c="var(--amber)" />
              : isStepError ? <ErrorIcon />
              : <PendingIcon c="var(--surface3)" />;

            return (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 14 }}>
                {icon}
                <div style={{ fontWeight: isDone || isActive ? 600 : 400, fontSize: 15, color: textColor, lineHeight: 1.3, whiteSpace: "nowrap" }}>
                  {label}{isActive ? "..." : ""}
                </div>
              </div>
            );
          })}
        </div>

        {/* Progress bar */}
        <div style={{ width: "100%" }}>
          <div style={{ width: "100%", height: 6, borderRadius: 3, background: "var(--surface3)", overflow: "hidden" }}>
            <div style={{
              width: `${Math.max(progress * 100, 2)}%`, height: "100%", borderRadius: 3,
              background: isError ? "var(--warning)" : "linear-gradient(90deg, var(--brand), var(--brand-dk))",
              transition: "width 0.5s ease-out",
            }} />
          </div>
        </div>

        {/* Bottom hint */}
        {isError ? (
          <div style={{ textAlign: "center" }}>
            <div style={{ fontSize: 14, color: "var(--text3)", marginBottom: 16 }}>網路不穩，請再試一次</div>
            <button onClick={onRetry} style={{
              height: 44, padding: "0 28px", borderRadius: 999,
              border: "1.5px solid var(--surface3)", background: "transparent",
              color: "var(--text)", fontFamily: "inherit", fontWeight: 600, fontSize: 15, cursor: "pointer",
            }}>重新整理</button>
          </div>
        ) : step >= 4 ? (
          <div style={{ fontSize: 14, color: "var(--brand)", fontWeight: 600 }}>即將跳轉...</div>
        ) : (
          <div style={{ fontSize: 13, color: "var(--text3)" }}>通常需要 10-20 秒</div>
        )}
      </div>
    </section>
  );
}
