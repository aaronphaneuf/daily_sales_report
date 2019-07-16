# Daily Sales Report - SQL Query

Pulls from a table named v_TJTrans for each store in the company and summarizes yesterday's sales along with the matching day for last year, week to date, and matching week to date for last year.

Week to date sales are calculated from Monday - Sunday for each week.

run_report.py runs daily_sales.sql, writes the results to a file and iterates through the data, writing to a table which is then emailed out to certain individuals in the company.
