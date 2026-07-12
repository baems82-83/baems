-- Fix: change admin@baems.com's role to 'admin' (it's currently set to 'teacher')
update staff_roles
set role = 'admin', subject = null
where user_id = (select id from auth.users where email = 'admin@baems.com');

-- Confirm it worked — should show role = admin
select u.email, r.role, r.name
from staff_roles r
join auth.users u on u.id = r.user_id;
