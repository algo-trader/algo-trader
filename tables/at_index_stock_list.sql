/* Formatted on 2013/02/08 1:30:51 AM (QP5 v5.126.903.23003) */
CREATE TABLE at_index_stock_list
(
   index_name   VARCHAR2 (100 BYTE)
 , ticker       VARCHAR2 (100 BYTE)
);

ALTER TABLE at_index_stock_list ADD (
  CONSTRAINT at_index_stock_list_r01
 FOREIGN KEY (index_name)
 REFERENCES at_index (index_name),
  CONSTRAINT at_index_stock_list_r02
 FOREIGN KEY (ticker)
 REFERENCES at_stock (ticker));