# Nice to meeT · 群史

基于 React、TypeScript、Vite 与 Supabase 的静态群史 CMS。公开访客可以浏览时间线、事件和成员；管理员通过 Supabase Auth 登录后维护内容。前端使用 HashRouter，可直接部署到 GitHub Pages。

## 本地启动

需要 Node.js 20 或更高版本。

```bash
npm install
copy .env.example .env
npm run dev
```

在 `.env` 填入：

```text
VITE_SUPABASE_URL=你的 Project URL
VITE_SUPABASE_ANON_KEY=你的 anon/publishable key
```

不要在前端或 GitHub 仓库中放置 service role key、数据库密码或管理员密码。

## Supabase 人工配置

1. 创建 Supabase Project。
2. 在 SQL Editor 中按文件名顺序执行 `supabase/migrations/001_schema.sql` 至 `004_seed_categories.sql`。迁移会创建表、索引、约束、RLS、事务性 `save_event` RPC、公开 `event-media` bucket 及其 Storage policies。
3. 在 Authentication → Providers → Email 中关闭公开注册。V1 没有注册入口。
4. 在 Authentication → Users 中手工创建管理员账号。
5. 复制该用户 UUID，在 SQL Editor 中执行：

```sql
insert into public.profiles (id, role, display_name)
values ('管理员用户 UUID', 'admin', '管理员');
```

6. 从 Project Settings → API 取得 Project URL 与 anon/publishable key，写入本地 `.env`。
7. 确认 Storage 中存在公开 bucket `event-media`。迁移通常会自动创建；如果当前项目限制 SQL 创建 bucket，请手工创建同名 public bucket，限制 JPEG/PNG/WebP、单文件 10 MB，再重新执行 `002_rls.sql` 中四条 `storage.objects` policy。

### 已有项目升级成员资料字段

如果数据库已经执行过 `001`—`004`，不需要重建数据库。只需在 Supabase SQL Editor 执行：

```text
supabase/migrations/005_member_profile_fields.sql
```

该迁移为 `members` 增加 MBTI、出生年份、出生月份、太阳、月亮、上升、水星、金星和火星星座字段，并添加 MBTI、年份和月份约束。现有成员数据不会被删除，新字段初始均为 `NULL`。

## 数据与安全

- 所有业务表均启用 RLS；匿名访客仅有公开业务表 SELECT 权限。
- `profiles` 仅本人或管理员可读，revision 仅管理员可读写。
- 事件新增/编辑通过 `save_event(jsonb)` 在单一数据库事务中完成。编辑前会保存事件主体和成员关系 JSONB snapshot。
- 图片存储路径为 `events/{event_id}/{uuid}.{ext}`；数据库只存路径，不存二进制和永久签名 URL。
- 删除事件时前端先尝试清理 Storage；Storage 失败会明确提示残留文件，数据库删除仍会继续。

建议配置完成后，用未登录的 anon 客户端验证 events/members 的 INSERT、UPDATE、DELETE 与 Storage upload 均被 RLS 拒绝，再以管理员登录验证 CRUD。

## 构建与部署

```bash
npm run build
```

GitHub Pages：

1. 推送仓库，在 Settings → Pages 将 Source 设为 GitHub Actions。
2. 在 Settings → Secrets and variables → Actions 中添加 Repository Variable `VITE_SUPABASE_URL`。
3. 添加 Repository Secret `VITE_SUPABASE_ANON_KEY`。
4. 推送 `main`，工作流会执行 `npm ci`、构建并发布 `dist`。

Vite 使用相对 `base`，路由使用 HashRouter，因此 Project Pages 子路径和刷新子页面都可工作。

## V1 验收清单

- 匿名浏览：首页、时间线搜索/筛选、事件详情、成员及其参与事件。
- 日期：精确日、仅月、月初/月中/月末、仅年和未知日期不会被伪造成具体日。
- 管理：登录/退出；事件新增、编辑、双重确认删除、revision；成员和分类 CRUD；多成员和多图片。
- 异常：数据页均有 loading/empty/error，提交期间禁用，移动端可浏览与编辑。
- 部署：`npm run build` 成功，Pages Actions 使用仓库变量/密钥。

原始开发文档见 `wechat_history_technical_spec_v1.md`。
