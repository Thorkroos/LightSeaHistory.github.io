alter table public.members
  add column if not exists birth_day integer null;

alter table public.members
  add constraint members_birth_day_check
    check (birth_day is null or birth_day between 1 and 31),
  add constraint members_birth_day_pair_check
    check (birth_day is null or (birth_year is not null and birth_month is not null));

comment on column public.members.birth_day is '出生日期；填写时必须同时填写出生年份和月份';
