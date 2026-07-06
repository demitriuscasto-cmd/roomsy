create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text, age int, area text, bio text, budget text,
  move_date text, type text, photo_url text,
  lat double precision, lng double precision,
  radius_miles int default 25,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles readable by members" on public.profiles;
create policy "profiles readable by members" on public.profiles
  for select to authenticated using (true);

drop policy if exists "insert own profile" on public.profiles;
create policy "insert own profile" on public.profiles
  for insert to authenticated with check (auth.uid() = id);

drop policy if exists "update own profile" on public.profiles;
create policy "update own profile" on public.profiles
  for update to authenticated using (auth.uid() = id);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatar public read" on storage.objects;
create policy "avatar public read" on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists "avatar upload own" on storage.objects;
create policy "avatar upload own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

drop policy if exists "avatar update own" on storage.objects;
create policy "avatar update own" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

drop policy if exists "avatar delete own" on storage.objects;
create policy "avatar delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
