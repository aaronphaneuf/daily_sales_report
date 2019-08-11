# Daily Sales Report - SQL Query & Python Script

Pulls from a SQL table named v_SummaryData for each store in the company and summarizes yesterday's sales along with the matching day for last year, week to date, and matching week to date for last year. No access to python modules (pandas, pyodbc, etc) or SQL login parameters so I am working with what I can. The pie chart is generated with matplotlib, but is a concept only and not in production, due to lack of module access.
An older version of this repository pulled from a table named v_TJTrans, which lists every transaction and was more onerous than needed.

<p align="center">
<img src="https://github.com/aaronphaneuf/daily_sales_report/blob/master/daily_sales.PNG">
</p>

# daily_sales.sql

<code>SELECT * from v_SummaryData</code>
<p>results in over 20 million rows and 26 columns - over 520 million cells of data dating back to 2013.
Net sales are based off Gross sales - Cash Negatives - Taxes. These are obtained through the following filters:</p>

| Column | WHERE Clause | Description |
|--------|:------------:|:-----------:|
| SGP_STO_FK | None | All stores are parsed |
| STN_Type | = 1 | Gross Sales for each department |
| SNG_Type | Not like 11,12,13| Cash Negatives |
| STX_Type | not like '%99%' | Taxes |
|TRN_EndTime | variable | TRN_EndTime is used over TRN_StartTime, which is not maintained |

Week to date sales are calculated from Monday - Sunday for each week.

# run_report.py

Executes daily_sales.sql, which writes to daily_sales.txt. Iterates through the text file and writes the individual store data to dictionaries using a for loop. Stores are accessed through key values and written between <td> tags and sent using smtp.
