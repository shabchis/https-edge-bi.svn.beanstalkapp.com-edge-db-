CREATE PROCEDURE [dbo].[MD_EdgeType_Get]
	@accountID int
	
AS
BEGIN
	SET NOCOUNT ON;

	select t.AccountID, t.ChannelID, t.BaseTypeID, t.ClrType, t.Name, t.TableName, t.TypeID
	from dbo.MD_EdgeType t
	where t.AccountID = @accountID or t.AccountID = -1
END