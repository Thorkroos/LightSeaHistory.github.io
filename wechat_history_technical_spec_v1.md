# 微信群群史网站 V1 技术规格说明书

> 项目目标：开发一个托管在 GitHub Pages 的静态前端网站，用于长期记录微信群历史和重要事件。普通访客无需登录即可浏览；管理员通过 Supabase Auth 登录后，可在前端新增、修改、删除群史事件，并管理成员、分类和事件图片。
>
> 本文档用于直接交给 Codex 实现。除“待人工配置项”外，Codex 应按本文档完成可运行的 V1 项目，不应擅自增加超出范围的产品功能。

---

## 0. 实现原则

1. **前端静态托管**：GitHub Pages。
2. **后端能力全部使用 Supabase**：
   - Auth：管理员认证；
   - PostgreSQL：结构化数据；
   - Row Level Security（RLS）：访问控制；
   - Storage：事件图片/聊天截图。
3. **不自建服务器**，V1 不使用 Node/Express、Flask、PHP 等独立后端。
4. **所有写权限必须由 Supabase RLS 兜底**，不能仅依赖前端隐藏按钮。
5. **前端不得包含 Supabase service role key、数据库密码或其他高权限密钥**。
6. 数据量预计仅几十 MB，按小型、低并发、长期维护型网站设计，不做过度工程化。
7. 界面默认中文。
8. 网站默认名称可使用“光说不下海”，但必须集中配置，方便以后修改。

---

# 1. V1 功能范围

## 1.1 普通访客功能

### 1.1.1 首页

首页展示：

- 网站名称与简短简介；
- 最近发生的若干事件；
- 被标记为重要事件（featured）的若干事件；
- 进入完整时间线的入口；
- 进入成员列表的入口。

首页不要求复杂统计图表。

### 1.1.2 群史时间线

完整时间线按时间倒序或正序展示，默认建议最新在前，并提供排序切换。

必须支持：

- 按年份筛选；
- 按月份筛选；
- 按事件类型筛选；
- 按成员筛选；
- 按重要程度筛选；
- “只看重要事件”筛选；
- 点击事件进入事件详情页。

时间线需要兼容以下日期形式：

- 精确到日，例如 `2025-05-09`；
- 月初，例如 `2025 年 11 月初`；
- 月中；
- 月末，例如 `2025 年 6 月末`；
- 仅知道月份；
- 其他无法精确到具体日期的情况。

**禁止为了排序而把“6 月末”等信息伪造成真实的 6 月 30 日。**

### 1.1.3 搜索

支持关键字搜索：

- 事件标题；
- 事件摘要；
- 事件正文；
- 地点；
- 成员名称。

V1 可使用 PostgreSQL `ILIKE` 进行模糊搜索，不要求引入 Elasticsearch 或第三方搜索服务。

### 1.1.4 事件详情

事件详情页至少显示：

- 标题；
- 日期/日期描述；
- 事件类型；
- 涉及成员；
- 地点；
- 简短摘要；
- 详细正文；
- 重要程度；
- 是否为重要事件；
- 图片/聊天截图；
- 最后更新时间。

如果正文为空，应正常显示，不得报错。

### 1.1.5 成员列表

展示群史数据库中已有成员。

成员卡片至少可以显示：

- 当前显示名称；
- 头像（如有）；
- 简介（如有）；
- 当前状态（如有）。

### 1.1.6 成员详情

成员详情页显示：

- 当前名称；
- 头像；
- 简介；
- 当前状态；
- 该成员参与过的历史事件列表。

成员参与的事件通过 `event_members` 关联表查询，不允许将成员列表以逗号分隔字符串的方式存储在事件表中。

---

# 2. 管理员功能

## 2.1 登录

管理员使用：

- Email；
- Password。

通过 Supabase Auth 登录。

V1 **不提供用户注册页面**。

Supabase 项目应人工关闭公开 Sign Up，只保留已创建管理员登录。

登录成功后进入管理员后台。

## 2.2 管理后台首页

