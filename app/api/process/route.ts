import { NextResponse } from "next/server";
import { SYSTEM_PROMPT } from "@/lib/systemPrompt";
import { extractJson } from "@/lib/claudeJson";

export const runtime = "nodejs";
export const maxDuration = 60;

interface ImgIn { type: string; data: string; }

async function callClaude(content: unknown[]): Promise<string> {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": process.env.ANTHROPIC_API_KEY || "",
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4000,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content }],
    }),
  });
  if (!res.ok) throw new Error(`Claude API ${res.status}`);
  const data = await res.json();
  return data?.content?.[0]?.text ?? "";
}

export async function POST(req: Request) {
  let body: { images?: ImgIn[]; text?: string; priorResult?: unknown };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "格式錯誤" }, { status: 400 });
  }
  const { images = [], text = "", priorResult } = body;
  if (!images.length && !text) {
    return NextResponse.json({ error: "請至少上傳一張圖片或填寫說明" }, { status: 400 });
  }

  const content: unknown[] = [];
  for (const img of images.slice(0, 3)) {
    content.push({ type: "image", source: { type: "base64", media_type: img.type, data: img.data } });
  }
  if (text) content.push({ type: "text", text: `照護者補充：${text}` });
  if (priorResult) {
    content.push({ type: "text", text: `現有整理結果（priorResult，請合併新文件）：\n${JSON.stringify(priorResult)}` });
  }
  content.push({ type: "text", text: "請辨識並結構化以上所有醫療文件內容，只回傳 JSON。" });

  // 呼叫 + 解析，失敗重試 1 次
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const raw = await callClaude(content);
      return NextResponse.json({ result: extractJson(raw) });
    } catch {
      if (attempt === 1) {
        return NextResponse.json({ error: "AI 整理失敗，請稍後再試" }, { status: 502 });
      }
    }
  }
  return NextResponse.json({ error: "未知錯誤" }, { status: 500 });
}
