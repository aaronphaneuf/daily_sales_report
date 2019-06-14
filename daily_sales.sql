DECLARE @now Date
SET @now = (GETDATE()-1)
--Since we're always concerned with yesterday's sales, subtract one from the current date
DECLARE @monday Date
DECLARE @mondayly Date
SET DATEFIRST 1 --Set datefirst equal to the first day of the week (monday)
SET @MONDAY = DATEADD(DD, 0 - DATEPART(DW, @now), GETDATE())
--Finds the first monday of the current week
SET @MONDAYLY = DATEADD(DD, -364 - DATEPART(DW, @now), GETDATE())
--Finds the first monday of the week for last year

--Selecting headers
SELECT TRN_STO_FK AS Store, SUM(Yesterday) AS Yesterday, SUM(Discount) AS Discount, SUM(Combos) AS Combos, (Yesterday+Discount+Combos)AS TOTALYESTERDAY, SUM(GrossLY) AS GrossLY, SUM(DiscountLY) AS DiscountLY, SUM(CombosLY) AS CombosLY, (GrossLY+DiscountLY+CombosLY) AS TOTALLY, ((Yesterday-LastYear)/LastYear) AS Difference, COUNT(DISTINCT Transactions) AS Transactions, COUNT(DISTINCT TransactionsLY) AS TransactionsLY
, SUM(WTDGross) AS WTDGross, SUM(WTDDiscounts) AS WTDDiscounts, SUM(WTDCombos) AS WTDCombos, (WTDGross+WTDDiscounts+WTDCombos) AS TOTALWTD, SUM(WTDLYGross) AS WTDLYGross, SUM(WTDLYDiscounts) AS WTDLYDiscounts, SUM(WTDLYCombos) AS WTDLYCombos, (WTDLYGross+WTDLYDiscounts+WTDLYCombos) AS TOTALWTDLY

--Sub selection where individual stores are parsed
FROM (

--Yesterday's gross sales
SELECT TRN_STO_FK, ExtendedBasePrice AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Yesterday's discounts
SELECT TRN_STO_FK, NULL AS Yesterday, TLI_Amount AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Yesterday's combo discounts
SELECT TRN_STO_FK, ExtendedBasePrice AS Yesterday, NULL AS Discount, TLI_Amount AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL
--Yesterday's transactions
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, ExtendedBasePrice AS Yesterday, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, TRN_PK AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
FROM v_TJTrans
where v_TJTrans.TRN_EndTime >= (DATEADD(hour, 1, @now)) --Add 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now))--Add 23 hours to 00:00:00
and v_TJTrans.TLI_LIT_FK = 2
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
UNION ALL

--Last year's gross sales
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, ExtendedBasePrice AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date and 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now) --Add (-52) weeks from yesterda's date and 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year's discounts
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, TLI_Amount AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date and 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now) --Add (-52) weeks from yesterda's date and 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year's combo discounts
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, TLI_Amount AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date and 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now) --Add (-52) weeks from yesterda's date and 23 hours to 00:00:00
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL

--Last year's transactions
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, TRN_PK AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
FROM v_TJTrans
where v_TJTrans.TRN_EndTime >= DATEADD(week, -52, @now) + DATEADD(hour, 1, @now) --Add (-52) weeks from yesterday's date and 1 hour to 00:00:00
and v_TJTrans.TRN_EndTime <= DATEADD(week, -52, @now) + DATEADD(hour, 23, @now) --Add (-52) weeks from yesterda's date and 23 hours to 00:00:00
and v_TJTrans.TLI_LIT_FK = 2
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
UNION ALL

--Week to date gross
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, ExtendedBasePrice AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY,NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Week to date discounts
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, TLI_Amount AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Week to date combo discounts
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, TLI_Amount AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @monday --Find the first Monday of the week
and v_TJTrans.TRN_EndTime <= (DATEADD(hour, 23, @now)) --End of day for yesterday
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0

UNION ALL

--Last year week to date gross
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, ExtendedBasePrice AS WTDLYGross, NULL AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL
--Last year week to date discounts
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, TLI_Amount AS WTDLYDiscounts, NULL AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 4
and v_TJTrans.ITI_Void = 0
and DPT_Name not like '%99%'

UNION ALL

--Last year week to date combos
SELECT TRN_STO_FK, NULL AS Yesterday, NULL AS Discount, NULL AS Combos, NULL AS GrossLY, NULL AS DiscountLY, NULL AS CombosLY, NULL AS Transactions, NULL AS WTDGross, NULL AS WTDDiscounts, NULL AS WTDCombos, NULL AS TransactionsLY, NULL AS WTDLYGross, NULL AS WTDLYDiscounts, TLI_Amount AS WTDLYCombos
from v_TJTrans
where v_TJTrans.TRN_EndTime >= @mondayly --Find the first Monday of the week for last year.
and v_TJTrans.TRN_EndTime <= (DATEADD(week, -52, @now) + DATEADD(hour, 23, @now)) --Add (-52) weeks from yesterday's date
and v_TJTrans.TRN_AllVoid = 0
and v_TJTrans.TLI_LIT_FK = 35
and v_TJTrans.ITI_Void = 0
) a

GROUP BY Store
