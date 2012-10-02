-- =============================================
-- Author:		daterre
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE ServiceInstance_Save 
	
	@instanceID char(32),
	@parentInstanceID char(32),
	@profileID char(32),
	@serviceName nvarchar(100),
	@hostName nvarchar(50),
	@hostGuid char(32),
	@progress float,
	@state int,
	@outcome int,
	@timeInitialized datetime,
	@timeStarted datetime,
	@timeEnded datetime,
	@timeLastPaused datetime,
	@timeLastResumed datetime,
	@resumeCount int,
	@configuration xml,
	@Scheduling_Status int,
	@Scheduling_Scope int,
	@Scheduling_MaxDeviationBefore bigint,
	@Scheduling_MaxDeviationAfter bigint,
	@Scheduling_RequestedTime datetime,
	@Scheduling_ExpectedStartTime datetime,
	@Scheduling_ExpectedEndTime datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @isUpdate int;
	select @isUpdate = count(1) from ServiceInstance_v3 where InstanceID = @instanceID;
	
	if (@isUpdate = 1)
		update ServiceInstance_v3
		set
			[InstanceID] = @instanceID,
			[ParentInstanceID] = @parentInstanceID,
			[ProfileID] = @profileID,
			[ServiceName] = @serviceName,
			[HostName] = @hostName,
			[HostGuid] = @hostGuid,
			[Progress] = @progress,
			[State] = @state,
			[Outcome] = @outcome,
			[TimeInitialized] = @timeInitialized,
			[TimeStarted] = @timeStarted,
			[TimeEnded] = @timeEnded,
			[TimeLastPaused] = @timeLastPaused,
			[TimeLastResumed] = @timeLastResumed,
			[ResumeCount] = @resumeCount,
			[Configuration] = ISNULL(@configuration, si.Configuration),
			[Scheduling_Status] = @Scheduling_Status,
			[Scheduling_Scope] = @Scheduling_Scope,
			[Scheduling_MaxDeviationBefore] = @Scheduling_MaxDeviationBefore,
			[Scheduling_MaxDeviationAfter] = @Scheduling_MaxDeviationAfter,
			[Scheduling_RequestedTime] = @Scheduling_RequestedTime,
			[Scheduling_ExpectedStartTime] = @Scheduling_ExpectedStartTime,
			[Scheduling_ExpectedEndTime] = @Scheduling_ExpectedEndTime
		from ServiceInstance_v3 si
		where
			InstanceID = @instanceID;
	else
		insert into ServiceInstance_v3
		(
			[InstanceID],
			[ParentInstanceID],
			[ProfileID],
			[ServiceName],
			[HostName],
			[HostGuid],
			[Progress],
			[State],
			[Outcome],
			[TimeInitialized],
			[TimeStarted],
			[TimeEnded],
			[TimeLastPaused],
			[TimeLastResumed],
			[ResumeCount],
			[Configuration],
			[Scheduling_Status],
			[Scheduling_Scope],
			[Scheduling_MaxDeviationBefore],
			[Scheduling_MaxDeviationAfter],
			[Scheduling_RequestedTime],
			[Scheduling_ExpectedStartTime],
			[Scheduling_ExpectedEndTime]
		)
		values
		(
			@instanceID,
			@parentInstanceID,
			@profileID,
			@serviceName,
			@hostName,
			@hostGuid,
			@progress,
			@state,
			@outcome,
			@timeInitialized,
			@timeStarted,
			@timeEnded,
			@timeLastPaused,
			@timeLastResumed,
			@resumeCount,
			@configuration,
			@Scheduling_Status,
			@Scheduling_Scope,
			@Scheduling_MaxDeviationBefore,
			@Scheduling_MaxDeviationAfter,
			@Scheduling_RequestedTime,
			@Scheduling_ExpectedStartTime,
			@Scheduling_ExpectedEndTime
		);

END
