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

