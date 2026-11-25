-- =====================================================================
-- TeamUp – Supabase schema (run FIRST in the SQL editor, then seed.sql)
-- Safe to re-run: drops & recreates functions/policies.
-- =====================================================================
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- tables
create table if not exists public.profiles (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid unique references auth.users(id) on delete cascade,
  email           text,
  name            text not null check (char_length(trim(name)) between 1 and 50),
  university      text not null default 'COMSATS Wah',
  department      text not null,
  semester        int  not null check (semester between 1 and 8),
  skills          text[] not null default '{}',
  interests       text[] not null default '{}',
  skills_needed   text[] not null default '{}',
  project_type    text not null default 'FYP',
  availability    text[] not null default '{}',
  bio             text not null default '' check (char_length(bio) <= 300),
  work_experience text not null default '' check (char_length(work_experience) <= 400),
  avatar_url      text,
  is_sample       boolean not null default false,
  created_at      timestamptz not null default now()
);
alter table public.profiles add column if not exists university text not null default 'COMSATS Wah';
alter table public.profiles add column if not exists work_experience text not null default '';

create table if not exists public.teams (
  id              uuid primary key default gen_random_uuid(),
  owner_profile   uuid not null references public.profiles(id) on delete cascade,
  title           text not null check (char_length(trim(title)) between 1 and 60),
  description     text not null default '' check (char_length(description) <= 500),
  project_type    text not null default 'FYP',
  roles_needed    text[] not null default '{}',
  required_skills text[] not null default '{}',
  domain_tags     text[] not null default '{}',
  created_at      timestamptz not null default now()
);
alter table public.teams add column if not exists description text not null default '';
alter table public.teams add column if not exists required_skills text[] not null default '{}';
alter table public.teams add column if not exists domain_tags text[] not null default '{}';

create table if not exists public.requests (
  id           uuid primary key default gen_random_uuid(),
  from_profile uuid not null constraint requests_from_profile_fkey references public.profiles(id) on delete cascade,
  to_profile   uuid not null constraint requests_to_profile_fkey   references public.profiles(id) on delete cascade,
  message      text not null check (char_length(trim(message)) between 1 and 200),
  status       text not null default 'pending'
               check (status in ('pending','accepted','rejected','cancelled')),
  team_id      uuid references public.teams(id) on delete set null,
  created_at   timestamptz not null default now(),
  check (from_profile <> to_profile)
);
create unique index if not exists requests_one_pending_per_pair
  on public.requests (from_profile, to_profile) where status = 'pending';
create index if not exists requests_to_idx on public.requests (to_profile);

create table if not exists public.team_members (
  team_id    uuid not null references public.teams(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role       text not null default 'Member',
  joined_at  timestamptz not null default now(),
  primary key (team_id, profile_id)
);
create index if not exists team_members_profile_idx on public.team_members (profile_id);

-- ---------------------------------------------------------------- helpers
-- My profile id (null if I have not completed profile setup).
create or replace function public.my_profile_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from public.profiles where user_id = auth.uid() limit 1
$$;

create or replace function public.is_team_member(p_team uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.team_members
                 where team_id = p_team and profile_id = public.my_profile_id())
$$;

-- Must match kRoleSkills in lib/core/constants.dart
create or replace function public.role_skills(p_role text) returns text[]
language sql immutable as $$
  select case p_role
    when 'Developer'        then array['Flutter','React','Node.js','Firebase','SQL']
    when 'Designer'         then array['UI/UX Design','Figma','Graphic Design']
    when 'Tester'           then array['Manual Testing','Automation Testing']
    when 'Report Writer'    then array['Technical Writing','Documentation','Project Management']
    when 'Data/ML Engineer' then array['Python','Machine Learning','Deep Learning','Data Analysis']
    else '{}'::text[] end
$$;

-- Best open role for a skill set: max role-skill overlap, else first open role, else 'Member'.
create or replace function public.best_role(p_skills text[], p_roles text[]) returns text
language plpgsql immutable as $$
declare r text; best text; best_score int := 0; s int;
begin
  if p_roles is null or cardinality(p_roles) = 0 then return 'Member'; end if;
  best := p_roles[1];
  foreach r in array p_roles loop
    select count(*) into s from unnest(public.role_skills(r)) x where x = any(p_skills);
    if s > best_score then best := r; best_score := s; end if;
  end loop;
  return best;
end $$;

-- The team I belong to: the one I own, else the most recently joined.
create or replace function public.my_team_id() returns uuid
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select id from public.teams where owner_profile = public.my_profile_id()
       order by created_at desc limit 1),
    (select team_id from public.team_members where profile_id = public.my_profile_id()
       order by joined_at desc limit 1))
