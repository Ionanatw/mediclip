import type { Medication } from "@/lib/types";
import { drugSvg } from "@/lib/drugSvg";

export default function DrugCard({ med }: { med: Medication }) {
  return (
    <div className="card" style={{ borderLeft: "4px solid var(--purple)" }}>
      <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
        <span dangerouslySetInnerHTML={{ __html: drugSvg(med.shape, med.color) }} />
        <div>
          <div style={{ fontWeight: 700 }}>
            {med.name_zh}{" "}
            {med.name_en && <span className="muted" style={{ fontSize: 15 }}>{med.name_en}</span>}
          </div>
          <div className="muted" style={{ fontSize: 16 }}>
            {[med.dosage, med.frequency, med.duration].filter(Boolean).join(" · ")}
          </div>
        </div>
      </div>
      {med.notes && (
        <div style={{ marginTop: 10, background: "var(--purpleBg)", padding: 10, borderRadius: 10, fontSize: 16 }}>
          <strong>專業版注意事項：</strong>{med.notes}
        </div>
      )}
    </div>
  );
}
