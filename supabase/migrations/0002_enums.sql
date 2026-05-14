create type public.user_role as enum (
  'parent',
  'guardian',
  'lawyer',
  'mediator',
  'psychologist',
  'caregiver',
  'delivery_authorized_person',
  'relative',
  'pickup_delegate',
  'admin',
  'support'
);

create type public.family_member_status as enum (
  'active',
  'invited',
  'pending',
  'blocked',
  'removed',
  'solo_external_contact',
  'suspended'
);

create type public.access_level as enum (
  'full',
  'limited_read',
  'report_view',
  'delivery_only',
  'calendar_only',
  'expense_only',
  'no_access'
);

create type public.invitation_status as enum (
  'pending',
  'accepted',
  'expired',
  'revoked',
  'rejected'
);

create type public.event_status as enum (
  'scheduled',
  'change_requested',
  'accepted',
  'declined',
  'completed',
  'missed',
  'cancelled',
  'disputed'
);

create type public.request_status as enum (
  'draft',
  'sent',
  'read',
  'accepted',
  'rejected',
  'counter_proposed',
  'expired',
  'cancelled'
);

create type public.expense_status as enum (
  'draft',
  'sent',
  'read',
  'accepted',
  'partially_accepted',
  'rejected',
  'paid',
  'partially_paid',
  'overdue',
  'disputed',
  'cancelled'
);

create type public.document_category as enum (
  'school',
  'health',
  'transport',
  'expense',
  'legal',
  'identity',
  'activity',
  'handover',
  'journal',
  'report',
  'other'
);

create type public.message_topic as enum (
  'handover',
  'school',
  'transport',
  'health',
  'expense',
  'document',
  'emergency',
  'general',
  'decision',
  'travel'
);

create type public.handover_status as enum (
  'planned',
  'on_the_way',
  'arrived',
  'completed',
  'delayed',
  'missed',
  'cancelled',
  'disputed'
);

create type public.subscription_status as enum (
  'trial',
  'trialing',
  'active',
  'grace_period',
  'past_due',
  'cancelled',
  'expired',
  'refunded',
  'unknown'
);

create type public.notification_channel as enum ('email', 'sms', 'push');
