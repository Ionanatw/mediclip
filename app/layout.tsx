import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CareDoc — 醫療照護懶人包",
  description: "拍照上傳醫療單，AI 幫你秒懂、秒整理、秒提醒。",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-Hant">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
