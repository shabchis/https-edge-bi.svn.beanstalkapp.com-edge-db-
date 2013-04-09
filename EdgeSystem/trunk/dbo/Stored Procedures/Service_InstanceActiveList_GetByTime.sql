CREATE PROCEDURE [dbo].[Service_InstanceActiveList_GetByTime]
	@timeframeStart datetime2
AS
BEGIN
	SELECT  [InstanceID], [Progress], [State], [Outcome], Configuration,
			[TimeCreated] ,[TimeInitialized], [TimeStarted], [TimeEnded], [TimeLastPaused], [TimeLastResumed],
			Scheduling_Status, Scheduling_Scope, Scheduling_MaxDeviationBefore, Scheduling_MaxDeviationAfter, 
			Scheduling_RequestedTime, Scheduling_ExpectedStartTime, Scheduling_ExpectedEndTime
	FROM    ServiceInstance_v3 AS s
	WHERE   /* only active services */
			(S.Scheduling_Status = 2) AND
			/* already started by not ended services*/
			((s.TimeInitialized <= @timeframeStart and s.TimeEnded IS NULL) or
			/* services which are already ended and can be scheduled according to max deviation*/ 
			(DATEADD(SECOND, s.Scheduling_MaxDeviationAfter, s.Scheduling_RequestedTime) >= @timeframeStart)); 
END