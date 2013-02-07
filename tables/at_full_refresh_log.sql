/* Formatted on 2013/02/08 3:35:22 AM (QP5 v5.126.903.23003) */
CREATE TABLE at_full_refresh_log
(
   refresh_num    INTEGER
 , refresh_date   DATE
 , ticker         VARCHAR2 (100)
 , status         VARCHAR2 (100)
 , err_msg        VARCHAR (4000)
)