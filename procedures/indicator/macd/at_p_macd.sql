/* Formatted on 2013/02/19 7:51:21 PM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE at_p_macd
(
   v_ticker      VARCHAR2
 , v_ema_1_n     INTEGER
 , v_ema_2_n     INTEGER
 , v_signal_n    INTEGER
)
IS
BEGIN
   EXECUTE IMMEDIATE ('truncate table at_macd_temp');

   INSERT INTO at_macd_temp
              (
                  ticker
                , day_seq
                , ema_1
                , ema_2
              )
      SELECT   ema_1.ticker
             , ema_1.day_seq
             , ema_1.ema ema_12
             , ema_2.ema ema_26
        FROM   (SELECT   ticker
                       , day_seq
                       , close
                       , ema
                  FROM   at_hist_price h
                 WHERE   ticker = v_ticker
                MODEL
                   PARTITION BY (ticker)
                   DIMENSION BY (day_seq)
                   MEASURES (close, 0 ema)

                      (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_ema_1_n * (close[CV ()] - ema[CV () - 1]), close[CV ()]))) ema_1
             , (SELECT   day_seq
                       , ticker
                       , close
                       , ema
                  FROM   at_hist_price a
                 WHERE   ticker = v_ticker
                MODEL
                   PARTITION BY (ticker)
                   DIMENSION BY (day_seq)
                   MEASURES (close, 0 ema)

                      (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_ema_2_n * (close[CV ()] - ema[CV () - 1]), close[CV ()]))) ema_2
       WHERE   ema_1.day_seq = ema_2.day_seq
               AND ema_1.ticker = ema_2.ticker;

   COMMIT;
END;