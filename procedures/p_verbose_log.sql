/* Formatted on 2013/02/08 12:45:25 AM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE p_verbose_log (log_msg VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO verbose_logs
              (
                  log_id
                , log_timestamp
                , log_message
              )
     VALUES
              (
                  verbose_logs_seq.NEXTVAL
                , SYSTIMESTAMP
                , log_msg
              );

   COMMIT;
END;
/