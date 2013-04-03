-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MD_Measure_Get]
	@accountID int,
	@channelID int = null,
	@measureID int = null,
	@includeBase bit = 0,
	@flags int = 0xff,
	@operator int = 0
	
AS
BEGIN
	SET NOCOUNT ON;

	select	t.ID, t.AccountID, t.Name, t.DisplayName, 
			t.DataType, t.Options, t.OptionsOverride
	from dbo.MD_Measure t
	where (t.AccountID = @accountID or t.AccountID = -1)

END