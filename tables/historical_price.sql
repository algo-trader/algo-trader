/* Formatted on 2013/02/08 12:26:50 AM (QP5 v5.126.903.23003) */
CREATE TABLE historical_price
(
   ticker      VARCHAR2 (100 BYTE)
 , day         DATE
 , open        NUMBER
 , high        NUMBER
 , low         NUMBER
 , close       NUMBER
 , volume      NUMBER
 , adj_close   NUMBER
 , raw_csv     VARCHAR2 (1000 BYTE)
);