export default function LockedFeature({ title, cta }: { title: string; cta: string }) {
  return (
    <div className="card lock-wrap" style={{ minHeight: 110, overflow: "hidden" }}>
      {/* Blurred preview */}
      <div className="blur-lock">
        <div className="h2" style={{ fontSize: 18, marginBottom: 8 }}>{title}</div>
        <p style={{ fontSize: 14, color: "var(--text2)" }}>這是進階功能的預覽內容，下載 App 解鎖完整體驗。</p>
      </div>

      {/* Lock overlay */}
      <div className="lock-cta" style={{ background: "rgba(253,251,247,0.72)", backdropFilter: "blur(2px)" }}>
        <div style={{
          width: 32, height: 32, borderRadius: 10,
          background: "var(--card)", border: "1px solid var(--border)",
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: "0 1px 4px rgba(0,0,0,.06)",
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--text2)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
          </svg>
        </div>
        <p style={{ fontSize: 14, fontWeight: 600, color: "var(--text)", marginTop: 2 }}>{cta}</p>
      </div>
    </div>
  );
}
