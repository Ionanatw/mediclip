"use client";
import { useMemo, useState } from "react";
import type { CareDocResult } from "@/lib/types";
import { deriveChecklist, type ChecklistItem } from "@/lib/checklist";

export default function Checklist({ result }: { result: CareDocResult }) {
  const initial = useMemo(() => deriveChecklist(result), [result]);
  const [items, setItems] = useState<ChecklistItem[]>(initial);
  const [draft, setDraft] = useState("");

  const toggle = (id: string) =>
    setItems((p) => p.map((i) => (i.id === id ? { ...i, done: !i.done } : i)));
  const addUser = () => {
    const label = draft.trim();
    if (!label) return;
    setItems((p) => [...p, { id: `user-${Date.now()}`, label, done: false, source: "user" }]);
    setDraft("");
  };
  const doneCount = items.filter((i) => i.done).length;

  return (
    <div className="card" style={{ borderLeft: "4px solid var(--green)" }}>
      <div className="h2" style={{ fontSize: 19, marginBottom: 6 }}>📋 今日照護 Checklist</div>
      <div className="muted" style={{ fontSize: 15, marginBottom: 10 }}>{doneCount}/{items.length} 完成</div>
      {items.map((i) => (
        <label
          key={i.id}
          style={{
            display: "flex", gap: 10, alignItems: "center", padding: "6px 0", fontSize: 16,
            textDecoration: i.done ? "line-through" : "none",
            color: i.done ? "var(--text3)" : "var(--text)",
          }}
        >
          <input type="checkbox" checked={i.done} onChange={() => toggle(i.id)} style={{ width: 20, height: 20 }} />
          {i.label}
        </label>
      ))}
      <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
        <input
          value={draft}
          placeholder="新增自己的項目（單子上沒有的）…"
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") addUser(); }}
          style={{ flex: 1, fontSize: 16, padding: 10, border: "1px solid var(--bg3)", borderRadius: 10 }}
        />
        <button className="btn-secondary" style={{ width: "auto", padding: "10px 16px" }} onClick={addUser}>＋</button>
      </div>
    </div>
  );
}
