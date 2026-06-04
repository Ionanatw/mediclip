import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabaseAdmin";

export const runtime = "nodejs";

export async function POST(req: Request) {
  let email = "";
  try {
    ({ email } = await req.json());
  } catch {
    return NextResponse.json({ error: "格式錯誤" }, { status: 400 });
  }
  email = (email || "").trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    return NextResponse.json({ error: "email 格式不正確" }, { status: 400 });
  }
  const db = supabaseAdmin();
  const { data: existing, error: selErr } = await db
    .from("sns_usage").select("email").eq("email", email).maybeSingle();
  if (selErr) return NextResponse.json({ error: "服務暫時無法使用" }, { status: 500 });
  if (existing) return NextResponse.json({ allowed: false });

  const { error: insErr } = await db.from("sns_usage").insert({ email });
  if (insErr) {
    // unique 競態：視為已使用
    return NextResponse.json({ allowed: false });
  }
  return NextResponse.json({ allowed: true });
}
