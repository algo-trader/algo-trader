/* Formatted on 2013/02/19 7:13:52 PM (QP5 v5.126.903.23003) */
CREATE TABLE at_indicator_value
(
   ticker            VARCHAR2 (100 BYTE)
 , day_seq           INTEGER
 , INDICATOR         VARCHAR2 (100 BYTE)
 , indicator_value   NUMBER
);


CREATE UNIQUE INDEX at_indicator_value_pk
   ON at_indicator_value
   (
      ticker
    , day_seq
    , INDICATOR
   );

ALTER TABLE at_indicator_value ADD (
  CONSTRAINT at_indicator_value_pk
 PRIMARY KEY
 (ticker, day_seq, INDICATOR));