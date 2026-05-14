insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', false, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('documents', 'documents', false, 26214400, null),
  ('expense-files', 'expense-files', false, 26214400, null),
  ('handover-photos', 'handover-photos', false, 10485760, array['image/png', 'image/jpeg', 'image/webp']),
  ('journal-files', 'journal-files', false, 26214400, null),
  ('report-pdfs', 'report-pdfs', false, 26214400, array['application/pdf']),
  ('support-files', 'support-files', false, 26214400, null)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create policy "Family members can read family scoped storage objects"
on storage.objects for select
using (
  bucket_id in ('documents', 'expense-files', 'handover-photos', 'report-pdfs')
  and public.storage_family_id(name) is not null
  and public.is_family_member(public.storage_family_id(name))
);

create policy "Full members can upload family scoped storage objects"
on storage.objects for insert
with check (
  bucket_id in ('documents', 'expense-files', 'handover-photos', 'report-pdfs')
  and public.storage_family_id(name) is not null
  and public.has_family_full_access(public.storage_family_id(name))
);

create policy "Users can read own private files"
on storage.objects for select
using (
  bucket_id in ('avatars', 'journal-files')
  and (string_to_array(name, '/'))[1] = 'users'
  and (string_to_array(name, '/'))[2] = auth.uid()::text
);

create policy "Users can upload own private files"
on storage.objects for insert
with check (
  bucket_id in ('avatars', 'journal-files')
  and (string_to_array(name, '/'))[1] = 'users'
  and (string_to_array(name, '/'))[2] = auth.uid()::text
);
