# Multiplayer Quiz

تم تجهيز مخطط القاعدة وملف seed للأسئلة تلقائيًا، ومخطط واجهة Next.js مبدئي.

الملفات مهمة:
- supabase/migrations/001_create_schema.sql  — تعريف الجداول والوظائف المبدئية
- supabase/seeds/questions_seed.sql        — سكربت SQL يولّد 160 سؤال لكل فئة (سهل/متوسط/صعب/أسطوري)
- scripts/generate_questions.js           — سكربت Node لتوليد seed (بديل)
- app/                                    — هيكل صفحات Next.js مبدئي (Home, Create, Join, Room/...)
- lib/supabaseClient.ts                   — تهيئة Supabase client

تشغيل محلي (اختصار):
1. تثبيت الحزم:
   npm install

2. لتطبيق الـ migrations على قاعدة Supabase:
   - باستخدام supabase CLI:
     supabase db push --schema supabase/migrations/001_create_schema.sql
   - أو نفّذ ملف SQL عبر psql/pgAdmin ضد قاعدة البيانات.

3. لملء الأسئلة في جدول question_bank:
   - نفّذ الملف `supabase/seeds/questions_seed.sql` في قاعدة البيانات (سيضيف 160 سؤال لكل فئة).

4. لتشغيل الواجهة:
   - اضبط متغيري البيئة NEXT_PUBLIC_SUPABASE_URL و NEXT_PUBLIC_SUPABASE_ANON_KEY
   - npm run dev

ملاحظة: السكربت الحالي يُنشئ أسئلة نمطية بالعربية كقالب. يمكن تعديل `supabase/seeds/questions_seed.sql` أو سكربت `scripts/generate_questions.js` لتغيير نصوص الأسئلة أو استبدالها بأسئلة فعلية.

التالي منّي إذا رغبت:
- تنفيذ كامل منطق الـ RPCs (create_room, submit_answer...) ورفعها كمigrations
- ربط الواجهة بالـ Supabase realtime وملء واجهات التحكم
- توليد أسئلة فعلية ومتميزة (يمكنني توليد محتوى أسئلة عالية الجودة بالعربية)

اخبرني أي جزء تريدني أفعله الآن (أكواد RPC، ربط الواجهة، أو توليد أسئلة فعلية).
