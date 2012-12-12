GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[GetTableStructureByName]
		@virtualTableName = N'Ad'

SELECT	'Return Value' = @return_value

GO
