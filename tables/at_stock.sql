/* Formatted on 2013/02/08 1:28:51 AM (QP5 v5.126.903.23003) */
CREATE TABLE at_stock
(
   ticker         VARCHAR2 (100 BYTE)
 , company_name   VARCHAR2 (100 BYTE)
);


CREATE UNIQUE INDEX at_stock_pk
   ON at_stock (ticker);

ALTER TABLE at_stock ADD (
  CONSTRAINT at_stock_pk
 PRIMARY KEY
 (ticker));