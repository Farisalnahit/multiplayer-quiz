"use client";
import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createRoom } from '../../lib/api';

export default function CreateRoom(){
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  async function onCreate(){
    if(!name) return alert('ادخل اسمك');
    setLoading(true);
    try{
      const res = await createRoom(name, null, {}, 10);
      // store player id and owner_key locally
      const owner_key = res.owner_key;
      const player_id = res.owner_player_id;
      const room_code = res.code;
      localStorage.setItem('player_id', player_id);
      localStorage.setItem('owner_key', owner_key);
      localStorage.setItem('player_name', name);
      router.push(`/room/${room_code}/waiting`);
    }catch(err:any){
      console.error(err);
      alert(err.message || 'خطأ أثناء إنشاء الغرفة');
    }finally{setLoading(false)}
  }

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-xl mx-auto">
        <h2 className="text-2xl font-bold mb-4">إنشاء غرفة جديدة</h2>
        <p className="mb-4">أدخل اسمك ثم اضغط إنشاء. سيتم توليد كود الغرفة وصلاحيات المالك.</p>
        <div className="space-y-4">
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="اسمك" className="w-full p-2 border rounded" />
          <button onClick={onCreate} disabled={loading} className="px-4 py-2 bg-green-600 text-white rounded">{loading? 'جاري الإنشاء...':'إنشاء'}</button>
        </div>
      </div>
    </main>
  );
}
