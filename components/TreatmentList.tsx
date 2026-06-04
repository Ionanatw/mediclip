import type { Treatment } from "@/lib/types";

const TYPE_ICON: Record<string, string> = {
  "化療": "💉", "電療": "☢️", "放射線治療": "☢️", "物理治療": "🤸", "復健": "🤸",
};

function iconFor(t: Treatment): string {
  const key = t.type || t.name || "";
  for (const k of Object.keys(TYPE_ICON)) if (key.includes(k)) return TYPE_ICON[k];
  return "🏥";
}

export default function TreatmentList({ items }: { items: Treatment[] }) {
  if (!items.length) return null;
  return (
    <div>
      <div className="h2" style={{ fontSize: 19, margin: "8px 0" }}>🏥 療程</div>
      {items.map((t, i) => (
        <div key={i} className="card" style={{ borderLeft: "4px solid var(--blue)" }}>
          <div style={{ fontWeight: 700 }}>
            {iconFor(t)} {t.name}
            {t.type && !t.name.includes(t.type) && <span className="muted" style={{ fontSize: 15 }}>（{t.type}）</span>}
          </div>
          {[t.schedule, t.frequency, t.location].some(Boolean) && (
            <div className="muted" style={{ fontSize: 16, marginTop: 4 }}>
              {[t.schedule, t.frequency, t.location].filter(Boolean).join(" · ")}
            </div>
          )}
          {t.notes && <div style={{ marginTop: 6, fontSize: 15 }}>{t.notes}</div>}
        </div>
      ))}
    </div>
  );
}
