import { supabase } from './supabaseClient';

export async function createRoom(name: string, title?: string, settings: any = {}, num_questions = 10) {
  const { data, error } = await supabase.rpc('create_room', { owner_name: name, room_title: title, settings: settings, num_questions: num_questions });
  if (error) throw error;
  return data?.[0] ?? data;
}

export async function joinRoom(code: string, name: string) {
  const { data, error } = await supabase.rpc('join_room', { room_code: code, player_name: name });
  if (error) throw error;
  return data?.[0] ?? data;
}

export async function submitAnswer(room_question_id: string, player_id: string, choice: number, response_time_ms?: number) {
  const { data, error } = await supabase.rpc('submit_answer', { room_question_id, player_id, choice, response_time_ms });
  if (error) throw error;
  return data?.[0] ?? data;
}

export async function startQuestion(owner_key: string, room_id: string, ord: number) {
  const { data, error } = await supabase.rpc('start_question', { owner_key, room_id, ord });
  if (error) throw error;
  return data?.[0] ?? data;
}

export async function assignTeam(owner_key: string, player_id: string, team_id: string) {
  const { error } = await supabase.rpc('assign_team', { owner_key, target_player_id: player_id, team_id });
  if (error) throw error;
  return true;
}

export async function kickPlayer(owner_key: string, player_id: string) {
  const { error } = await supabase.rpc('kick_player', { owner_key, target_player_id: player_id });
  if (error) throw error;
  return true;
}
