CREATE PROCEDURE [dbo].[Service_EnvironmentEventListenerListGet] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select ListenerID, EventType, EndpointName, EndpointAddress from ServiceEnvironmentEvent;
END