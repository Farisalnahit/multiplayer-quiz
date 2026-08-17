import '../styles/globals.css';
import React from 'react';

export const metadata = {
  title: 'لعبة أسئلة جماعية',
  description: 'Multiplayer quiz game',
};

export default function RootLayout({ children }: { children: React.ReactNode }){
  return (
    <html lang="ar" dir="rtl">
      <body className="min-h-screen flex flex-col">
        <header className="w-full py-4 text-center bg-yellow-50 border-b">
          <h1 className="text-xl font-semibold">العبوا واستانسوا ياعيالي</h1>
        </header>
        <div className="flex-1">{children}</div>
        <footer className="w-full py-4 text-center text-sm text-gray-600 border-t">
          صنع بواسطة فارس
        </footer>
      </body>
    </html>
  );
}
