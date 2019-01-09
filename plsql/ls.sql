begin
 DBMS_SCHEDULER.CREATE_JOB(
  job_name            => 'lsdir005',
  job_type            => 'EXECUTABLE',
  job_action          => '/bin/ls',
  number_of_arguments => 1,
  enabled             => false,
  auto_drop           => false,
  credential_name     => 'my_cred');
 DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('lsdir005',1,'/tmp');
 DBMS_SCHEDULER.ENABLE('lsdir005');
end;
/
