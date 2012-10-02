CREATE PROCEDURE [dbo].ServiceExecutionHost_Register
	@hostName nvarchar(50),
	@hostGuid char(32),
	@endpointName nvarchar(100),
	@endpointAddress nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    EXEC [dbo].[Service_HostUnregister] @hostName;
	insert into ServiceExecutionHost (HostName, HostGuid, EndpointName, EndpointAddress)
		values (@hostName, @hostGuid, @endpointName, @endpointAddress);
END
