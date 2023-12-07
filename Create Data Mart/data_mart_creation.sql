/*
	Description: This SQL script is used to move data into Staging from a table that was created
	to import data using Azure Data Studio Import Wizard. This script assumes you have 2 tables.
	TABLE 1: [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Azure_Staging] --> This was the table used by the Azure 
	Data Tools Import Wizard to load data.
	TABLE 2: [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Staging] --> This is the table that will be used to complete the
	Data Mart ETL process. Once this is complete, you can now proceed with the rest of the 
	ETL process. 
*/
-- TABLE 1
INSERT INTO [dbo].[Real_Estate_Sales_Staging]
           (
                [Serial_Number]
                ,[List_Year]
                ,[Date_Recorded]
                ,[Town]
                ,[Address]
                ,[Assessed_Value]
                ,[Sale_Amount]
                ,[Sales_Ratio]
                ,[Property_Type]
                ,[Residential_Type]
                ,[Non_Use_Code]
                ,[Assessor_Remarks]
                ,[OPM_remarks]
                ,[Location])
		   -- TABLE 2
			SELECT [Serial_Number]
                ,[List_Year]
                ,[Date_Recorded]
                ,[Town]
                ,[Address]
                ,[Assessed_Value]
                ,[Sale_Amount]
                ,[Sales_Ratio]
                ,[Property_Type]
                ,[Residential_Type]
                ,[Non_Use_Code]
                ,[Assessor_Remarks]
                ,[OPM_remarks]
                ,[Location]
            FROM [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Azure_Staging]

-- After staging the table, I am linking the buyer with real estate using fabricated buyerID.
-- Add buyerID to the staging table.
alter table [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Staging]
add BuyerID INT;

--Using the below logic I am adding the random values(1-10) as FK for the staging table from buyers
update [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Staging]
set BuyerID = cast((abs(checksum(newid())) %10)+1 as INT);

-- Now I am creating a new staging table joining the previously created staging and the columns from the buyers.
select [Serial_Number]
      ,[List_Year]
      ,[List_Year_ID]
      ,[Date_Recorded]
      ,[Date_Recorded_ID]
      ,[Town]
      ,[Town_ID]
      ,[Address]
      ,[Address_ID]
      ,[Assessed_Value]
      ,[Sale_Amount]
      ,[Sales_Ratio]
      ,[Property_Type]
      ,[Residential_Type]
      ,[Property_ID]
      ,[Non_Use_Code]
      ,[Non_Use_Code_ID]
      ,[Assessor_Remarks]
      ,[Assessor_Remarks_ID]
      ,[OPM_remarks]
      ,[OPM_remarks_ID]
      ,[Location]
      ,[Location_ID]
	  ,RDR.[BuyerID]
	  ,[FIRST NAME] as [First_Name]
	  ,[LAST NAME] as [Last_Name]
	  ,[PHONE NUMBER] as [Phone_Number]
into [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_new_Staging]
from [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Staging] RDR
inner join [REAL_ESTATE_DB].[ESTATE_SALES_SCHEMA].[BUYERS] REB
on RDR.BuyerID = REB.[BUYER ID];


/*
Description: This SQL code uses the Real Estate Data Mart design. 
	This script can be used in the event that the developer does not want to build an automated
	pipeline with tools such as SQL Server Integration Services (SSIS) in Visual Studio. 
	This script assumes that the developer has already imported data from the Real_Estate_data.csv into the 
	Real_Estate_Sales_new_Staging table. Now that data has been imported from the CSV, this
	SQL code will populated the empty ID columns in the Real_Estate_Sales_new_Staging table 
	as they are being created in the Real Estate Dimensions. Once all Dimensions and the
	Real_Estate_Sales_new_Staging table are populated with data, this SQL script will populate
	the FACT table. 
	NOTE: The sequence of executing these SQL statements is important
*/

