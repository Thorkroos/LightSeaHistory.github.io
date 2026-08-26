alter table public.members
  add column if not exists mbti text null,
  add column if not exists birth_year integer null,
  add column if not exists birth_month integer null,
  add column if not exists sun_sign text null,
  add column if not exists moon_sign text null,
  add column if not exists rising_sign text null,
  add column if not exists mercury_sign text null,
  add column if not exists venus_sign text null,
  add column if not exists mars_sign text null;

alter table public.members
  add constraint members_mbti_check
    check (mbti is null or mbti in ('INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP','ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP')),
  add constraint members_birth_year_check
    check (birth_year is null or birth_year between 1900 and 2200),
  add constraint members_birth_month_check
    check (birth_month is null or birth_month between 1 and 12),
  add constraint members_birth_pair_check
    check (birth_month is null or birth_year is not null);

comment on column public.members.display_name is '前台展示的当前昵称，可重复';
comment on column public.members.canonical_name is '成员稳定唯一标识，不随昵称变化，不可重复';
comment on column public.members.mbti is '16型 MBTI，大写四字母';
comment on column public.members.birth_year is '出生年份';
comment on column public.members.birth_month is '出生月份；填写时必须同时填写出生年份';
comment on column public.members.sun_sign is '太阳星座';
comment on column public.members.moon_sign is '月亮星座';
comment on column public.members.rising_sign is '上升星座';
comment on column public.members.mercury_sign is '水星星座';
comment on column public.members.venus_sign is '金星星座';
comment on column public.members.mars_sign is '火星星座';
