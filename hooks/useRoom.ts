import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';

export function useRoom(roomCode: string | null){
  const [players, setPlayers] = useState<any[]>([]);
  const [teams, setTeams] = useState<any[]>([]);

  useEffect(()=>{
    if(!roomCode) return;
    let mounted = true;
    async function load(){
      // fetch room id by code
      const { data: rooms } = await supabase.from('rooms').select('id, code').eq('code', roomCode).limit(1);
      if(!rooms || rooms.length===0) return;
      const roomId = rooms[0].id;
      const { data: pls } = await supabase.from('players').select('*').eq('room_id', roomId);
      if(mounted) setPlayers(pls ?? []);
      const { data: tms } = await supabase.from('teams').select('*').eq('room_id', roomId);
      if(mounted) setTeams(tms ?? []);

      // subscribe to players and teams changes
      const channel = supabase.channel(`room-${roomId}`)
        .on('postgres_changes', { event: '*', schema: 'public', table: 'players', filter: `room_id=eq.${roomId}` }, (payload) => {
          if(payload.eventType === 'INSERT') setPlayers(prev=>[...prev, payload.new]);
          else if(payload.eventType === 'DELETE') setPlayers(prev=>prev.filter(p=>p.id!==payload.old.id));
          else if(payload.eventType === 'UPDATE') setPlayers(prev=>prev.map(p=>p.id===payload.new.id?payload.new:p));
        })
        .on('postgres_changes', { event: '*', schema: 'public', table: 'teams', filter: `room_id=eq.${roomId}` }, (payload) => {
          if(payload.eventType === 'INSERT') setTeams(prev=>[...prev, payload.new]);
          else if(payload.eventType === 'DELETE') setTeams(prev=>prev.filter(t=>t.id!==payload.old.id));
          else if(payload.eventType === 'UPDATE') setTeams(prev=>prev.map(t=>t.id===payload.new.id?payload.new:t));
        })
        .subscribe();

      return ()=>{ mounted = false; channel.unsubscribe(); };
    }
    load();
  }, [roomCode]);

  return { players, teams };
}
