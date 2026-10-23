-- KainWise Database Schema & Row Level Security Policies
-- Supabase PostgreSQL Free Tier Compatible

-- Enable UUID extension
create extension if not exists "uuid-ossp";

--------------------------------------------------
-- 1. PROFILES TABLE
--------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  age integer check (age >= 10 and age <= 120),
  biological_sex text check (biological_sex in ('male', 'female')),
  height_cm numeric(5, 2) check (height_cm > 50 and height_cm < 300),
  current_weight_kg numeric(5, 2) check (current_weight_kg > 20 and current_weight_kg < 500),
  goal_weight_kg numeric(5, 2) check (goal_weight_kg > 20 and goal_weight_kg < 500),
  activity_level text check (activity_level in ('sedentary', 'lightly_active', 'moderately_active', 'very_active')),
  weight_goal text check (weight_goal in ('lose_weight', 'maintain_weight', 'gain_weight')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can select own profile" on public.profiles
  for select using (auth.uid() = id);

create policy "Users can insert own profile" on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);

create policy "Users can delete own profile" on public.profiles
  for delete using (auth.uid() = id);

-- Trigger to create initial profile upon auth signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', ''));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

--------------------------------------------------
-- 2. USER GOALS TABLE
--------------------------------------------------
create table if not exists public.user_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  daily_calorie_target integer not null check (daily_calorie_target between 800 and 10000),
  protein_target_g numeric(6, 2) not null check (protein_target_g >= 0),
  carbs_target_g numeric(6, 2) not null check (carbs_target_g >= 0),
  fat_target_g numeric(6, 2) not null check (fat_target_g >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_goals_user_id_key unique (user_id)
);

alter table public.user_goals enable row level security;

create policy "Users can select own goal" on public.user_goals
  for select using (auth.uid() = user_id);

create policy "Users can insert own goal" on public.user_goals
  for insert with check (auth.uid() = user_id);

create policy "Users can update own goal" on public.user_goals
  for update using (auth.uid() = user_id);

create policy "Users can delete own goal" on public.user_goals
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 3. MEALS TABLE
--------------------------------------------------
create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_type text not null check (meal_type in ('Breakfast', 'Lunch', 'Dinner', 'Snacks')),
  logged_at timestamptz not null default now(),
  total_calories numeric(7, 2) not null default 0 check (total_calories >= 0),
  total_protein_g numeric(6, 2) not null default 0 check (total_protein_g >= 0),
  total_carbs_g numeric(6, 2) not null default 0 check (total_carbs_g >= 0),
  total_fat_g numeric(6, 2) not null default 0 check (total_fat_g >= 0),
  created_at timestamptz not null default now()
);

alter table public.meals enable row level security;

create index if not exists idx_meals_user_date on public.meals (user_id, logged_at);

create policy "Users can select own meals" on public.meals
  for select using (auth.uid() = user_id);

create policy "Users can insert own meals" on public.meals
  for insert with check (auth.uid() = user_id);

create policy "Users can update own meals" on public.meals
  for update using (auth.uid() = user_id);

create policy "Users can delete own meals" on public.meals
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 4. MEAL ITEMS TABLE
--------------------------------------------------
create table if not exists public.meal_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  food_name text not null,
  serving_quantity numeric(6, 2) not null default 1 check (serving_quantity > 0),
  serving_unit text not null default 'serving',
  serving_weight_g numeric(7, 2) check (serving_weight_g >= 0),
  calories numeric(7, 2) not null check (calories >= 0),
  protein_g numeric(6, 2) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6, 2) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6, 2) not null default 0 check (fat_g >= 0),
  fiber_g numeric(6, 2) default 0 check (fiber_g >= 0),
  sodium_mg numeric(7, 2) default 0 check (sodium_mg >= 0),
  source text not null default 'manual' check (source in ('manual', 'barcode', 'ai_text', 'ai_photo', 'voice', 'search')),
  is_ai_estimated boolean not null default false,
  barcode text,
  created_at timestamptz not null default now()
);

alter table public.meal_items enable row level security;

create index if not exists idx_meal_items_meal on public.meal_items (meal_id);
create index if not exists idx_meal_items_user on public.meal_items (user_id);

create policy "Users can select own meal items" on public.meal_items
  for select using (auth.uid() = user_id);

