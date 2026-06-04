import type { DocumentItem } from "@/lib/types";

export default function DocumentList({ items }: { items: DocumentItem[] }) {
  if (!items.length) return null;
  return (
    <div className="card" style={{ borderLeft: "4px solid var(--text3)" }}>
      <div className="h2" style={{ fontSize: 19, marginBottom: 10 }}>📄 本次上傳文件</div>
      {items.map((d, i) => (
        <div key={i} style={{ padding: "8px 0", borderBottom: i < items.length - 1 ? "1px solid var(--bg3)" : "none" }}>
          <div style={{ fontSize: 16, fontWeight: 600 }}>
            {d.title || `文件 ${i + 1}`}
            {d.date && <span className="muted" style={{ fontSize: 14, fontWeight: 400 }}>　{d.date}</span>}
          </div>
          {d.summary && <div className="muted" style={{ fontSize: 15, marginTop: 2 }}>{d.summary}</div>}
        </div>
      ))}
    </div>
  );
}