后台至少提供以下入口：

- 事件管理；
- 新增事件；
- 成员管理；
- 分类管理；
- 退出登录。

## 2.3 事件管理

事件列表支持：

- 搜索；
- 年份筛选；
- 类型筛选；
- 编辑；
- 删除；
- 查看 revision 历史。

## 2.4 新增事件

表单字段：

- 标题；
- 年；
- 月；
- 日；
- 日期精度；
- 自定义日期显示文本；
- 事件分类；
- 涉及成员（多选）；
- 成员在事件中的角色（可选）；
- 地点；
- 摘要；
- 正文；
- 重要程度 1–5；
- 是否 featured；
- 图片上传（0..N 张）。

## 2.5 修改事件

允许修改新增事件时的全部字段。

保存修改时必须写入 revision。

V1 revision 记录以下信息：

- 修改前事件主体字段；
- 修改前成员关联；
- 修改时间；
- 修改管理员；
- revision number。

V1 **不要求对图片二进制文件做历史版本管理**。

## 2.6 删除事件

- 删除前必须出现二次确认；
- 确认后删除数据库事件及其关联数据；
- 删除关联的 Storage 文件应尽最大可能同步执行；
- 如果 Storage 删除失败，不得阻止数据库层明确提示管理员处理残留文件。

V1 不要求实现回收站。

## 2.7 成员管理

管理员可以：

- 新增成员；
- 修改成员当前显示名称；
- 修改 canonical name；
- 修改头像；
- 修改简介；
- 修改当前状态；
- 删除没有被任何事件引用的成员。

如果成员已被事件引用，默认禁止直接删除，应提示先解除关联。

## 2.8 分类管理

管理员可以：

- 新增分类；
- 修改分类名称；
- 修改 icon；
- 修改排序；
- 删除未被事件使用的分类。

如果分类正在被事件引用，应禁止直接删除。

## 2.9 图片上传

图片存储于 Supabase Storage。

V1 实现规则：

- 一个事件支持 0..N 张图片；
- 支持 JPEG、PNG、WebP；
- 默认单文件最大 10 MB；
- Storage bucket：`event-media`；
- 路径：`events/{event_id}/{uuid}.{ext}`；
- 普通访客可读取；
- 只有管理员可以上传、删除。

图片元数据存储于 `event_images` 表，不把图片二进制写入 PostgreSQL。

---

# 3. 明确不在 V1 范围内的功能

Codex 不要擅自实现以下功能：

- 普通用户注册；
- 普通用户登录；
- 评论；
- 点赞；
- 标签系统；
- 草稿/发布工作流；
- 年度自动统计；
- 地图；
- 人物关系图；
- 独立 relationship 表；
- CP 关系自动维护；
- 历史昵称/alias 系统；
- 聊天记录自动导入；
- AI 自动摘要；
- AI 自动识别成员；
- 全文搜索引擎；
- 消息通知；
- 多级管理员权限；
- revision 一键回滚；
- revision 图片文件版本控制。

如未来需要，上述功能另行迭代。

---

# 4. 技术栈

## 4.1 前端

建议固定使用：

- React；
- Vite；
- TypeScript；
- React Router；
- Supabase JS Client；
- CSS Modules、普通 CSS 或轻量 Tailwind 均可，但不要引入大型 UI 框架作为硬依赖。

### 路由策略

因为部署在 GitHub Pages，V1 使用 `HashRouter`，避免刷新子路径产生 404。

示例：

- `/#/`
- `/#/timeline`
- `/#/events/:id`
- `/#/members`
- `/#/members/:id`
- `/#/admin/login`
- `/#/admin`

未来如迁移到支持 SPA fallback 的平台，再考虑 BrowserRouter。

## 4.2 后端能力

只使用 Supabase：

- Supabase Auth；
- Supabase PostgreSQL；
- Supabase RLS；
- Supabase Storage。

## 4.3 部署

- GitHub Repository；
- GitHub Actions；
- GitHub Pages。

