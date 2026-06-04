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
