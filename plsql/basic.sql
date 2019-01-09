BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'zzy005',
   job_type           =>  'EXECUTABLE', 
   job_action         =>  '/nfs/users/zhaozhan/test/plsql/test.sh',
   repeat_interval    =>  'FREQ=SECONDLY;BYSECOND=2', /* every other day */
   auto_drop          =>   FALSE,
   job_class          =>  'zzyclass1',
   comments           =>  'My new job');
END;
/
