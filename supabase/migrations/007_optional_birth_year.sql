alter table public.members
  drop constraint if exists members_birth_pair_check,
  drop constraint if exists members_birth_day_pair_check;

alter table public.members
  add constraint members_birth_day_requires_month_check
    check (birth_day is null or birth_month is not null);

comment on column public.members.birth_year is '出生年份，可选；月份和日期可以在没有年份时保存';
comment on column public.members.birth_month is '出生月份，可独立于年份保存';
comment on column public.members.birth_day is '出生日期；填写时必须同时填写出生月份，年份可为空';
