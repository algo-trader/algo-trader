/* Formatted on 2013/02/19 7:32:19 PM (QP5 v5.126.903.23003) */
CREATE TABLE at_macd_temp
(
   ticker      VARCHAR2 (100 BYTE)
 , day_seq     INTEGER
 , ema_1       NUMBER
 , ema_2       NUMBER
 , macd        NUMBER
 , signal      NUMBER
 , histogram   NUMBER
);


CREATE UNIQUE INDEX at_macd_temp_pk
   ON at_macd_temp
   (
      ticker
    , day_seq
   );

ALTER TABLE at_macd_temp ADD (
  CONSTRAINT at_macd_temp_pk
 PRIMARY KEY
 (ticker, day_seq));