"use client";
import { useEffect, useState } from "react";
import { SAKURA, stageFor, loadSun, addSun, SUN_EVENT } from "@/lib/gardenConfig";

export default function HappyGarden() {
  const [sun, setSun] = useState(0);
  const [splash, setSplash] = useState(false);
  const [gratitude, setGratitude] = useState("");
  const [breathing, setBreathing] = useState(false);

  useEffect(() => {
    setSun(loadSun());
    const onSun = (e: Event) => setSun((e as CustomEvent<number>).detail);
    window.addEventListener(SUN_EVENT, onSun);
    return () => window.removeEventListener(SUN_EVENT, onSun);
  }, []);

  const water = (amount: number) => {
    addSun(amount); // 寫入共享 ☀️ 並透過事件同步 state
    setSplash(true);
    setTimeout(() => setSplash(false), 900);
  };
  const stage = stageFor(SAKURA, sun);

  return (
    <div className="card" style={{ background: "var(--greenBg)", borderLeft: "4px solid var(--green)" }}>
      <div className="h2" style={{ fontSize: 19 }}>🌿 快樂花園（體驗版）</div>
      <p className="muted" style={{ fontSize: 15, margin: "4px 0 14px" }}>
        照顧家人，也照顧自己。完成任務澆灌你的櫻花樹。
      </p>

      <div style={{ display: "flex", gap: 18, alignItems: "center", justifyContent: "center", padding: "10px 0" }}>
        <div style={{ textAlign: "center" }}>
          <div style={{ fontSize: 56, transition: "transform .3s", transform: splash ? "scale(1.25)" : "scale(1)" }}>
            {stage.emoji}
          </div>
          <div style={{ fontSize: 14 }} className="muted">{SAKURA.name_zh}　☀️ {sun}</div>
        </div>
        <div style={{ textAlign: "center", opacity: 0.55 }}>
          <div style={{ fontSize: 44 }}>🪷</div>
          <div style={{ fontSize: 13 }} className="muted">蓮花種子<br />下一棵即將解鎖</div>
        </div>
      </div>

      {/* 呼吸練習 */}
      {!breathing ? (
        <button className="btn-secondary" onClick={() => setBreathing(true)} style={{ marginTop: 8 }}>
          🫁 478 呼吸練習（+2 ☀️）
        </button>
      ) : (
        <div style={{ textAlign: "center", margin: "10px 0" }}>
          <div
            style={{
              width: 90, height: 90, borderRadius: "50%", margin: "0 auto",
              background: "var(--green)", animation: "breathe 4s ease-in-out infinite",
            }}
          />
          <button className="btn-secondary" style={{ marginTop: 12 }} onClick={() => { setBreathing(false); water(2); }}>
            完成一輪（+2 ☀️）
          </button>
          <style>{`@keyframes breathe{0%,100%{transform:scale(.7);opacity:.6}50%{transform:scale(1.1);opacity:1}}`}</style>
        </div>
      )}

      {/* 感恩日記 */}
      <div style={{ marginTop: 12 }}>
        <input
          value={gratitude}
          placeholder="寫一件今天感恩的事…（+2 ☀️）"
          onChange={(e) => setGratitude(e.target.value)}
          style={{ width: "100%", fontSize: 16, padding: 10, border: "1px solid var(--bg3)", borderRadius: 10 }}
        />
        <button
          className="btn-secondary"
          style={{ marginTop: 8 }}
          disabled={!gratitude.trim()}
          onClick={() => { water(2); setGratitude(""); }}
        >
          記下並澆灌
        </button>
      </div>

      <p style={{ marginTop: 14, textAlign: "center", fontWeight: 700, color: "var(--greenDk)" }}>
        下載 App 種完整的快樂森林 🌸
      </p>
    </div>
  );
}
