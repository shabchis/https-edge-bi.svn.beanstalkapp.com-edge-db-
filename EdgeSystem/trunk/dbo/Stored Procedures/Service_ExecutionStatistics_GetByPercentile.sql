CREATE PROCEDURE [dbo].[Service_ExecutionStatistics_GetByPercentile]
	-- Add the parameters for the stored procedure here
	@Percentile INT
AS
BEGIN
	  SELECT [ConfigName]
		  ,[ConfigID]
		  ,[ProfileID]
		  ,[Value] 
	  FROM [EdgeSystem].[dbo].[ServiceExecutionStatistics]
	  WHERE [Percentile] = @Percentile;
END