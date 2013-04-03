-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Channel_Get]
AS

BEGIN
	SET NOCOUNT ON;

	select	t.ID, t.Name, t.ChannelType
	from dbo.Channel t
END