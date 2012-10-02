
-- =============================================
-- Author:		Amit Bluman
-- Create date: Jan 9th 2012
-- update date: Apr 10th 2012
-- Last update: Adjust the Commit SP to the new Generic BO delivery format
--				Mar 20th 2012 - Added a "distinct" to the final metrics creation, in order to avoid the duplicate ads in bbinary
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delivery_OLD_Commit_BO_Generic]
	@DeliveryID					Nvarchar(4000),
	@DeliveryTablePrefix		Nvarchar(4000),
	@MeasuresNamesSQL			Nvarchar(4000) = null,
	@MeasuresFieldNamesSQL		Nvarchar(4000) = null,
	@CommitTableName			Nvarchar(4000) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
		
	Declare @DeliveryDB as nvarchar(4000)
	Declare @OLTPDB as nvarchar(4000)

	Declare @SegmentTable as nvarchar(4000)
	Declare @MetricsTable as nvarchar(4000)
	Declare @FinalMetricsTable as nvarchar(4000)
	Declare @TrackersTable as nvarchar(4000)
	
	Declare @SQL as nvarchar(4000)
	Declare @SQL1 as nvarchar(4000)
	Declare @newLine as nvarchar(50)
	Declare @DislayTime as nvarchar(50)
	Declare @DebugMode as bit
	
	-- Start Debug
	/*			declare @DeliveryID as nvarchar(4000);
				declare @DeliveryTablePrefix as nvarchar(4000);
				declare @CommitTableName as nvarchar(4000);
				set @DeliveryTablePrefix = 'GEN_95_20120410_132125_9887011e40ce4612b236fa296e259765'
				set @DeliveryID = '9887011e40ce4612b236fa296e259765'
	*/
	-- End Debug
	set @DeliveryDB = 'Deliveries'
	set @OLTPDB = 'TestDB'		
	set @CommitTableName = 'BackOffice_Client_Gateway'
	
	set @SegmentTable = @DeliveryTablePrefix + '_MetricsDimensionSegment' 
	set @MetricsTable = @DeliveryTablePrefix + '_Metrics' 
	set @FinalMetricsTable = @DeliveryTablePrefix + '_Commit_FinalMetrics' 
	set @TrackersTable = @DeliveryTablePrefix +'_Commit_Trackers' 
	
	set @DislayTime = convert(nvarchar(400),CONVERT (time, GETDATE()))
	set @newLine = CHAR(13)+CHAR(10)
	Set @DebugMode = 1 
	
	-- Check if the DeliveryID is empty
	if	(@DeliveryTablePrefix is null)
		return; 		 
	
	-- Create indexes
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create indexes on the deliveries tables...' + @newLine 
			set @SQL = ''
		
			set @SQL = 
			
			' USE '+ @DeliveryDB +'

		--  AdSegment index
			IF  EXISTS 
				(SELECT 1 FROM sys.indexes WHERE  name = ''' + @SegmentTable +'_HeaderFields'')
			DROP INDEX [' + @SegmentTable +'_HeaderFields] ON ' + @SegmentTable +' WITH ( ONLINE = OFF )		
		
			CREATE CLUSTERED INDEX [' + @SegmentTable + '_HeaderFields] ON ' + @SegmentTable + '
			(
				[MetricsUsid] ASC,
				[OriginalID] ASC
			) ON [PRIMARY]

		--  Metrics index
			IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE  name = ''' + @MetricsTable +'_HeaderFields'')
				DROP INDEX [' + @MetricsTable +'_HeaderFields] ON ' + @MetricsTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX  [' + @MetricsTable + '_HeaderFields] ON ' + @MetricsTable + '
			(
				[MetricsUsid] ASC,
				[DownloadedDate] ASC,
				[TargetPeriodStart] ASC,
				[TargetPeriodEnd] ASC
			) ON [PRIMARY]
			
			'
			EXEC (@sql)
		
	
	-- checks if there is a @TrackersTable 
	IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@TrackersTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @TrackersTable 
			EXEC (@sql)
		  END
		  
	  -- Create @TrackersTable table
		   if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create trackers table ...' +@newLine +@newLine
	
	set @sql = ''
	set @SQL =' USE '+ @DeliveryDB +' 
	CREATE TABLE ' + @TrackersTable + '(
		[AccountID] [int] NOT NULL,
		[TrackerID] [nvarchar](4000) NOT NULL,
		[TrackerGK] [nvarchar](50) NULL
		) ON [PRIMARY]'
		EXEC (@sql)
		  
		set @SQL = ''
		set @SQL = '
				insert into ' + @TrackersTable + '
				select distinct
					Metrics.Account_ID			as AccountID, 
					Trackers.Value				as TrackerID,
					Null						as TrackerGK
				from
					' + @SegmentTable +' Trackers 
					inner join 
					 '+ @MetricsTable +' Metrics
						on Trackers.MetricsUsid = Metrics.MetricsUsid
				Where	Trackers.SegmentID=  -977						
				union all		 
				select 	top 1	
					Metrics.Account_ID			as AccountID, 
					''0''						as TrackerID,
					NULL						as TrackerGK
				from ' + @SegmentTable + ' Trackers	
					inner join 
					 '+ @MetricsTable +' Metrics
						on Trackers.MetricsUsid = Metrics.MetricsUsid
		
			-- Create OriginalID index	
				CREATE NONCLUSTERED INDEX [' + @TrackersTable + '_OriginalID] 
				ON ' + @TrackersTable + '   (
						[AccountID] ASC,
						[TrackerID] ASC 
				) ON [PRIMARY]
			'
			
			EXEC (@sql)
			
	-- Update Tracker Gks
	 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Tracker Gks' +@newLine +@newLine
	
	
	set @sql = ''
	set @sql = '
			Declare @AccountID int;
			Declare @TrackerID nvarchar(4000) ; -- gateway_id
			Declare @TrackerGK as nvarchar(50);

			DECLARE index_cursor CURSOR FOR 
					SELECT  [AccountID]
							,[TrackerID]
					FROM ' + @TrackersTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @TrackerID

			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				
				EXECUTE  @TrackerGK =  '+ @OLTPDB +' .dbo.GkManager_GetGatewayGK_WithReturn			
					@Account_ID	 = @AccountID ,		
					@Gateway_ID  = @TrackerID 
					
				-- print ''GetTrackerGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @TrackersTable + '
				set		TrackerGK = @TrackerGK 
				from ' + @TrackersTable + ' Trackers
				where	Trackers.AccountID = @AccountID and
						Trackers.TrackerID = @TrackerID 
			
			-- Get the next index
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @TrackerID

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			EXEC (@sql)
		
-- Gathering all the data from all the tables into FinalMetrics table

  			-- checks if there is a FinalMetrics table
			IF EXISTS
		(SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@FinalMetricsTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @FinalMetricsTable 
			EXEC (@sql)
		  END
		 
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create final metrics table' +@newLine +@newLine  
		 
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
	select	distinct '''+ @DeliveryID +''' as DeliveryID,''' +@DeliveryTablePrefix +''' as DeliveryFileName ,
		Trackers.TrackerID, Trackers.TrackerGK, 
	    CASE	
					when month(TargetPeriodStart) <10 and day(TargetPeriodStart) <10  then  
						convert(varchar(4),year(TargetPeriodStart))+  ''0'' + convert(varchar(2),month(TargetPeriodStart))+ ''0'' +convert(varchar(2),day(TargetPeriodStart))
					when  month(TargetPeriodStart) <10 and day(TargetPeriodStart) >9  then  
						convert(varchar(4),year(TargetPeriodStart))+  ''0'' + convert(varchar(2),month(TargetPeriodStart)) +convert(varchar(2),day(TargetPeriodStart))
					when  month(TargetPeriodStart) >9 and day(TargetPeriodStart) >9  then  
						convert(varchar(4),year(TargetPeriodStart))+  convert(varchar(2),month(TargetPeriodStart)) +convert(varchar(2),day(TargetPeriodStart))
					when month(TargetPeriodStart) >9 and day(TargetPeriodStart) <10  then  
						convert(varchar(4),year(TargetPeriodStart))+  convert(varchar(2),month(TargetPeriodStart))+ ''0'' +convert(varchar(2),day(TargetPeriodStart))		
		END as Day_Code,
		Metrics.*
	 into	' + @FinalMetricsTable + '
	from	'+	@MetricsTable +' Metrics 
		
	inner join '+	@SegmentTable +' Segments
		on Segments.MetricsUsid = Metrics.MetricsUsid and Segments.segmentID = -977
	inner join '+ @TrackersTable +' Trackers
		on Trackers.TrackerID = Segments.Value 
		and Metrics.Account_ID = Trackers.AccountID
		and Segments.segmentID = -977
		'
EXEC (@sql)



		
END


