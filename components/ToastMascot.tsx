export default function ToastMascot({ size = 44 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <defs>
        <linearGradient id="toastGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#5A9A7D" />
          <stop offset="100%" stopColor="#5B8FC9" />
        </linearGradient>
      </defs>
      <path d="M14 22 Q14 8 32 8 Q50 8 50 22 L50 52 Q50 56 46 56 L18 56 Q14 56 14 52 Z" fill="url(#toastGrad)" />
      <path d="M18 56 L46 56 Q50 56 50 52 L50 48 Q42 52 32 52 Q22 52 14 48 L14 52 Q14 56 18 56Z" fill="rgba(255,255,255,0.12)" />
      <circle cx="24" cy="32" r="3" fill="#fff" />
      <circle cx="40" cy="32" r="3" fill="#fff" />
      <circle cx="24.5" cy="32.5" r="1.5" fill="#2A3A32" />
      <circle cx="40.5" cy="32.5" r="1.5" fill="#2A3A32" />
      <circle cx="23.5" cy="31" r="0.8" fill="#fff" />
      <circle cx="39.5" cy="31" r="0.8" fill="#fff" />
      <ellipse cx="20" cy="37" rx="3.5" ry="2" fill="#F4A8A8" opacity="0.4" />
      <ellipse cx="44" cy="37" rx="3.5" ry="2" fill="#F4A8A8" opacity="0.4" />
      <path d="M28 39 Q32 44 36 39" stroke="#2A3A32" strokeWidth="1.8" fill="none" strokeLinecap="round" />
      <path d="M13 38 Q8 36 10 32" stroke="url(#toastGrad)" strokeWidth="3" fill="none" strokeLinecap="round" />
      <path d="M51 38 Q56 36 54 32" stroke="url(#toastGrad)" strokeWidth="3" fill="none" strokeLinecap="round" />
    </svg>
  );
}
