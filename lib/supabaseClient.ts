import { createClient } from '@supabase/supabase-js';

// Lazily create a Supabase client to avoid constructing it during server-side build time
export function getSupabaseClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '';
  // Do not throw here; caller should handle missing env if invoked on server without config
  return createClient(supabaseUrl, supabaseAnonKey);
}
