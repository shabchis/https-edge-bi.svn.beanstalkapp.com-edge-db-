-- =============================================
-- Author:		Shay Bar-Chen
-- Create date: 24/05/2011
-- Description:	Returns Google report definision ID  from google reports definitions table
-- =============================================
CREATE PROCEDURE [dbo].[GetGoogleReportDefinitionId]
	@Account_Id int, 
	@GoogleUniqueID Nvarchar(100),
	@Date_Range Nvarchar(100)= null,
	@Google_Report_Type Nvarchar(100) ,
	@StartDay Nvarchar(100) = null,
	@EndDay Nvarchar(100) = null,
	@ReportName Nvarchar(100) = null,
	@ReportFields Nvarchar(1000) = null

AS

BEGIN
IF @Date_Range != 'CUSTOM_DATE'
(
 -- get report by DateRange
		SELECT[Google_Report_ID] 
		FROM [GoogleReportsDefinitions]
		WHERE 
				Account_ID = @Account_Id
				and GoogleUniqueID = @GoogleUniqueID
				and Date_Range = @Date_Range
				and Google_Report_Type = @Google_Report_Type
				and ReportName = @ReportName
				and ReportFields = @ReportFields
)
ELSE
(
-- get report by start and end date
		SELECT[Google_Report_ID] 
		FROM [GoogleReportsDefinitions]
		WHERE 
				Account_ID = @Account_Id
				and GoogleUniqueID = @GoogleUniqueID
				and [Start_Date] = @StartDay
				and [End_Date] = @EndDay 
				and Google_Report_Type = @Google_Report_Type
				and ReportName = @ReportName
				and ReportFields = @ReportFields
)
		
END