alter table public.profiles enable row level security;
alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.family_invitations enable row level security;
alter table public.children enable row level security;
alter table public.custody_plans enable row level security;
alter table public.custody_rules enable row level security;
alter table public.custody_events enable row level security;
alter table public.change_requests enable row level security;
alter table public.handover_logs enable row level security;
alter table public.contacts enable row level security;
alter table public.school_infos enable row level security;
alter table public.service_infos enable row level security;
alter table public.health_infos enable row level security;
alter table public.documents enable row level security;
alter table public.message_threads enable row level security;
alter table public.messages enable row level security;
alter table public.message_read_receipts enable row level security;
alter table public.expenses enable row level security;
alter table public.expense_documents enable row level security;
alter table public.decision_requests enable row level security;
alter table public.disputes enable row level security;
alter table public.personal_journal_entries enable row level security;
alter table public.child_needs enable row level security;
alter table public.handover_checklists enable row level security;
alter table public.handover_checklist_items enable row level security;
alter table public.emergency_events enable row level security;
alter table public.reports enable row level security;
alter table public.audit_logs enable row level security;
alter table public.subscriptions enable row level security;
alter table public.external_notifications enable row level security;
alter table public.subscription_plan_catalog enable row level security;

create policy "Users can view own profile"
on public.profiles for select
using (id = auth.uid());

create policy "Users can update own profile"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "Users can create own profile"
on public.profiles for insert
with check (id = auth.uid());

create policy "Members can view their families"
on public.families for select
using (public.is_family_member(id));

create policy "Creators can view families before membership"
on public.families for select
using (created_by = auth.uid());

create policy "Authenticated users can create families"
on public.families for insert
with check (created_by = auth.uid());

create policy "Full members can update families"
on public.families for update
using (public.has_family_full_access(id))
with check (public.has_family_full_access(id));

create policy "Members can view family members"
on public.family_members for select
using (public.is_family_member(family_id));

create policy "Full members can invite family members"
on public.family_members for insert
with check (public.has_family_full_access(family_id));

create policy "Family creators can create own first membership"
on public.family_members for insert
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.families f
    where f.id = family_id
      and f.created_by = auth.uid()
  )
);

create policy "Full members can update family members"
on public.family_members for update
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view invitations"
on public.family_invitations for select
using (public.is_family_member(family_id));

create policy "Full members can create invitations"
on public.family_invitations for insert
with check (public.has_family_full_access(family_id) and created_by = auth.uid());

create policy "Members can view children"
on public.children for select
using (public.is_family_member(family_id));

create policy "Full members can create children"
on public.children for insert
with check (public.has_family_full_access(family_id) and created_by = auth.uid());

create policy "Full members can update children"
on public.children for update
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view custody plans"
on public.custody_plans for select
using (public.is_family_member(family_id));

create policy "Full members can write custody plans"
on public.custody_plans for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view custody rules"
on public.custody_rules for select
using (public.is_family_member(family_id));

create policy "Full members can write custody rules"
on public.custody_rules for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view custody events"
on public.custody_events for select
using (public.is_family_member(family_id));

create policy "Full members can write custody events"
on public.custody_events for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view change requests"
on public.change_requests for select
using (public.is_family_member(family_id));

create policy "Full members can create change requests"
on public.change_requests for insert
with check (public.has_family_full_access(family_id) and requested_by = auth.uid());

create policy "Full members can respond to change requests"
on public.change_requests for update
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view handover logs"
on public.handover_logs for select
using (public.is_family_member(family_id));

create policy "Full members can create handover logs"
on public.handover_logs for insert
with check (public.has_family_full_access(family_id) and actor_id = auth.uid());

create policy "Members can view contacts"
on public.contacts for select
using (public.is_family_member(family_id));

create policy "Full members can write contacts"
on public.contacts for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view school info"
on public.school_infos for select
using (public.is_family_member(family_id));

create policy "Full members can write school info"
on public.school_infos for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view service info"
on public.service_infos for select
using (public.is_family_member(family_id));

create policy "Full members can write service info"
on public.service_infos for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view health info"
on public.health_infos for select
using (public.is_family_member(family_id));

create policy "Full members can write health info"
on public.health_infos for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view documents"
on public.documents for select
using (public.is_family_member(family_id));

create policy "Full members can create documents"
on public.documents for insert
with check (public.has_family_full_access(family_id) and uploaded_by = auth.uid());

create policy "Members can view message threads"
on public.message_threads for select
using (public.is_family_member(family_id));

create policy "Full members can create message threads"
on public.message_threads for insert
with check (public.has_family_full_access(family_id) and created_by = auth.uid());

create policy "Family members can view messages"
on public.messages for select
using (public.is_family_member(family_id));

create policy "Full family members can send messages"
on public.messages for insert
with check (public.has_family_full_access(family_id) and sender_id = auth.uid());

create policy "Members can view message read receipts"
on public.message_read_receipts for select
using (public.is_family_member(family_id));

create policy "Members can create own read receipts"
on public.message_read_receipts for insert
with check (public.is_family_member(family_id) and user_id = auth.uid());

create policy "Members can view expenses"
on public.expenses for select
using (public.is_family_member(family_id));

create policy "Full members can write expenses"
on public.expenses for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view expense documents"
on public.expense_documents for select
using (public.is_family_member(family_id));

create policy "Full members can write expense documents"
on public.expense_documents for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view decisions"
on public.decision_requests for select
using (public.is_family_member(family_id));

create policy "Full members can write decisions"
on public.decision_requests for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view disputes"
on public.disputes for select
using (public.is_family_member(family_id));

create policy "Full members can write disputes"
on public.disputes for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Users can view own journal entries"
on public.personal_journal_entries for select
using (user_id = auth.uid());

create policy "Users can create own journal entries"
on public.personal_journal_entries for insert
with check (user_id = auth.uid() and public.is_family_member(family_id));

create policy "Users can update own journal entries"
on public.personal_journal_entries for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Members can view child needs"
on public.child_needs for select
using (public.is_family_member(family_id));

create policy "Full members can write child needs"
on public.child_needs for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view checklists"
on public.handover_checklists for select
using (public.is_family_member(family_id));

create policy "Full members can write checklists"
on public.handover_checklists for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view checklist items"
on public.handover_checklist_items for select
using (public.is_family_member(family_id));

create policy "Full members can write checklist items"
on public.handover_checklist_items for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Members can view emergency events"
on public.emergency_events for select
using (public.is_family_member(family_id));

create policy "Full members can write emergency events"
on public.emergency_events for all
using (public.has_family_full_access(family_id))
with check (public.has_family_full_access(family_id));

create policy "Report viewers can view reports"
on public.reports for select
using (public.has_family_report_access(family_id));

create policy "Full members can create reports"
on public.reports for insert
with check (public.has_family_full_access(family_id) and generated_by = auth.uid());

create policy "Family members can view audit logs"
on public.audit_logs for select
using (family_id is not null and public.has_family_report_access(family_id));

create policy "Users can view own subscriptions"
on public.subscriptions for select
using (user_id = auth.uid());

create policy "Members can view external notifications"
on public.external_notifications for select
using (family_id is not null and public.is_family_member(family_id));

create policy "Full members can create external notifications"
on public.external_notifications for insert
with check (family_id is not null and public.has_family_full_access(family_id) and created_by = auth.uid());

create policy "Authenticated users can view subscription plans"
on public.subscription_plan_catalog for select
using (auth.role() = 'authenticated');
