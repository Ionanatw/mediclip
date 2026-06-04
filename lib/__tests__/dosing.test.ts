import { describe, it, expect } from "vitest";
import { dosingBySlot } from "@/lib/dosing";
import type { Medication } from "@/lib/types";

describe("dosingBySlot", () => {
  it("一天三次飯後 → 早中晚都有", () => {
    const meds: Medication[] = [{ name_zh: "普拿疼", timing: ["早", "中", "晚"], meal_relation: "飯後" }];
    const slots = dosingBySlot(meds);
    expect(slots.map((s) => s.slot)).toEqual(["早", "中", "晚"]);
    expect(slots[0].meds[0]).toEqual({ name: "普拿疼", meal: "飯後" });
  });
  it("睡前藥只出現在睡前", () => {
    const meds: Medication[] = [{ name_zh: "安眠藥", timing: ["睡前"] }];
    expect(dosingBySlot(meds).map((s) => s.slot)).toEqual(["睡前"]);
  });
  it("沒有 timing 的藥不進任何時段", () => {
    expect(dosingBySlot([{ name_zh: "備用藥" }])).toEqual([]);
  });
  it("同一時段多種藥都列出", () => {
    const meds: Medication[] = [
      { name_zh: "A", timing: ["早"] },
      { name_zh: "B", timing: ["早"] },
    ];
    const slots = dosingBySlot(meds);
    expect(slots).toHaveLength(1);
    expect(slots[0].meds.map((m) => m.name)).toEqual(["A", "B"]);
  });
});
