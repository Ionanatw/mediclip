export default function LockedFeature({ title, cta }: { title: string; cta: string }) {
  return (
    <div className="card lock-wrap" style={{ minHeight: 120 }}>
      <div className="blur-lock">
        <div className="h2" style={{ fontSize: 19 }}>{title}</div>
        <p style={{ marginTop: 8 }}>這是進階功能的預覽內容，下載 App 解鎖完整體驗。</p>
      </div>
      <div className="lock-cta">
        <div style={{ fontSize: 28 }}>🔒</div>
        <div style={{ fontWeight: 700 }}>{cta}</div>
      </div>
    </div>
  );
}
