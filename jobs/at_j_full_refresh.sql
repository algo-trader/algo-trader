/* Formatted on 2013/02/08 2:54:56 AM (QP5 v5.126.903.23003) */
DECLARE
   x   NUMBER;
BEGIN
   sys.DBMS_JOB.submit
   (
      job         => x
    , what        => 'begin at_p_hist_price_refresh_full(120); end;'
    , next_date   => SYSDATE
    , interval    => 'TRUNC(SYSDATE+7)'
    , no_parse    => FALSE
   );
   sys.DBMS_OUTPUT.put_line ('Job Number is: ' || TO_CHAR (x));
   COMMIT;
END;
/