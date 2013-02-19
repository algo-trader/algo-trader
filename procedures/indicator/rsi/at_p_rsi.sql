/* Formatted on 2013/02/19 9:01:26 PM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE at_p_rsi
(
   v_ticker      VARCHAR2
 , v_smooth_n    INTEGER
)
IS
   v_indicator_name   VARCHAR2 (1000) := 'RSI(' || v_smooth_n || ')';
BEGIN
   EXECUTE IMMEDIATE ('truncate table at_rsi_temp');

   INSERT INTO at_rsi_temp
              (
                  ticker
                , day_seq
                , u
                , d
              )
      SELECT   u.ticker
             , u.day_seq
             , u.u
             , d.d
        FROM   (SELECT   ticker
                       , day_seq
                       , close
                       , u
                  FROM   at_hist_price a
                 WHERE   ticker = v_ticker
                MODEL
                   PARTITION BY (ticker)
                   DIMENSION BY (day_seq)
                   MEASURES (close, 0 u)

                      (u [ANY] ORDER BY day_seq = NVL2 (close[CV () - 1], GREATEST (close[CV ()] - close[CV () - 1], 0), 0))) u
             , (SELECT   day_seq
                       , ticker
                       , close
                       , d
                  FROM   at_hist_price a
                 WHERE   ticker = v_ticker
                MODEL
                   PARTITION BY (ticker)
                   DIMENSION BY (day_seq)
                   MEASURES (close, 0 d)

                      (d [ANY] ORDER BY day_seq = NVL2 (close[CV () - 1], GREATEST (close[CV () - 1] - close[CV ()], 0), 0))) d
       WHERE   u.day_seq = d.day_seq
               AND u.ticker = d.ticker;

   MERGE INTO   at_rsi_temp x
        USING   (SELECT   ema_u.ticker
                        , ema_u.day_seq
                        , ema_u.u
                        , ema_d.d
                        , ema_u.ema_u
                        , ema_d.ema_d
                        , CASE ema_d.ema_d WHEN 0 THEN 100 ELSE ema_u.ema_u / ema_d.ema_d END AS rs
                        , 100 - 100 / (1 + CASE ema_d.ema_d WHEN 0 THEN 100 ELSE ema_u.ema_u / ema_d.ema_d END) rsi
                   FROM   (SELECT   day_seq
                                  , ticker
                                  , u
                                  , ema AS ema_u
                             FROM   at_rsi_temp
                           MODEL
                              PARTITION BY (ticker)
                              DIMENSION BY (day_seq)
                              MEASURES (u, 0 ema)

                                 (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_smooth_n * (u[CV ()] - ema[CV () - 1]), u[CV ()]))) ema_u
                        , (SELECT   day_seq
                                  , ticker
                                  , d
                                  , ema AS ema_d
                             FROM   at_rsi_temp
                           MODEL
                              PARTITION BY (ticker)
                              DIMENSION BY (day_seq)
                              MEASURES (d, 0 ema)

                                 (ema [ANY] ORDER BY day_seq = NVL2 (ema[CV () - 1], ema[CV () - 1] + 1 / v_smooth_n * (d[CV ()] - ema[CV () - 1]), d[CV ()]))) ema_d
                  WHERE   ema_u.ticker = ema_d.ticker
                          AND ema_u.day_seq = ema_d.day_seq) v
           ON   (x.ticker = v.ticker
                 AND x.day_seq = v.day_seq)
   WHEN MATCHED
   THEN
      UPDATE SET x.ema_u = v.ema_u
               , x.ema_d = v.ema_d
               , x.rs = v.rs
               , x.rsi = v.rsi;

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
      (SELECT   ticker
              , day_seq
              , v_indicator_name
              , 'RSI'
              , rsi
         FROM   at_rsi_temp);

   COMMIT;
END;