Vite 建议设置相对路径 base，保证 project page 可运行。

---

# 5. 项目目录结构

Codex 应至少生成以下结构：

```text
wechat-history/
├─ .github/
│  └─ workflows/
│     └─ deploy.yml
├─ public/
│  └─ favicon.svg
├─ src/
│  ├─ app/
│  │  └─ router.tsx
│  ├─ components/
│  │  ├─ layout/
│  │  │  ├─ Header.tsx
│  │  │  ├─ Footer.tsx
│  │  │  └─ AdminLayout.tsx
│  │  ├─ events/
│  │  │  ├─ EventCard.tsx
│  │  │  ├─ TimelineItem.tsx
│  │  │  ├─ EventFilters.tsx
│  │  │  └─ EventImageGallery.tsx
│  │  ├─ members/
│  │  │  └─ MemberCard.tsx
│  │  └─ common/
│  │     ├─ Loading.tsx
│  │     ├─ EmptyState.tsx
│  │     ├─ ErrorState.tsx
│  │     └─ ConfirmDialog.tsx
│  ├─ pages/
│  │  ├─ HomePage.tsx
│  │  ├─ TimelinePage.tsx
│  │  ├─ EventDetailPage.tsx
│  │  ├─ MembersPage.tsx
│  │  ├─ MemberDetailPage.tsx
│  │  └─ admin/
│  │     ├─ AdminLoginPage.tsx
│  │     ├─ AdminDashboardPage.tsx
│  │     ├─ AdminEventsPage.tsx
│  │     ├─ AdminEventEditPage.tsx
│  │     ├─ AdminMembersPage.tsx
│  │     ├─ AdminCategoriesPage.tsx
│  │     └─ AdminRevisionsPage.tsx
│  ├─ hooks/
│  │  ├─ useAuth.ts
│  │  └─ useAdmin.ts
│  ├─ lib/
│  │  ├─ supabase.ts
│  │  ├─ auth.ts
│  │  ├─ dates.ts
│  │  └─ storage.ts
│  ├─ services/
│  │  ├─ eventService.ts
│  │  ├─ memberService.ts
│  │  ├─ categoryService.ts
│  │  └─ revisionService.ts
│  ├─ types/
│  │  └─ database.ts
│  ├─ styles/
│  │  └─ global.css
│  ├─ App.tsx
│  └─ main.tsx
├─ supabase/
│  ├─ migrations/
│  │  ├─ 001_schema.sql
│  │  ├─ 002_rls.sql
│  │  ├─ 003_functions.sql
│  │  └─ 004_seed_categories.sql
│  └─ README.md
├─ .env.example
├─ .gitignore
├─ index.html
├─ package.json
├─ tsconfig.json
├─ vite.config.ts
├─ README.md
└─ TECH_SPEC.md
```

Codex 可以适当调整文件拆分，但不得改变核心架构和职责边界。

---

# 6. 数据库设计

## 6.1 `profiles`

用途：补充 Supabase Auth 用户的应用角色。

```sql
profiles
- id uuid primary key references auth.users(id) on delete cascade
- role text not null default 'viewer'
- display_name text null
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()
```

V1 实际只创建 admin 用户。

约束：

```sql
role in ('admin', 'viewer')
```

普通访客并不需要 profiles 记录；`viewer` 仅为将来保留。

---

## 6.2 `event_categories`

```sql
event_categories
- id uuid primary key default gen_random_uuid()
- code text not null unique
- name text not null
- icon text null
- sort_order integer not null default 0
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()
```

V1 seed 分类：

```text
group_created          建群
member_join            进群
member_leave           退群
member_return          回群
member_removed         被踢
meetup                  面基
first_meeting           首次见面
relationship_start      恋爱 / 官宣
relationship_end        分手
hiatus                  闭关
hiatus_end              闭关结束
group_activity          群活动
other                   其他事件
```

分类 `code` 作为稳定标识；UI 显示 `name`。

---

## 6.3 `members`

