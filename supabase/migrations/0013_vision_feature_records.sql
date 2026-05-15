create table if not exists public.vision_feature_records (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  feature_key text not null,
  title text not null,
  detail text,
  status text not null default 'draft',
  payload jsonb not null default '{}'::jsonb,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists vision_feature_records_family_feature_idx
on public.vision_feature_records(family_id, feature_key, created_at desc);

alter table public.vision_feature_records enable row level security;

create policy "Members can view vision feature records"
on public.vision_feature_records for select
using (public.is_family_member(family_id));

create policy "Full members can create vision feature records"
on public.vision_feature_records for insert
with check (public.has_family_full_access(family_id) and created_by = auth.uid());

create policy "Full members can update vision feature records"
on public.vision_feature_records for update
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

drop trigger if exists vision_feature_records_set_updated_at on public.vision_feature_records;
create trigger vision_feature_records_set_updated_at
before update on public.vision_feature_records
for each row execute function public.set_updated_at();

drop trigger if exists audit_vision_feature_records on public.vision_feature_records;
create trigger audit_vision_feature_records
after insert or update on public.vision_feature_records
for each row execute function public.append_audit_log();
