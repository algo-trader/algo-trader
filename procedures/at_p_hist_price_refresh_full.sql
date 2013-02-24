/* Formatted on 2013/02/24 11:55:32 AM (QP5 v5.126.903.23003) */
set define off

CREATE OR REPLACE PROCEDURE at_p_hist_price_refresh_full
(
   v_ticker        VARCHAR2
 , v_num_months    INTEGER
)
IS
   http_req           UTL_HTTP.req;
   http_resp          UTL_HTTP.resp;
   raw_csv_record     VARCHAR2 (1024);
   v_req_url          VARCHAR2 (1000);
   v_sqlerrm          VARCHAR2 (4000);
   v_full_fresh_num   INTEGER;
BEGIN
   SELECT   NVL (MAX (refresh_num), 0) + 1
     INTO   v_full_fresh_num
     FROM   at_full_refresh_log
    WHERE   ticker = v_ticker;

   at_p_log ('Deleting ' || v_ticker || ' from AT_HIST_PRICE...');

   EXECUTE IMMEDIATE ('delete from AT_HIST_PRICE where ticker = :ticker') USING v_ticker;

   at_p_log (v_ticker || ' data deleted from AT_HIST_PRICE');

   at_p_log ('Start retrieving historical data for ' || v_ticker || '...');


   BEGIN
      v_req_url :=
            'http://ichart.finance.yahoo.com/table.csv?s='
         || v_ticker
         || '&a='
         || LPAD (TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_num_months), 'mm')) - 1, 2, '0')
         || '&b='
         || TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_num_months), 'dd'))
         || '&c='
         || TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_num_months), 'yyyy')
         || '&d='
         || LPAD (TO_NUMBER (TO_CHAR (SYSDATE, 'mm')) - 1, 2, '0')
         || '&e='
         || TO_NUMBER (TO_CHAR (SYSDATE, 'dd'))
         || '&f='
         || TO_CHAR (SYSDATE, 'yyyy')
         || '&g=d&ignore=.csv';

      at_p_log ('Request url: ' || v_req_url);

      http_req := UTL_HTTP.begin_request (v_req_url);
      UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
      http_resp := UTL_HTTP.get_response (http_req);
      at_p_log ('Response received, discard 1st line... ');

      UTL_HTTP.read_line (http_resp, raw_csv_record, TRUE);

      LOOP
         UTL_HTTP.read_line (http_resp, raw_csv_record, TRUE);

         INSERT INTO at_hist_price
                    (
                        ticker
                      , raw_csv
                      , day
                      , open
                      , high
                      , low
                      , close
                      , volume
                      , adj_close
                    )
           VALUES
                    (
                        v_ticker
                      , raw_csv_record
                      , TO_DATE (REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 1), 'yyyy-mm-dd')
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 2)
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 3)
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 4)
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 5)
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 6)
                      , REGEXP_SUBSTR (raw_csv_record, '[^,]+', 1, 7)
                    );
      END LOOP;

      INSERT INTO at_full_refresh_log
                 (
                     refresh_num
                   , refresh_date
                   , ticker
                   , status
                   , err_msg
                 )
        VALUES
                 (
                     v_full_fresh_num
                   , SYSDATE
                   , v_ticker
                   , 'SUCCESSFUL'
                   , NULL
                 );

      UTL_HTTP.end_response (http_resp);
      COMMIT;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         COMMIT;

         INSERT INTO at_full_refresh_log
                    (
                        refresh_num
                      , refresh_date
                      , ticker
                      , status
                      , err_msg
                    )
           VALUES
                    (
                        v_full_fresh_num
                      , SYSDATE
                      , v_ticker
                      , 'SUCCESSFUL'
                      , NULL
                    );

         COMMIT;

         BEGIN
            UTL_HTTP.end_response (http_resp);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      WHEN OTHERS
      THEN
         ROLLBACK;
         v_sqlerrm := SQLERRM;
         at_p_log (v_sqlerrm);

         INSERT INTO at_full_refresh_log
                    (
                        refresh_num
                      , refresh_date
                      , ticker
                      , status
                      , err_msg
                    )
           VALUES
                    (
                        v_full_fresh_num
                      , SYSDATE
                      , v_ticker
                      , 'FAILED'
                      , v_sqlerrm
                    );

         COMMIT;

         BEGIN
            UTL_HTTP.end_response (http_resp);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;

   MERGE INTO   at_hist_price a
        USING   (SELECT   s.ticker
                        , s.day
                        , s.ROWID AS row_id
                        , ROW_NUMBER () OVER (PARTITION BY ticker ORDER BY day DESC) * (-1) + 1 AS day_seq
                   FROM   at_hist_price s
                  WHERE   ticker = v_ticker) v
           ON   (a.ROWID = v.row_id)
   WHEN MATCHED
   THEN
      UPDATE SET a.day_seq = v.day_seq;

   COMMIT;
END;
/