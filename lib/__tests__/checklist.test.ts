import { describe, it, expect } from "vitest";
import { deriveChecklist } from "@/lib/checklist";
import type { CareDocResult } from "@/lib/types";

const base: CareDocResult = {
  medication: [], schedule: [], precautions: [], lab_tests: [],
  symptoms: [], doctor_responses: [], followup_questions: [],
  lifestyle_notes: [], warnings: [],
};

describe("deriveChecklist", () => {
  it("把必做注意事項變成項目", () => {
    const r = { ...base, precautions: [{ category: "傷口", description: "每天換藥", severity: "必做" }] };
    const items = deriveChecklist(r);
    expect(items.some((i) => i.label.includes("每天換藥"))).toBe(true);
  });
  it("非必做的注意事項不進清單", () => {
    const r = { ...base, precautions: [{ category: "飲食", description: "少油", severity: "知道就好" }] };
    expect(deriveChecklist(r).length).toBe(0);
  });
  it("用藥變成今天吃藥項目", () => {
    const r = { ...base, medication: [{ name_zh: "普拿疼", frequency: "一天三次" }] };
    expect(deriveChecklist(r).some((i) => i.label.includes("普拿疼"))).toBe(true);
  });
  it("每個項目有唯一 id 且預設未勾", () => {
    const r = { ...base, medication: [{ name_zh: "A" }, { name_zh: "B" }] };
    const items = deriveChecklist(r);
    expect(new Set(items.map((i) => i.id)).size).toBe(items.length);
    expect(items.every((i) => i.done === false)).toBe(true);
  });
});
