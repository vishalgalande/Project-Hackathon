import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Team Strawhats | Hackathon 2026",
  description: "Showcasing Team Strawhats and the SafeTravel project.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        {children}
      </body>
    </html>
  );
}
