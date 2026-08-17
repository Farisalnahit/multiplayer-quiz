import React from 'react';

export default function WaitingRoom(){
  return (
    <main className="min-h-screen p-6">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-2xl font-bold mb-2">غرفة الانتظار</h2>
        <p className="mb-4">قائمة اللاعبين والخيارات الخاصة بالمالك تظهر هنا.</p>
        <div className="grid grid-cols-2 gap-4">
          <div className="p-4 border rounded">قائمة اللاعبين (اشتراك Realtime)</div>
          <div className="p-4 border rounded">تحكمات المالك: توزيع فرق، طرد، تغيير أسماء الفرق</div>
        </div>
      </div>
    </main>
  );
}
