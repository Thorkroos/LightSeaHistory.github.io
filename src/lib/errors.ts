type DatabaseError={message?:string;code?:string;details?:string;hint?:string};

const fieldNames:Record<string,string>={
  canonical_name:'固定称呼',display_name:'显示名称',code:'分类代码',name:'分类名称',
  members_canonical_name_key:'固定称呼',event_categories_code_key:'分类代码',
  events_category_id_fkey:'事件分类',event_members_member_id_fkey:'关联成员'
};

export function friendlyError(error:unknown,action='保存'):string{
  if(error instanceof Error&&!('code' in error))return error.message;
  const e=error as DatabaseError;
  const raw=[e.message,e.details,e.hint].filter(Boolean).join(' ');
  const field=Object.entries(fieldNames).find(([key])=>raw.includes(key))?.[1];
  if(e.code==='23505')return `${field||'要求唯一的字段'}已经存在，请换一个值后重试。`;
  if(e.code==='23503')return `${field||'该记录'}仍被其他数据引用，不能直接删除或修改。`;
  if(e.code==='23514')return '输入内容不符合限制，请检查年份、月份、日期精度或数值范围。';
  if(e.code==='23502')return `${field||'必填字段'}不能为空，请补充后重试。`;
  if(e.code==='42501'||raw.toLowerCase().includes('permission'))return '当前账号没有执行此操作的权限，请重新登录管理员账号。';
  if(e.code==='PGRST204'||raw.includes('column'))return '数据库结构尚未更新，请先执行最新的 Supabase migration。';
  if(raw.toLowerCase().includes('failed to fetch'))return '无法连接 Supabase，请检查网络和环境变量配置。';
  return `${action}失败：${e.message||'请检查输入内容或稍后重试。'}`;
}