-- Get Town data from Staging Table and Load into Dim_Town:
-- This code retrieves distinct town names from the staging table and inserts them into the Dim_Town table.
INSERT INTO Dim_Town([Town])
	SELECT
	DISTINCT [Town]
	FROM [dbo].[Real_Estate_Sales_new_Staging]
	ORDER BY [Town] ASC


-- Update TownID in Staging table:
-- This code updates the Town_ID in the staging table based on a join with the Dim_Town table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Town_ID = dbo.Dim_Town.Town_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Town ON 
Real_Estate_Sales_new_Staging.Town = Dim_Town.Town

-- Get Town and AddressID from Staging Table and Load into Dim_Address:
-- This code retrieves distinct address and town IDs from the staging table and inserts them into the Dim_Address table.
INSERT INTO dbo.Dim_Address([Address],[Town_ID])
	SELECT
	DISTINCT Address, Town_ID
	FROM dbo.Real_Estate_Sales_new_Staging
	ORDER BY Town_ID ASC


-- Update Address_ID in Staging Table:
-- This code updates the Address_ID in the staging table based on a join with the Dim_Address table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Address_ID = dbo.Dim_Address.Address_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Address ON Real_Estate_Sales_new_Staging.Address = dbo.Dim_Address.Address AND Real_Estate_Sales_new_Staging.Town_ID = dbo.Dim_Address.Town_ID;

-- Get List_Year from Staging Table:
-- This code retrieves distinct list years from the staging table and inserts them into the Dim_List_Year table.
INSERT INTO dbo.Dim_List_Year ([List_Year])
SELECT 
DISTINCT [List_Year]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [List_Year] ASC

-- Update List_Year_ID in Staging:
-- This code updates the List_Year_ID in the staging table based on a join with the Dim_List_Year table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.List_Year_ID = dbo.Dim_List_Year.List_Year_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_List_Year ON dbo.Real_Estate_Sales_new_Staging.List_Year = dbo.Dim_List_Year.List_Year

-- Load data into Dim_Date_Recorded:
-- This code retrieves distinct date recorded values from the staging table and inserts them into the Dim_Date_Recorded table.
INSERT INTO dbo.Dim_Date_Recorded([Date_Recorded])
SELECT 
DISTINCT [Date_Recorded]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [Date_Recorded] ASC

-- Update Date_Recorded_ID in Staging:
-- This code updates the Date_Recorded_ID in the staging table based on a join with the Dim_Date_Recorded table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Date_Recorded_ID = dbo.Dim_Date_Recorded.Date_Recorded_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Date_Recorded ON dbo.Real_Estate_Sales_new_Staging.Date_Recorded = dbo.Dim_Date_Recorded.Date_Recorded

-- Load data into Dim_OPM_Remarks:
-- This code retrieves distinct OPM remarks from the staging table and inserts them into the Dim_OPM_Remarks table.
INSERT INTO dbo.Dim_OPM_Remarks ([OPM_remarks])
SELECT 
DISTINCT [OPM_remarks]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [OPM_remarks] ASC

-- Update OPM_remarks_ID in Staging:
-- This code updates the OPM_remarks_ID in the staging table based on a join with the Dim_OPM_Remarks table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.OPM_remarks_ID = dbo.Dim_OPM_Remarks.OPM_remarks_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_OPM_Remarks ON dbo.Real_Estate_Sales_new_Staging.OPM_remarks = dbo.Dim_OPM_Remarks.OPM_remarks

-- Load data into Dim_Assessor_Remarks:
-- This code retrieves distinct assessor remarks from the staging table and inserts them into the Dim_Assessor_Remarks table.
INSERT INTO dbo.Dim_Assessor_Remarks ([Assessor_remarks])
SELECT 
DISTINCT [Assessor_remarks]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [Assessor_remarks] ASC

-- Update Assessor_Remarks_ID in Staging:
-- This code updates the Assessor_Remarks_ID in the staging table based on a join with the Dim_Assessor_Remarks table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Assessor_Remarks_ID = dbo.Dim_Assessor_Remarks.Assessor_Remarks_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Assessor_Remarks ON dbo.Real_Estate_Sales_new_Staging.Assessor_Remarks = dbo.Dim_Assessor_Remarks.Assessor_Remarks

