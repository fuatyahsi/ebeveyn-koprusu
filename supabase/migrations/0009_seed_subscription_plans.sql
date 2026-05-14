insert into public.subscription_plan_catalog (
  code,
  title,
  monthly_price_try,
  yearly_price_try,
  entitlement,
  max_children,
  storage_limit_gb,
  features
)
values
  (
    'plus',
    'Ebeveyn Köprüsü Plus',
    299,
    2999,
    'plus_access',
    1,
    2,
    '{"calendar": true, "handover": true, "messages": true, "expenses": true, "basic_reports": true}'::jsonb
  ),
  (
    'premium',
    'Ebeveyn Köprüsü Premium',
    499,
    4999,
    'premium_access',
    5,
    10,
    '{"verified_reports": true, "tone_assistant": true, "journal": true, "disputes": true, "decision_requests": true}'::jsonb
  ),
  (
    'professional',
    'Ebeveyn Köprüsü Professional',
    899,
    8999,
    'professional_access',
    10,
    50,
    '{"expert_access": true, "multi_family": true, "advanced_reports": true, "priority_support": true}'::jsonb
  )
on conflict (code) do update
set title = excluded.title,
    monthly_price_try = excluded.monthly_price_try,
    yearly_price_try = excluded.yearly_price_try,
    entitlement = excluded.entitlement,
    max_children = excluded.max_children,
    storage_limit_gb = excluded.storage_limit_gb,
    features = excluded.features;
