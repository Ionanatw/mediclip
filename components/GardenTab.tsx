"use client";
import { useEffect, useState } from "react";
import HappyGarden from "./HappyGarden";
import WateringGame from "./WateringGame";
import { addSun } from "@/lib/gardenConfig";
import { loadWateringState } from "@/lib/wateringGame";

export default function GardenTab() {
  const [playing, setPlaying] = useState(false);
  const [gameInfo, setGameInfo] = useState<{ level: number; bestScore: number; plays: number }>({
    level: 1, bestScore: 0, plays: 0,
  });

  useEffect(() => {
    if (!playing) {
      const st = loadWateringState();
      setGameInfo({ level: st.level, bestScore: st.bestScore, plays: st.plays });
    }
  }, [playing]);

  return (
    <div style={{ flex: 1, overflowY: "auto", padding: "24px 20px 110px" }}>
      <div className="a0" style={{ marginBottom: 18 }}>
        <div style={{ fontSize: 26, fontWeight: 900, color: "var(--text)" }}>🌿 快樂花園</div>
        <p style={{ fontSize: 15, color: "var(--text2)", marginTop: 4 }}>
          照顧家人，也照顧自己的心和腦。
        </p>
      </div>

      {/* 澆花記憶遊戲入口 */}
      <div
        className="card a1"
        style={{ padding: 18, marginBottom: 16, borderLeft: "4px solid #3a86ff", cursor: "pointer" }}
        onClick={() => setPlaying(true)}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{
            width: 64, height: 64, borderRadius: 16, background: "#cce0ff", flexShrink: 0,
            display: "flex", alignItems: "center", justifyContent: "center", fontSize: 34,
          }}>🚿</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 19, fontWeight: 700 }}>澆花記憶</div>
            <div style={{ fontSize: 14, color: "var(--text2)", marginTop: 2 }}>
              記住口渴的花盆，訓練工作記憶 · 每天 3 分鐘
            </div>
            <div style={{ display: "flex", gap: 10, marginTop: 6, fontSize: 13, color: "var(--text3)", fontWeight: 600 }}>
              <span>🌱 第 {gameInfo.level} 關</span>
              {gameInfo.bestScore > 0 && <span>⭐ 最佳 {gameInfo.bestScore}</span>}
              {gameInfo.plays > 0 && <span>🎮 玩過 {gameInfo.plays} 局</span>}
            </div>
          </div>
        </div>
        <button
          style={{
            width: "100%", marginTop: 14, border: "none", background: "#40916c", color: "#fff",
            fontSize: 18, fontWeight: 700, padding: "14px 0", borderRadius: 14, cursor: "pointer",
          }}
        >開始訓練 💧</button>
      </div>

      <div className="a2">
        <HappyGarden />
      </div>

      {/* 更多遊戲預告 */}
      <div className="card a3" style={{ padding: 18, marginTop: 16, opacity: 0.75 }}>
        <div style={{ fontSize: 17, fontWeight: 700 }}>🔒 更多花園遊戲</div>
        <p style={{ fontSize: 14, color: "var(--text2)", marginTop: 4 }}>
          數字花圃、香草配對⋯⋯更多認知訓練遊戲，下載 App 搶先玩。
        </p>
      </div>

      {playing && (
        <WateringGame
          onExit={() => setPlaying(false)}
          onReward={(sun) => addSun(sun)}
        />
      )}
    </div>
  );
}
