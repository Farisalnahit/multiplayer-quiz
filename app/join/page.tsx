import React from 'react';

export default function JoinRoom(){
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-xl mx-auto">
        <h2 className="text-2xl font-bold mb-4">الانضمام لغرفة</h2>
        <form className="space-y-4">
          <input placeholder="اسمك" className="w-full p-2 border rounded" />
          <input placeholder="كود الغرفة" className="w-full p-2 border rounded" />
          <button type="button" className="px-4 py-2 bg-blue-600 text-white rounded">انضم</button>
        </form>
      </div>
    </main>
  );
}
