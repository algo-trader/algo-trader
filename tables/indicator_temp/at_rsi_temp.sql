/* Formatted on 2013/02/19 6:03:13 PM (QP5 v5.126.903.23003) */
CREATE TABLE at_rsi_temp
(
   ticker    VARCHAR2 (100 BYTE)
 , day_seq   INTEGER
 , u         NUMBER
 , d         NUMBER
 , ema_u     NUMBER
 , ema_d     NUMBER
 , rs        NUMBER
 , rsi       NUMBER
);


CREATE UNIQUE INDEX at_rsi_temp_pk
   ON at_rsi_temp
   (
      ticker
    , day_seq
   );

ALTER TABLE at_rsi_temp ADD (
  CONSTRAINT at_rsi_temp_pk
 PRIMARY KEY
 (ticker, day_seq));