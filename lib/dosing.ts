import type { Medication } from "@/lib/types";

export const DOSE_SLOTS = ["早", "中", "晚", "睡前"] as const;

export interface SlotEntry {
  slot: string;
  meds: { name: string; meal?: string }[];
}

/** 把藥品依「早/中/晚/睡前」分組，只回傳有藥的時段。 */
export function dosingBySlot(meds: Medication[]): SlotEntry[] {
  return DOSE_SLOTS.map((slot) => ({
    slot,
    meds: meds
      .filter((m) => (m.timing || []).includes(slot))
      .map((m) => ({ name: m.name_zh || m.name_en || "藥品", meal: m.meal_relation })),
  })).filter((e) => e.meds.length > 0);
}
