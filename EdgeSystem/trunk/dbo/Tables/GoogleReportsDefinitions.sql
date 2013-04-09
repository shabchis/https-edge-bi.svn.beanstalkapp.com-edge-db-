CREATE TABLE [dbo].[GoogleReportsDefinitions] (
    [Google_Report_ID]   INT             NOT NULL,
    [Google_Report_Type] NVARCHAR (100)  NOT NULL,
    [Account_ID]         INT             NOT NULL,
    [GoogleUniqueID]     NVARCHAR (100)  NOT NULL,
    [Date_Range]         NVARCHAR (100)  NULL,
    [Start_Date]         INT             NULL,
    [End_Date]           INT             NULL,
    [Creation_Time]      DATETIME        CONSTRAINT [DF_GoogleReportsDefinitions_Creation_Time] DEFAULT (getdate()) NULL,
    [ReportName]         NVARCHAR (100)  NULL,
    [ReportFields]       NVARCHAR (1000) NULL
);

