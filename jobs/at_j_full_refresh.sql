/* Formatted on 2013/02/08 2:54:56 AM (QP5 v5.126.903.23003) */
DECLARE
   x   NUMBER;
BEGIN
   sys.DBMS_JOB.submit
   (
      job         => x
    , what        => 'begin for stock in (select * from at_stock) loop at_p_hist_price_refresh_full(stock.ticker, 120); end loop; end;'
    , next_date   => SYSDATE
    , interval    => 'TRUNC(SYSDATE+1)'
    , no_parse    => FALSE
   );
   sys.DBMS_OUTPUT.put_line ('Job Number is: ' || TO_CHAR (x));
   COMMIT;
END;
/