/* Formatted on 2013/02/08 2:34:15 AM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE at_p_log (log_msg VARCHAR2)
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