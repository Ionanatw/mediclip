import type { Medication } from "@/lib/types";
import { dosingBySlot } from "@/lib/dosing";

const SLOT_ICON: Record<string, string> = { "早": "🌅", "中": "☀️", "晚": "🌙", "睡前": "🛏️" };

export default function DosingSchedule({ meds }: { meds: Medication[] }) {
  const slots = dosingBySlot(meds);
  if (!slots.length) return null;
  return (
    <div className="card" style={{ borderLeft: "4px solid var(--purple)" }}>
      <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>⏰ 服用時段</div>
      {slots.map((s) => (
        <div key={s.slot} style={{ display: "flex", gap: 12, padding: "8px 0", borderBottom: "1px solid var(--bg3)", alignItems: "flex-start" }}>
          <div style={{ minWidth: 56, fontWeight: 700, color: "var(--greenDk)" }}>
            {SLOT_ICON[s.slot] || ""} {s.slot}
          </div>
          <div style={{ fontSize: 16 }}>
            {s.meds.map((m, i) => (
              <span key={i}>
                {m.name}{m.meal ? <span className="muted" style={{ fontSize: 14 }}>（{m.meal}）</span> : null}
                {i < s.meds.length - 1 ? "、" : ""}
              </span>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