$$;

-- ---------------------------------------------------------------- RLS
alter table public.profiles     enable row level security;
alter table public.requests     enable row level security;
alter table public.teams        enable row level security;
alter table public.team_members enable row level security;

drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_insert on public.profiles;
drop policy if exists profiles_update on public.profiles;
create policy profiles_select on public.profiles for select to authenticated using (true);
create policy profiles_insert on public.profiles for insert to authenticated
  with check (user_id = auth.uid() and is_sample = false);
create policy profiles_update on public.profiles for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid() and is_sample = false);

drop policy if exists requests_select on public.requests;
create policy requests_select on public.requests for select to authenticated
  using (from_profile = public.my_profile_id() or to_profile = public.my_profile_id());

drop policy if exists teams_select on public.teams;
create policy teams_select on public.teams for select to authenticated using (true);

drop policy if exists team_members_select on public.team_members;
create policy team_members_select on public.team_members for select to authenticated using (true);
-- No insert/update/delete policies on requests/teams/team_members:
-- all writes go through the SECURITY DEFINER RPCs below.

-- ---------------------------------------------------------------- RPCs
create or replace function public.send_request(p_to_profile uuid, p_message text, p_team_id uuid default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); msg text := trim(coalesce(p_message, '')); new_id uuid;
begin
  if me is null then raise exception 'Please complete your profile first.'; end if;
  if p_to_profile is null or not exists (select 1 from profiles where id = p_to_profile) then
    raise exception 'Student not found.'; end if;
  if p_to_profile = me then raise exception 'You cannot send a request to yourself.'; end if;
  if msg = '' then raise exception 'Please write a short message.'; end if;
  if char_length(msg) > 200 then raise exception 'Message is too long (max 200 characters).'; end if;
  if exists (select 1 from requests where status = 'pending'
             and ((from_profile = me and to_profile = p_to_profile)
               or (from_profile = p_to_profile and to_profile = me))) then
    raise exception 'There is already a pending request with this student.';
  end if;
  if p_team_id is not null and not exists (select 1 from teams t where t.id = p_team_id) then
    raise exception 'Target team not found.';
  end if;
  if p_team_id is not null and exists (select 1 from team_members where team_id = p_team_id and profile_id = p_to_profile)
     and exists (select 1 from team_members where team_id = p_team_id and profile_id = me) then
    raise exception 'Both students are already in this team.';
  end if;
  insert into requests (from_profile, to_profile, message, team_id)
  values (me, p_to_profile, msg, p_team_id) returning id into new_id;
  return new_id;
end $$;

create or replace function public.update_project(
  p_team_id uuid,
  p_title text,
  p_description text,
  p_project_type text,
  p_roles text[],
  p_skills text[] default '{}',
  p_domains text[] default '{}'
)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can edit project details.'; end if;
  update teams set
    title = trim(p_title),
    description = left(trim(coalesce(p_description, '')), 500),
    project_type = p_project_type,
    roles_needed = coalesce((select array_agg(distinct x) from unnest(p_roles) x), '{}'),
    required_skills = coalesce((select array_agg(distinct x) from unnest(p_skills) x), '{}'),
    domain_tags = coalesce((select array_agg(distinct x) from unnest(p_domains) x), '{}')
  where id = p_team_id;
end $$;

