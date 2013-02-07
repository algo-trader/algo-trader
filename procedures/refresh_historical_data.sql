/* Formatted on 2013/02/07 11:57:36 PM (QP5 v5.126.903.23003) */
set define off

CREATE OR REPLACE PROCEDURE refresh_historical_data
IS
   http_req           UTL_HTTP.req;
   http_resp          UTL_HTTP.resp;
   raw_csv_record     VARCHAR2 (1024);
   v_ticker           VARCHAR2 (100) := 'GE';
   v_req_url          VARCHAR2 (1000);
   v_range_in_month   INTEGER := 60;

   CURSOR cr_stock_list
   IS
      SELECT   ticker
        FROM   stock_list
       WHERE   ROWNUM <= 1;
BEGIN
   p_verbose_log ('Truncating table HISTORICAL_PRICE...');

   EXECUTE IMMEDIATE ('truncate table historical_price');

   p_verbose_log ('HISTORICAL_PRICE truncated');
   p_verbose_log ('Start retrieving historical data ticker by ticker...');


   FOR cur_stock IN cr_stock_list
   LOOP
     <<load_each_ticker>>
      BEGIN
         p_verbose_log ('Current ticker: ' || cur_stock.ticker);

         v_req_url :=
               'http://ichart.finance.yahoo.com/table.csv?s='
            || cur_stock.ticker
            || '&a='
            || LPAD (TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_range_in_month), 'mm')) - 1, 2, '0')
            || '&b='
            || TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_range_in_month), 'dd'))
            || '&c='
            || TO_CHAR (ADD_MONTHS (SYSDATE, -1 * v_range_in_month), 'yyyy')
            || '&d='
            || LPAD (TO_NUMBER (TO_CHAR (SYSDATE, 'mm')) - 1, 2, '0')
            || '&e='
            || TO_NUMBER (TO_CHAR (SYSDATE, 'dd'))
            || '&f='
            || TO_CHAR (SYSDATE, 'yyyy')
            || '&g=d&ignore=.csv';

         p_verbose_log ('Current request url: ' || v_req_url);

         http_req := UTL_HTTP.begin_request (v_req_url);
         UTL_HTTP.set_header (http_req, 'User-Agent', 'Mozilla/4.0');
         http_resp := UTL_HTTP.get_response (http_req);
         p_verbose_log ('Response received, discard 1st line... ');

         UTL_HTTP.read_line (http_resp, raw_csv_record, TRUE);

         LOOP
            UTL_HTTP.read_line (http_resp, raw_csv_record, TRUE);
            p_verbose_log ('Current record is:' || raw_csv_record);

            INSERT INTO historical_price
                       (
                           ticker
                         , raw_csv
                       )
              VALUES
                       (
                           cur_stock.ticker
                         , raw_csv_record
                       );
         END LOOP;

         UTL_HTTP.end_response (http_resp);

         COMMIT;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            COMMIT;
            p_verbose_log ('Exception UTL_HTTP.end_of_body');

            UTL_HTTP.end_response (http_resp);
         WHEN OTHERS
         THEN
            COMMIT;
            p_verbose_log ('Exception ' || SQLERRM);


            UTL_HTTP.end_response (http_resp);
      END load_each_ticker;
   END LOOP;
END;