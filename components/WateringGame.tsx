"use client";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  FLOWERS, MEMORY_GAP_MS, ROUNDS_PER_SESSION,
  adjustLevel, haptics, levelConfig, loadWateringState, saveWateringState, sessionScore,
} from "@/lib/wateringGame";
import {
  playBloom, playCelebrate, playChime, playKnock, playSplash, unlockAudio,
} from "@/lib/gameAudio";

type Phase =
  | "tutorial" | "intro" | "show" | "memory" | "action"
  | "question" | "round-result" | "summary";

interface Pot {
  flower: string;
  isTarget: boolean;
  watered: boolean;   // 已正確澆灌（或自動揭示）
  failed: boolean;    // 試過但不渴
}

interface Butterfly { id: number; top: number; dur: number; }

const TUTORIAL_STEPS = [
  { emoji: "💧", title: "記住亮起的花盆", text: "遊戲開始時，幾個花盆會亮起藍色光暈。請記住它們的位置。" },
  { emoji: "🫥", title: "光暈會消失", text: "幾秒後光暈消失，憑記憶找出剛剛口渴的花。" },
  { emoji: "🚿", title: "拖水壺去澆花", text: "把右下角的水壺，慢慢拖到記住的花盆上放開。不用急，慢慢來。" },
];

function makeRound(level: number): Pot[] {
  const cfg = levelConfig(level);
  const flowers = [...FLOWERS].sort(() => Math.random() - 0.5).slice(0, cfg.pots);
  const targetIdx = new Set<number>();
  while (targetIdx.size < cfg.targets) targetIdx.add(Math.floor(Math.random() * cfg.pots));
  return flowers.map((flower, i) => ({
    flower, isTarget: targetIdx.has(i), watered: false, failed: false,
  }));
}

