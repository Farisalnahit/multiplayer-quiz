-- Migration: Create RPCs for multiplayer quiz

-- create_room(owner_name TEXT, room_title TEXT, settings JSONB, num_questions INT)
CREATE OR REPLACE FUNCTION create_room(owner_name TEXT, room_title TEXT DEFAULT NULL, settings JSONB DEFAULT '{}'::jsonb, num_questions INT DEFAULT 10)
RETURNS TABLE(room_id uuid, code text, owner_key text, owner_player_id uuid) AS $$
DECLARE
  r_id uuid;
  p_id uuid;
BEGIN
  INSERT INTO rooms (title, settings, num_questions) VALUES (room_title, settings, num_questions) RETURNING id, code, owner_key INTO r_id, code, owner_key;
  INSERT INTO players (room_id, name, is_owner) VALUES (r_id, owner_name, true) RETURNING id INTO p_id;
  UPDATE rooms SET owner_player_id = p_id WHERE id = r_id;
  room_id := r_id;
  owner_player_id := p_id;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- join_room(room_code TEXT, player_name TEXT)
CREATE OR REPLACE FUNCTION join_room(room_code TEXT, player_name TEXT)
RETURNS TABLE(player_id uuid, room_id uuid, code text) AS $$
DECLARE
  r RECORD;
  p_id uuid;
BEGIN
  SELECT id, code FROM rooms WHERE code = room_code INTO r;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'ROOM_NOT_FOUND';
  END IF;
  INSERT INTO players (room_id, name, is_owner) VALUES (r.id, player_name, false) RETURNING id INTO p_id;
  player_id := p_id;
  room_id := r.id;
  code := r.code;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- assign_team(owner_key TEXT, target_player_id UUID, team_id UUID)
CREATE OR REPLACE FUNCTION assign_team(owner_key TEXT, target_player_id UUID, team_id UUID)
RETURNS void AS $$
DECLARE
  r_id uuid;
BEGIN
  SELECT id INTO r_id FROM rooms WHERE owner_key = owner_key LIMIT 1;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'INVALID_OWNER_KEY';
  END IF;
  UPDATE players SET team_id = team_id WHERE id = target_player_id AND room_id = r_id;
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- kick_player(owner_key TEXT, target_player_id UUID)
CREATE OR REPLACE FUNCTION kick_player(owner_key TEXT, target_player_id UUID)
RETURNS void AS $$
DECLARE
  r_id uuid;
BEGIN
  SELECT id INTO r_id FROM rooms WHERE owner_key = owner_key LIMIT 1;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'INVALID_OWNER_KEY';
  END IF;
  DELETE FROM players WHERE id = target_player_id AND room_id = r_id;
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- start_question(owner_key TEXT, room_id UUID, ord INT)
CREATE OR REPLACE FUNCTION start_question(owner_key TEXT, room_id uuid, ord int)
RETURNS TABLE(room_question_id uuid, question_id uuid, started_at timestamptz, question_text text, choices jsonb, points int) AS $$
DECLARE
  r RECORD;
  rq_id uuid;
  qb RECORD;
BEGIN
  -- validate owner
  SELECT id INTO r FROM rooms WHERE id = room_id AND owner_key = owner_key LIMIT 1;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'INVALID_OWNER_OR_ROOM';
  END IF;
  -- pick room_question row
  SELECT id, question_id, started_at INTO rq_id, question_id, started_at FROM room_questions WHERE room_id = room_id AND ord = ord LIMIT 1;
  IF FOUND THEN
    UPDATE room_questions SET started_at = now() WHERE id = rq_id;
  ELSE
    RAISE EXCEPTION 'ROOM_QUESTION_NOT_FOUND';
  END IF;
  SELECT question_text, choices, points INTO question_text, choices, points FROM question_bank WHERE id = question_id;
  room_question_id := rq_id;
  question_id := question_id;
  started_at := now();
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- submit_answer(room_question_id UUID, player_id UUID, choice INT, response_time_ms INT)
CREATE OR REPLACE FUNCTION submit_answer(room_question_id uuid, player_id uuid, choice int, response_time_ms int DEFAULT NULL)
RETURNS TABLE(is_correct boolean, points_awarded int, was_first_correct boolean) AS $$
DECLARE
  rq RECORD;
  p RECORD;
  correct_idx int;
  base_points int;
  already boolean;
  first_team uuid;
  team_id uuid;
  awarded int := 0;
  first_claim boolean := false;
BEGIN
  -- Validate context
  SELECT * INTO rq FROM room_questions WHERE id = room_question_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'RQ_NOT_FOUND'; END IF;
  SELECT * INTO p FROM players WHERE id = player_id AND room_id = rq.room_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'PLAYER_NOT_IN_ROOM'; END IF;
  -- prevent double answer
  SELECT EXISTS(SELECT 1 FROM answers WHERE room_question_id = room_question_id AND player_id = player_id) INTO already;
  IF already THEN
    is_correct := NULL; points_awarded := 0; was_first_correct := false; RETURN NEXT;
  END IF;
  SELECT correct_choice, points INTO correct_idx, base_points FROM question_bank WHERE id = rq.question_id;
  team_id := p.team_id;
  is_correct := (choice = correct_idx);
  IF is_correct THEN
    -- check and set first_correct_team_id if null
    IF rq.first_correct_team_id IS NULL THEN
      UPDATE room_questions SET first_correct_team_id = team_id WHERE id = room_question_id AND first_correct_team_id IS NULL RETURNING first_correct_team_id INTO first_team;
      IF FOUND THEN first_claim := true; END IF;
    END IF;
    awarded := base_points;
    IF first_claim THEN
      awarded := ceil(awarded * 1.5);
    END IF;
    -- insert answer and update scores
    INSERT INTO answers (room_question_id, player_id, team_id, choice, is_correct, response_time_ms, points_awarded) VALUES (room_question_id, player_id, team_id, choice, true, response_time_ms, awarded);
    -- upsert player_scores
    INSERT INTO player_scores (player_id, room_id, total_points, correct_count, updated_at)
    VALUES (player_id, rq.room_id, awarded, 1, now())
    ON CONFLICT (player_id) DO UPDATE SET total_points = player_scores.total_points + excluded.total_points, correct_count = player_scores.correct_count + 1, updated_at = now();
    -- upsert team_scores
    IF team_id IS NOT NULL THEN
      INSERT INTO team_scores (team_id, room_id, total_points, correct_count, updated_at)
      VALUES (team_id, rq.room_id, awarded, 1, now())
      ON CONFLICT (team_id) DO UPDATE SET total_points = team_scores.total_points + excluded.total_points, correct_count = team_scores.correct_count + 1, updated_at = now();
    END IF;
    points_awarded := awarded;
    was_first_correct := first_claim;
    RETURN NEXT;
  ELSE
    INSERT INTO answers (room_question_id, player_id, team_id, choice, is_correct, response_time_ms, points_awarded) VALUES (room_question_id, player_id, team_id, choice, false, response_time_ms, 0);
    is_correct := false; points_awarded := 0; was_first_correct := false; RETURN NEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- End of RPCs
