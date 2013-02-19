/* Formatted on 2013/02/19 8:52:12 PM (QP5 v5.126.903.23003) */
CREATE TABLE at_indicator_value
(
   ticker            VARCHAR2 (100 BYTE)
 , day_seq           INTEGER
 , indicator_name    VARCHAR2 (100 BYTE)
 , indicator_key     VARCHAR (100 BYTE)
 , indicator_value   NUMBER
);


CREATE UNIQUE INDEX at_indicator_value_pk
   ON at_indicator_value
   (
      ticker
    , day_seq
    , indicator_name
    , indicator_key
   );

ALTER TABLE at_indicator_value ADD (
  CONSTRAINT at_indicator_value_pk
 PRIMARY KEY
 (ticker, day_seq, indicator_name, indicator_key));