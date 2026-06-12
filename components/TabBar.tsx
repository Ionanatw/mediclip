"use client";

const TABS = [
  { key: "home", label: "首頁" },
  { key: "library", label: "筆記" },
  { key: "garden", label: "花園" },
  { key: "profile", label: "我的" },
] as const;

type TabKey = (typeof TABS)[number]["key"];

const Icons: Record<TabKey, (c: string, filled: boolean) => React.ReactNode> = {
  home: (c, filled) =>
    filled ? (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M3 10.5L12 3l9 7.5V20a1.5 1.5 0 01-1.5 1.5h-4.25V15a1.25 1.25 0 00-1.25-1.25h-2A1.25 1.25 0 0010.75 15v6.5H6.5A1.5 1.5 0 015 20V10.5H3z" fill={c} />
      </svg>
    ) : (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M3 10.5L12 3l9 7.5V20a1.5 1.5 0 01-1.5 1.5h-4.25V15a1.25 1.25 0 00-1.25-1.25h-2A1.25 1.25 0 0010.75 15v6.5H6.5A1.5 1.5 0 015 20V10.5H3z" stroke={c} strokeWidth="1.8" strokeLinejoin="round" />
      </svg>
    ),
  library: (c, filled) =>
    filled ? (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <rect x="3" y="4" width="5" height="16" rx="1.5" fill={c} />
        <rect x="10" y="6" width="5" height="14" rx="1.5" fill={c} fillOpacity="0.6" />
        <rect x="17" y="3" width="5" height="17" rx="1.5" fill={c} fillOpacity="0.35" transform="rotate(6 17 3)" />
      </svg>
    ) : (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <rect x="3" y="4" width="5" height="16" rx="1.5" stroke={c} strokeWidth="1.6" />
        <rect x="10" y="6" width="5" height="14" rx="1.5" stroke={c} strokeWidth="1.6" />
        <path d="M17 4l4.5 1-1 15-4.5-1z" stroke={c} strokeWidth="1.6" strokeLinejoin="round" />
      </svg>
    ),
  garden: (c, filled) =>
    filled ? (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M12 22V13" stroke={c} strokeWidth="2" strokeLinecap="round" />
        <path d="M12 13C12 13 7 12 5 8c-1.5-3 1-6 4-5 1.5.5 3 2 3 5z" fill={c} />
        <path d="M12 13C12 13 17 12 19 8c1.5-3-1-6-4-5-1.5.5-3 2-3 5z" fill={c} fillOpacity="0.6" />
        <path d="M9 22h6" stroke={c} strokeWidth="2" strokeLinecap="round" />
      </svg>
    ) : (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M12 22V13" stroke={c} strokeWidth="1.8" strokeLinecap="round" />
        <path d="M12 13C12 13 7 12 5 8c-1.5-3 1-6 4-5 1.5.5 3 2 3 5z" stroke={c} strokeWidth="1.8" fill="none" strokeLinejoin="round" />
        <path d="M12 13C12 13 17 12 19 8c1.5-3-1-6-4-5-1.5.5-3 2-3 5z" stroke={c} strokeWidth="1.8" fill="none" strokeLinejoin="round" />
        <path d="M9 22h6" stroke={c} strokeWidth="1.8" strokeLinecap="round" />
      </svg>
    ),
  profile: (c, filled) => (
    <svg width="26" height="26" viewBox="0 0 64 64" fill="none">
      <defs>
        <linearGradient id="tbG" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#5A9A7D" />
          <stop offset="100%" stopColor="#5B8FC9" />
        </linearGradient>
      </defs>
      <circle cx="32" cy="32" r="30" fill={filled ? "url(#tbG)" : "none"} stroke={filled ? "none" : c} strokeWidth="3" fillOpacity={filled ? 0.12 : 0} />
      <path d="M20 26 Q20 16 32 16 Q44 16 44 26 L44 44 Q44 47 41 47 L23 47 Q20 47 20 44 Z" fill="url(#tbG)" />
      <circle cx="27" cy="32" r="2" fill="#fff" />
      <circle cx="37" cy="32" r="2" fill="#fff" />
      <circle cx="27.3" cy="32.3" r="1" fill="#2A3A32" />
      <circle cx="37.3" cy="32.3" r="1" fill="#2A3A32" />
      <path d="M29.5 37 Q32 40 34.5 37" stroke="#2A3A32" strokeWidth="1.5" fill="none" strokeLinecap="round" />
    </svg>
  ),
};

export default function TabBar({
  active = "home",
  onTabChange,
}: {
  active?: TabKey;
  onTabChange?: (tab: TabKey) => void;
}) {
  return (
    <div style={{
      position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 30,
      background: "#FFFFFF", borderTop: "1px solid rgba(120,100,80,0.08)",
      display: "flex", justifyContent: "space-around", alignItems: "center",
      padding: "6px 0 22px",
    }}>
      {TABS.map((tab) => {
        const isActive = tab.key === active;
        const color = isActive ? "#5A9A7D" : "#A09890";
        return (
          <div
            key={tab.key}
            onClick={() => onTabChange?.(tab.key)}
            style={{
              display: "flex", flexDirection: "column", alignItems: "center",
              gap: 2, cursor: "pointer", minWidth: 48,
            }}
          >
            {Icons[tab.key](color, isActive)}
            <span style={{
              fontSize: 10, fontWeight: isActive ? 700 : 500,
              color, letterSpacing: 0.2, whiteSpace: "nowrap",
            }}>{tab.label}</span>
          </div>
        );
      })}
    </div>
  );
}
