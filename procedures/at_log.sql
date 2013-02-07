CREATE OR REPLACE PROCEDURE at_log (log_msg VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO at_log
              (
                  log_id
                , log_timestamp
                , log_message
              )
     VALUES
              (
                  at_log_seq.NEXTVAL
                , SYSTIMESTAMP
                , log_msg
              );

   COMMIT;
END;
/