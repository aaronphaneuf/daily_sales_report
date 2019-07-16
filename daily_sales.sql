DECLARE @now Date
--Since the report will always contain yesterday's sales, subtract one day from the current date
SET @now = (GETDATE()-1)
DECLARE @MONDAY Date
DECLARE @MONDAYLY Date
SET DATEFIRST 1 --Monday
SET @MONDAY = DATEADD(DD, 0 - DATEPART(DW, @now), GETDATE())
SET @MONDAYLY = DATEADD(DD, -364 - DATEPART(DW, @now), GETDATE())
--Selecting headers
SELECT TRN_STO_FK AS Store, SUM(GrossYesterday) AS GrossYesterday, SUM(DiscountYesterday) AS DiscountYesterday, SUM(CombosYesterday) AS CombosYesterday, (GrossYesterday+ISNULL(DiscountYesterday,0)+ISNULL(CombosYesterday,0))AS TotalYesterday, SUM(GrossLY) AS GrossLY, SUM(DiscountLY) AS DiscountLY, SUM(CombosLY) AS CombosLY, (GrossLY+ISNULL(DiscountLY,0)+ISNULL(CombosLY,0)) AS TOTALLY, ((TotalYesterday-TOTALLY)/TOTALLY) AS Difference, COUNT(DISTINCT Transactions) AS Transactions, COUNT(DISTINCT TransactionsLY) AS TransactionsLY
, SUM(WTDGross) AS WTDGross, SUM(WTDDiscounts) AS WTDDiscounts, SUM(WTDCombos) AS WTDCombos, (WTDGross+ISNULL(WTDDiscounts,0)+ISNULL(WTDCombos,0)) AS TOTALWTD, SUM(WTDLYGross) AS WTDLYGross, SUM(WTDLYDiscounts) AS WTDLYDiscounts, SUM(WTDLYCombos) AS WTDLYCombos, (WTDLYGross+ISNULL(WTDLYDiscounts,0)+ISNULL(WTDLYCombos,0)) AS TOTALWTDLY

--Sub selection where individual stores are parsed
FROM (
--Yesterday's gross sales
SELECT TRN_STO_FK, ExtendedBasePrice AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Yesterday discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, TLI_Amount AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Yesterday's combo discounts
SELECT TRN_STO_FK, ExtendedBasePrice AS GrossYesterday, NULL AS DiscountYesterday, TLI_Amount AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL

--Yesterday's sales & transactions (this is inaccurate, use previous columns)
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, TRN_PK AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
FROM v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TLI_LIT_FK = 2
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
UNION ALL

--Last year's gross sales
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, ExtendedBasePrice AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year's discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, TLI_Amount AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year's combo discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, TLI_Amount AS CombosLY, NULL AS Transactions, NULL AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL

--Last year's sales & transactions
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, ExtendedBasePrice AS LastYear,NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, TRN_PK AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
FROM v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)
and v_TJTrans.TLI_LIT_FK = 2
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
UNION ALL

--Week to date gross
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, ExtendedBasePrice AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Week to date discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, TLI_Amount AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Week to date combo discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, NULL AS WTDDiscounts, TLI_Amount AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL

--Last year week to date gross
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, ExtendedBasePrice AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year week to date discounts
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, TLI_Amount AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL

--Last year week to date combos
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, TLI_Amount AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0
UNION ALL



--Last Year week to date sales (This is innaccurate) - This will now pull transactions based off of TLI_LIT_FK = 2
SELECT TRN_STO_FK, NULL AS GrossYesterday, NULL AS DiscountYesterday, NULL AS CombosYesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS LastYear, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
FROM v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (52) weeks from yesterday's date
and v_TJTrans.TLI_LIT_FK = 1
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
) a

GROUP BY Store

--Orders the stores in a specific order, as the python file iterates from top down
ORDER BY (CASE Store
WHEN '16' THEN 2 --Edmonton Jasper
WHEN '22' THEN 3 --Edmonton Ellerslie
WHEN '27' THEN 4 --Edmonton Sherwood
WHEN '3' THEN 7 --Calgary Shepard
WHEN '12' THEN 1 --Edmonton Classic
WHEN '10' THEN 5 --Calgary Classic
WHEN '11' THEN 6 --Calgary Shaganappi
WHEN '14' THEN 8 --Calgary Royal Oak
WHEN '1029' THEN 9 --Calgary Britannia
WHEN '9' THEN 10 --Victoria
WHEN '6' THEN 11 --Port Credit
ELSE 100 END)ASC, STORE DESC;

--Writes the file to the chosen location
OUTPUT TO 'C:\Users\aphaneuf\Desktop\daily_sales.txt';
