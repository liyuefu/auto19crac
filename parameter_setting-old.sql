--for RAC, 内存大于100G的, ref: Doc ID 1619155.1
--Set shared_pool_size to 15% or larger of the total SGA size.
--Set _gc_policy_minimum to 15000
--检查aio

COL NAME FORMAT A50

SELECT NAME,ASYNCH_IO FROM V$DATAFILE F,V$IOSTAT_FILE I

WHERE F.FILE#=I.FILE_NO

AND FILETYPE_NAME='Data File';

--启用aio

alter system set filesystemio_options=setall scope=spfile;

 

--设置密码不过期

alter profile default limit PASSWORD_LIFE_TIME unlimited;

--禁用自动任务

begin

dbms_auto_task_admin.disable(client_name=>'sql tuning advisor',operation=>NULL,window_name=>NULL);

end;

/

begin

dbms_auto_task_admin.disable(client_name=>'auto space advisor',operation=>NULL,window_name=>NULL);

end;

/

 

begin

dbms_auto_task_admin.disable(client_name=>'auto optimizer stats collection',operation=>NULL,window_name=>NULL);

end;

 

/

select client_name, status from dba_autotask_client;

 

--rac

alter system set "_gc_policy_time"=0 scope=spfile sid='*';

alter system set "_gc_undo_affinity"=false scope=spfile sid='*';

 

 

--其它

alter system set deferred_segment_creation=false scope=spfile sid='*';

alter system set audit_trail=none scope=spfile sid='*';

alter system set aq_tm_processes=10 scope=spfile sid='*';

alter system set open_cursors=3000 scope=spfile sid='*';

alter system set fast_start_mttr_target=900 scope=spfile sid='*';

alter system set db_flashback_retention_target=10800 scope=spfile sid='*';

alter system set undo_retention=10800 scope=spfile sid='*';

alter system set optimizer_capture_sql_plan_baselines=false scope=spfile sid='*';

alter system set "_optim_peek_user_binds"=false scope=spfile sid='*';

alter system set "_optimizer_extended_cursor_sharing_rel"=none scope=spfile sid='*';

alter system set "_optimizer_extended_cursor_sharing"=none scope=spfile sid='*';

alter system set "_optimizer_adaptive_cursor_sharing"=false scope=spfile sid='*';

alter system set "_in_memory_undo"=false scope=spfile sid='*';

alter system set "_memory_imm_mode_without_autosga"=false scope=spfile sid='*';

alter system set "_b_tree_bitmap_plans"=false scope=spfile sid='*';

alter system set db_securefile='NEVER' scope=spfile sid='*';

alter system set "_gc_policy_time"=0 scope=spfile sid='*';

alter system set result_cache_mode='MANUAL' scope=spfile sid='*';

alter system set optimizer_capture_sql_plan_baselines=false scope=spfile sid='*';

 

 

 

--重启

host srvctl stop database -d orcl

host srvctl start database -d orcl

--检查aio

conn / as sysdba

COL NAME FORMAT A50

SELECT NAME,ASYNCH_IO FROM V$DATAFILE F,V$IOSTAT_FILE I

WHERE F.FILE#=I.FILE_NO

AND FILETYPE_NAME='Data File';