create policy "Users can insert own meal items" on public.meal_items
  for insert with check (auth.uid() = user_id);

create policy "Users can update own meal items" on public.meal_items
  for update using (auth.uid() = user_id);

create policy "Users can delete own meal items" on public.meal_items
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 5. CUSTOM FOODS TABLE
--------------------------------------------------
create table if not exists public.custom_foods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  serving_size text not null default '1 serving',
  serving_weight_g numeric(7, 2) check (serving_weight_g >= 0),
  calories numeric(7, 2) not null check (calories >= 0),
  protein_g numeric(6, 2) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6, 2) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6, 2) not null default 0 check (fat_g >= 0),
  fiber_g numeric(6, 2) default 0 check (fiber_g >= 0),
  created_at timestamptz not null default now()
);

alter table public.custom_foods enable row level security;

create index if not exists idx_custom_foods_user on public.custom_foods (user_id);

create policy "Users can select own custom foods" on public.custom_foods
  for select using (auth.uid() = user_id);

create policy "Users can insert own custom foods" on public.custom_foods
  for insert with check (auth.uid() = user_id);

create policy "Users can update own custom foods" on public.custom_foods
  for update using (auth.uid() = user_id);

create policy "Users can delete own custom foods" on public.custom_foods
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 6. FAVORITES TABLE
--------------------------------------------------
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_type text not null check (item_type in ('food', 'meal')),
  food_name text not null,
  serving_quantity numeric(6, 2) not null default 1,
  serving_unit text not null default 'serving',
  calories numeric(7, 2) not null check (calories >= 0),
  protein_g numeric(6, 2) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6, 2) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6, 2) not null default 0 check (fat_g >= 0),
  created_at timestamptz not null default now()
);

alter table public.favorites enable row level security;

create index if not exists idx_favorites_user on public.favorites (user_id);

create policy "Users can select own favorites" on public.favorites
  for select using (auth.uid() = user_id);

create policy "Users can insert own favorites" on public.favorites
  for insert with check (auth.uid() = user_id);

create policy "Users can update own favorites" on public.favorites
  for update using (auth.uid() = user_id);

create policy "Users can delete own favorites" on public.favorites
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 7. WEIGHT LOGS TABLE
--------------------------------------------------
create table if not exists public.weight_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  weight_kg numeric(5, 2) not null check (weight_kg > 20 and weight_kg < 500),
  logged_at date not null default current_date,
  notes text,
  created_at timestamptz not null default now(),
  constraint weight_logs_user_date_key unique (user_id, logged_at)
);

alter table public.weight_logs enable row level security;

create index if not exists idx_weight_logs_user_date on public.weight_logs (user_id, logged_at desc);

create policy "Users can select own weight logs" on public.weight_logs
  for select using (auth.uid() = user_id);

create policy "Users can insert own weight logs" on public.weight_logs
  for insert with check (auth.uid() = user_id);

create policy "Users can update own weight logs" on public.weight_logs
  for update using (auth.uid() = user_id);

create policy "Users can delete own weight logs" on public.weight_logs
  for delete using (auth.uid() = user_id);

--------------------------------------------------
-- 8. DAILY AI USAGE TABLE
--------------------------------------------------
create table if not exists public.daily_ai_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null default current_date,
  photo_scans_count integer not null default 0 check (photo_scans_count >= 0),
  text_logs_count integer not null default 0 check (text_logs_count >= 0),
  assistant_chats_count integer not null default 0 check (assistant_chats_count >= 0),
  created_at timestamptz not null default now(),
  constraint daily_ai_usage_user_date_key unique (user_id, usage_date)
);

alter table public.daily_ai_usage enable row level security;

create index if not exists idx_daily_ai_usage_user_date on public.daily_ai_usage (user_id, usage_date);

create policy "Users can select own AI usage" on public.daily_ai_usage
  for select using (auth.uid() = user_id);

create policy "Users can insert own AI usage" on public.daily_ai_usage
  for insert with check (auth.uid() = user_id);

create policy "Users can update own AI usage" on public.daily_ai_usage
  for update using (auth.uid() = user_id);

create policy "Users can delete own AI usage" on public.daily_ai_usage
  for delete using (auth.uid() = user_id);
