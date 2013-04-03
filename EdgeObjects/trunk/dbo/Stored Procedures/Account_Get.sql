-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Account_Get]
	@accountID int
	
AS
BEGIN
	SET NOCOUNT ON;

	select	t.ID, t.Name, t.ParentAccountID, t.Status
	from dbo.Account t
	where t.ID = @accountID 
END