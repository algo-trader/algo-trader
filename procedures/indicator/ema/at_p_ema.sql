/* Formatted on 2013/02/19 9:55:23 PM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE at_p_ema
(
   v_ticker      VARCHAR2
 , v_smooth_n    INTEGER
)
IS
   v_indicator_name   VARCHAR2 (1000) := 'EMA(' || v_smooth_n || ')';
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
      SELECT   ticker
             , day_seq
             , v_indicator_name
             , 'EMA'
             , ema
        FROM   at_hist_price
       WHERE   ticker = v_ticker
      MODEL
         PARTITION BY (ticker)
         DIMENSION BY (day_seq)
         MEASURES (close, 0 ema)

            (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_smooth_n * (close[CV ()] - ema[CV () - 1]), close[CV ()]));

   COMMIT;
END;