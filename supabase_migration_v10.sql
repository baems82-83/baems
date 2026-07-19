-- ============================================================================
-- BAEMS STUDY — migration v10: voice clips + "delete your own message"
-- ============================================================================

alter table discussions add column if not exists audio_url text;
alter table discussions add column if not exists author_token text;

-- Secure "delete my own post" function. A normal visitor (student/teacher,
-- who aren't real Supabase Auth accounts) can only delete a row if they
-- supply the matching author_token — a long random ID generated once per
-- browser and never shown to anyone else, so in practice only the original
-- poster (on the same browser) can delete their own message. Admin can
-- delete anything regardless of token.
create or replace function delete_own_discussion(p_id bigint, p_token text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if is_admin() then
    delete from discussions where id = p_id;
    return true;
  elsif exists (select 1 from discussions where id = p_id and author_token = p_token) then
    delete from discussions where id = p_id;
    return true;
  else
    return false;
  end if;
end;
$$;
grant execute on function delete_own_discussion(bigint, text) to anon;

-- Done. Push the updated admin.html, teacher.html, student.html.