export default function WateringGame({
  onExit, onReward,
}: {
  onExit: () => void;
  onReward: (sun: number) => void;
}) {
  const [store] = useState(loadWateringState);
  const level = store.level;
  const cfg = useMemo(() => levelConfig(level), [level]);

  const [phase, setPhase] = useState<Phase>(store.tutorialDone ? "intro" : "tutorial");
  const [tutorialStep, setTutorialStep] = useState(0);
  const [round, setRound] = useState(1);
  const [pots, setPots] = useState<Pot[]>(() => makeRound(store.level));
  const [countdown, setCountdown] = useState(0);
  const [paused, setPaused] = useState(false);
  const [pauseMsg, setPauseMsg] = useState("");
  const [hint, setHint] = useState("");
  const [shakeIdx, setShakeIdx] = useState(-1);
  const [flash, setFlash] = useState<"good" | "bad" | "">("");

  // 干擾任務
  const [butterflies, setButterflies] = useState<Butterfly[]>([]);
  const butterflyTotal = useRef(0);
  const [questionOpts, setQuestionOpts] = useState<number[]>([]);
  const [answered, setAnswered] = useState<number | null>(null);

  // 統計
  const stats = useRef({
    correct: 0, wrong: 0, dualCorrect: 0, dualTotal: 0,
    reactions: [] as number[], perfectRounds: 0, memorySpan: 0,
  });
  const roundWrong = useRef(0);
  const actionStart = useRef(0);
  const firstCorrectDone = useRef(false);
  const rewarded = useRef(false);
  const [finalScore, setFinalScore] = useState(0);

  // 拖曳
  const [dragging, setDragging] = useState(false);
  const [dragPos, setDragPos] = useState({ x: 0, y: 0 });
  const [hoverIdx, setHoverIdx] = useState(-1);
  const potRefs = useRef<(HTMLDivElement | null)[]>([]);
  const canHome = useRef<HTMLDivElement | null>(null);

  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);
  const after = useCallback((fn: () => void, ms: number) => {
    const t = setTimeout(fn, ms);
    timers.current.push(t);
    return t;
  }, []);
  const clearTimers = useCallback(() => {
    timers.current.forEach(clearTimeout);
    timers.current = [];
  }, []);
  useEffect(() => () => clearTimers(), [clearTimers]);

  // ===== 階段流程 =====
  const startShow = useCallback((potsForRound: Pot[]) => {
    clearTimers();
    setPots(potsForRound);
    setHint("");
    setButterflies([]);
    butterflyTotal.current = 0;
    roundWrong.current = 0;
    firstCorrectDone.current = false;
    setAnswered(null);
    setPhase("show");
    const secs = Math.round(cfg.showMs / 1000);
    setCountdown(secs);
    for (let i = 1; i <= secs; i++) after(() => setCountdown(secs - i), i * 1000);
    after(() => {
      setPhase("memory");
      after(() => {
        setPhase("action");
        actionStart.current = Date.now();
        // 干擾蝴蝶（Level 6+）
        if (cfg.distraction) {
          const n = 1 + Math.floor(Math.random() * 3); // 1-3 隻
          butterflyTotal.current = n;
          for (let b = 0; b < n; b++) {
            after(() => {
              const fly: Butterfly = {
                id: Math.random(), top: 8 + Math.random() * 18, dur: 3500 + Math.random() * 1500,
              };
              setButterflies((arr) => [...arr, fly]);
              playChime();
              haptics.distract();
              after(() => setButterflies((arr) => arr.filter((f) => f.id !== fly.id)), fly.dur + 200);
            }, 800 + b * (2200 + Math.random() * 1500));
          }
        }
      }, MEMORY_GAP_MS);
    }, cfg.showMs);
  }, [after, cfg, clearTimers]);

  useEffect(() => {
    if (phase === "intro") after(() => startShow(makeRound(level)), 2400);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phase]);

  const finishRound = useCallback(() => {
    setPhase("round-result");
    const perfect = roundWrong.current === 0;
    if (perfect) {
      stats.current.perfectRounds += 1;
      stats.current.memorySpan = Math.max(stats.current.memorySpan, cfg.targets);
      haptics.perfect();
    }
    playBloom();
    after(() => {
      if (round >= ROUNDS_PER_SESSION) {
        // 結算
        const s = stats.current;
        const avgReaction = s.reactions.length
          ? Math.round(s.reactions.reduce((a, b) => a + b, 0) / s.reactions.length)
          : null;
        const score = sessionScore(s.correct, s.wrong, s.dualCorrect, s.dualTotal, avgReaction ?? 99999);
        setFinalScore(score);
        const attempts = s.correct + s.wrong;
        const accuracy = attempts ? s.correct / attempts : 0;
        const st = loadWateringState();
        const history = [...st.history, { accuracy }];
        saveWateringState({
          ...st,
          history,
          level: adjustLevel(st.level, history),
          bestScore: Math.max(st.bestScore, score),
          lastScore: score,
          plays: st.plays + 1,
          tutorialDone: true,
        });
        if (!rewarded.current) {
          rewarded.current = true;
          onReward(3);
        }
        haptics.complete();
        playCelebrate();
        setPhase("summary");
      } else {
        setRound((r) => r + 1);
        startShow(makeRound(level));
      }
    }, 2200);
  }, [after, cfg.targets, level, onReward, round, startShow]);

  const afterWateringDone = useCallback(() => {
    if (cfg.distraction && butterflyTotal.current > 0) {
      const n = butterflyTotal.current;
      const base = Math.max(1, n - 1);
      setQuestionOpts([base, base + 1, base + 2]);
      setButterflies([]);
      setPhase("question");
    } else {
      finishRound();
    }
  }, [cfg.distraction, finishRound]);

  // ===== 澆水判定 =====
  const dropOnPot = useCallback((idx: number) => {
    {
      const pot = pots[idx];
      if (!pot || pot.watered) return;
      const next = pots.map((p) => ({ ...p }));
      if (pot.isTarget) {
        next[idx].watered = true;
        if (!firstCorrectDone.current) {
          firstCorrectDone.current = true;
          stats.current.reactions.push(Date.now() - actionStart.current);
        }
        stats.current.correct += 1;
        haptics.correct();
        playSplash();
        setFlash("good");
        setTimeout(() => setFlash(""), 500);
      } else {
        if (!next[idx].failed) {
          next[idx].failed = true;
          stats.current.wrong += 1;
          roundWrong.current += 1;
        }
        haptics.wrong();
        playKnock();
        setShakeIdx(idx);
        setHint("這朵花不渴哦 🌿");
        setTimeout(() => setShakeIdx(-1), 600);
      }
      // 錯誤的盆會留下 💤 標記，正確率已反映錯誤；不自動揭示，
      // 讓長輩自己完成澆灌動作（動作本身有訓練價值）
      if (next.every((p) => !p.isTarget || p.watered)) {
        setTimeout(afterWateringDone, 700);
      }
      setPots(next);
    }
  }, [pots, afterWateringDone]);

  // ===== 拖曳（pointer events）=====
  const findHover = useCallback((x: number, y: number) => {
    let best = -1;
    let bestDist = 70; // 吸附半徑
    potRefs.current.forEach((el, i) => {
      if (!el) return;
      const r = el.getBoundingClientRect();
      const d = Math.hypot(x - (r.left + r.width / 2), y - (r.top + r.height / 2));
      if (d < bestDist) { best = i; bestDist = d; }
    });
    return best;
  }, []);

  const onCanDown = useCallback((e: React.PointerEvent) => {
    if (phase !== "action" || paused) return;
    unlockAudio();
    try { (e.target as HTMLElement).setPointerCapture(e.pointerId); } catch { /* 部分舊瀏覽器不支援 */ }
    setDragging(true);
    setDragPos({ x: e.clientX, y: e.clientY });
    haptics.pickup();
  }, [phase, paused]);

  const onCanMove = useCallback((e: React.PointerEvent) => {
    if (!dragging) return;
    setDragPos({ x: e.clientX, y: e.clientY });
    const h = findHover(e.clientX, e.clientY);
    setHoverIdx((prev) => {
      if (h !== prev && h >= 0) haptics.hover();
      return h;
    });
  }, [dragging, findHover]);

  const onCanUp = useCallback((e: React.PointerEvent) => {
    if (!dragging) return;
    setDragging(false);
    const h = findHover(e.clientX, e.clientY);
    setHoverIdx(-1);
    if (h >= 0) dropOnPot(h);
  }, [dragging, dropOnPot, findHover]);

  // ===== 暫停 / 背景切換 / 閒置 =====
  const pauseGame = useCallback((msg: string) => {
    if (["show", "memory", "action", "question"].includes(phase)) {
      setPaused(true);
      setPauseMsg(msg);
      clearTimers();
      setDragging(false);
    }
  }, [phase, clearTimers]);

  const resumeGame = useCallback(() => {
    setPaused(false);
    setPauseMsg("");
    // PRD：回來後從當前回合重新開始（重新展示目標）
    setPots((prev) => {
      const reset = prev.map((p) => ({ ...p, watered: false, failed: false }));
      startShow(reset);
      return reset;
    });
  }, [startShow]);

  useEffect(() => {
    const onVis = () => { if (document.hidden) pauseGame("休息一下也很好 🌿"); };
    document.addEventListener("visibilitychange", onVis);
    return () => document.removeEventListener("visibilitychange", onVis);
  }, [pauseGame]);

  // 閒置提醒：澆花階段 30 秒提示、120 秒自動暫停
  const lastActive = useRef(Date.now());
  useEffect(() => {
    if (phase !== "action" || paused) return;
    lastActive.current = Date.now();
    const iv = setInterval(() => {
      const idle = Date.now() - lastActive.current;
      if (idle > 120000) pauseGame("休息一下也很好 🌿");
      else if (idle > 30000) {
        setHint("要幫花兒澆水嗎？💧");
        haptics.distract();
      }
    }, 5000);
    return () => clearInterval(iv);
  }, [phase, paused, pauseGame]);
  useEffect(() => {
    const mark = () => { lastActive.current = Date.now(); };
    window.addEventListener("pointerdown", mark);
    window.addEventListener("pointermove", mark);
    return () => {
      window.removeEventListener("pointerdown", mark);
      window.removeEventListener("pointermove", mark);
    };
  }, []);

  // ===== 干擾問答 =====
  function answerQuestion(opt: number) {
    if (answered !== null) return;
    setAnswered(opt);
    stats.current.dualTotal += 1;
    if (opt === butterflyTotal.current) stats.current.dualCorrect += 1;
    // 答錯不扣分（PRD：不是懲罰機制）
    setTimeout(finishRound, 900);
  }

  // ===== Render =====
  const s = stats.current;
  const wateredCount = pots.filter((p) => p.isTarget && p.watered).length;

  return (
    <div style={{
      position: "fixed", inset: 0, zIndex: 60,
      background: "linear-gradient(180deg, #EAF4EE 0%, #FDFBF7 45%, #F6EFDB 100%)",
      display: "flex", flexDirection: "column", maxWidth: 480, margin: "0 auto",
      touchAction: "none", userSelect: "none", WebkitUserSelect: "none",
      fontFamily: '"Noto Sans TC", system-ui, sans-serif',
    }}>
      <style>{`
        @keyframes wgShake{0%,100%{transform:translateX(0) rotate(0)}25%{transform:translateX(-6px) rotate(-4deg)}75%{transform:translateX(6px) rotate(4deg)}}
        @keyframes wgGlow{0%,100%{box-shadow:0 0 0 4px #3a86ff, 0 0 22px rgba(58,134,255,.55)}50%{box-shadow:0 0 0 6px #3a86ff, 0 0 34px rgba(58,134,255,.8)}}
        @keyframes wgBloom{0%{transform:scale(1)}45%{transform:scale(1.45) rotate(-6deg)}100%{transform:scale(1.18)}}
        @keyframes wgFly{from{left:-60px}to{left:calc(100% + 60px)}}
        @keyframes wgFloat{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
        @keyframes wgPop{from{transform:scale(.8);opacity:0}to{transform:scale(1);opacity:1}}
        @keyframes wgFlash{from{opacity:.5}to{opacity:0}}
        @keyframes wgRipple{from{transform:scale(.4);opacity:.8}to{transform:scale(1.6);opacity:0}}
      `}</style>

      {/* 成功/提示閃光（iOS 無震動時的視覺補償） */}
      {flash && (
        <div style={{
          position: "absolute", inset: 0, pointerEvents: "none", zIndex: 5,
          background: flash === "good" ? "rgba(127,182,158,.35)" : "rgba(212,129,107,.25)",
          animation: "wgFlash .5s ease forwards",
        }} />
      )}

      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "18px 20px 6px" }}>
        <button
          onClick={onExit}
          style={{ border: "none", background: "rgba(255,255,255,.8)", borderRadius: 12, padding: "8px 14px", fontSize: 15, color: "#5A9A7D", fontWeight: 700, cursor: "pointer" }}
        >← 離開</button>
        <div style={{ fontSize: 20, fontWeight: 700, color: "#2d6a4f" }}>
          {phase === "summary" ? "🌿 訓練完成" : `🌿 第 ${round} 回合`}
        </div>
        <button
          onClick={() => pauseGame("")}
          aria-label="暫停"
          style={{ border: "none", background: "rgba(255,255,255,.8)", borderRadius: 12, padding: "8px 14px", fontSize: 16, cursor: "pointer", minWidth: 48 }}
        >⏸</button>
      </div>

      {/* 進度與計數 */}
      {!["tutorial", "intro", "summary"].includes(phase) && (
        <div style={{ padding: "0 24px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 16, color: "#6E6A62", fontWeight: 600 }}>
            <span>💧 {wateredCount}/{cfg.targets}</span>
            <span>回合 {round}/{ROUNDS_PER_SESSION}</span>
          </div>
          <div style={{ height: 6, background: "rgba(0,0,0,.08)", borderRadius: 3, marginTop: 6 }}>
            <div style={{
              height: "100%", borderRadius: 3, background: "#40916c", transition: "width .4s",
              width: `${((round - 1) / ROUNDS_PER_SESSION) * 100 + (wateredCount / cfg.targets) * (100 / ROUNDS_PER_SESSION)}%`,
            }} />
          </div>
        </div>
      )}

      {/* ===== 教學 ===== */}
      {phase === "tutorial" && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "center", padding: 28, animation: "wgPop .35s ease" }} key={tutorialStep}>
          <div style={{ background: "#fff", borderRadius: 18, padding: "36px 28px", textAlign: "center", boxShadow: "0 4px 24px rgba(120,100,80,.12)" }}>
            <div style={{ fontSize: 64, animation: "wgFloat 2.4s ease-in-out infinite" }}>{TUTORIAL_STEPS[tutorialStep].emoji}</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: "#2d6a4f", marginTop: 16 }}>{TUTORIAL_STEPS[tutorialStep].title}</div>
            <p style={{ fontSize: 17, color: "#6E6A62", marginTop: 10, lineHeight: 1.7 }}>{TUTORIAL_STEPS[tutorialStep].text}</p>
            <div style={{ display: "flex", justifyContent: "center", gap: 8, margin: "20px 0 8px" }}>
              {TUTORIAL_STEPS.map((_, i) => (
                <div key={i} style={{ width: 8, height: 8, borderRadius: 4, background: i === tutorialStep ? "#40916c" : "#D8D2C8" }} />
              ))}
            </div>
            <button
              onClick={() => {
                unlockAudio();
                if (tutorialStep < TUTORIAL_STEPS.length - 1) setTutorialStep(tutorialStep + 1);
                else {
                  saveWateringState({ ...loadWateringState(), tutorialDone: true });
                  setPhase("intro");
                }
              }}
              style={{ marginTop: 8, border: "none", background: "#40916c", color: "#fff", fontSize: 18, fontWeight: 700, padding: "14px 44px", borderRadius: 14, cursor: "pointer" }}
            >{tutorialStep < TUTORIAL_STEPS.length - 1 ? "下一步" : "開始玩 🌷"}</button>
          </div>
        </div>
      )}

      {/* ===== 開場 ===== */}
      {phase === "intro" && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", animation: "wgPop .4s ease" }}>
          <div style={{ fontSize: 72, animation: "wgFloat 2.2s ease-in-out infinite" }}>🌅</div>
          <div style={{ fontSize: 24, fontWeight: 900, color: "#2d6a4f", marginTop: 14 }}>今天的花園</div>
          <div style={{ fontSize: 17, color: "#6E6A62", marginTop: 6 }}>第 {level} 關 · {ROUNDS_PER_SESSION} 回合 · 約 3 分鐘</div>
        </div>
      )}

      {/* ===== 遊戲主畫面（show / memory / action）===== */}
      {["show", "memory", "action"].includes(phase) && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", position: "relative", overflow: "hidden" }}>

          {/* 蝴蝶干擾 */}
          {butterflies.map((b) => (
            <div key={b.id} style={{
              position: "absolute", top: `${b.top}%`, left: -60, fontSize: 34, zIndex: 4,
              animation: `wgFly ${b.dur}ms linear forwards`,
              filter: "drop-shadow(1px 2px 2px rgba(0,0,0,.15))",
            }}>🦋</div>
          ))}

          {/* 提示文字區 */}
          <div style={{ textAlign: "center", padding: "18px 24px 0", minHeight: 86 }}>
            {phase === "show" && (
              <div style={{ background: "#cce0ff", borderRadius: 14, padding: "12px 18px", display: "inline-block", animation: "wgPop .3s ease" }}>
                <div style={{ fontSize: 19, fontWeight: 700, color: "#1d4e89" }}>記住亮起的花盆！</div>
                <div style={{ fontSize: 16, color: "#3a86ff", fontWeight: 700, marginTop: 2 }}>{countdown > 0 ? countdown : "…"}</div>
              </div>
            )}
            {phase === "memory" && (
              <div style={{ fontSize: 19, fontWeight: 700, color: "#6E6A62", paddingTop: 12 }}>記好了嗎？🤫</div>
            )}
            {phase === "action" && (
              <div style={{ fontSize: 18, fontWeight: 600, color: hint ? "#D4816B" : "#5A9A7D", paddingTop: 12, transition: "color .3s" }}>
                {hint || "拖水壺到記住的花盆 💧"}
              </div>
            )}
          </div>

          {/* 花盆列 */}
          <div style={{
            flex: 1, display: "flex", alignItems: "center", justifyContent: "center",
            alignContent: "center", gap: 18, flexWrap: "wrap", padding: "0 16px 120px",
          }}>
            {pots.map((pot, i) => {
              const lit = phase === "show" && pot.isTarget;
              const isHover = hoverIdx === i && dragging;
              return (
                <div
                  key={i}
                  ref={(el) => { potRefs.current[i] = el; }}
                  style={{
                    width: 84, height: 110, display: "flex", flexDirection: "column", alignItems: "center",
                    animation: shakeIdx === i ? "wgShake .5s ease" : undefined,
                    position: "relative",
                  }}
                >
                  {pot.watered && (
                    <div style={{ position: "absolute", top: -6, right: 2, fontSize: 20, zIndex: 2, animation: "wgPop .3s ease" }}>✅</div>
                  )}
                  {pot.failed && !pot.watered && (
                    <div style={{ position: "absolute", top: -4, right: 6, fontSize: 15, zIndex: 2, opacity: .75 }}>💤</div>
                  )}
                  <div style={{
                    fontSize: 40, lineHeight: 1.1, zIndex: 1,
                    animation: pot.watered ? "wgBloom .8s ease forwards" : undefined,
                    filter: pot.watered ? "saturate(1.3)" : pot.failed ? "grayscale(.4) opacity(.8)" : undefined,
                  }}>{pot.flower}</div>
                  <div style={{
                    width: 72, height: 56, marginTop: -8,
                    background: "linear-gradient(180deg,#c9a96e,#b8954f)",
                    border: "2px solid #a8853f",
                    borderRadius: "6px 6px 14px 14px",
                    boxShadow: lit
                      ? undefined
                      : pot.watered
                        ? "0 0 0 4px #40916c, 0 0 16px rgba(64,145,108,.4)"
                        : isHover
                          ? "0 0 0 4px #95d5b2, 0 0 14px rgba(149,213,178,.6)"
                          : "0 2px 6px rgba(0,0,0,.12)",
                    animation: lit ? "wgGlow 1s ease-in-out infinite" : undefined,
                    transition: "box-shadow .2s",
                  }}>
                    {lit && <div style={{ textAlign: "center", fontSize: 22, paddingTop: 12 }}>💧</div>}
                  </div>
                </div>
              );
            })}
          </div>

          {/* 水壺（拖曳起點 80dp） */}
          {phase === "action" && (
            <>
              <div
                ref={canHome}
                onPointerDown={onCanDown}
                onPointerMove={onCanMove}
                onPointerUp={onCanUp}
                onPointerCancel={() => { setDragging(false); setHoverIdx(-1); }}
                style={{
                  position: "absolute",
                  ...(dragging
                    ? { left: dragPos.x - 44, top: dragPos.y - 52, transition: "none" }
                    : { right: 22, bottom: 30, transition: "all .35s cubic-bezier(.34,1.4,.64,1)" }),
                  width: 88, height: 88, borderRadius: "50%",
                  background: dragging ? "rgba(58,134,255,.18)" : "rgba(255,255,255,.9)",
                  border: "3px solid #3a86ff",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 46, cursor: "grab", zIndex: 10,
                  boxShadow: "0 4px 16px rgba(58,134,255,.3)",
                  animation: dragging ? undefined : "wgFloat 2.6s ease-in-out infinite",
                  touchAction: "none",
                }}
              >🚿</div>
              {!dragging && (
                <div style={{ position: "absolute", right: 14, bottom: 8, fontSize: 13, color: "#6E6A62", zIndex: 10 }}>按住拖曳</div>
              )}
            </>
          )}
        </div>
      )}

      {/* ===== 干擾問答 ===== */}
      {phase === "question" && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 28, animation: "wgPop .35s ease" }}>
          <div style={{ fontSize: 56 }}>🦋</div>
          <div style={{ background: "#fff", borderRadius: 18, padding: "26px 30px", textAlign: "center", marginTop: 16, boxShadow: "0 4px 20px rgba(120,100,80,.12)", width: "100%", maxWidth: 340 }}>
            <div style={{ fontSize: 20, fontWeight: 700, color: "#2d6a4f" }}>剛剛飛過幾隻蝴蝶？</div>
            <div style={{ fontSize: 14, color: "#A09890", marginTop: 4 }}>答錯也沒關係，是附加題 🌿</div>
            <div style={{ display: "flex", gap: 12, justifyContent: "center", marginTop: 20 }}>
              {questionOpts.map((opt) => {
                const isPick = answered === opt;
                const showRight = answered !== null && opt === butterflyTotal.current;
                return (
                  <button
                    key={opt}
                    onClick={() => answerQuestion(opt)}
                    style={{
                      minWidth: 72, padding: "14px 10px", fontSize: 19, fontWeight: 700,
                      borderRadius: 14, cursor: "pointer",
                      border: showRight ? "3px solid #40916c" : "3px solid transparent",
                      background: isPick ? (opt === butterflyTotal.current ? "#d8f3dc" : "#F4F1EA") : "#F4F1EA",
                      color: "#3A4642",
                    }}
                  >{opt} 隻</button>
                );
              })}
            </div>
            {answered !== null && (
              <div style={{ marginTop: 14, fontSize: 16, fontWeight: 700, color: answered === butterflyTotal.current ? "#40916c" : "#6E6A62" }}>
                {answered === butterflyTotal.current ? "答對了！+雙重任務獎勵 ⭐" : `是 ${butterflyTotal.current} 隻哦，下次再注意看 🌿`}
              </div>
            )}
          </div>
        </div>
      )}

      {/* ===== 回合結算 ===== */}
      {phase === "round-result" && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", animation: "wgPop .35s ease" }}>
          <div style={{ fontSize: 58 }}>
            {pots.filter((p) => p.watered).map((p, i) => (
              <span key={i} style={{ display: "inline-block", animation: `wgBloom .9s ${i * 0.15}s ease both` }}>{p.flower}</span>
            ))}
          </div>
          <div style={{ fontSize: 22, fontWeight: 900, color: "#2d6a4f", marginTop: 16 }}>
            {roundWrong.current === 0 ? "完美回合！🎉" : "花兒喝飽水了 💧"}
          </div>
          {roundWrong.current > 0 && (
            <div style={{ fontSize: 16, color: "#6E6A62", marginTop: 6 }}>沒關係，記憶就是這樣練起來的 🌿</div>
          )}
        </div>
      )}

      {/* ===== 全局結算 ===== */}
      {phase === "summary" && (
        <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 24, animation: "wgPop .4s ease" }}>
          <div style={{ fontSize: 40 }}>🌻🌷🌸🌹🌺</div>
          <div style={{ background: "#fff", borderRadius: 18, padding: "24px 36px", textAlign: "center", marginTop: 14, boxShadow: "0 4px 20px rgba(120,100,80,.12)", width: "100%", maxWidth: 340 }}>
            <div style={{ fontSize: 14, color: "#A09890" }}>今日成績</div>
            <div style={{ fontSize: 48, fontWeight: 900, color: "#2d6a4f", lineHeight: 1.2 }}>{finalScore}</div>
            {store.lastScore !== null && finalScore > store.lastScore && (
              <div style={{ fontSize: 15, color: "#40916c", fontWeight: 700 }}>▲ 比上次進步 {finalScore - store.lastScore} 分</div>
            )}
            <div style={{ display: "flex", justifyContent: "space-around", marginTop: 18 }}>
              <div><div style={{ fontSize: 20, fontWeight: 700 }}>{s.correct}/{s.correct + s.wrong || 1}</div><div style={{ fontSize: 13, color: "#A09890" }}>澆對</div></div>
              <div><div style={{ fontSize: 20, fontWeight: 700 }}>{s.reactions.length ? `${(s.reactions.reduce((a, b) => a + b, 0) / s.reactions.length / 1000).toFixed(1)}s` : "—"}</div><div style={{ fontSize: 13, color: "#A09890" }}>反應</div></div>
              {s.dualTotal > 0 && (
                <div><div style={{ fontSize: 20, fontWeight: 700 }}>{s.dualCorrect}/{s.dualTotal}</div><div style={{ fontSize: 13, color: "#A09890" }}>附加題</div></div>
              )}
            </div>
            <div style={{ marginTop: 16, background: "#FBF5E8", borderRadius: 12, padding: "10px 14px", fontSize: 16, fontWeight: 700, color: "#C9A862" }}>
              ☀️ +3 已澆灌你的櫻花樹！
            </div>
          </div>
          <button
            onClick={() => {
              // 重開一局（重讀 level，因可能已升降級）
              stats.current = { correct: 0, wrong: 0, dualCorrect: 0, dualTotal: 0, reactions: [], perfectRounds: 0, memorySpan: 0 };
              rewarded.current = false;
              setRound(1);
              setFinalScore(0);
              setPhase("intro");
            }}
            style={{ marginTop: 20, border: "none", background: "#40916c", color: "#fff", fontSize: 19, fontWeight: 700, padding: "16px 52px", borderRadius: 14, cursor: "pointer", boxShadow: "0 4px 14px rgba(64,145,108,.35)" }}
          >再玩一局</button>
          <button
            onClick={onExit}
            style={{ marginTop: 12, border: "none", background: "rgba(255,255,255,.85)", color: "#5A9A7D", fontSize: 17, fontWeight: 700, padding: "13px 40px", borderRadius: 14, cursor: "pointer" }}
          >回到花園</button>
        </div>
      )}

      {/* ===== 暫停遮罩 ===== */}
      {paused && (
        <div style={{
          position: "absolute", inset: 0, zIndex: 40, background: "rgba(253,251,247,.92)",
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 28,
        }}>
          <div style={{ fontSize: 56 }}>🍵</div>
          <div style={{ fontSize: 22, fontWeight: 700, color: "#2d6a4f", marginTop: 12 }}>{pauseMsg || "暫停中"}</div>
          <div style={{ fontSize: 16, color: "#6E6A62", marginTop: 6 }}>回來後會重新展示這回合的花盆</div>
          <button
            onClick={resumeGame}
            style={{ marginTop: 24, border: "none", background: "#40916c", color: "#fff", fontSize: 19, fontWeight: 700, padding: "16px 52px", borderRadius: 14, cursor: "pointer" }}
          >繼續 🌷</button>
          <button
            onClick={onExit}
            style={{ marginTop: 12, border: "none", background: "transparent", color: "#A09890", fontSize: 16, fontWeight: 600, padding: "10px 24px", cursor: "pointer" }}
          >結束本局</button>
        </div>
      )}
    </div>
  );
}
