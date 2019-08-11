SET ANSINULL OFF
--Declare variables for yesterday & last year
DECLARE @now Date
SET @now = (GETDATE()-1)
DECLARE @MONDAY Date
DECLARE @MONDAYLY Date
SET DATEFIRST 1 --Monday
SET @MONDAY = DATEADD(DD, 0 - DATEPART(DW, @now), GETDATE())
SET @MONDAYLY = DATEADD(DD, -364 - DATEPART(DW, @now), GETDATE())

--Main select query
SELECT Store, SUM(GrossYesterday) AS GrossYesterday, SUM(CashNegativesYesterday) AS CashNegativesYesterday, SUM(TaxesYesterday) AS TaxesYesterday, (GrossYesterday-ISNULL(CashNegativesYesterday,0)-ISNULL(TaxesYesterday,0))AS TotalYesterday, SUM(GrossLY) AS GrossLY,
SUM(CashNegativesLY) AS CashNegativesLY, SUM(TaxesLY) AS TaxesLY, (GrossLY-ISNULL(CashNegativesLY,0)-ISNULL(TaxesLY, 0)) AS TotalLY, ((TotalYesterday-TotalLY)/TotalLY) AS Difference, FLOOR(SUM(TransactionsYesterday)) AS TransactionsYesterday,
FLOOR(SUM(TransactionsLY)) AS TransactionsLY, ((TransactionsYesterday-TransactionsLY)/TransactionsLY) AS TransactionDifference, (TotalYesterday/TransactionsYesterday) AS AverageSaleYesterday, (TotalLY/TransactionsLY) AS AverageSaleLY,
((AverageSaleYesterday-AverageSaleLY)/AverageSaleLY) AS AverageSaleDifference, SUM(GrossWTD) AS GrossWTD, SUM(CashNegativesWTD) AS CashNegativesWTD, SUM(TaxesWTD) AS TaxesWTD, (GrossWTD-ISNULL(CashNegativesWTD,0)-ISNULL(TaxesWTD,0)) AS TotalWTD,
SUM(GrossWTDLY) AS GrossWTDLY, SUM(CashNegativesWTDLY) AS CashNegativesWTDLY, SUM(TaxesWTDLY) AS TaxesWTDLY, (GrossWTDLY-ISNULL(CashNegativesWTDLY,0)-ISNULL(TaxesWTDLY, 0)) AS TotalWTDLY, ((TotalWTD-TotalWTDLY)/TotalWTDLY) AS WTDDifference,
FLOOR(SUM(TransactionsWTD)) AS TransactionsWTD, FLOOR(SUM(TransactionsWTDLY)) AS TransactionsWTDLY, ((TransactionsWTD-TransactionsWTDLY)/TransactionsWTDLY) AS WTDTransactionDifference
FROM (
--Sub select queries
--Gross yesterday
SELECT SGP_STO_FK AS Store, STN_Amount AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= (DATEADD(hour, 0, @now)) --Start from time = 00:00:00
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
UNION ALL
--Cash negatives yesterday
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, ABS(SNG_Amount) AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= (DATEADD(hour, 0, @now)) --Start from time = 00:00:00
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND SNG_Type not like 11
AND SNG_Type not like 12
AND SNG_Type not like 13
UNION ALL
--Taxes Yesterday
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, STX_Amount AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= (DATEADD(hour, 0, @now)) --Start from time = 00:00:00
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STX_Type = 1
UNION ALL
--Gross last year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, STN_Amount AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(week, -52, @now) --Subtract 52 weeks from yesterday
AND SGP_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, +DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now)))) --Add 23:59:59.999 to last year
AND STN_Type = 1
UNION ALL
--Cash negatives last year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, ABS(SNG_Amount) CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(week, -52, @now) --Subtract 52 weeks from yesterday
AND SGP_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, +DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now)))) --Add 23:59:59.999 to last year
AND SNG_Type not like 11
AND SNG_Type not like 12
AND SNG_Type not like 13
UNION ALL
--Taxes last year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, STX_Amount TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(week, -52, @now) --Subtract 52 weeks from yesterday
AND SGP_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, +DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now)))) --Add 23:59:59.999 to last year
AND STX_Type = 1
UNION ALL
--Transactions yesterday
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, STN_Quantity AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= (DATEADD(hour, 0, @now)) --Start from time = 00:00:00
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
UNION ALL
--Transactions last year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, STN_Quantity AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(week, -52, @now) --Subtract 52 weeks from yesterday
AND SGP_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, +DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now)))) --Add 23:59:59.999 to last year
AND STN_Type = 1
UNION ALL
--WTD gross
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
STN_Amount AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @monday) --Add 00:00:00 to the first monday of the week
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
UNION ALL
--Cash negatives WTD
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, ABS(SNG_Amount) AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @monday) --Add 00:00:00 to the first monday of the week
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND SNG_Type not like 11
AND SNG_Type not like 12
AND SNG_Type not like 13
UNION ALL
--Taxes WTD
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, STX_Amount AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @monday) --Add 00:00:00 to the first monday of the week
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STX_Type = 1
UNION ALL
--Gross WTD last year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, STN_Amount AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @mondayly) --Add 00:00:00 to the first monday of the week (last year)
AND SGP_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999,  @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
UNION ALL
--Cash negatives WTD lasy year
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, ABS(SNG_Amount) AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @mondayly) --Add 00:00:00 to the first monday of the week (last year)
AND SGP_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999,  @now))))) --Add 23:59:59.999 to 00:00:00
AND SNG_Type not like 11
AND SNG_Type not like 12
AND SNG_Type not like 13
UNION ALL
--Taxes WTDLY
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, STX_Amount AS TaxesWTDLY, NULL AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @mondayly) --Add 00:00:00 to the first monday of the week (last year)
AND SGP_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999,  @now))))) --Add 23:59:59.999 to 00:00:00
AND STX_Type = 1
UNION ALL
--Transactions WTD
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, STN_Quantity AS TransactionsWTD, NULL AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @monday) --Add 00:00:00 to the first monday of the week
AND SGP_EndTime <= (DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999, @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
UNION ALL
--Transactions WTDLY
SELECT SGP_STO_FK AS Store, NULL AS GrossYesterday, NULL AS CashNegativesYesterday, NULL AS TaxesYesterday, NULL AS GrossLY, NULL AS CashNegativesLY, NULL AS TaxesLY, NULL AS TransactionsYesterday, NULL AS TransactionsLY,
NULL AS GrossWTD, NULL AS CashNegativesWTD, NULL AS TaxesWTD, NULL AS GrossWTDLY, NULL AS CashNegativesWTDLY, NULL AS TaxesWTDLY, NULL AS TransactionsWTD, STN_Quantity AS TransactionsWTDLY
FROM v_SummaryData
WHERE SGP_StartTime >= DATEADD(hour, 0, @mondayly) --Add 00:00:00 to the first monday of the week (last year)
AND SGP_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, DATEADD(MINUTE, 59, DATEADD(SECOND, 59, DATEADD(MS, 999,  @now))))) --Add 23:59:59.999 to 00:00:00
AND STN_Type = 1
)a

GROUP BY Store
ORDER BY (CASE Store
WHEN '16' THEN 2
WHEN '22' THEN 3
WHEN '27' THEN 4
WHEN '3' THEN 7
WHEN '12' THEN 1
WHEN '10' THEN 5
WHEN '11' THEN 6
WHEN '14' THEN 8
WHEN '1029' THEN 9
WHEN '9' THEN 10
WHEN '6' THEN 11
ELSE 100 END)ASC, STORE DESC;

OUTPUT TO 'path_to_file/daily_sales.txt';
