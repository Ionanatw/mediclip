export default function FinalCTA() {
  return (
    <div className="card" style={{ background: "var(--greenBg)", textAlign: "center" }}>
      <div className="h2">你的照護懶人包整理好了 🌿</div>
      <p style={{ margin: "12px 0" }}>
        想要更多？<br />
        📲 一鍵加入行事曆　🌸 種快樂樹　💊 白話版注意事項　📋 完整 Checklist
      </p>
      <button className="btn-primary" onClick={() => alert("App 即將上線")}>→ 下載 CareDoc App</button>
    </div>
  );
}
