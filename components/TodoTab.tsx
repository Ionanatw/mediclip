"use client";
import type { CareDocResult } from "@/lib/types";
import Checklist from "./Checklist";

export default function TodoTab({ result }: { result: CareDocResult }) {
  const { summary, lifestyle_notes: notes, precautions } = result;
  const hasFlow = Boolean(summary) || notes.length > 0 || precautions.length > 0;

  return (
    <div>
      {/* 療程流程（唯讀）在上 */}
      <div className="card" style={{ borderLeft: "4px solid var(--blue)" }}>
        <div className="h2" style={{ fontSize: 19, marginBottom: 8 }}>📖 療程重點 / 流程</div>
        {summary && <p style={{ fontSize: 16, marginBottom: 10 }}>{summary}</p>}
        {notes.map((n, i) => (
          <div key={`n${i}`} style={{ fontSize: 16, padding: "4px 0" }}>
            {n.icon || "•"} <strong>{n.title}</strong>：{n.description}
          </div>
        ))}
        {precautions.map((p, i) => (
          <div key={`p${i}`} style={{ fontSize: 16, padding: "4px 0", color: "var(--text2)" }}>
            ・{p.description}
          </div>
        ))}
        {!hasFlow && <p className="muted" style={{ fontSize: 15 }}>此次未擷取到流程說明。</p>}
      </div>

      {/* 今日待辦（可勾選）在下 */}
      <Checklist result={result} />
    </div>
  );
}
