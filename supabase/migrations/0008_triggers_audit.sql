create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.prevent_message_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Messages cannot be updated or deleted';
end;
$$;

create or replace function public.compute_audit_hash(
  previous_hash text,
  action text,
  entity_type text,
  entity_id uuid,
  payload jsonb
)
returns text
language sql
immutable
as $$
  select encode(
    digest(
      coalesce(previous_hash, '') || '|' ||
      coalesce(action, '') || '|' ||
      coalesce(entity_type, '') || '|' ||
      coalesce(entity_id::text, '') || '|' ||
      coalesce(payload::text, '{}'),
      'sha256'
    ),
    'hex'
  );
$$;

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
  fam := coalesce(new.family_id, null);
  child := coalesce(new.child_id, null);
  entity_payload := to_jsonb(new);

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

create trigger prevent_message_update
before update on public.messages
for each row execute function public.prevent_message_mutation();

create trigger prevent_message_delete
before delete on public.messages
for each row execute function public.prevent_message_mutation();

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger families_set_updated_at
before update on public.families
for each row execute function public.set_updated_at();

create trigger children_set_updated_at
before update on public.children
for each row execute function public.set_updated_at();

create trigger custody_events_set_updated_at
before update on public.custody_events
for each row execute function public.set_updated_at();

create trigger message_threads_set_updated_at
before update on public.message_threads
for each row execute function public.set_updated_at();

create trigger expenses_set_updated_at
before update on public.expenses
for each row execute function public.set_updated_at();

create trigger decisions_set_updated_at
before update on public.decision_requests
for each row execute function public.set_updated_at();

create trigger disputes_set_updated_at
before update on public.disputes
for each row execute function public.set_updated_at();

create trigger audit_custody_events
after insert or update on public.custody_events
for each row execute function public.append_audit_log();

create trigger audit_handover_logs
after insert on public.handover_logs
for each row execute function public.append_audit_log();

create trigger audit_messages
after insert on public.messages
for each row execute function public.append_audit_log();

create trigger audit_expenses
after insert or update on public.expenses
for each row execute function public.append_audit_log();

create trigger audit_documents
after insert on public.documents
for each row execute function public.append_audit_log();

create trigger audit_decisions
after insert or update on public.decision_requests
for each row execute function public.append_audit_log();

create trigger audit_disputes
after insert or update on public.disputes
for each row execute function public.append_audit_log();

create trigger audit_reports
after insert on public.reports
for each row execute function public.append_audit_log();
