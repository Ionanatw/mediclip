const COLORS: Record<string, string> = {
  "白色": "#F8F8F5", "粉紅色": "#F5D0C8", "粉紅": "#F5D0C8",
  "黃色": "#FDF8EC", "綠色": "#D0E8D4", "膚色": "#F0E8D8",
};

export function drugColorFill(color?: string): string {
  if (!color) return "#F8F8F5";
  for (const key of Object.keys(COLORS)) if (color.includes(key)) return COLORS[key];
  return "#F8F8F5";
}

export function drugSvg(shape?: string, color?: string): string {
  const fill = drugColorFill(color);
  const stroke = "#C9BFB2";
  const open = `<svg viewBox="0 0 120 80" width="120" height="80" xmlns="http://www.w3.org/2000/svg">`;
  let body: string;
  if (shape?.includes("橢圓")) {
    body = `<ellipse cx="60" cy="40" rx="44" ry="24" fill="${fill}" stroke="${stroke}" stroke-width="2"/><line x1="60" y1="18" x2="60" y2="62" stroke="${stroke}" stroke-width="1.5"/>`;
  } else if (shape?.includes("膠囊")) {
    body = `<rect x="16" y="28" width="44" height="24" rx="12" fill="${fill}" stroke="${stroke}" stroke-width="2"/><rect x="60" y="28" width="44" height="24" rx="12" fill="#EBE3D6" stroke="${stroke}" stroke-width="2"/>`;
  } else if (shape?.includes("粉包")) {
    body = `<rect x="20" y="16" width="80" height="48" rx="6" fill="${fill}" stroke="${stroke}" stroke-width="2" stroke-dasharray="5 4"/>`;
  } else {
    body = `<circle cx="60" cy="40" r="26" fill="${fill}" stroke="${stroke}" stroke-width="2"/><line x1="40" y1="40" x2="80" y2="40" stroke="${stroke}" stroke-width="1.5"/>`;
  }
  return `${open}${body}</svg>`;
}
