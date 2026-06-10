"use client";
import { useState, useRef } from "react";
import type { CareDocResult } from "@/lib/types";
import Splash from "./Splash";
import Landing from "./Landing";
import Uploader from "./Uploader";
import Processing from "./Processing";
import Followup from "./Followup";
import Results from "./Results";

type Step = "splash" | "landing" | "upload" | "processing" | "followup" | "results";

export default function Flow() {
  const [step, setStep] = useState<Step>("splash");
  const [result, setResult] = useState<CareDocResult | null>(null);
  const [error, setError] = useState<string>("");
  const [procError, setProcError] = useState<string>("");
  const imgsRef = useRef<{ type: string; data: string }[]>([]);
  const textRef = useRef("");

  async function runProcess(
    images: { type: string; data: string }[],
    text: string,
    prior?: CareDocResult,
  ) {
    imgsRef.current = images;
    textRef.current = text;
    setStep("processing");
    setError("");
    setProcError("");
    try {
      const res = await fetch("/api/process", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ images, text, priorResult: prior ?? undefined }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "整理失敗");
      const r = data.result as CareDocResult;
      setResult(r);
      if (r.followup_questions && r.followup_questions.length > 0) {
        setStep("followup");
      } else {
        setStep("results");
      }
    } catch (e) {
      setProcError(e instanceof Error ? e.message : "整理失敗");
    }
  }

  function handleRetry() {
    if (imgsRef.current.length > 0) {
      runProcess(imgsRef.current, textRef.current);
    } else {
      setProcError("");
      setStep("upload");
    }
  }

  function handleFollowupSubmit(answers: Record<number, string>) {
    if (!result) return;
    const supplementText = Object.entries(answers)
      .map(([qi, ans]) => `${result.followup_questions[Number(qi)]?.question}: ${ans}`)
      .join("\n");
    const combined = textRef.current ? `${textRef.current}\n${supplementText}` : supplementText;
    runProcess(imgsRef.current, combined, result);
  }

  function handleFollowupSkip() {
    setStep("results");
  }

  return (
    <main className="container">
      {step === "splash" && <Splash onDone={() => setStep("landing")} />}
      {step === "landing" && (
        <Landing onStart={(email) => { setStep("upload"); }} />
      )}
      {step === "upload" && (
        <Uploader
          error={error}
          onSubmit={(imgs, text) => runProcess(imgs, text)}
          onBack={() => setStep("landing")}
        />
      )}
      {step === "processing" && (
        <Processing error={procError} onRetry={handleRetry} />
      )}
      {step === "followup" && result && (
        <Followup
          questions={result.followup_questions}
          onSubmit={handleFollowupSubmit}
          onSkip={handleFollowupSkip}
        />
      )}
      {step === "results" && result && (
        <Results
          result={result}
          onRollingUpdate={(imgs, text) => runProcess(imgs, text, result)}
        />
      )}
      {step !== "results" && step !== "splash" && step !== "processing" && (
        <p className="disclaimer" style={{ padding: "8px 22px 20px" }}>AI 輔助整理，請以原始醫療文件為準</p>
      )}
    </main>
  );
}
