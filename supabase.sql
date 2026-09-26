-- Carnet de Meute : table unique, une ligne par profil / plan / séance.
-- Chaque ligne appartient à un compte : la sécurité (RLS) empêche de voir les données des autres.

create table if not exists public.carnet_docs (
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  collection text        not null check (collection in ('profiles', 'plans', 'sessions')),
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, collection, id)
);

alter table public.carnet_docs enable row level security;

grant select, insert, update, delete on public.carnet_docs to authenticated;

drop policy if exists "carnet_lire"      on public.carnet_docs;
drop policy if exists "carnet_ajouter"   on public.carnet_docs;
drop policy if exists "carnet_modifier"  on public.carnet_docs;
drop policy if exists "carnet_supprimer" on public.carnet_docs;

create policy "carnet_lire"      on public.carnet_docs for select to authenticated using ((select auth.uid()) = user_id);
create policy "carnet_ajouter"   on public.carnet_docs for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "carnet_modifier"  on public.carnet_docs for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "carnet_supprimer" on public.carnet_docs for delete to authenticated using ((select auth.uid()) = user_id);
