import './globals.css';
import React from 'react';

export const metadata = {
  title: 'لعبة أسئلة جماعية',
  description: 'Multiplayer quiz game',
};

export default function RootLayout({ children }: { children: React.ReactNode }){
  return (
    <html lang="ar" dir="rtl">
      <body className="min-h-screen flex flex-col">
        <div className="flex-1">{children}</div>
        <footer className="w-full py-4 text-center text-sm text-gray-600 border-t">
          صنع بواسطة فارس
        </footer>
      </body>
    </html>
  );
}