```sql
members
- id uuid primary key default gen_random_uuid()
- display_name text not null
- canonical_name text not null unique
- avatar_url text null
- description text null
- current_status text null
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()
```

说明：

- `display_name`：当前展示昵称；
- `canonical_name`：数据库稳定识别名；
- V1 不实现 alias/history name 表。

---

## 6.4 `events`

```sql
events
- id uuid primary key default gen_random_uuid()
- title text not null
- event_year integer not null
- event_month integer null
- event_day integer null
- date_precision text not null default 'day'
- date_text text null
- category_id uuid not null references event_categories(id)
- summary text not null default ''
- content text null
- location text null
- importance smallint not null default 1
- is_featured boolean not null default false
- created_at timestamptz not null default now()
- updated_at timestamptz not null default now()
- created_by uuid null references auth.users(id)
- updated_by uuid null references auth.users(id)
```

约束：

```text
1900 <= event_year <= 2200
1 <= event_month <= 12 或 NULL
1 <= event_day <= 31 或 NULL
1 <= importance <= 5
```

`date_precision` V1 允许：

```text
day
month
early_month
mid_month
late_month
year
unknown
```

规则：

- `day`：year/month/day 均应存在；
- `month`：year/month 存在，day = NULL；
- `early_month`、`mid_month`、`late_month`：year/month 存在，day = NULL；
- `year`：仅 year；
- `unknown`：至少 year 可用；
- `date_text` 保存管理员希望显示的原始表达，如 `6月末`、`11月初`。

### 时间排序

排序可以使用逻辑排序值，但这个值只用于 UI 排序，不能显示成事实日期。

建议前端排序位置：

```text
exact day        -> event_day
month/unknown    -> 15
early_month      -> 5
mid_month        -> 15
late_month       -> 28
```

以上数字只是显示排序权重，不得渲染成具体日期。

---

## 6.5 `event_members`

多对多关联。

```sql
event_members
- id uuid primary key default gen_random_uuid()
- event_id uuid not null references events(id) on delete cascade
- member_id uuid not null references members(id) on delete restrict
- role text null
- note text null
- created_at timestamptz not null default now()
```

唯一约束：

```sql
unique(event_id, member_id)
```

`role` 示例：

```text
participant
subject
organizer
partner
other
```

V1 不强制枚举；可为 NULL。

---

## 6.6 `event_images`

```sql
event_images
- id uuid primary key default gen_random_uuid()
- event_id uuid not null references events(id) on delete cascade
- storage_path text not null unique
- caption text null
- sort_order integer not null default 0
- uploaded_by uuid null references auth.users(id)
- created_at timestamptz not null default now()
```

不要永久存储签名 URL。

若 bucket 为 public，前端通过 `storage_path` 生成 public URL。

---

## 6.7 `event_revisions`

采用 JSONB snapshot，避免未来事件字段变化时频繁改 revision schema。

```sql
event_revisions
- id uuid primary key default gen_random_uuid()
- event_id uuid not null references events(id) on delete cascade
- revision_number integer not null
- snapshot jsonb not null
- edited_by uuid null references auth.users(id)
- edited_at timestamptz not null default now()
```

唯一约束：

```sql
unique(event_id, revision_number)
```

`snapshot` 至少包含：

```json
{
  "event": {
    "title": "...",
    "event_year": 2025,
    "event_month": 8,
    "event_day": 17,
    "date_precision": "day",
    "date_text": "8.17",
    "category_id": "uuid",
    "summary": "...",
    "content": "...",
    "location": "杭州",
    "importance": 2,
    "is_featured": false
  },
  "members": [
    {
      "member_id": "uuid",
      "role": "participant",
      "note": null
    }
  ]
}
```

V1 revision 不需要保存图片文件历史。

---

# 7. 数据库索引

至少建立：

```sql
create index idx_events_year on events(event_year);
create index idx_events_month on events(event_month);
create index idx_events_category on events(category_id);
create index idx_events_featured on events(is_featured);
create index idx_events_importance on events(importance);
create index idx_event_members_event on event_members(event_id);
create index idx_event_members_member on event_members(member_id);
create index idx_event_images_event on event_images(event_id);
create index idx_event_revisions_event on event_revisions(event_id);
```

