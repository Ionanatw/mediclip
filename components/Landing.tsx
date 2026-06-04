export default function Landing({ onStart }: { onStart: () => void }) {
  return (
    <section style={{ paddingTop: 40 }}>
      <div style={{ fontSize: 56, textAlign: "center" }}>🌿</div>
      <h1 className="h1" style={{ textAlign: "center", marginTop: 12 }}>CareDoc 照護懶人包</h1>
      <p className="muted" style={{ textAlign: "center", margin: "12px 0 28px" }}>
        拍照上傳醫療單，AI 幫你秒懂、秒整理、秒提醒。3 分鐘體驗。
      </p>
      <div className="card">
        <p>📋 出院衛教單、處方箋、回診單看不懂？</p>
        <p style={{ marginTop: 8 }}>上傳照片，AI 幫你整理成家人一看就懂的照護指南。</p>
      </div>
      <button className="btn-primary" onClick={onStart}>開始整理 →</button>
    </section>
  );
}
