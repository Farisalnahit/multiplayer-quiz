import React from 'react';

"use client";
import React from 'react';
import { useParams } from 'next/navigation';
import { useRoom } from '../../../../hooks/useRoom';

export default function WaitingRoom(){
  const params = useParams();
  const roomCode = params?.code ?? null;
  const { players, teams } = useRoom(roomCode);

  return (
    <main className="min-h-screen p-6">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-2xl font-bold mb-2">غرفة الانتظار: {roomCode}</h2>
        <p className="mb-4">قائمة اللاعبين والخيارات الخاصة بالمالك تظهر هنا.</p>
        <div className="grid grid-cols-2 gap-4">
          <div className="p-4 border rounded">
            <h3 className="font-semibold mb-2">اللاعبون ({players.length})</h3>
            <ul>
              {players.map(p=> (
                <li key={p.id} className="py-1">{p.name} {p.is_owner? '(مالك)':''}</li>
              ))}
            </ul>
          </div>
          <div className="p-4 border rounded">
            <h3 className="font-semibold mb-2">الفرق ({teams.length})</h3>
            <ul>
              {teams.map(t=> (
                <li key={t.id} className="py-1">{t.name}</li>
              ))}
            </ul>
            <div className="mt-4 text-sm text-gray-600">تحكمات المالك تظهر هنا (assign/kick/start)</div>
          </div>
        </div>
      </div>
    </main>
  );
}
