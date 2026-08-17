import React from 'react';

export default function CreateRoom(){
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-xl mx-auto">
        <h2 className="text-2xl font-bold mb-4">إنشاء غرفة جديدة</h2>
        <p className="mb-4">أدخل اسمك ثم اضغط إنشاء. سيتم توليد كود الغرفة وصلاحيات المالك.</p>
        <form className="space-y-4">
          <input placeholder="اسمك" className="w-full p-2 border rounded" />
          <button type="button" className="px-4 py-2 bg-green-600 text-white rounded">إنشاء</button>
        </form>
      </div>
    </main>
  );
}
