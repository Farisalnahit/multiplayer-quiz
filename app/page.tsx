import React from 'react';

export default function Home(){
  return (
    <main className="min-h-screen flex items-center justify-center p-8">
      <div className="max-w-2xl w-full text-center">
        <h1 className="text-4xl font-bold mb-4">لعبة أسئلة جماعية</h1>
        <p className="mb-6">انشئ غرفة، ادع أصدقائك عبر الكود، والعب في وقت واحد.</p>
        <div className="flex gap-4 justify-center">
          <a href="/create" className="px-4 py-2 bg-blue-600 text-white rounded">إنشاء غرفة</a>
          <a href="/join" className="px-4 py-2 bg-gray-200 rounded">الانضمام لغرفة</a>
        </div>
      </div>
    </main>
  );
}
