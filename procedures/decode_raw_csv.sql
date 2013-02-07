/* Formatted on 2013/02/08 12:38:14 AM (QP5 v5.126.903.23003) */
CREATE OR REPLACE PROCEDURE dacheng.decode_raw_csv
IS
BEGIN
   UPDATE   historical_price
      SET   day = TO_DATE (REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 1), 'yyyy-mm-dd')
          , open = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 2)
          , high = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 3)
          , low = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 4)
          , close = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 5)
          , volume = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 6)
          , adj_close = REGEXP_SUBSTR (raw_csv, '[^,]+', 1, 7);

   COMMIT;
END;
/