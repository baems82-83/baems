-- Add a Qualification field to Faculty (e.g. "M.Sc. Physics, Tribhuvan University")
alter table faculty add column if not exists qualification text;
