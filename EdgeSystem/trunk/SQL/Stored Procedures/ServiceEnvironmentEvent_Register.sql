CREATE PROCEDURE [dbo].ServiceEnvironmentEvent_Register
	@eventType nvarchar(50),
	@endpointName nvarchar(100),
	@endpointAddress nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    delete from ServiceEnvironmentEvent where EventType = @eventType;
	insert into ServiceEnvironmentEvent (EventType, EndpointName, EndpointAddress)
		values (@eventType, @endpointName, @endpointAddress);
END
