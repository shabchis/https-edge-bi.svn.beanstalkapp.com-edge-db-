CREATE PROCEDURE [dbo].[MD_EdgeTypeField_Get]
	@accountID int
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  tf.[FieldID], tf.[ParentTypeID], tf.[ColumnName], tf.[IsIdentity]
	FROM	dbo.MD_EdgeTypeField tf, dbo.MD_EdgeField f, dbo.MD_EdgeType t
	WHERE   tf.FieldID = f.FieldID AND
			t.TypeID = tf.ParentTypeID AND
			(t.AccountID = @accountID or t.AccountID = -1) AND
			(f.AccountID = @accountID or f.AccountID = -1)		
END