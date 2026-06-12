// 澆花記憶 Watering Memory — 遊戲設定與邏輯（PRD v1.0，MVP Level 1-8）

export interface WateringLevelCfg {
  pots: number;
  targets: number;
  showMs: number;
  distraction: boolean; // Level 6+ 計數干擾
}

export const MAX_LEVEL = 8;
export const ROUNDS_PER_SESSION = 4;
export const MEMORY_GAP_MS = 1500;

export function levelConfig(level: number): WateringLevelCfg {
  if (level <= 3) return { pots: 3, targets: 2, showMs: 5000, distraction: false };
  if (level <= 5) return { pots: 4, targets: 2, showMs: 4000, distraction: false };
  return { pots: 4, targets: 2, showMs: 4000, distraction: true };
}

export const FLOWERS = ["🌷", "🌻", "🌹", "🌸", "🌺", "🪻", "🌼"];

export interface SessionRecord {
  accuracy: number; // 0-1
}

// PRD 升降級規則：連續3局≥85%升1級、連續5局100%升2級、連續2局≤50%降1級
export function adjustLevel(current: number, history: SessionRecord[]): number {
  const avg = (arr: SessionRecord[]) =>
    arr.reduce((s, r) => s + r.accuracy, 0) / arr.length;
  const last3 = history.slice(-3);
  if (last3.length >= 3 && avg(last3) >= 0.85) {
    const last5 = history.slice(-5);
    if (last5.length >= 5 && last5.every((s) => s.accuracy >= 1))
      return Math.min(MAX_LEVEL, current + 2);
    return Math.min(MAX_LEVEL, current + 1);
  }
  const last2 = history.slice(-2);
  if (last2.length >= 2 && avg(last2) <= 0.5) return Math.max(1, current - 1);
  return current;
}

// 計分：基礎 70（正確率）＋雙重任務 20＋速度獎勵 10（只獎不罰）
export function sessionScore(
  correct: number,
  wrong: number,
  dualCorrect: number,
  dualTotal: number,
  avgReactionMs: number | null,
): number {
  const attempts = correct + wrong;
  const accuracy = attempts > 0 ? correct / attempts : 0;
  const base = accuracy * 70;
  const dual = dualTotal > 0 ? (dualCorrect / dualTotal) * 20 : accuracy * 20;
  let speed = 0;
  if (avgReactionMs !== null && correct > 0) {
    if (avgReactionMs < 2500) speed = 10;
    else if (avgReactionMs < 4000) speed = 6;
    else if (avgReactionMs < 6000) speed = 3;
  }
  return Math.round(base + dual + speed);
}

// ===== 本地進度（SNS 版不上傳，僅 localStorage）=====
export interface WateringState {
  level: number;
  history: SessionRecord[];
  tutorialDone: boolean;
  bestScore: number;
  lastScore: number | null;
  plays: number;
}

const KEY = "caredoc_watering_v1";

export function loadWateringState(): WateringState {
  const fallback: WateringState = {
    level: 1, history: [], tutorialDone: false, bestScore: 0, lastScore: null, plays: 0,
  };
  if (typeof window === "undefined") return fallback;
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return fallback;
    return { ...fallback, ...JSON.parse(raw) };
  } catch {
    return fallback;
  }
}

export function saveWateringState(state: WateringState) {
  try {
    localStorage.setItem(KEY, JSON.stringify({ ...state, history: state.history.slice(-10) }));
  } catch { /* 私密瀏覽模式等情況直接略過 */ }
}

// ===== 震動（Android Chrome 有效；iOS Safari 不支援，UI 以視覺補償）=====
function vib(pattern: number | number[]) {
  try {
    if (typeof navigator !== "undefined" && "vibrate" in navigator) navigator.vibrate(pattern);
  } catch { /* noop */ }
}

export const haptics = {
  pickup: () => vib(15),
  hover: () => vib(8),
  correct: () => vib([100, 100, 100]),
  wrong: () => vib([60, 80, 60, 80, 60]),
  distract: () => vib(8),
  perfect: () => vib([80, 120, 120, 120, 180]),
  complete: () => vib([400, 300, 60, 60, 60, 60, 60]),
};
