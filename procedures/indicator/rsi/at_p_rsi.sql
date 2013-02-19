/* Formatted on 2013/02/08 4:43:28 AM (QP5 v5.126.903.23003) */
INSERT INTO at_rsi_temp
           (
               ticker
             , day_seq
             , day
             , close
           )
   (SELECT   *
      FROM   (  SELECT   ticker
                       , ROWNUM
                       , day
                       , close
                  FROM   at_hist_price
                 WHERE   ticker = 'MMM'
              ORDER BY   day));

UPDATE   at_rsi_temp curr
   SET   curr.u =
            curr.close
            - (SELECT   prev.close
                 FROM   at_rsi_temp prev
                WHERE   prev.day_seq = curr.day_seq - 1)
       , curr.d =
            -1
            * (curr.close
               - (SELECT   prev.close
                    FROM   at_rsi_temp prev
                   WHERE   prev.day_seq = curr.day_seq - 1));

UPDATE   at_rsi_temp
   SET   u = 0
 WHERE   u < 0;

UPDATE   at_rsi_temp
   SET   d = 0
 WHERE   d < 0;

UPDATE   at_rsi_temp
   SET   n = 14;