V1 不要求复杂全文索引。

---

# 8. Supabase Auth 与管理员权限

## 8.1 登录流程

```text
Admin Login Page
      ↓
supabase.auth.signInWithPassword()
      ↓
Supabase Auth 验证
      ↓
获得 session / JWT
      ↓
查询 profiles.id = auth user id
      ↓
role == 'admin'
      ↓
进入后台
```

前端 `AdminGuard` 必须处理：

- session 不存在 -> 跳转登录页；
- session 存在但 profile 不是 admin -> 显示无权限并退出后台；
- session 正常且 admin -> 渲染后台。

但前端 AdminGuard 只是 UX，真正权限由 RLS 实现。

---

# 9. RLS 安全策略

所有 public schema 业务表必须开启 RLS。

## 9.1 管理员判断函数

建议创建一个 SQL helper：

```sql
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;
```

应合理设置函数 owner / execute 权限，避免客户端任意绕过。

## 9.2 `events`

- SELECT：所有人允许；
- INSERT：仅 admin；
- UPDATE：仅 admin；
- DELETE：仅 admin。

## 9.3 `members`

- SELECT：所有人允许；
- INSERT/UPDATE/DELETE：仅 admin。

## 9.4 `event_categories`

- SELECT：所有人允许；
- INSERT/UPDATE/DELETE：仅 admin。

## 9.5 `event_members`

- SELECT：所有人允许；
- INSERT/UPDATE/DELETE：仅 admin。

## 9.6 `event_images`

- SELECT：所有人允许；
- INSERT/UPDATE/DELETE：仅 admin。

## 9.7 `event_revisions`

默认：

- SELECT：仅 admin；
- INSERT：仅 admin；
- UPDATE：禁止；
- DELETE：仅 admin 或直接禁止手工删除。

V1 public 前台不展示 revision 历史。

## 9.8 `profiles`

- 用户可以 SELECT 自己的 profile；
- admin 可以 SELECT 必要 profile；
- 客户端不得任意把自己 role 改为 admin；
- role 的设置由 Supabase Dashboard / SQL 管理操作完成。

---

# 10. Storage 安全策略

Bucket：

```text
event-media
```

V1 可设置为 public bucket，以简化普通访客图片访问。

写操作仍必须受 Storage policy 控制。

规则：

- public read；
- admin insert；
- admin update；
- admin delete。

禁止使用 service role key 在浏览器上传。

---

# 11. Revision 保存流程

为减少“先改数据、后写 revision”导致旧版本丢失的风险，建议实现 Supabase PostgreSQL RPC。

函数概念：

```text
save_event(payload jsonb)
```

### 新增事件

1. 检查 `is_admin()`；
2. INSERT events；
3. INSERT event_members；
4. 返回 event id。

新增事件不需要创建 revision 0。

### 修改事件

在同一个数据库事务内：

1. 检查 `is_admin()`；
2. 查询当前 event；
3. 查询当前 event_members；
4. 计算下一个 revision_number；
5. 把旧状态写入 event_revisions.snapshot；
6. UPDATE events；
7. 替换 event_members；
8. 返回更新后的 event。

图片上传/删除可在 RPC 外处理；V1 revision 不保证图片回滚。

Codex 如果能以数据库 trigger + transaction 实现同等语义也可以，但最终必须保证“修改前的事件主体和成员关系”被保存。

---

# 12. 前端数据访问

## 12.1 Public event list

列表查询不要默认把完整正文和所有图片一次性下载。

事件列表建议只取：

```text
id
title
event_year
event_month
event_day
date_precision
date_text
summary
location
importance
is_featured
category
members
updated_at
```

正文和完整图片列表在详情页按需加载。

## 12.2 Pagination

虽然数据量不大，仍建议事件列表分页。

默认：

