create or replace function public.append_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  fam uuid;
  child uuid;
  previous text;
  current text;
  entity_payload jsonb;
begin
  entity_payload := to_jsonb(new);
  fam := nullif(entity_payload ->> 'family_id', '')::uuid;

  if entity_payload ? 'child_id' then
    child := nullif(entity_payload ->> 'child_id', '')::uuid;
  else
    child := null;
  end if;

  select al.current_hash
  into previous
  from public.audit_logs al
  where al.family_id = fam
  order by al.created_at desc
  limit 1;

  current := public.compute_audit_hash(
    previous,
    tg_table_name || '.' || tg_op,
    tg_table_name,
    new.id,
    entity_payload
  );

  insert into public.audit_logs (
    family_id,
    child_id,
    actor_id,
    action,
    entity_type,
    entity_id,
    previous_hash,
    current_hash,
    payload
  )
  values (
    fam,
    child,
    auth.uid(),
    tg_table_name || '.' || tg_op,
    tg_table_name,
    new.id,
    previous,
    current,
    entity_payload
  );

  return new;
end;
$$;
