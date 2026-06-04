"use client";
import { useState } from "react";
import type { CareDocResult } from "@/lib/types";
import Landing from "./Landing";
import EmailGate from "./EmailGate";
import Uploader from "./Uploader";
import Processing from "./Processing";
import Results from "./Results";

type Step = "landing" | "gate" | "upload" | "processing" | "results";

export default function Flow() {
  const [step, setStep] = useState<Step>("landing");
  const [result, setResult] = useState<CareDocResult | null>(null);
  const [error, setError] = useState<string>("");

  async function runProcess(
    images: { type: string; data: string }[],
    text: string,
    prior?: CareDocResult,
  ) {
    setStep("processing");
    setError("");
    try {
      const res = await fetch("/api/process", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ images, text, priorResult: prior ?? undefined }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "整理失敗");
      setResult(data.result);
      setStep("results");
    } catch (e) {
      setError(e instanceof Error ? e.message : "整理失敗");
      setStep("upload");
    }
  }

  return (
    <main className="container">
      {step === "landing" && <Landing onStart={() => setStep("gate")} />}
      {step === "gate" && <EmailGate onPass={() => setStep("upload")} />}
      {step === "upload" && (
        <Uploader error={error} onSubmit={(imgs, text) => runProcess(imgs, text)} />
      )}
      {step === "processing" && <Processing />}
      {step === "results" && result && (
        <Results
          result={result}
          onRollingUpdate={(imgs, text) => runProcess(imgs, text, result)}
        />
      )}
      <p className="disclaimer" style={{ paddingBottom: 80 }}>⚠️ AI 輔助整理，請與原始醫療文件核對</p>
    </main>
  );
}
