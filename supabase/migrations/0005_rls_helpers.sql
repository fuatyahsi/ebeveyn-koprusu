create or replace function public.is_family_member(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.access_level <> 'no_access'
  );
$$;

create or replace function public.has_family_full_access(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.access_level = 'full'
  );
$$;

create or replace function public.has_family_report_access(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.access_level in ('full', 'report_view', 'limited_read')
  );
$$;

create or replace function public.storage_family_id(object_name text)
returns uuid
language plpgsql
stable
as $$
declare
  parts text[];
begin
  parts := string_to_array(object_name, '/');
  if array_length(parts, 1) >= 2 and parts[1] = 'families' then
    return parts[2]::uuid;
  end if;
  return null;
exception when others then
  return null;
end;
$$;
