-- 按“光海与Meet(1).xlsx”清空并重建成员资料。
-- 生日中的 2025/2026 是 Excel 为仅有月日的数据自动补出的年份，因此不写入；1990 保留。
-- 注意：清空 members 时必须同时清空引用它的 event_members；历史事件本身不会被删除。

begin;

alter table public.members
  add column if not exists city text null;

create temporary table member_profile_import (
  source_name text primary key,
  mbti text,
  birth_year integer,
  birth_month integer,
  birth_day integer,
  sun_sign text,
  moon_sign text,
  mercury_sign text,
  venus_sign text,
  mars_sign text,
  rising_sign text,
  city text
) on commit drop;

insert into member_profile_import values
('OAOA','INTP',NULL,1,3,'摩羯','射手','摩羯','射手','水瓶','双鱼','上海'),
('理','ENTP',NULL,1,9,'摩羯','摩羯','摩羯','射手','天秤','白羊','深圳'),
('火总','INFJ',NULL,1,14,'摩羯','白羊','摩羯','摩羯','天秤','双子','无锡'),
('一只','ENTP',NULL,1,17,'摩羯','射手','水瓶','双鱼','水瓶','双子','武汉'),
('海伦','INFJ',NULL,1,25,'水瓶','处女','水瓶','摩羯','双鱼','摩羯','上海'),
('李卓','ENTP',NULL,2,7,'水瓶','双鱼','双鱼','双子','双鱼','射手','杭州'),
('c','INFJ',NULL,2,7,'水瓶','双子','水瓶','摩羯','金牛','金牛','宁波/武汉'),
('汐汐','INFJ',NULL,3,13,'双鱼','双子','双鱼','水瓶','白羊','双子','上海'),
('粥粥','INFJ',NULL,4,14,'白羊','狮子','白羊','白羊','金牛','摩羯','上海'),
('刀刀鲨','ENTP',NULL,4,18,'白羊','巨蟹','金牛','金牛','双子','处女','东莞'),
('金歡','INFJ',NULL,5,3,'金牛','金牛','白羊','金牛','双鱼','巨蟹','青岛'),
('linko','ISTP',NULL,5,11,'金牛','天秤','双子','白羊','狮子','射手','暂上海'),
('小叶','INFJ',NULL,5,12,'金牛','水瓶','金牛','白羊','狮子','天秤','东京'),
('长风','INFJ',NULL,5,16,'金牛','水瓶','双子','白羊','射手','白羊','温州'),
('呆','INFJ',NULL,5,18,'金牛','巨蟹','金牛','巨蟹','天秤','狮子','广州'),
('叔叔','INFJ',NULL,5,21,'双子','金牛','双子','白羊','狮子','天秤','福州'),
('姜姐夫','ENTP',NULL,6,3,'双子','天秤','双子','金牛','天秤','水瓶','成都'),
('不想说','INFJ',NULL,6,4,'双子','狮子','双子','金牛','处女','双子','北京'),
('轻轻','INFJ',NULL,6,10,'双子','双子','双子','巨蟹','巨蟹','水瓶','武汉'),
('667','ENTP',NULL,6,22,'巨蟹','巨蟹','双子','金牛','射手','双子','霞浦/厦门'),
('怪兽','INFJ',NULL,6,26,'巨蟹','巨蟹','巨蟹','双子','巨蟹','处女','杭州'),
('姜葵泱','INFJ',1990,6,26,'巨蟹','狮子','双子','双子','白羊','摩羯','成都'),
('图图','INFJ',NULL,6,26,'巨蟹','射手','巨蟹','狮子','天秤','摩羯','河南'),
('黑黑','ENTP',NULL,6,29,'巨蟹','处女','巨蟹','双子','双子','天秤','重庆'),
('loui🥕','INFJ',NULL,8,7,'狮子','白羊','巨蟹','巨蟹','处女','摩羯','广州'),
('33','ENTP',NULL,8,15,'狮子','巨蟹','狮子','巨蟹','天秤','摩羯','成都'),
('何老师','INFJ',NULL,8,17,'狮子','双鱼','狮子','处女','狮子','摩羯','上海'),
('梦游','ENTP',NULL,8,19,'狮子','狮子','处女','巨蟹','射手','狮子','重庆'),
('浅浅','INFJ',NULL,8,22,'狮子','摩羯','狮子','狮子','天蝎','天秤','天津'),
('夕夏','INFJ',NULL,8,23,'狮子','水瓶','狮子','狮子','处女','天蝎','重庆'),
('南绛','INFJ',NULL,8,29,'处女','处女','处女','处女','狮子','摩羯','杭州/临沂'),
('十六','ENTP',NULL,9,29,'天秤','金牛','天秤','狮子','射手','射手','福州'),
('呱呱','INFJ',NULL,11,2,'天蝎','双鱼','天蝎','天蝎','处女','摩羯','衢州'),
('小四','INFJ',NULL,11,7,'天蝎','射手','天蝎','天蝎','天秤','白羊','北京'),
('阿尧','INFJ',NULL,11,20,'天蝎','金牛','射手','天蝎','天秤','处女','上海'),
('夜航星','ESTJ',NULL,12,10,'射手','白羊','摩羯','摩羯','摩羯','天秤','上海'),
('辣哦','ENTP',NULL,12,11,'射手','射手','摩羯','天蝎','处女','双鱼','米兰/国内随机刷新'),
('三两','ENTP',NULL,12,13,'射手','天秤','射手','摩羯','天秤','摩羯','深圳'),
('鳗鱼','ENTP',NULL,12,14,'射手','狮子','射手','水瓶','天秤','双鱼','上海'),
('阿玉','INFJ',NULL,12,27,'摩羯','巨蟹','摩羯','射手','处女','天蝎','辽宁'),
('Aaron','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('阿森','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('小哀','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('壁寺','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('信徒','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('柴犬','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('物理老师','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('挨个亲亲','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('大7','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('松鼠','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('蚊子哥','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('蝴蝶老太','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('晴天','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('奈何','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('燃枫','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('黑粉头子','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('雨老师','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('花子','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('4Y','INTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('美爷','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('胡子哥','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('李总','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('章鱼哥','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('老实人','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('ISFJ','ISFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('圆圆','ESFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('小紫','ISTJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('桃子',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('粥粥2号','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('小锅','INTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('不能打盹','INFP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('小枝','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('草莓','ENTP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('窝头','ENFP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('佳姐','INFJ',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

-- 删除全部旧成员以及事件与成员之间的旧关联。
truncate table public.event_members, public.members;

-- display_name 与 canonical_name 初始均使用表格中的成员名称。
-- avatar_url、description、current_status 等表格未提供的字段保持 NULL。
insert into public.members (
  display_name,
  canonical_name,
  mbti,
  birth_year,
  birth_month,
  birth_day,
  sun_sign,
  moon_sign,
  mercury_sign,
  venus_sign,
  mars_sign,
  rising_sign,
  city
)
select
  source_name,
  source_name,
  mbti,
  birth_year,
  birth_month,
  birth_day,
  sun_sign,
  moon_sign,
  mercury_sign,
  venus_sign,
  mars_sign,
  rising_sign,
  city
from member_profile_import;

-- SQL Editor 会返回本次覆盖后的资料，便于人工复核。
select m.canonical_name, m.display_name, m.mbti,
       m.birth_year, m.birth_month, m.birth_day,
       m.sun_sign, m.moon_sign, m.rising_sign,
       m.mercury_sign, m.venus_sign, m.mars_sign, m.city
from public.members m
order by m.birth_month nulls last, m.birth_day nulls last, m.display_name;

commit;
