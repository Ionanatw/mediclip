import type { ScheduleItem } from "@/lib/types";

export default function CalendarList({ items }: { items: ScheduleItem[] }) {
  if (!items.length) return null;
  return (
    <div className="card" style={{ borderLeft: "4px solid var(--blue)" }}>
      <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>📅 行事曆</div>
      {items.map((e, i) => (
        <div
          key={i}
          style={{
            display: "flex", gap: 10, padding: "8px 0",
            borderBottom: i < items.length - 1 ? "1px solid var(--bg3)" : "none",
          }}
        >
          <div style={{ minWidth: 92, color: "var(--blue)", fontWeight: 600, fontSize: 16 }}>
            {e.date || "—"}{e.time ? ` ${e.time}` : ""}
          </div>
          <div style={{ fontSize: 16 }}>
            <div>{e.event}{e.department && <span style={{ color: "var(--greenDk)", fontWeight: 600 }}>（{e.department}）</span>}</div>
            {e.location && <div className="muted" style={{ fontSize: 15 }}>📍 {e.location}</div>}
          </div>
        </div>
      ))}
    </div>
  );
}
