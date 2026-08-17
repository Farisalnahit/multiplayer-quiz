-- Migration: Create schema for multiplayer quiz

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- rooms
CREATE TABLE IF NOT EXISTS rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code varchar(8) UNIQUE NOT NULL,
  owner_player_id uuid,
  owner_key text NOT NULL,
  title text,
  settings jsonb DEFAULT '{}'::jsonb,
  num_questions int DEFAULT 10,
  status text DEFAULT 'waiting' CHECK (status IN ('waiting','playing','finished')),
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_rooms_code ON rooms(code);

-- teams
CREATE TABLE IF NOT EXISTS teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES rooms(id) ON DELETE CASCADE,
  name text NOT NULL,
  "order" int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_teams_room_id ON teams(room_id);

-- players
CREATE TABLE IF NOT EXISTS players (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES rooms(id) ON DELETE CASCADE,
  name text NOT NULL,
  is_owner boolean DEFAULT false,
  team_id uuid NULL REFERENCES teams(id),
  joined_at timestamptz DEFAULT now(),
  last_seen_at timestamptz,
  connection_id text
);
CREATE INDEX IF NOT EXISTS idx_players_room_id ON players(room_id);

-- question_bank
CREATE TABLE IF NOT EXISTS question_bank (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_text text NOT NULL,
  choices jsonb NOT NULL,
  correct_choice int NOT NULL,
  difficulty text NOT NULL CHECK (difficulty IN ('easy','medium','hard','legendary')),
  points int NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_question_bank_difficulty ON question_bank(difficulty);

-- room_questions
CREATE TABLE IF NOT EXISTS room_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES rooms(id) ON DELETE CASCADE,
  question_id uuid REFERENCES question_bank(id),
  ord int NOT NULL,
  started_at timestamptz,
  ended_at timestamptz,
  first_correct_team_id uuid NULL REFERENCES teams(id),
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_room_questions_room_id ON room_questions(room_id);

-- answers
CREATE TABLE IF NOT EXISTS answers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_question_id uuid REFERENCES room_questions(id) ON DELETE CASCADE,
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  team_id uuid NULL,
  choice int NOT NULL,
  is_correct boolean,
  submitted_at timestamptz DEFAULT now(),
  response_time_ms int,
  points_awarded int DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS uniq_player_answer_per_question ON answers(room_question_id, player_id);

-- player_scores (materialized via RPC/upsert)
CREATE TABLE IF NOT EXISTS player_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid REFERENCES players(id) UNIQUE,
  room_id uuid REFERENCES rooms(id),
  total_points int DEFAULT 0,
  correct_count int DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_player_scores_room_id ON player_scores(room_id);

-- team_scores
CREATE TABLE IF NOT EXISTS team_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid REFERENCES teams(id) UNIQUE,
  room_id uuid REFERENCES rooms(id),
  total_points int DEFAULT 0,
  correct_count int DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_team_scores_room_id ON team_scores(room_id);

-- Simple helper to generate room codes (function)
CREATE OR REPLACE FUNCTION generate_room_code() RETURNS text AS $$
DECLARE
  chars text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  out text := '';
  i int;
BEGIN
  FOR i IN 1..6 LOOP
    out := out || substr(chars, floor(random()*length(chars))+1, 1);
  END LOOP;
  RETURN out;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- Trigger to set code and owner_key if missing
CREATE OR REPLACE FUNCTION rooms_insert_defaults() RETURNS trigger AS $$
BEGIN
  IF NEW.code IS NULL OR LENGTH(TRIM(NEW.code)) = 0 THEN
    NEW.code := generate_room_code();
  END IF;
  IF NEW.owner_key IS NULL OR LENGTH(TRIM(NEW.owner_key)) = 0 THEN
    NEW.owner_key := gen_random_uuid()::text;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_rooms_defaults ON rooms;
CREATE TRIGGER trg_rooms_defaults BEFORE INSERT ON rooms FOR EACH ROW EXECUTE FUNCTION rooms_insert_defaults();

-- End of migration
