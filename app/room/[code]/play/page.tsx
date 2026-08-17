import React from 'react';

export default function PlayRoom(){
  return (
    <main className="min-h-screen p-6">
      <div className="max-w-3xl mx-auto text-center">
        <h2 className="text-2xl font-bold mb-2">المباراة</h2>
        <div className="p-4 border rounded mb-4">سؤال الآن (Realtime)</div>
        <div className="grid grid-cols-2 gap-4">
          <div className="p-4 border rounded">خيارات الإجابة</div>
          <div className="p-4 border rounded">لوحة النتائج الحية</div>
        </div>
      </div>
    </main>
  );
}
