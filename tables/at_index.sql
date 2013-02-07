/* Formatted on 2013/02/08 1:28:21 AM (QP5 v5.126.903.23003) */
CREATE TABLE at_index
(
   index_name    VARCHAR2 (100 BYTE)
 , index_descr   VARCHAR2 (4000 BYTE)
);


CREATE UNIQUE INDEX at_index_pk
   ON at_index (index_name);

ALTER TABLE at_index ADD (
  CONSTRAINT at_index_pk
 PRIMARY KEY
 (index_name));