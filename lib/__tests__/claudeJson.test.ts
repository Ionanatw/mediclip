import { describe, it, expect } from "vitest";
import { extractJson } from "@/lib/claudeJson";

describe("extractJson", () => {
  it("解析乾淨 JSON", () => {
    expect(extractJson('{"summary":"hi","medication":[]}').summary).toBe("hi");
  });
  it("剝除 ```json 圍欄", () => {
    const r = extractJson('```json\n{"summary":"x","medication":[]}\n```');
    expect(r.summary).toBe("x");
  });
  it("抓出前後夾雜文字中的物件", () => {
    const r = extractJson('好的：{"summary":"y","medication":[]} 以上');
    expect(r.summary).toBe("y");
  });
  it("補滿缺漏陣列欄位", () => {
    const r = extractJson('{"summary":"z"}');
    expect(r.medication).toEqual([]);
    expect(r.warnings).toEqual([]);
  });
  it("無法解析時丟錯", () => {
    expect(() => extractJson("完全不是 json")).toThrow();
  });
});
