import type { CareDocResult } from "@/lib/types";

const SEV_COLOR: Record<string, string> = {
  "必做": "var(--coral)", "注意": "var(--amber)", "知道就好": "var(--green)",
};

export default function OverviewCards({ r }: { r: CareDocResult }) {
  return (
    <>
      {r.summary && (
        <div className="card" style={{ background: "var(--greenBg)" }}>
          <strong>📝 {r.summary}</strong>
        </div>
      )}
      {r.warnings.length > 0 && (
        <div className="card" style={{ background: "var(--coralBg)", borderLeft: "4px solid var(--coral)" }}>
          {r.warnings.map((w, i) => <div key={i}>⚠️ {w}</div>)}
        </div>
      )}
      {r.precautions.length > 0 && (
        <div className="card">
          <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>🩺 注意事項</div>
          {r.precautions.map((p, i) => (
            <div key={i} style={{ padding: "6px 0", fontSize: 16 }}>
              <span style={{ color: SEV_COLOR[p.severity] || "var(--text2)", fontWeight: 600 }}>
                [{p.severity}]
              </span>{" "}
              {p.description}
            </div>
          ))}
        </div>
      )}
      {r.lab_tests.length > 0 && (
        <div className="card">
          <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>🧪 檢驗</div>
          {r.lab_tests.map((t, i) => (
            <div key={i} style={{ fontSize: 16, padding: "4px 0" }}>
              {t.name}{t.fasting ? "（需空腹）" : ""}{t.date ? ` · ${t.date}` : ""}
            </div>
          ))}
        </div>
      )}
      {r.doctor_responses.length > 0 && (
        <div className="card">
          <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>💬 醫師回覆</div>
          {r.doctor_responses.map((d, i) => (
            <div key={i} style={{ fontSize: 16, padding: "4px 0" }}>
              <strong>Q：</strong>{d.question}<br />
              <strong>A：</strong>{d.answer}
            </div>
          ))}
        </div>
      )}
    </>
  );
}
