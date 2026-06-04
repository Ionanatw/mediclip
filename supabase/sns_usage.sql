-- CareDoc SNS 試玩版：email 限 1 次用量表
-- 在 Supabase 後台 → SQL Editor → 貼上執行一次即可
create table if not exists sns_usage (
  id uuid default gen_random_uuid() primary key,
  email text unique not null,
  used_at timestamptz default now()
);

-- 僅伺服器端 secret key 存取；啟用 RLS 且不開任何 public policy，
-- 前端 anon/publishable 金鑰完全碰不到此表。secret key 會繞過 RLS。
alter table sns_usage enable row level security;
