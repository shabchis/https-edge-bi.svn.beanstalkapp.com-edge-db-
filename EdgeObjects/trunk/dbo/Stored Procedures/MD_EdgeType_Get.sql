CREATE PROCEDURE [dbo].[MD_EdgeType_Get]
	@accountID int
	
AS
BEGIN
	SET NOCOUNT ON;

	select t.AccountID, t.ChannelID, t.BaseTypeID, t.ClrType, t.Name, t.TableName, t.TypeID, t.IsAbstract
	from dbo.MD_EdgeType t
	where t.AccountID = @accountID or t.AccountID = -1
	order by t.BaseTypeID
END