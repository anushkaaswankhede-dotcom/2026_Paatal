-- =========================================================
-- SEHATVERSE — Supabase schema (PostgreSQL)
-- Compact, normalized schema per product spec.
-- Run in the Supabase SQL editor, then enable RLS policies below.
-- =========================================================

create extension if not exists "uuid-ossp";

-- ---------- profiles ----------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  age_group text not null check (age_group in ('k','teen','lab','guard','pro','bal','mast')),
  gender_style text check (gender_style in ('feminine','action','neutral','calm','custom','na')),
  avatar text,
  companion text,
  xp integer not null default 0,
  level integer not null default 1,
  streak integer not null default 0,
  last_active_date date,
  created_at timestamptz not null default now()
);

-- ---------- zones ----------
create table if not exists zones (
  id text primary key,               -- e.g. 'hygiene', 'nutrition'
  name text not null,
  category text not null,
  age_group text,                    -- null = applies to all age groups
  required_level integer not null default 1
);


-- ---------- levels ----------
create table if not exists levels (
  id uuid primary key default uuid_generate_v4(),
  zone_id text references zones(id) on delete cascade,
  level_number integer not null,
  difficulty text not null check (difficulty in ('foundation','challenge','expert','master')),
  unique(zone_id, level_number)
);


-- ---------- quiz_attempts ----------
create table if not exists quiz_attempts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  question_id uuid references questions(id) on delete cascade,
  answer integer,
  correct boolean not null,
  xp_earned integer not null default 0,
  time_taken_seconds integer,
  created_at timestamptz not null default now()
);

-- ---------- badges ----------
create table if not exists badges (
  id text primary key,               -- e.g. 'bubble_hero'
  name text not null,
  category text not null,
  description text not null,
  icon text not null,
  requirement text not null          -- human-readable unlock condition
);

-- ---------- user_badges ----------
create table if not exists user_badges (
  user_id uuid references profiles(id) on delete cascade,
  badge_id text references badges(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

-- ---------- daily_tasks ----------
create table if not exists daily_tasks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  task_type text not null,           -- e.g. 'hygiene_mission'
  zone_id text references zones(id),
  xp_value integer not null default 10,
  completed boolean not null default false,
  date date not null default current_date
);


-- ---------- gratitude_entries ----------
create table if not exists gratitude_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  entry text not null,
  icon text not null default '⭐',
  created_at timestamptz not null default now()
);


-- =========================================================
-- ROW LEVEL SECURITY
-- Users can only read/write their own rows.
-- zones / levels / questions / badges are public reference data.
-- =========================================================

alter table profiles enable row level security;
alter table quiz_attempts enable row level security;
alter table user_badges enable row level security;
alter table daily_tasks enable row level security;
alter table gratitude_entries enable row level security;

create policy "own profile" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "own quiz attempts" on quiz_attempts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own badges" on user_badges
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own daily tasks" on daily_tasks
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own gratitude entries" on gratitude_entries
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);



-- Reference tables: readable by any authenticated user, no writes from client.
alter table zones enable row level security;
alter table levels enable row level security;
alter table questions enable row level security;
alter table badges enable row level security;

create policy "read zones" on zones for select using (true);
create policy "read levels" on levels for select using (true);
create policy "read questions" on questions for select using (true);
create policy "read badges" on badges for select using (true);