create or replace function public.remove_team_member(p_team_id uuid, p_member_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype; m team_members%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can remove members.'; end if;
  if p_member_id = me then raise exception 'Owner cannot remove themselves.'; end if;
  select * into m from team_members where team_id = p_team_id and profile_id = p_member_id;
  if not found then raise exception 'Member not found.'; end if;
  delete from team_members where team_id = p_team_id and profile_id = p_member_id;
  if m.role in ('Developer','Designer','Tester','Report Writer','Data/ML Engineer')
     and not (m.role = any(t.roles_needed)) then
    update teams set roles_needed = array_append(roles_needed, m.role) where id = p_team_id;
  end if;
end $$;

-- Accept: the joiner is normally the SENDER. If the request carries a team
-- the sender already belongs to (an invitation), the RECEIVER joins it.
create or replace function public.accept_request(p_request_id uuid)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  me uuid := public.my_profile_id();
  r requests%rowtype;
  target uuid;
  joiner uuid;
  my_name text; my_type text;
  roles text[]; jskills text[]; chosen text;
begin
  if me is null then raise exception 'Please complete your profile first.'; end if;
  select * into r from requests where id = p_request_id for update;
  if not found then raise exception 'Request not found.'; end if;
  if r.to_profile <> me then raise exception 'Only the receiver can accept this request.'; end if;
  if r.status <> 'pending' then raise exception 'This request is already %.', r.status; end if;

  joiner := r.from_profile;
  if r.team_id is not null and exists (select 1 from teams where id = r.team_id) then
    target := r.team_id;
    if exists (select 1 from team_members where team_id = target and profile_id = r.from_profile) then
      joiner := me;  -- invitation
    end if;
  end if;

  if target is null then target := public.my_team_id(); end if;

  if target is null then
    select name, project_type into my_name, my_type from profiles where id = me;
    insert into teams (owner_profile, title, project_type, roles_needed)
    values (me, left(my_name || '''s Team', 60), coalesce(my_type, 'FYP'),
            array['Developer','Designer','Tester','Report Writer'])
    returning id into target;
    insert into team_members (team_id, profile_id, role) values (target, me, 'Owner');
  end if;

  if exists (select 1 from team_members where team_id = target and profile_id = joiner) then
    raise exception 'This student is already a member of the team.';
  end if;

  select roles_needed into roles from teams where id = target for update;
  select skills into jskills from profiles where id = joiner;
  chosen := public.best_role(jskills, roles);

  insert into team_members (team_id, profile_id, role) values (target, joiner, chosen);
  update teams set roles_needed = array_remove(roles_needed, chosen) where id = target;
  update requests set status = 'accepted', team_id = target where id = r.id;
  return target;
end $$;

create or replace function public.reject_request(p_request_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); r requests%rowtype;
begin
  select * into r from requests where id = p_request_id for update;
  if not found then raise exception 'Request not found.'; end if;
  if me is null or r.to_profile <> me then raise exception 'Only the receiver can reject this request.'; end if;
  if r.status <> 'pending' then raise exception 'This request is already %.', r.status; end if;
  update requests set status = 'rejected' where id = r.id;
end $$;

create or replace function public.cancel_request(p_request_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); r requests%rowtype;
begin
  select * into r from requests where id = p_request_id for update;
  if not found then raise exception 'Request not found.'; end if;
  if me is null or r.from_profile <> me then raise exception 'Only the sender can cancel this request.'; end if;
  if r.status <> 'pending' then raise exception 'This request is already %.', r.status; end if;
  update requests set status = 'cancelled' where id = r.id;
end $$;

create or replace function public.create_team(p_title text, p_project_type text, p_roles text[])
returns uuid language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t text := trim(coalesce(p_title, '')); new_id uuid;
begin
  if me is null then raise exception 'Please complete your profile first.'; end if;
  if t = '' then raise exception 'Please enter a team title.'; end if;
  if char_length(t) > 60 then raise exception 'Title is too long (max 60 characters).'; end if;
  if p_project_type not in ('Semester Project','FYP') then raise exception 'Please select a project type.'; end if;
  insert into teams (owner_profile, title, project_type, roles_needed)
  values (me, t, p_project_type, coalesce((select array_agg(distinct x) from unnest(p_roles) x), '{}'))
  returning id into new_id;
  insert into team_members (team_id, profile_id, role) values (new_id, me, 'Owner');
  return new_id;
end $$;

create or replace function public.update_project(
  p_team_id uuid,
  p_title text,
  p_description text,
  p_project_type text,
  p_roles text[],
  p_skills text[] default '{}',
  p_domains text[] default '{}'
)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can edit project details.'; end if;
  update teams set
    title = trim(p_title),
    description = left(trim(coalesce(p_description, '')), 500),
    project_type = p_project_type,
    roles_needed = coalesce((select array_agg(distinct x) from unnest(p_roles) x), '{}'),
    required_skills = coalesce((select array_agg(distinct x) from unnest(p_skills) x), '{}'),
    domain_tags = coalesce((select array_agg(distinct x) from unnest(p_domains) x), '{}')
  where id = p_team_id;
end $$;

create or replace function public.remove_team_member(p_team_id uuid, p_member_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype; m team_members%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can remove members.'; end if;
  if p_member_id = me then raise exception 'Owner cannot remove themselves.'; end if;
  select * into m from team_members where team_id = p_team_id and profile_id = p_member_id;
  if not found then raise exception 'Member not found.'; end if;
  delete from team_members where team_id = p_team_id and profile_id = p_member_id;
  if m.role in ('Developer','Designer','Tester','Report Writer','Data/ML Engineer')
     and not (m.role = any(t.roles_needed)) then
    update teams set roles_needed = array_append(roles_needed, m.role) where id = p_team_id;
  end if;
end $$;

create or replace function public.create_project(
  p_title text,
  p_description text,
  p_project_type text,
  p_roles text[],
  p_skills text[] default '{}',
  p_domains text[] default '{}'
)
returns uuid language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t text := trim(coalesce(p_title, '')); new_id uuid;
begin
  if me is null then raise exception 'Please complete your profile first.'; end if;
  if t = '' then raise exception 'Please enter a project title.'; end if;
  if char_length(t) > 60 then raise exception 'Title is too long (max 60 characters).'; end if;
  if p_project_type not in ('Semester Project','FYP') then raise exception 'Please select a project type.'; end if;
  insert into teams (owner_profile, title, description, project_type, roles_needed, required_skills, domain_tags)
  values (
    me, t, left(trim(coalesce(p_description, '')), 500), p_project_type,
    coalesce((select array_agg(distinct x) from unnest(p_roles) x), '{}'),
    coalesce((select array_agg(distinct x) from unnest(p_skills) x), '{}'),
    coalesce((select array_agg(distinct x) from unnest(p_domains) x), '{}')
  )
  returning id into new_id;
  insert into team_members (team_id, profile_id, role) values (new_id, me, 'Owner');
  return new_id;
end $$;

create or replace function public.update_project(
  p_team_id uuid,
  p_title text,
  p_description text,
  p_project_type text,
  p_roles text[],
  p_skills text[] default '{}',
  p_domains text[] default '{}'
)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can edit project details.'; end if;
  update teams set
    title = trim(p_title),
    description = left(trim(coalesce(p_description, '')), 500),
    project_type = p_project_type,
    roles_needed = coalesce((select array_agg(distinct x) from unnest(p_roles) x), '{}'),
    required_skills = coalesce((select array_agg(distinct x) from unnest(p_skills) x), '{}'),
    domain_tags = coalesce((select array_agg(distinct x) from unnest(p_domains) x), '{}')
  where id = p_team_id;
end $$;

create or replace function public.remove_team_member(p_team_id uuid, p_member_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype; m team_members%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Project not found.'; end if;
  if t.owner_profile <> me then raise exception 'Only the project owner can remove members.'; end if;
  if p_member_id = me then raise exception 'Owner cannot remove themselves.'; end if;
  select * into m from team_members where team_id = p_team_id and profile_id = p_member_id;
  if not found then raise exception 'Member not found.'; end if;
  delete from team_members where team_id = p_team_id and profile_id = p_member_id;
  if m.role in ('Developer','Designer','Tester','Report Writer','Data/ML Engineer')
     and not (m.role = any(t.roles_needed)) then
    update teams set roles_needed = array_append(roles_needed, m.role) where id = p_team_id;
  end if;
end $$;

-- Member leaves -> their role re-opens. Owner leaves -> team disbanded.
create or replace function public.leave_team(p_team_id uuid)
returns text language plpgsql security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); t teams%rowtype; m team_members%rowtype;
begin
  select * into t from teams where id = p_team_id for update;
  if not found then raise exception 'Team not found.'; end if;
  select * into m from team_members where team_id = p_team_id and profile_id = me;
  if not found then raise exception 'You are not a member of this team.'; end if;
  if t.owner_profile = me then
    delete from teams where id = p_team_id;
    return 'disbanded';
  end if;
  delete from team_members where team_id = p_team_id and profile_id = me;
  if m.role in ('Developer','Designer','Tester','Report Writer','Data/ML Engineer')
     and not (m.role = any(t.roles_needed)) then
    update teams set roles_needed = array_append(roles_needed, m.role) where id = p_team_id;
  end if;
  return 'left';
end $$;

-- My primary team as JSON in the exact shape of Team.fromJson (or null).
create or replace function public.get_my_team()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare me uuid := public.my_profile_id(); tid uuid := public.my_team_id(); t teams%rowtype;
begin
  if tid is null then return null; end if;
  select * into t from teams where id = tid;
  return jsonb_build_object(
    'id', t.id, 'title', t.title, 'description', coalesce(t.description, ''),
    'project_type', t.project_type,
    'open_roles', to_jsonb(t.roles_needed),
    'required_skills', to_jsonb(coalesce(t.required_skills, '{}')),
    'domain_tags', to_jsonb(coalesce(t.domain_tags, '{}')),
    'i_am_owner', t.owner_profile = me,
    'members', coalesce((
      select jsonb_agg(jsonb_build_object(
               'role', m.role, 'is_owner', m.profile_id = t.owner_profile, 'profile', to_jsonb(p))
             order by (m.profile_id = t.owner_profile) desc, m.joined_at)
      from team_members m join profiles p on p.id = m.profile_id
      where m.team_id = t.id), '[]'::jsonb));
end $$;

-- All teams/projects I own or belong to.
create or replace function public.get_my_teams()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare me uuid := public.my_profile_id();
begin
  if me is null then return '[]'::jsonb; end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', t.id, 'title', t.title, 'description', coalesce(t.description, ''),
      'project_type', t.project_type,
      'open_roles', to_jsonb(t.roles_needed),
      'required_skills', to_jsonb(coalesce(t.required_skills, '{}')),
      'domain_tags', to_jsonb(coalesce(t.domain_tags, '{}')),
      'i_am_owner', t.owner_profile = me,
      'members', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'role', m.role, 'is_owner', m.profile_id = t.owner_profile, 'profile', to_jsonb(p))
               order by (m.profile_id = t.owner_profile) desc, m.joined_at)
        from team_members m join profiles p on p.id = m.profile_id
        where m.team_id = t.id), '[]'::jsonb))
      order by t.created_at desc)
    from teams t
    where t.owner_profile = me
       or exists (select 1 from team_members m where m.team_id = t.id and m.profile_id = me)
  ), '[]'::jsonb);
end $$;

-- Public open teams posted by other students that are looking for teammates.
create or replace function public.get_open_teams()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare me uuid := public.my_profile_id();
begin
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', t.id, 'title', t.title, 'description', coalesce(t.description, ''),
      'project_type', t.project_type,
      'open_roles', to_jsonb(t.roles_needed),
      'required_skills', to_jsonb(coalesce(t.required_skills, '{}')),
      'domain_tags', to_jsonb(coalesce(t.domain_tags, '{}')),
      'i_am_owner', false,
      'members', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'role', m.role, 'is_owner', m.profile_id = t.owner_profile, 'profile', to_jsonb(p))
               order by (m.profile_id = t.owner_profile) desc, m.joined_at)
        from team_members m join profiles p on p.id = m.profile_id
        where m.team_id = t.id), '[]'::jsonb))
      order by t.created_at desc)
    from teams t
    where (me is null or (t.owner_profile <> me and not exists (select 1 from team_members m where m.team_id = t.id and m.profile_id = me)))
      and (cardinality(t.roles_needed) > 0 or cardinality(t.required_skills) > 0)
  ), '[]'::jsonb);
end $$;

grant execute on function public.send_request(uuid, text, uuid), public.accept_request(uuid),
  public.reject_request(uuid), public.cancel_request(uuid), public.create_team(text, text, text[]),
  public.create_project(text, text, text, text[], text[], text[]),
  public.update_project(uuid, text, text, text, text[], text[], text[]),
  public.remove_team_member(uuid, uuid),
  public.leave_team(uuid), public.get_my_team(), public.get_my_teams(), public.get_open_teams(),
  public.my_profile_id(), public.my_team_id(), public.is_team_member(uuid) to authenticated;

-- ---------------------------------------------------------------- trigger
-- Every new real account receives 3 pending requests from sample students
-- (the ones whose skills best fit what the new user is looking for), so
-- accept / reject can be tested immediately.
create or replace function public.seed_requests_for_new_profile()
returns trigger language plpgsql security definer set search_path = public as $$
declare msgs text[] := array[
  'Hi! Your profile looks like a great fit for my project. Want to team up?',
  'Hey, I need someone with your skills for my FYP. Interested?',
  'Saw your skills on TeamUp, would love to work together this semester!'];
begin
  insert into requests (from_profile, to_profile, message, status, created_at)
  select s.id, new.id, msgs[s.rn], 'pending', now() - make_interval(hours => s.rn::int)
  from (
    select p.id, row_number() over (order by
             (select count(*) from unnest(p.skills) k where k = any(new.skills_needed)) desc,
             random()) as rn
    from profiles p where p.is_sample
  ) s
  where s.rn <= 3;
  return new;
end $$;

drop trigger if exists on_profile_created on public.profiles;
create trigger on_profile_created after insert on public.profiles
  for each row when (new.user_id is not null)
  execute function public.seed_requests_for_new_profile();

-- Auto-confirm email on sign-up so users can sign in immediately during the competition demo
-- even if "Confirm email" is left enabled in the Supabase dashboard.
create or replace function public.auto_confirm_auth_user()
returns trigger language plpgsql security definer set search_path = auth as $$
begin
  if new.email_confirmed_at is null then
    new.email_confirmed_at := now();
  end if;
  return new;
end $$;

drop trigger if exists on_auth_user_auto_confirm on auth.users;
create trigger on_auth_user_auto_confirm before insert on auth.users
  for each row execute function public.auto_confirm_auth_user();

