"use client";
import { useEffect } from "react";
import ToastMascot from "./ToastMascot";

export default function Splash({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 2000);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <section style={{
      flex: 1, display: "flex", flexDirection: "column", alignItems: "center",
      justifyContent: "center", gap: 16,
      background: "linear-gradient(175deg, #FDFBF7 0%, #EDF5F0 100%)",
      minHeight: "100dvh",
    }}>
      <div style={{ animation: "cdFloat 3s ease-in-out infinite" }}>
        <ToastMascot size={160} />
      </div>
      <div style={{ fontWeight: 900, fontSize: 28, letterSpacing: 2, color: "#5A9A7D" }}>
        CareDoc
      </div>
    </section>
  );
}
