create or replace function public.accept_family_invitation(invitation_code_input text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  invitation public.family_invitations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select *
  into invitation
  from public.family_invitations
  where invitation_code = upper(trim(invitation_code_input))
  for update;

  if not found then
    raise exception 'Invitation not found';
  end if;

  if invitation.status <> 'pending' then
    raise exception 'Invitation is not pending';
  end if;

  if invitation.expires_at < now() then
    update public.family_invitations
    set status = 'expired'
    where id = invitation.id;
    raise exception 'Invitation expired';
  end if;

  insert into public.family_members (
    family_id,
    user_id,
    role,
    relationship_label,
    status,
    access_level,
    invited_by,
    joined_at
  )
  values (
    invitation.family_id,
    auth.uid(),
    invitation.invited_role,
    case
      when invitation.invited_role = 'parent' then 'Ebeveyn'
      else initcap(replace(invitation.invited_role::text, '_', ' '))
    end,
    'active',
    'full',
    invitation.created_by,
    now()
  )
  on conflict (family_id, user_id, role) do update
  set status = 'active',
      access_level = excluded.access_level,
      joined_at = coalesce(public.family_members.joined_at, now());

  update public.family_invitations
  set status = 'accepted',
      accepted_by = auth.uid()
  where id = invitation.id;

  return invitation.family_id;
end;
$$;

grant execute on function public.accept_family_invitation(text) to authenticated;
