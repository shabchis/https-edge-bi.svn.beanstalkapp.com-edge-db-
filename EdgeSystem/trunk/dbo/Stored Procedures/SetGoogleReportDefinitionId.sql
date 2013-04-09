-- =============================================
-- Author:		Shay Bar-Chen
-- Create date: 24/05/2011
-- Description:	Returns Google report definision ID  from google reports definitions table
-- =============================================
CREATE PROCEDURE [dbo].[SetGoogleReportDefinitionId]
	@Google_Report_Id int,
	@Account_Id int, 
	@GoogleUniqueID Nvarchar(100),
	@Date_Range Nvarchar(100),
	@Google_Report_Type Nvarchar(100) ,
	@StartDay Nvarchar(100) = null,
	@EndDay Nvarchar(100) = null,
	@Update bit = 0,
	@ReportName Nvarchar(100) = null,
	@ReportFields Nvarchar(1000) = null

AS

BEGIN

if (@Update = 0)
		INSERT INTO [GoogleReportsDefinitions]
		VALUES (@Google_Report_Id,@Google_Report_Type,@Account_Id,@GoogleUniqueID,
				@Date_Range,@StartDay,@EndDay,GETDATE(),@ReportName,@ReportFields)
else 

		UPDATE [GoogleReportsDefinitions]
		SET Google_Report_ID = @Google_Report_Id
		WHERE
				Account_ID = @Account_Id
				and GoogleUniqueID = @GoogleUniqueID
				and Date_Range = @Date_Range
				and [Start_Date] = @StartDay
				and End_Date = @EndDay
				and Creation_Time = GETDATE()
				and ReportName = @ReportName
				and ReportFields = @ReportFields
END