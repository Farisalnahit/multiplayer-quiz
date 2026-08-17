-- Seed: generate 160 questions per difficulty (Arabic)
-- This script programmatically inserts 160 questions for each difficulty into question_bank.

DO $$
DECLARE
  topics text[] := ARRAY[
    'الرياضيات','التاريخ','الجغرافيا','العلوم','الثقافة العامة','اللغة العربية','الرياضة','الفنون','الاختراعات','الطبيعة'
  ];
  diff text;
  pts int;
  n int;
  topic text;
BEGIN
  -- easy (سهل) 20 نقطة
  diff := 'easy'; pts := 20;
  FOR n IN 1..160 LOOP
    topic := topics[((n-1) % array_length(topics,1)) + 1];
    INSERT INTO question_bank (id, question_text, choices, correct_choice, difficulty, points, metadata)
    VALUES (
      gen_random_uuid(),
      format('%s سؤال %s (%s): ما الإجابة الصحيحة للاختيار التالي؟', topic, n, diff),
      to_jsonb(ARRAY[
        format('%s سؤال %s (%s) - الجواب الصحيح', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 2', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 3', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 4', topic, n, diff)
      ]),
      0,
      diff,
      pts,
      '{}'::jsonb
    );
  END LOOP;

  -- medium (متوسط) 30 نقطة
  diff := 'medium'; pts := 30;
  FOR n IN 1..160 LOOP
    topic := topics[((n-1) % array_length(topics,1)) + 1];
    INSERT INTO question_bank (id, question_text, choices, correct_choice, difficulty, points, metadata)
    VALUES (
      gen_random_uuid(),
      format('%s سؤال %s (%s): ما الإجابة الصحيحة للاختيار التالي؟', topic, n, diff),
      to_jsonb(ARRAY[
        format('%s سؤال %s (%s) - الجواب الصحيح', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 2', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 3', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 4', topic, n, diff)
      ]),
      0,
      diff,
      pts,
      '{}'::jsonb
    );
  END LOOP;

  -- hard (صعب) 40 نقطة
  diff := 'hard'; pts := 40;
  FOR n IN 1..160 LOOP
    topic := topics[((n-1) % array_length(topics,1)) + 1];
    INSERT INTO question_bank (id, question_text, choices, correct_choice, difficulty, points, metadata)
    VALUES (
      gen_random_uuid(),
      format('%s سؤال %s (%s): ما الإجابة الصحيحة للاختيار التالي؟', topic, n, diff),
      to_jsonb(ARRAY[
        format('%s سؤال %s (%s) - الجواب الصحيح', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 2', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 3', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 4', topic, n, diff)
      ]),
      0,
      diff,
      pts,
      '{}'::jsonb
    );
  END LOOP;

  -- legendary (أسطوري) 50 نقطة
  diff := 'legendary'; pts := 50;
  FOR n IN 1..160 LOOP
    topic := topics[((n-1) % array_length(topics,1)) + 1];
    INSERT INTO question_bank (id, question_text, choices, correct_choice, difficulty, points, metadata)
    VALUES (
      gen_random_uuid(),
      format('%s سؤال %s (%s): ما الإجابة الصحيحة للاختيار التالي؟', topic, n, diff),
      to_jsonb(ARRAY[
        format('%s سؤال %s (%s) - الجواب الصحيح', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 2', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 3', topic, n, diff),
        format('%s سؤال %s (%s) - خيار 4', topic, n, diff)
      ]),
      0,
      diff,
      pts,
      '{}'::jsonb
    );
  END LOOP;

END $$;

-- End of seed
