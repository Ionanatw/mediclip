"use client";
import { useEffect, useState } from "react";

const STEPS = ["辨識文件中…", "提取醫療資訊…", "整理成懶人包…"];

export default function Processing() {
  const [i, setI] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setI((p) => (p + 1) % STEPS.length), 1500);
    return () => clearInterval(t);
  }, []);
  return (
    <section style={{ paddingTop: 80, textAlign: "center" }}>
      <div style={{ fontSize: 56 }}>🌿</div>
      <p className="h2" style={{ marginTop: 20 }}>{STEPS[i]}</p>
      <p className="muted" style={{ marginTop: 10, fontSize: 16 }}>約需 10–20 秒，照片不會被儲存</p>
    </section>
  );
}