```text
pageSize = 50
```

## 12.3 Search

搜索行为：

1. 对 events 的 title/summary/content/location 使用 `ILIKE`；
2. 同时搜索 members.display_name / canonical_name；
3. 将匹配成员关联到的 event id 并入结果；
4. 去重；
5. 再应用年份、分类、重要程度等过滤条件。

对于 V1 数据量，可以接受简单多查询实现。

---

# 13. 日期展示工具

创建统一函数，例如：

```ts
formatEventDate(event): string
```

展示优先级：

1. `date_text` 非空 -> 优先使用其表达；
2. 否则根据 `date_precision` 和 year/month/day 生成；
3. 不允许把 approximate date 伪装成精确日期。

示例：

```text
2025 + 5 + 9 + day -> 2025 年 5 月 9 日
2025 + 6 + null + late_month -> 2025 年 6 月末
2025 + 11 + null + early_month -> 2025 年 11 月初
```

---

# 14. 页面详细要求

## 14.1 `/`

HomePage：

- Header；
- 简介；
- 最近事件；
- featured 事件；
- “查看完整群史”按钮；
- Footer。

## 14.2 `/timeline`

TimelinePage：

- 搜索框；
- 年份过滤；
- 月份过滤；
- 分类过滤；
- 成员过滤；
- importance 过滤；
- featured only 开关；
- 排序开关；
- 时间线列表；
- loading / empty / error state。

## 14.3 `/events/:id`

EventDetailPage：

- 日期；
- category；
- title；
- summary；
- content；
- location；
- members；
- importance；
- images gallery；
- updated_at。

## 14.4 `/members`

MembersPage：

- 成员搜索；
- member card grid/list。

## 14.5 `/members/:id`

MemberDetailPage：

- member metadata；
- 参与事件列表。

## 14.6 `/admin/login`

AdminLoginPage：

- Email；
- Password；
- 登录按钮；
- 错误提示；
- 已登录自动跳转 `/admin`。

禁止注册入口。

## 14.7 `/admin`

Dashboard：

- 事件总数；
- 成员总数；
- 最近修改事件；
- 快捷新增事件。

简单即可，不做复杂统计。

## 14.8 `/admin/events`

- admin event table；
- 搜索 / filter；
- 新增；
- 编辑；
- 删除；
- revisions。

## 14.9 `/admin/events/new`

与 edit 共用 EventForm。

## 14.10 `/admin/events/:id/edit`

- 加载现有事件；
- 编辑；
- 保存；
- 图片上传 / 删除 / 排序；
- 成员多选。

## 14.11 `/admin/events/:id/revisions`

- revision number；
- edited_at；
- edited_by；
- 查看 snapshot；
- V1 不提供 restore 按钮。

## 14.12 `/admin/members`

CRUD。

## 14.13 `/admin/categories`

CRUD + sort_order。

---

# 15. UI / UX

设计目标：

- 简洁；
- 以内容阅读为主；
- 不做过度炫技动画；
- 手机和桌面均可使用；
- 时间线要有明显年份/月分组；
- 管理后台以效率优先。

最低响应式断点：

- mobile `< 768px`；
- desktop `>= 768px`。

管理员表单在手机端也必须可操作。

重要事件可以视觉上突出，但不要用过度复杂的动效。

---

# 16. 状态与错误处理

所有数据页面必须有：

- Loading；
- Empty；
- Error。

管理员写操作必须：

- 按钮提交期间 disabled；
- 防止重复提交；
- 成功后 toast/message；
- 失败时显示可理解的错误信息；
- 不直接把原始数据库异常栈展示给普通用户。

---

# 17. 环境变量

`.env.example`：

```bash
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
```

说明：

- anon/publishable key 可以用于浏览器；
- service role key **不得**写入前端 `.env`；
- `.env` 加入 `.gitignore`；
- GitHub Actions 使用 GitHub Repository Secrets/Variables 注入构建环境变量。

---

# 18. GitHub Pages 部署

