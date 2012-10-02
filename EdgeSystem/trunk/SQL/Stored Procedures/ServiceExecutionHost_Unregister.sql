CREATE PROCEDURE [dbo].ServiceExecutionHost_Unregister
	@hostName nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	delete from ServiceExecutionHost where HostName = @hostName;
END
