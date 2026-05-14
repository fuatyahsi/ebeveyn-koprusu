create or replace function public.compute_audit_hash(
  previous_hash text,
  action text,
  entity_type text,
  entity_id uuid,
  payload jsonb
)
returns text
language plpgsql
immutable
set search_path = public, extensions
as $$
begin
  return encode(
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
end;
$$;
