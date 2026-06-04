import { describe, it, expect } from "vitest";
import { drugColorFill, drugSvg } from "@/lib/drugSvg";

describe("drugColorFill", () => {
  it("已知顏色對應 fill", () => {
    expect(drugColorFill("粉紅色")).toBe("#F5D0C8");
    expect(drugColorFill("白色")).toBe("#F8F8F5");
  });
  it("未知顏色給預設白", () => {
    expect(drugColorFill(undefined)).toBe("#F8F8F5");
  });
});

describe("drugSvg", () => {
  it("圓形錠用 circle", () => {
    expect(drugSvg("圓形", "白色")).toContain("<circle");
  });
  it("橢圓用 ellipse", () => {
    expect(drugSvg("橢圓", "黃色")).toContain("<ellipse");
  });
  it("膠囊含兩個 rect", () => {
    const svg = drugSvg("膠囊", "粉紅色");
    expect((svg.match(/<rect/g) || []).length).toBeGreaterThanOrEqual(2);
  });
  it("粉包含虛線", () => {
    expect(drugSvg("粉包", "白色")).toContain("stroke-dasharray");
  });
  it("永遠回傳 svg 元素", () => {
    expect(drugSvg(undefined, undefined)).toContain("<svg");
  });
});
