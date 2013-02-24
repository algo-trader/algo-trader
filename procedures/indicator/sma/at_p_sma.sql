/* Formatted on 2013/02/24 1:26:12 PM (QP5 v5.126.903.23003) */
set define off

CREATE OR REPLACE PROCEDURE at_p_sma
(
   v_ticker    VARCHAR2
 , v_period    INTEGER
)
IS
   v_indicator_name   VARCHAR2 (1000) := 'SMA(' || v_period || ')';
BEGIN
   DELETE FROM   at_indicator_value
         WHERE   ticker = v_ticker
                 AND indicator_name = v_indicator_name;

   INSERT INTO at_indicator_value
              (
                  ticker
                , day_seq
                , indicator_name
                , indicator_key
                , indicator_value
              )
        SELECT   curr.ticker
               , curr.day_seq
               , v_indicator_name
               , 'SMA'
               , AVG (r.close)
          FROM   at_hist_price curr
               , at_hist_price r
         WHERE       curr.ticker = v_ticker
                 AND curr.ticker = r.ticker
                 AND r.day_seq BETWEEN curr.day_seq - v_period + 1 AND curr.day_seq
      GROUP BY   curr.ticker
               , curr.day_seq;

   COMMIT;
END;