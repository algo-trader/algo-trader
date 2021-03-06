/* Formatted on 2013/02/19 3:49:35 PM (QP5 v5.126.903.23003) */
CREATE TABLE at_hist_price
(
   ticker      VARCHAR2 (100 BYTE)
 , day         DATE
 , day_seq     INTEGER
 , open        NUMBER
 , high        NUMBER
 , low         NUMBER
 , close       NUMBER
 , volume      NUMBER
 , adj_close   NUMBER
 , raw_csv     VARCHAR2 (1000 BYTE)
);


CREATE UNIQUE INDEX at_hist_price_pk
   ON at_hist_price
   (
      ticker
    , day
   );

ALTER TABLE at_hist_price ADD (
  CONSTRAINT at_hist_price_pk
 PRIMARY KEY
 (ticker, day));