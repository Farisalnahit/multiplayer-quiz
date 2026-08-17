"use client";
import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { joinRoom } from '../../lib/api';

export default function JoinRoom(){
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  async function onJoin(){
    if(!name || !code) return alert('ادخل اسمك وكود الغرفة');
    setLoading(true);
    try{
      const res = await joinRoom(code.toUpperCase(), name);
      const player_id = res.player_id;
      localStorage.setItem('player_id', player_id);
      localStorage.setItem('player_name', name);
      router.push(`/room/${code.toUpperCase()}/waiting`);
    }catch(err:any){
      console.error(err);
      alert(err.message || 'خطأ أثناء الانضمام');
    }finally{setLoading(false)}
  }

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-xl mx-auto">
        <h2 className="text-2xl font-bold mb-4">الانضمام لغرفة</h2>
        <div className="space-y-4">
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="اسمك" className="w-full p-2 border rounded" />
          <input value={code} onChange={e=>setCode(e.target.value)} placeholder="كود الغرفة" className="w-full p-2 border rounded" />
          <button onClick={onJoin} disabled={loading} className="px-4 py-2 bg-blue-600 text-white rounded">{loading? 'جاري الانضمام...':'انضم'}</button>
        </div>
      </div>
    </main>
  );
}
