create extension if not exists "pgcrypto";

create table if not exists public.app_users (
  id text primary key,
  display_name text not null default 'GrowFi 用户',
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.app_users(id) on delete cascade,
  title text not null,
  category text not null default '其他',
  amount numeric(12, 2) not null,
  happened_at timestamptz not null default now(),
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.saving_goals (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.app_users(id) on delete cascade,
  title text not null,
  target_amount numeric(12, 2) not null check (target_amount > 0),
  current_amount numeric(12, 2) not null default 0 check (current_amount >= 0),
  emoji text not null default '🌱',
  due_date date,
  created_at timestamptz not null default now()
);

create table if not exists public.favorite_stocks (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.app_users(id) on delete cascade,
  stock_code text not null,
  stock_name text not null,
  created_at timestamptz not null default now(),
  unique (user_id, stock_code)
);

insert into public.app_users (id, display_name)
values ('demo-user', 'GrowFi 用户')
on conflict (id) do nothing;

insert into public.transactions (user_id, title, category, amount, happened_at, note)
values
  ('demo-user', '工资到账', '收入', 12800, now() - interval '5 days', '五月工资'),
  ('demo-user', '午餐', '餐饮', -38, now() - interval '3 days', '工作日午餐'),
  ('demo-user', '指数基金定投', '投资', -600, now() - interval '4 days', '自动扣款')
on conflict do nothing;

insert into public.saving_goals (user_id, title, target_amount, current_amount, emoji, due_date)
values
  ('demo-user', '夏日旅行基金', 12000, 6800, '✈️', '2026-08-01'),
  ('demo-user', '应急备用金', 30000, 17450, '🛟', null),
  ('demo-user', '成长课程', 3000, 960, '📚', '2026-06-30')
on conflict do nothing;

alter table public.app_users enable row level security;
alter table public.transactions enable row level security;
alter table public.saving_goals enable row level security;
alter table public.favorite_stocks enable row level security;

drop policy if exists "service role can manage app users" on public.app_users;
drop policy if exists "service role can manage transactions" on public.transactions;
drop policy if exists "service role can manage saving goals" on public.saving_goals;
drop policy if exists "service role can manage favorite stocks" on public.favorite_stocks;

create policy "service role can manage app users"
on public.app_users
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

create policy "service role can manage transactions"
on public.transactions
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

create policy "service role can manage saving goals"
on public.saving_goals
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

create policy "service role can manage favorite stocks"
on public.favorite_stocks
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');
