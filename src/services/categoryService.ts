import {supabase} from '../lib/supabase';import type {Category} from '../types/database';
export async function listCategories(){const {data,error}=await supabase.from('event_categories').select('*').order('sort_order');if(error)throw error;return data as Category[]}
export async function saveCategory(v:Omit<Category,'id'>,id?:string){const q=id?supabase.from('event_categories').update(v).eq('id',id):supabase.from('event_categories').insert(v);const {error}=await q;if(error)throw error}
export async function deleteCategory(id:string){const refs=await supabase.from('events').select('id',{count:'exact',head:true}).eq('category_id',id);if(refs.count)throw new Error('该分类正在被事件使用，不能删除。');const {error}=await supabase.from('event_categories').delete().eq('id',id);if(error)throw error}
