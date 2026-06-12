export interface Stage { emoji: string; threshold: number; }
export interface Species { id: string; name_zh: string; emoji_tree: string; stages: Stage[]; }

export const SAKURA: Species = {
  id: "sakura", name_zh: "櫻花樹", emoji_tree: "🌸",
  stages: [
    { emoji: "🌰", threshold: 0 }, { emoji: "🌱", threshold: 20 },
    { emoji: "🌿", threshold: 60 }, { emoji: "🪴", threshold: 120 }, { emoji: "🌸", threshold: 200 },
  ],
};

export const DAILY_CAP = 15;

export function stageFor(species: Species, sun: number): Stage {
  let s = species.stages[0];
  for (const st of species.stages) if (sun >= st.threshold) s = st;
  return s;
}

// ===== ☀️ 太陽值共享（HappyGarden 與遊戲共用，僅 localStorage）=====
const SUN_KEY = "caredoc_sun_v1";
export const SUN_EVENT = "caredoc-sun";
export const SUN_MAX = DAILY_CAP * 20; // demo 體驗用，放寬上限讓人看到成長

export function loadSun(): number {
  if (typeof window === "undefined") return 0;
  try {
    return Math.min(SUN_MAX, Number(localStorage.getItem(SUN_KEY)) || 0);
  } catch {
    return 0;
  }
}

export function addSun(amount: number): number {
  const next = Math.min(SUN_MAX, loadSun() + amount);
  try { localStorage.setItem(SUN_KEY, String(next)); } catch { /* noop */ }
  if (typeof window !== "undefined") {
    window.dispatchEvent(new CustomEvent(SUN_EVENT, { detail: next }));
  }
  return next;
}
