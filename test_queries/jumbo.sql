select count(distinct ticker) from at_hist_price;

select count(distinct ticker)  from at_full_refresh_log;

select * from at_stock;


select * from at_log order by 1 desc;

select refresh_date, status, count(1) from at_full_refresh_log
group by refresh_date, status;

select * from at_full_refresh_log where status = 'FAILED'



SELECT TICKER, COUNT(1) FROM  at_full_refresh_log GROUP BY TICKER  HAVING COUNT(1) > 1;

select count(distinct ticker)  from at_full_refresh_log



truncate table at_full_refresh_log;

truncate table at_log;