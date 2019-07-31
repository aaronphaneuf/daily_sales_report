# Daily Sales Report - SQL Query

Pulls from a SQL table named v_TJTrans for each store in the company and summarizes yesterday's sales along with the matching day for last year, week to date, and matching week to date for last year.

# daily_sales.sql

<code>SELECT * from v_TJTrans</code> results in over 20 million rows and 38 columns - over 760 million cells of data dating back to 2013.
Net sales are based off Gross sales - Combos - Discounts. These are obtained through the following filters:

| Column | WHERE Clause | Description |
|-------------------------------------|
| TRN_STO_FK | None | All stores are parsed |
| TRN_AllVoid | = 0 | Void transactions are not included - Primary key |
| TRN_Void | = 0 | Void transactions are not included - Foreign key |
| DPT_Name | not like '%99%' | Bottle refunds are not included |
| TLI_LIT_FK | = 4 | Discount line items included |
| TLI_LIT_FK | = 35 | Combo line items included |
| TLI_LIT_FK | = 2 | Unique transactions |
|TRN_EndTime | variable | TRN_EndTime is used over TRN_StartTime, which is not maintained |

Week to date sales are calculated from Monday - Sunday for each week.

run_report.py executes daily_sales.sql, writes the results to a file and iterates through the data, writing to a table which is then emailed out to certain individuals in the company on a daily basis.

# run_report.py

Executes daily_sales.sql, which writes to daily_sales.txt. Iterates through the text file and writes the individual store data to dictionaries using a for loop. Stores are accessed through key values and written between <td> tags and sent using smtp.
