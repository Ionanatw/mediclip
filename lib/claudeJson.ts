import type { CareDocResult } from "@/lib/types";

const EMPTY: CareDocResult = {
  medication: [], schedule: [], precautions: [], lab_tests: [],
  symptoms: [], doctor_responses: [], followup_questions: [],
  lifestyle_notes: [], warnings: [],
};

export function extractJson(raw: string): CareDocResult {
  let text = raw.trim();
  const fence = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) text = fence[1].trim();
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start === -1 || end === -1 || end <= start) {
      throw new Error("無法從回應中解析 JSON");
    }
    parsed = JSON.parse(text.slice(start, end + 1));
  }
  return { ...EMPTY, ...(parsed as object) } as CareDocResult;
}