-- Load data into Dim_Non_Use_Code:
-- This code retrieves distinct non-use codes from the staging table and inserts them into the Dim_Non_Use_Code table.
INSERT INTO dbo.Dim_Non_Use_Code ([Non_Use_Code])
SELECT 
DISTINCT [Non_Use_Code]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [Non_Use_Code] ASC

-- Update Non_Use_Code_ID in Staging:
-- This code updates the Non_Use_Code_ID in the staging table based on a join with the Dim_Non_Use_Code table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Non_Use_Code_ID = dbo.Dim_Non_Use_Code.Non_Use_Code_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Non_Use_Code ON dbo.Real_Estate_Sales_new_Staging.Non_Use_Code = dbo.Dim_Non_Use_Code.Non_Use_Code

-- Load data into Dim_Location:
-- This code retrieves distinct location values from the staging table and inserts them into the Dim_Location table.
INSERT INTO dbo.Dim_Location ([Location])
SELECT 
DISTINCT [Location]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [Location] ASC

-- Update Location_ID in Staging:
-- This code updates the Location_ID in the staging table based on a join with the Dim_Location table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Location_ID = dbo.Dim_Location.Location_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Location ON dbo.Real_Estate_Sales_new_Staging.[Location] = dbo.Dim_Location.[Location]

-- Load data into Dim_Property:
-- This code retrieves distinct property types and residential types from the staging table and inserts them into the Dim_Property table.
INSERT INTO dbo.Dim_Property ([Property_Type], [Residential_Type])
SELECT 
DISTINCT [Property_Type], [Residential_Type]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [Property_Type],[Residential_Type] ASC

-- Update Location_ID in Property_ID:
-- This code updates the Property_ID in the staging table based on a join with the Dim_Property table.
UPDATE dbo.Real_Estate_Sales_new_Staging
SET dbo.Real_Estate_Sales_new_Staging.Property_ID = dbo.Dim_Property.Property_ID
FROM dbo.Real_Estate_Sales_new_Staging
INNER JOIN dbo.Dim_Property ON dbo.Real_Estate_Sales_new_Staging.[Property_Type] = dbo.Dim_Property.[Property_Type] 
and dbo.Real_Estate_Sales_new_Staging.[Residential_Type] = dbo.Dim_Property.[Residential_Type];

-- Load data into Dim_Buyer:
-- This code retrieves distinct buyer information from the staging table and inserts them into the Dim_Buyer table.
INSERT INTO dbo.Dim_Buyer ([BuyerID], [First_Name], [Last_Name], [Phone_Number])
SELECT 
DISTINCT [BuyerID], [First_Name], [Last_Name], [Phone_Number]
FROM dbo.Real_Estate_Sales_new_Staging
ORDER BY [BuyerID] ASC


-- Load FACT Table with all of the appropriate data from the Staging table
INSERT INTO [dbo].[Fact_Real_Estate_Sales]
           ([Serial_Number]
           ,[List_Year_ID]
           ,[Date_Recorded_ID]
           ,[Address_ID]
           ,[Property_ID]
           ,[OPM_remarks_ID]
           ,[Assessor_Remarks_ID]
           ,[Non_Use_Code_ID]
           ,[Location_ID]
           ,[BuyerID]
           ,[Assessed_Value]
           ,[Sale_Amount]
           ,[Sales_Ratio])
		   SELECT
			[Serial_Number]
           ,[List_Year_ID]
           ,[Date_Recorded_ID]
           ,[Address_ID]
           ,[Property_ID]
           ,[OPM_remarks_ID]
           ,[Assessor_Remarks_ID]
           ,[Non_Use_Code_ID]
           ,[Location_ID]
           ,[BuyerID]
           ,[Assessed_Value]
           ,[Sale_Amount]
           ,[Sales_Ratio]
		  FROM [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_new_Staging];



