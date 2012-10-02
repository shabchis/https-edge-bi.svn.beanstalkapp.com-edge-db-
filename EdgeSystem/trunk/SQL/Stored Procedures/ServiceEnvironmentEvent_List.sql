CREATE PROCEDURE [dbo].ServiceEnvironmentEvent_List 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select EventType, EndpointName, EndpointAddress from ServiceEnvironmentEvent;
END
