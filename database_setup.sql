-- Wall-E / Studio G Architects shared library
-- Run this entire file once in Supabase: SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.wall_e_materials (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    category text not null,
    emitted double precision not null default 0,
    stored double precision not null default 0,
    unit text not null,
    source text not null default 'Studio G shared library',
    source_declared_unit text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint wall_e_materials_name_not_blank check (length(trim(name)) > 0)
);

create table if not exists public.wall_e_assemblies (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    assembly jsonb not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint wall_e_assemblies_name_not_blank check (length(trim(name)) > 0),
    constraint wall_e_assemblies_json_object check (jsonb_typeof(assembly) = 'object')
);

-- The app uses a server-side Supabase secret key. Public and ordinary
-- authenticated Supabase roles receive no direct table access.
alter table public.wall_e_materials enable row level security;
alter table public.wall_e_assemblies enable row level security;

revoke all on table public.wall_e_materials from anon, authenticated;
revoke all on table public.wall_e_assemblies from anon, authenticated;

grant select, insert, update, delete on table public.wall_e_materials to service_role;
grant select, insert, update, delete on table public.wall_e_assemblies to service_role;

create index if not exists wall_e_materials_category_idx
    on public.wall_e_materials (category);
create index if not exists wall_e_materials_updated_at_idx
    on public.wall_e_materials (updated_at desc);
create index if not exists wall_e_assemblies_updated_at_idx
    on public.wall_e_assemblies (updated_at desc);
