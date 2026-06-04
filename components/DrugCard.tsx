import type { Medication } from "@/lib/types";
import { drugSvg } from "@/lib/drugSvg";

export default function DrugCard({ med }: { med: Medication }) {
  return (
    <div className="card" style={{ borderLeft: "4px solid var(--purple)" }}>
      <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
        <div
          aria-label={`${med.name_zh} 外觀`}
          style={{
            flex: "0 0 auto", width: 120, height: 80, display: "flex",
            alignItems: "center", justifyContent: "center",
            background: "var(--bg2)", border: "1px solid var(--bg3)", borderRadius: 12,
          }}
          dangerouslySetInnerHTML={{ __html: drugSvg(med.shape, med.color) }}
        />
        <div>
          <div style={{ fontWeight: 700 }}>
            {med.name_zh}{" "}
            {med.name_en && <span className="muted" style={{ fontSize: 15 }}>{med.name_en}</span>}
          </div>
          <div className="muted" style={{ fontSize: 16 }}>
            {[med.dosage, med.frequency, med.duration].filter(Boolean).join(" · ")}
          </div>
          {(med.timing?.length || med.meal_relation) && (
            <div style={{ fontSize: 15, color: "var(--greenDk)", marginTop: 4 }}>
              服用方式：{[med.timing?.join("・"), med.meal_relation].filter(Boolean).join("｜")}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
