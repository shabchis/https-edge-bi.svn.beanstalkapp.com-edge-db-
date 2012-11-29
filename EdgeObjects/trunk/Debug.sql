GO
DECLARE	@return_value int
EXEC	@return_value = [dbo].[GetTablesList]
		@accountID = 10035,
		@channelID = 1

SELECT	'Return Value' = @return_value

GO


--DECLARE	@return_value int

--EXEC	@return_value = [dbo].[ConversionAlerts]
--		@AccountID = 1239,
--		@Period = 30,
--		@ToDay = '2012-10-31 00:00:00',
--		@ChannelID = 1,
--		@threshold = 3,
--		@excludeIds = '101274942'

--SELECT	'Return Value' = @return_value




--DECLARE	@return_value int

--EXEC	@return_value = [dbo].[GetTableStructureByName]
--		@virtualTableName = N'PPCKeyword'

--SELECT	'Return Value' = @return_value



