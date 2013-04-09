CREATE PROCEDURE [dbo].[Service_EnvironmentEventListenerUnregister]
	@listenerID char(32)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	delete from ServiceEnvironmentEvent
	where ListenerID = @listenerID;
END