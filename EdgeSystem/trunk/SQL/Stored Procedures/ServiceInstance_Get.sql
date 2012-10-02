-- =============================================
-- Author:		daterre
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ServiceInstance_Get] 
	@instanceID char(32),
	@stateInfoOnly bit 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @parentInstanceID char(32);

	while(1=1)
	begin
		if @stateInfoOnly = 1
			select Progress, State, Outcome, TimeCreated ,TimeInitialized, TimeStarted, TimeEnded, TimeLastPaused, TimeLastResumed from ServiceInstance_v3 where InstanceID = @instanceID;
		else
			select * from ServiceInstance_v3 where InstanceID = @instanceID;

		select @parentInstanceID = ParentInstanceID from ServiceInstance_v3 where InstanceID = @instanceID;
		if (@parentInstanceID is null)
			break;
		else
			set @instanceID = @parentInstanceID;
	end
END
