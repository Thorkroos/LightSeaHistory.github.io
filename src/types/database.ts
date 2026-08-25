export type DatePrecision='day'|'month'|'early_month'|'mid_month'|'late_month'|'year'|'unknown';
export interface Category {id:string;code:string;name:string;icon:string|null;sort_order:number}
export interface Member {id:string;display_name:string;canonical_name:string;avatar_url:string|null;description:string|null;current_status:string|null;created_at?:string;updated_at?:string}
export interface EventMember {id?:string;member_id:string;role:string|null;note:string|null;member?:Member}
export interface EventImage {id:string;event_id:string;storage_path:string;caption:string|null;sort_order:number;created_at:string}
export interface HistoryEvent {id:string;title:string;event_year:number;event_month:number|null;event_day:number|null;date_precision:DatePrecision;date_text:string|null;category_id:string;summary:string;content:string|null;location:string|null;importance:number;is_featured:boolean;created_at:string;updated_at:string;category?:Category;event_members?:EventMember[];event_images?:EventImage[]}
export interface EventFormValue extends Omit<HistoryEvent,'id'|'created_at'|'updated_at'|'category'|'event_members'|'event_images'> {members:{member_id:string;role:string|null;note:string|null}[]}
export interface Revision {id:string;event_id:string;revision_number:number;snapshot:Record<string,unknown>;edited_by:string|null;edited_at:string}
export interface EventFilters {query:string;year:string;month:string;categoryId:string;memberId:string;importance:string;featured:boolean;ascending:boolean}