需要生成 `.github/workflows/deploy.yml`。

流程：

```text
push main
  ↓
npm ci
  ↓
npm run build
  ↓
upload pages artifact
  ↓
deploy GitHub Pages
```

Vite 配置要保证 GitHub Project Pages 能加载静态资源。

推荐：

```ts
base: './'
```

由于使用 HashRouter，不依赖服务器端 SPA fallback。

---

# 19. README 必须写清楚的人工步骤

Codex 需要在 README 中明确告诉维护者：

## 19.1 Supabase

1. 注册/登录 Supabase；
2. 新建 project；
3. 执行 `supabase/migrations` 中 SQL；
4. 创建 Storage bucket `event-media`；
5. 应用 Storage policies；
6. Auth 中关闭 public sign up；
7. 在 Authentication Users 中创建管理员账号；
8. 把管理员用户 UUID 插入 `profiles` 并设置 `role='admin'`；
9. 获取 Project URL；
10. 获取 anon/publishable key。

## 19.2 Local

```bash
npm install
cp .env.example .env
npm run dev
```

## 19.3 GitHub

1. push repository；
2. 设置 Pages source 为 GitHub Actions；
3. 配置构建所需环境变量；
4. push main；
5. 检查 Pages deployment。

---

# 20. 初始分类 Seed

Codex 应生成 SQL seed：

```sql
insert into public.event_categories (code, name, icon, sort_order)
values
('group_created', '建群', '🏠', 10),
('member_join', '进群', '➕', 20),
('member_leave', '退群', '🚪', 30),
('member_return', '回群', '↩️', 40),
('member_removed', '被踢', '⛔', 50),
('meetup', '面基', '📍', 60),
('first_meeting', '首次见面', '🤝', 70),
('relationship_start', '恋爱 / 官宣', '❤️', 80),
('relationship_end', '分手', '💔', 90),
('hiatus', '闭关', '🌙', 100),
('hiatus_end', '闭关结束', '☀️', 110),
('group_activity', '群活动', '🎉', 120),
('other', '其他事件', '📌', 999)
on conflict (code) do nothing;
```

图标属于 UI 默认值，后台可修改。

---

# 21. 测试要求

至少覆盖以下逻辑：

## 21.1 Public

- 未登录能访问首页；
- 未登录能查看 timeline；
- 未登录能查看 event detail；
- 未登录能查看 members；
- 未登录不能写数据库；
- 搜索正常；
- 筛选正常；
- approximate date 显示正确。

## 21.2 Auth

- 正确管理员可以登录；
- 错误密码显示错误；
- 非 admin session 不能进入后台；
- logout 后后台失效。

## 21.3 Admin CRUD

- 新建事件成功；
- 新建多成员事件成功；
- 编辑事件成功；
- 编辑前状态写入 revision；
- 删除事件有二次确认；
- 新增成员成功；
- 编辑成员成功；
- 被引用成员不能直接删除；
- 分类 CRUD 约束正确；
- 图片上传成功；
- 图片删除成功。

## 21.4 Security

直接使用 anon key 模拟未登录请求：

- INSERT events -> 必须失败；
- UPDATE events -> 必须失败；
- DELETE events -> 必须失败；
- INSERT members -> 必须失败；
- 上传 Storage -> 必须失败。

admin JWT 对应操作应成功。

---

# 22. 验收标准

V1 完成必须同时满足：

1. `npm install && npm run dev` 可启动；
2. `npm run build` 成功；
3. GitHub Pages 可部署；
4. 普通访客无需账号即可浏览；
5. 普通访客无法写数据库；
6. 管理员可以登录；
7. 管理员可以新增事件；
8. 管理员可以编辑事件；
9. 管理员可以删除事件；
10. 一个事件支持多成员；
11. 一个事件支持多图片；
12. 管理员可以管理成员；
13. 管理员可以管理分类；
14. 可以处理“6 月末”“11 月初”等非精确日期；
15. 修改事件前能保存 revision；
16. timeline 支持搜索和筛选；
17. 成员详情可以显示其参与事件；
18. 手机端可正常浏览和编辑；
19. 前端代码中没有 service role key；
20. 所有写权限由 RLS 控制。

