/* Formatted on 2013/02/19 8:54:40 PM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE at_p_macd
(
   v_ticker      VARCHAR2
 , v_ema_1_n     INTEGER
 , v_ema_2_n     INTEGER
 , v_signal_n    INTEGER
)
IS
   v_indicator_name   VARCHAR2 (1000) := 'MACD(' || v_ema_1_n || ',' || v_ema_2_n || ',' || v_signal_n || ')';
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

   UPDATE   at_macd_temp
      SET   macd = ema_1 - ema_2;

   MERGE INTO   at_macd_temp x
        USING   (SELECT   ticker
                        , day_seq
                        , macd
                        , ema AS signal
                   FROM   at_macd_temp
                  WHERE   ticker = v_ticker
                 MODEL
                    PARTITION BY (ticker)
                    DIMENSION BY (day_seq)
                    MEASURES (macd, 0 ema)

                       (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_signal_n * (macd[CV ()] - ema[CV () - 1]), macd[CV ()]))) v
           ON   (x.ticker = v.ticker
                 AND x.day_seq = v.day_seq)
   WHEN MATCHED
   THEN
      UPDATE SET x.signal = v.signal;

   UPDATE   at_macd_temp
      SET   histogram = macd - signal;



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
             , 'MACD'
             , macd
        FROM   at_macd_temp
       WHERE   ticker = v_ticker;

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
             , 'SIGNAL'
             , signal
        FROM   at_macd_temp
       WHERE   ticker = v_ticker;

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
             , 'HISTOGRAM'
             , histogram
        FROM   at_macd_temp
       WHERE   ticker = v_ticker;

   COMMIT;
END;