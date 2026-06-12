// WebAudio 合成音效 — 不需外部素材檔
let ctx: AudioContext | null = null;

function getCtx(): AudioContext | null {
  if (typeof window === "undefined") return null;
  try {
    if (!ctx) ctx = new (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)();
    if (ctx.state === "suspended") ctx.resume();
    return ctx;
  } catch {
    return null;
  }
}

// 需在使用者手勢內呼叫一次以解鎖 iOS 音訊
export function unlockAudio() {
  getCtx();
}

function tone(freq: number, start: number, dur: number, type: OscillatorType, gainVal: number) {
  const c = getCtx();
  if (!c) return;
  const osc = c.createOscillator();
  const g = c.createGain();
  osc.type = type;
  osc.frequency.value = freq;
  g.gain.setValueAtTime(0, c.currentTime + start);
  g.gain.linearRampToValueAtTime(gainVal, c.currentTime + start + 0.02);
  g.gain.exponentialRampToValueAtTime(0.001, c.currentTime + start + dur);
  osc.connect(g).connect(c.destination);
  osc.start(c.currentTime + start);
  osc.stop(c.currentTime + start + dur + 0.05);
}

// 水流潑灑：濾波噪音
export function playSplash() {
  const c = getCtx();
  if (!c) return;
  const dur = 0.45;
  const buf = c.createBuffer(1, c.sampleRate * dur, c.sampleRate);
  const data = buf.getChannelData(0);
  for (let i = 0; i < data.length; i++) data[i] = (Math.random() * 2 - 1) * (1 - i / data.length);
  const src = c.createBufferSource();
  src.buffer = buf;
  const filter = c.createBiquadFilter();
  filter.type = "bandpass";
  filter.frequency.setValueAtTime(2200, c.currentTime);
  filter.frequency.exponentialRampToValueAtTime(900, c.currentTime + dur);
  const g = c.createGain();
  g.gain.setValueAtTime(0.25, c.currentTime);
  g.gain.exponentialRampToValueAtTime(0.001, c.currentTime + dur);
  src.connect(filter).connect(g).connect(c.destination);
  src.start();
}

// 低沉木敲（不對哦）— 溫和不刺耳
export function playKnock() {
  tone(160, 0, 0.18, "triangle", 0.25);
  tone(110, 0.02, 0.2, "sine", 0.2);
}

// 風鈴（干擾出現）
export function playChime() {
  tone(1320, 0, 0.4, "sine", 0.08);
  tone(1760, 0.05, 0.35, "sine", 0.05);
}

// 花綻放叮咚
export function playBloom() {
  tone(523, 0, 0.25, "sine", 0.15);
  tone(659, 0.12, 0.25, "sine", 0.15);
  tone(784, 0.24, 0.4, "sine", 0.18);
}

// 全局完成慶祝
export function playCelebrate() {
  [523, 659, 784, 1047].forEach((f, i) => tone(f, i * 0.13, 0.35, "sine", 0.16));
  tone(1319, 0.55, 0.6, "sine", 0.12);
}
