import type { CareDocResult } from "@/lib/types";

export interface ChecklistItem {
  id: string;
  label: string;
  done: boolean;
  source: "med" | "precaution" | "schedule" | "user";
}

export function deriveChecklist(r: CareDocResult): ChecklistItem[] {
  const items: ChecklistItem[] = [];
  let n = 0;
  const add = (label: string, source: ChecklistItem["source"]) =>
    items.push({ id: `ai-${n++}`, label, done: false, source });

  r.medication.forEach((m) => {
    if (m.name_zh) add(`服用 ${m.name_zh}${m.frequency ? `（${m.frequency}）` : ""}`, "med");
  });
  r.precautions.forEach((p) => {
    if (p.severity === "必做" && p.description) add(p.description, "precaution");
  });
  return items;
}
