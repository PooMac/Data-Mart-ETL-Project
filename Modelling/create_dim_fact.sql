-- Create a staging table
CREATE TABLE [Real_Estate_Sales_DB].[dbo].[Real_Estate_Sales_Staging](
	[Source_Staging_ID] [int] IDENTITY(1,1) NOT NULL,
	[Serial_Number] [int] NULL,
	[List_Year] [int] NULL,
    [List_Year_ID] [int] NULL,
	[Date_Recorded] [varchar](100) NULL,
    [Date_Recorded_ID] [int] NULL,
	[Town] [varchar](100) NULL,
    [Town_ID] [int] NULL,
	[Address] [varchar](255) NULL,
    [Address_ID] [int] NULL,
	[Assessed_Value] [float] NULL,
	[Sale_Amount] [float] NULL,
	[Sales_Ratio] [float] NULL,
	[Property_Type] [varchar](100) NULL,
	[Residential_Type] [varchar](100) NULL,
    [Property_ID] [int] NULL,
	[Non_Use_Code] [varchar](100) NULL,
    [Non_Use_Code_ID] [int] NULL,
	[Assessor_Remarks] [varchar](max) NULL,
    [Assessor_Remarks_ID] [int] NULL,
	[OPM_remarks] [varchar](max) NULL,
    [OPM_remarks_ID] [int] NULL,
	[Location] [varchar](100) NULL,
    [Location_ID] [int] NULL,
    CONSTRAINT PK_Real_Estate_Sales_Staging PRIMARY KEY (Source_Staging_ID)
    );

-- Create Dimensional tables
CREATE TABLE [Dim_List_Year](
	[List_Year_ID] [int] IDENTITY(1,1) NOT NULL,
	[List_Year] [int] NULL,
    CONSTRAINT PK_Dim_List_Year PRIMARY KEY ([List_Year_ID])
);

CREATE TABLE [Dim_Date_Recorded](
	[Date_Recorded_ID] [int] IDENTITY(1,1) NOT NULL,
	[Date_Recorded] [varchar](100) NULL,
    CONSTRAINT PK_Dim_Date_Recorded PRIMARY KEY ([Date_Recorded_ID])
);

CREATE TABLE [Dim_Town](
	[Town_ID] [int] IDENTITY(1,1) NOT NULL,
    [Town] [varchar](100) NULL,
    CONSTRAINT PK_Dim_Town PRIMARY KEY ([Town_ID])
);

--Create the Dimension Address table. A Town can have multiple addresses, so I have created dimension hierarchy.
CREATE TABLE [Dim_Address](
	[Address_ID] [int] IDENTITY(1,1) NOT NULL,
	[Address] [varchar](255) NULL,
    [Town_ID] [int] NULL,
    CONSTRAINT PK_Dim_Address PRIMARY KEY ([Address_ID]),
    CONSTRAINT FK_Dim_Address FOREIGN KEY ([Town_ID]) REFERENCES [Dim_Town]([Town_ID])
);

CREATE TABLE [Dim_Property](
	[Property_ID] [int] IDENTITY(1,1) NOT NULL,
	[Property_Type] [varchar](100) NULL,
    [Residential_Type] [varchar](100) NULL,
    CONSTRAINT PK_Dim_Property PRIMARY KEY ([Property_ID])
);

CREATE TABLE [Dim_OPM_Remarks](
	[OPM_remarks_ID] [int] IDENTITY(1,1) NOT NULL,
    [OPM_remarks] [varchar](max) NULL,
    CONSTRAINT PK_Dim_OPM_Remarks PRIMARY KEY ([OPM_remarks_ID])
);

CREATE TABLE [Dim_Assessor_Remarks](
	[Assessor_Remarks_ID] [int] IDENTITY(1,1) NOT NULL,
    [Assessor_Remarks] [varchar](max) NULL,
    CONSTRAINT PK_Dim_Assessor_Remarks PRIMARY KEY ([Assessor_Remarks_ID])
);

CREATE TABLE [Dim_Non_Use_Code](
	[Non_Use_Code_ID] [int] IDENTITY(1,1) NOT NULL,
    [Non_Use_Code] [varchar](100) NULL,
    CONSTRAINT PK_Dim_Non_Use_Code PRIMARY KEY ([Non_Use_Code_ID])
);

CREATE TABLE [Dim_Location](
	[Location_ID] [int] IDENTITY(1,1) NOT NULL,
    [Location] [varchar](100) NULL,
    CONSTRAINT PK_Dim_Location PRIMARY KEY ([Location_ID])
);

create table [Dim_Buyer](
	[BuyerID] [int] NOT NULL,
	[First_Name] [nvarchar](50) NULL,
	[Last_Name] [nvarchar](50) NULL,
	[Phone_Number] [bigint] NULL,
	primary key(BuyerID));

--Create a Fact table
CREATE TABLE [Fact_Real_Estate_Sales](
	[Real_Estate_Sales_ID] [int] IDENTITY(1,1) NOT NULL,
    [Serial_Number] [int] NULL,
    [List_Year_ID] [int] NULL,
    [Date_Recorded_ID] [int] NULL,
    [Address_ID] [int] NULL,
    [Property_ID] [int] NULL,
    [OPM_remarks_ID] [int] NULL,
    [Assessor_Remarks_ID] [int] NULL,
    [Non_Use_Code_ID] [int] NULL,
    [Location_ID] [int] NULL,
    [BuyerID] [int] NULL,
    [Assessed_Value] [float] NULL,
	[Sale_Amount] [float] NULL,
	[Sales_Ratio] [float] NULL
    CONSTRAINT PK_Fact_Real_Estate_Sales PRIMARY KEY ([Real_Estate_Sales_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Year FOREIGN KEY ([List_Year_ID]) REFERENCES [Dim_List_Year]([List_Year_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Date FOREIGN KEY ([Date_Recorded_ID]) REFERENCES [Dim_Date_Recorded]([Date_Recorded_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Address FOREIGN KEY ([Address_ID]) REFERENCES [Dim_Address]([Address_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Property FOREIGN KEY ([Property_ID]) REFERENCES [Dim_Property]([Property_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_OPM_Remarks FOREIGN KEY ([OPM_remarks_ID]) REFERENCES [Dim_OPM_Remarks]([OPM_remarks_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Assessor_Remarks FOREIGN KEY ([Assessor_Remarks_ID]) REFERENCES [Dim_Assessor_Remarks]([Assessor_Remarks_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Non_Use_Code FOREIGN KEY ([Non_Use_Code_ID]) REFERENCES [Dim_Non_Use_Code]([Non_Use_Code_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Location FOREIGN KEY ([Location_ID]) REFERENCES [Dim_Location]([Location_ID]),
    CONSTRAINT FK_Fact_Real_Estate_Sales_Buyer FOREIGN KEY ([BuyerID]) REFERENCES [Dim_Buyer]([BuyerID])
);