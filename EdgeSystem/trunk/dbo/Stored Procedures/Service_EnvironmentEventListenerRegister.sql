CREATE PROCEDURE [dbo].[Service_EnvironmentEventListenerRegister]
	@listenerID char(32),
	@eventType nvarchar(50),
	@endpointName nvarchar(100),
	@endpointAddress nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into ServiceEnvironmentEvent (ListenerID, EventType, EndpointName, EndpointAddress)
		values (@listenerID, @eventType, @endpointName, @endpointAddress);
END