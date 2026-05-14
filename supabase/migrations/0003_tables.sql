create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email citext,
  phone text,
  default_role public.user_role not null default 'parent',
  avatar_url text,
  locale text not null default 'tr',
  timezone text not null default 'Europe/Istanbul',
  is_onboarding_completed boolean not null default false,
  terms_accepted_at timestamptz,
  kvkk_accepted_at timestamptz,
  marketing_consent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text,
  created_by uuid references public.profiles(id),
  is_single_parent_mode boolean not null default false,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role public.user_role not null,
  relationship_label text,
  status public.family_member_status not null default 'active',
  access_level public.access_level not null default 'full',
  permissions jsonb not null default '{}'::jsonb,
  invited_by uuid references public.profiles(id),
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  unique (family_id, user_id, role)
);

create table public.family_invitations (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  invited_email citext,
  invited_phone text,
  invited_role public.user_role not null,
  invitation_code text unique not null,
  status public.invitation_status not null default 'pending',
  expires_at timestamptz not null,
  accepted_by uuid references public.profiles(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.children (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  full_name text not null,
  birth_date date,
  gender text,
  notes text,
  profile_photo_url text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.custody_plans (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  title text not null,
  source_type text not null default 'manual'
    check (source_type in ('manual', 'court_order', 'protocol', 'agreement')),
  source_document_id uuid,
  effective_from date,
  effective_to date,
  is_active boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.custody_rules (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.custody_plans(id) on delete cascade,
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  rule_type text not null,
  rule_payload jsonb not null default '{}'::jsonb,
  delivery_location text,
  delivery_method text,
  delivery_person_id uuid,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.custody_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  assigned_parent_id uuid references public.profiles(id),
  title text not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  location_text text,
  location_lat numeric,
  location_lng numeric,
  event_type text not null default 'custody',
  status public.event_status not null default 'scheduled',
  source_plan_id uuid references public.custody_plans(id),
  recurrence_rule jsonb not null default '{}'::jsonb,
  change_history jsonb not null default '[]'::jsonb,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_at > start_at)
);

create table public.change_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  custody_event_id uuid references public.custody_events(id) on delete cascade,
  requested_by uuid references public.profiles(id),
  proposed_start_at timestamptz,
  proposed_end_at timestamptz,
  proposed_location text,
  reason text,
  status public.request_status not null default 'sent',
  responded_by uuid references public.profiles(id),
  responded_at timestamptz,
  response_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.handover_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  custody_event_id uuid references public.custody_events(id) on delete set null,
  actor_id uuid references public.profiles(id),
  action text not null,
  status public.handover_status not null default 'planned',
  note text,
  location_lat numeric,
  location_lng numeric,
  location_consent_at timestamptz,
  photo_path text,
  counterparty_ack_at timestamptz,
  disputed_at timestamptz,
  audit_hash text,
  created_at timestamptz not null default now()
);

create table public.contacts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  full_name text not null,
  relation text,
  phone text,
  email citext,
  address text,
  notes text,
  can_pickup boolean not null default false,
  can_be_called_in_emergency boolean not null default false,
  visible_to_other_parent boolean not null default true,
  approval_status public.request_status not null default 'draft',
  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.school_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  school_name text,
  class_name text,
  branch text,
  teacher_name text,
  teacher_phone text,
  school_phone text,
  school_address text,
  email citext,
  website text,
  notes text,
  updated_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.service_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  company_name text,
  driver_name text,
  driver_phone text,
  vehicle_plate text,
  route_notes text,
  pickup_time time,
  dropoff_time time,
  fee numeric(12,2),
  updated_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.health_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  blood_type text,
  allergies text,
  regular_medications text,
  doctor_name text,
  hospital_name text,
  doctor_phone text,
  emergency_notes text,
  chronic_condition_notes text,
  updated_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  uploaded_by uuid references public.profiles(id),
  category public.document_category not null default 'other',
  title text not null,
  description text,
  storage_bucket text not null,
  storage_path text not null,
  mime_type text,
  size_bytes bigint,
  is_sensitive boolean not null default false,
  visible_to_other_parent boolean not null default true,
  related_entity_type text,
  related_entity_id uuid,
  read_receipts jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.message_threads (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  topic public.message_topic not null,
  title text not null,
  created_by uuid references public.profiles(id),
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  thread_id uuid not null references public.message_threads(id) on delete cascade,
  sender_id uuid not null references public.profiles(id),
  body text not null,
  tone_assistant_used boolean not null default false,
  tone_risk_score integer,
  attachment_document_id uuid references public.documents(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.message_read_receipts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  message_id uuid not null references public.messages(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  read_at timestamptz not null default now(),
  unique (message_id, user_id)
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  title text not null,
  category text not null,
  amount numeric(12,2) not null check (amount >= 0),
  paid_by uuid references public.profiles(id),
  requested_from uuid references public.profiles(id),
  requested_share numeric(12,2) not null default 0 check (requested_share >= 0),
  share_type text not null default 'half',
  description text,
  is_urgent_health_expense boolean not null default false,
  due_date date,
  status public.expense_status not null default 'sent',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.expense_documents (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  expense_id uuid not null references public.expenses(id) on delete cascade,
  document_id uuid not null references public.documents(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (expense_id, document_id)
);

create table public.decision_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  decision_type text not null,
  title text not null,
  description text,
  requested_by uuid references public.profiles(id),
  response_due_at timestamptz,
  status public.request_status not null default 'sent',
  responded_by uuid references public.profiles(id),
  responded_at timestamptz,
  response_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.disputes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  dispute_type text not null,
  title text not null,
  description text,
  related_entity_type text,
  related_entity_id uuid,
  opened_by uuid references public.profiles(id),
  status text not null default 'open',
  resolution_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.personal_journal_entries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text,
  body text,
  category text,
  related_entity_type text,
  related_entity_id uuid,
  include_in_report boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.child_needs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  title text not null,
  need_type text not null,
  status text not null default 'open',
  due_date date,
  assigned_to uuid references public.profiles(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.handover_checklists (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  title text not null,
  checklist_type text not null default 'handover_bag',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.handover_checklist_items (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  checklist_id uuid not null references public.handover_checklists(id) on delete cascade,
  title text not null,
  is_checked boolean not null default false,
  checked_by uuid references public.profiles(id),
  checked_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.emergency_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  emergency_type text not null,
  title text not null,
  description text,
  opened_by uuid references public.profiles(id),
  status text not null default 'open',
  closed_by uuid references public.profiles(id),
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  report_type text not null,
  filters jsonb not null default '{}'::jsonb,
  storage_path text,
  report_hash text,
  verification_token text unique,
  generated_by uuid references public.profiles(id),
  generated_at timestamptz not null default now()
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete set null,
  child_id uuid references public.children(id) on delete set null,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  previous_hash text,
  current_hash text not null,
  ip_address inet,
  user_agent text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider text not null check (provider in ('revenuecat', 'apple', 'google', 'manual')),
  entitlement text not null,
  status public.subscription_status not null default 'unknown',
  product_id text,
  original_transaction_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  trial_ends_at timestamptz,
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.external_notifications (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  created_by uuid references public.profiles(id),
  channel public.notification_channel not null,
  recipient_email citext,
  recipient_phone text,
  notification_type text not null,
  related_entity_type text,
  related_entity_id uuid,
  subject text,
  body text,
  token text unique not null,
  status text not null default 'sent',
  expires_at timestamptz not null,
  responded_at timestamptz,
  response_payload jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

create table public.subscription_plan_catalog (
  code text primary key,
  title text not null,
  monthly_price_try numeric(12,2),
  yearly_price_try numeric(12,2),
  entitlement text not null,
  max_children integer not null,
  storage_limit_gb integer not null,
  features jsonb not null default '{}'::jsonb
);
