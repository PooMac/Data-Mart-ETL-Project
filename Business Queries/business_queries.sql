-- 1. Who are the top 10 buyers based on their total purchase amounts in real estate? Output the Buyer First Name and corresponding sale amount
select TOP(10) sum(FR.Sale_Amount) as Total_Sale_Amount, First_Name 
from [dbo].[Fact_Real_Estate_Sales] FR
inner join [dbo].[Dim_Buyer] DB
on FR.BuyerID = DB.BuyerID
group by First_Name
order by Total_Sale_Amount desc;


-- 2. Give the top 20 towns with highest Assessed value among all?
select TOP(20) sum(Assessed_Value) as Total_Assessed_Amount, Town
from [dbo].[Fact_Real_Estate_Sales] FR
inner join [dbo].[Dim_Address] DA on FR.Address_ID = DA.Address_ID
inner join [dbo].[Dim_Town] DT on DA.Town_ID = DT.Town_ID
group by Town
order by Total_Assessed_Amount desc;