---

# 23. Codex 实现顺序

请严格按照以下顺序完成：

### Phase 1 — Scaffold

- Vite + React + TypeScript；
- Router；
- basic layout；
- Supabase client；
- env config。

### Phase 2 — Supabase

- schema migration；
- indexes；
- RLS；
- helper functions；
- seed categories；
- Storage policy documentation。

### Phase 3 — Public pages

- Home；
- Timeline；
- Search/filters；
- Event detail；
- Member list/detail。

### Phase 4 — Auth

- Admin login；
- AuthProvider；
- AdminGuard；
- Logout。

### Phase 5 — Admin CRUD

- Events；
- Members；
- Categories；
- Image upload。

### Phase 6 — Revision

- save_event RPC / transactional equivalent；
- revision list/detail。

### Phase 7 — Deployment

- GitHub Actions；
- Pages config；
- README setup guide。

### Phase 8 — QA

- build；
- lint；
- manual test checklist；
- security verification。

---

# 24. Codex 输出要求

Codex 最终应输出一个完整可运行 repository，而不是只给代码片段。

必须包括：

- 所有 React 源代码；
- SQL migrations；
- RLS policies；
- Storage setup 说明；
- `.env.example`；
- GitHub Actions workflow；
- README；
- package.json；
- 可成功 build 的项目。

如果某一步需要 Supabase Dashboard 人工操作，必须在 README 中明确列出，不允许静默假设已经完成。

不要硬编码管理员邮箱、密码、Supabase URL 或 key。

---

# 25. 当前数据模型对应的真实群史结构

当前已有群史表现出以下稳定结构，因此 V1 数据模型必须支持：

- 一个事件可能只有一个成员；
- 一个事件可能同时涉及很多成员；
- 同一个成员会多次参与不同事件；
- 事件包含进群、退群、回群、被踢、面基、恋爱/官宣、分手、闭关等类别；
- 地点是常见属性；
- 日期有精确日期，也有“月初/月末”等模糊时间；
- 后续年份继续沿用同一套数据结构。

因此核心关系固定为：

```text
Auth User
   │
   └── profiles

Event ───────── Category
  │
  ├──< event_members >── Member
  │
  ├──< event_images
  │
  └──< event_revisions
```

这是 V1 的最终核心数据模型。

---

# 26. 完成后的最小用户流程

## 普通访客

```text
打开 GitHub Pages
    ↓
首页
    ↓
查看 Timeline
    ↓
搜索 / 筛选
    ↓
打开事件详情
    ↓
点击成员
    ↓
查看成员历史
```

## 管理员

```text
打开 /#/admin/login
    ↓
Email + Password
    ↓
Supabase Auth
    ↓
确认 profiles.role = admin
    ↓
Dashboard
    ↓
新增 / 修改 / 删除事件
    ↓
Supabase PostgreSQL
    ↓
前台刷新后显示最新数据
```

---

# 27. 非功能要求

- 代码应可维护，不把所有逻辑写在一个组件；
- TypeScript 避免滥用 `any`；
- 表单输入做前端基本校验；
- 数据库继续做约束校验；
- 使用 async error handling；
- 不静默吞掉错误；
- 不在 console 输出密码/token；
- 图片必须有合理 alt/caption fallback；
- 页面 title 应根据内容变化；
- 不要求 SEO 深度优化；
- 不要求 SSR；
- 不要求 PWA。

---

# 28. 最终说明

V1 的核心目标不是做社交平台，而是完成一套稳定的“群史 CMS”：

```text
公开浏览
+
时间线
+
人物关联
+
搜索筛选
+
管理员认证
+
前端内容编辑
+
图片存储
+
修改历史
+
GitHub Pages 静态部署
```

在此基础上，后续版本才考虑年度统计、地图、关系图、标签、聊天记录导入等扩展功能。
