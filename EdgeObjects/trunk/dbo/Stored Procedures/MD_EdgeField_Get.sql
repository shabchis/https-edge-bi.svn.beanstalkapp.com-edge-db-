CREATE PROCEDURE [dbo].[MD_EdgeField_Get]
	@accountID int
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	t.DisplayName, t.FieldType, t.FieldID, t.Name, ISNULL(t.FieldTypeID, 0) as FieldTypeID
	FROM	dbo.MD_EdgeField t
	WHERE	t.AccountID = @accountID or t.AccountID = -1
END