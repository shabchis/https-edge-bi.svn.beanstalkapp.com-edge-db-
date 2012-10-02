
-- =============================================
-- Author:		Amit Bluman
-- Create date: May 17th 2012
-- update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delivery_Transform_Adwords_Generic]
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
	Declare @EdgeSystemDeliveryTablePath as nvarchar(4000)
	Declare @AdTable as nvarchar(4000)
	Declare @AdCreativeTable as nvarchar(4000)
	Declare @AdSegmentTable as nvarchar(4000)
	Declare @AdTargetTable as nvarchar(4000)
	Declare @MetricsTargetMatchTable as nvarchar(4000)
	Declare @CampaignsTable as nvarchar(4000)
	Declare @AdgroupsTable as nvarchar(4000)
	Declare @MetricsTable as nvarchar(4000)
	Declare @MetricsUnifiedTable as nvarchar(4000)
	Declare @CreativeUnifiedTable as nvarchar(4000)
	Declare @TargetingUnifiedTable as nvarchar(4000)
	Declare @FinalMetricsTable as nvarchar(4000)
	Declare @TargetingMatchUnifiedTable as nvarchar(4000)
	Declare @TrackersTable as nvarchar(4000)
	Declare @TargetingMatchSegmentTable as nvarchar(4000)
	
	Declare @SQL as nvarchar(4000)
	Declare @SQL1 as nvarchar(4000)
	Declare @newLine as nvarchar(50)
	Declare @DislayTime as nvarchar(50)
	Declare @DebugMode as bit
	
	/*
	-- Start Debug
				declare @MeasuresFieldNamesSQL as nvarchar(4000)
				declare @MeasuresNamesSQL as nvarchar(4000)
				declare @DeliveryID as nvarchar(4000)
				declare @DeliveryTablePrefix as nvarchar(4000)
				declare @CommitTableName as nvarchar(4000)
				set @DeliveryTablePrefix = 'AD_1240235_20120618_153352_15a08454486f42698b5d1b69c6e80abf'
				set @DeliveryID = '15a08454486f42698b5d1b69c6e80abf'
				set @MeasuresNamesSQL = ',[AveragePosition],[Cost],[Clicks],[Impressions],[UniqueImpressions],[UniqueClicks],[AdCenterConversions]'
				set @MeasuresFieldNamesSQL= ',[Pos],[cost],[Clicks],[Imps],[unique_impressions],[unique_clicks],[Conv]'
	-- End Debug
	*/

	set @DeliveryDB = 'Deliveries'
	set @OLTPDB = 'testdb'		
	set @CommitTableName = 'Paid_API_AllColumns_v29'
	set @EdgeSystemDeliveryTablePath = '[Edge_System291].[dbo].[DeliveryOutput]'

	set @AdTable = @DeliveryTablePrefix + '_Ad' 
	set @AdCreativeTable = @DeliveryTablePrefix + '_AdCreative' 
	set @AdSegmentTable = @DeliveryTablePrefix + '_AdSegment' 
	set @AdTargetTable = @DeliveryTablePrefix + '_AdTarget' 
	set @MetricsTargetMatchTable = @DeliveryTablePrefix + '_MetricsDimensionTarget' 
	set @MetricsTable = @DeliveryTablePrefix + '_Metrics' 
	set @MetricsUnifiedTable = @DeliveryTablePrefix + '_Commit_MetricsUnified' 
	set @CreativeUnifiedTable = @DeliveryTablePrefix + '_Commit_CreativeUnified' 
	set @TargetingUnifiedTable = @DeliveryTablePrefix + '_Commit_TargetingUnified' 
	set @TargetingMatchUnifiedTable = @DeliveryTablePrefix + '_Commit_TargetingMatchUnified' 
	set @FinalMetricsTable = @DeliveryTablePrefix + '_Commit_FinalMetrics' 
	set @CampaignsTable = @DeliveryTablePrefix +'_Commit_Campaigns' 
	set @AdgroupsTable = @DeliveryTablePrefix +'_Commit_Adgroups' 
	set @TrackersTable = @DeliveryTablePrefix +'_Commit_Trackers' 
	set @TargetingMatchSegmentTable = @DeliveryTablePrefix +'_MetricsDimensionSegment' 
	
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
				IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE name = ''' + @AdTable +'_HeaderFields'')
				DROP INDEX [' + @AdTable +'_HeaderFields] ON ' + @AdTable +' WITH ( ONLINE = OFF )
							
			CREATE CLUSTERED INDEX [' + @AdTable +'_HeaderFields] ON ' + @AdTable +'
			(
				[AdUsid] ASC,	[Channel_ID] ASC, [Account_ID] ASC,	[DestinationURL] ASC
			) ON [PRIMARY]
			
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE name = ''' + @AdCreativeTable +'_HeaderFields'')
					DROP INDEX [' + @AdCreativeTable +'_HeaderFields] ON ' + @AdCreativeTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX [' + @AdCreativeTable + '_HeaderFields] ON ' + @AdCreativeTable + '
			(
				[AdUsid] ASC,	[OriginalID] ASC,	[CreativeType] ASC,	[Field1] ASC,[Field2] ASC
			) ON [PRIMARY]
			
			IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE name = ''' + @MetricsTargetMatchTable +'_HeaderFields'')
					DROP INDEX [' + @MetricsTargetMatchTable +'_HeaderFields] ON ' + @MetricsTargetMatchTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX [' + @MetricsTargetMatchTable + '_HeaderFields] ON ' + @MetricsTargetMatchTable + '
			(
				[MetricsUsid] ASC,
				[AdUsid] ASC,
				[TypeID] ASC,
				[OriginalID] ASC,
				[DestinationUrl] ASC,
				[Field1] ASC,
				[Field2] ASC
			) ON [PRIMARY]	
		
			IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE name = ''' + @MetricsTargetMatchTable +'_Type'')
					DROP INDEX [' + @MetricsTargetMatchTable +'_Type] ON ' + @MetricsTargetMatchTable +' WITH ( ONLINE = OFF )
						  
			CREATE NONCLUSTERED INDEX [' + @MetricsTargetMatchTable +'_Type] ON ' + @MetricsTargetMatchTable +'
			(
					[TypeID] ASC
			) ON [PRIMARY]	
			  
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE  name = ''' + @AdSegmentTable +'_HeaderFields'')
					DROP INDEX [' + @AdSegmentTable +'_HeaderFields] ON ' + @AdSegmentTable +' WITH ( ONLINE = OFF )
					
		
			CREATE CLUSTERED INDEX [' + @AdSegmentTable + '_HeaderFields] ON ' + @AdSegmentTable + '
			(
				[AdUsid] ASC,	[SegmentID] ASC, [TypeID] ASC, 	[OriginalID] ASC, 	[Field1] ASC, [Field2] ASC
			) ON [PRIMARY]
	
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE  name = ''' + @MetricsTable +'_HeaderFields'')
					DROP INDEX [' + @MetricsTable +'_HeaderFields] ON ' + @MetricsTable +' WITH ( ONLINE = OFF )
			CREATE CLUSTERED INDEX  [' + @MetricsTable + '_HeaderFields] ON ' + @MetricsTable + '
			(
				[AdUsid] ASC,
				[MetricsUsid] ASC
			) ON [PRIMARY]
			
			'
			Print @SQL
			exec (@sql)
			
	-- Check if _campaigns table exists	    
	IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@CampaignsTable) 
     BEGIN
		set @sql = ''
		set @sql = 'Drop table ' + @CampaignsTable 
	    exec (@sql)
	  END
    
	-- Create _campaigns table
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create _campaigns table...'+@newLine +@newLine 
	
	set @sql = 
	' USE '+ @DeliveryDB +'
		CREATE TABLE ' + @CampaignsTable + '(
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[Name] [nvarchar](4000) NOT NULL,
	[OriginalID] [nvarchar](4000)  NULL,
	[CampaignGK] [nvarchar](50) NOT NULL,
	[Status] [int] NULL
	) ON [PRIMARY]'
	exec (@sql)

	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
			insert into '+@CampaignsTable+'
		SELECT
				Ad.Account_ID			as AccountID,
				Ad.Channel_ID			as ChannelID,
				Segment.Value			as Name,
				Segment.OriginalID		as OriginalID,
				''-1''					as CampaignGK,
				Segment.Status			as [Status]			
			FROM '+ @AdTable +' Ad
				inner join  '+ @AdSegmentTable +' Segment
						on Ad.AdUsid = Segment.AdUsid
			WHERE Segment.SegmentID = -875 -- Campaign indicator
			GROUP BY
				Ad.Account_ID,
				Ad.Channel_ID,
				Segment.Value,
				Segment.Status,
				Segment.OriginalID
		UNION ALL
			SELECT 	top 1	
				Ad.Account_ID			as AccountID,
				Ad.Channel_ID			as ChannelID,
				''Unknown''				as Name,
				''0''					as OriginalID,
				(-1) * Ad.Account_ID	as CampaignGK,
				''0''					as [Status]			
			FROM '+ @AdTable +' Ad
				inner join  '+ @AdSegmentTable +' Segment
					on Ad.AdUsid = Segment.AdUsid
			WHERE Segment.SegmentID = -875 -- Campaign indicator	
			
	
		-- create primary key for fast join
	--	alter table ' + @CampaignsTable + ' with nocheck
	--	add constraint ' + @CampaignsTable + '_pk_campaign primary key clustered (AccountID, ChannelID, Name, OriginalID)'

	exec (@sql)
			
	-- Update Gks for campaigns from GkManager_GetCampaignGK_WithReturn SP
	 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for campaigns from GkManager_GetCampaignGK_WithReturn SP...'	+@newLine +@newLine 
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @name nvarchar(4000);
			Declare @OriginalID nvarchar(500);
			Declare @CampaignGK nvarchar(500);

			DECLARE index_cursor CURSOR FOR 
					SELECT  [AccountID]
							,[ChannelID]
							,[Name]
							,[OriginalID]
					FROM ' +@CampaignsTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID ,@ChannelID  ,@Name ,@OriginalID

			WHILE @@FETCH_STATUS = 0
			BEGIN

				execute  @CampaignGK =  '+ @OLTPDB +' .dbo.GkManager_GetCampaignGK_WithReturn
					@account_id = @AccountID,
					@Channel_id = @ChannelID,
					@Campaign = @Name,
					@Campaignid = @OriginalID 
					
				--	print ''GetCampaignGK ''+ convert(nvarchar(400),CONVERT (time, GETDATE()))
					
				Update ' +@CampaignsTable + '
				set		CampaignGK = @CampaignGK
				from ' +@CampaignsTable + ' campaigns
				where campaigns.Accountid = @AccountID and
					campaigns.Channelid = @ChannelID and
					campaigns.Name = @Name and
					IsNull(campaigns.OriginalID,0) = IsNull(@OriginalID,0)
					
			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID ,@ChannelID  ,@Name ,@OriginalID

			END 
			CLOSE index_cursor
			DEALLOCATE index_cursor
			'
		
		exec (@sql)
		

	-- Check if _adgroups table exists	
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create _Adgroups table...'	+@newLine +@newLine
     
		IF EXISTS
		 (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@AdgroupsTable) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @AdgroupsTable 
			exec (@sql)
		  END

  -- Create _Adgroups table
		set @sql = 
		' USE '+ @DeliveryDB +' 
			CREATE TABLE ' + @AdgroupsTable + '(
		[AccountID] [int] NOT NULL,
		[ChannelID] [int] NOT NULL,
		[Name] [nvarchar](4000) NOT NULL,
		[OriginalID] [nvarchar](500) NOT NULL,
		[CampaignGK] [nvarchar](50) NOT NULL,
		[AdgroupGK] [nvarchar](50) NULL,
		) ON [PRIMARY]'
		exec (@sql)
		  
		set @SQL = ''
		set @SQL = ' USE '+ @DeliveryDB +'
				insert into ' + @AdgroupsTable + '
				SELECT 
						campaigns.AccountID			as AccountID,
						campaigns.ChannelID			as ChannelID,
						adgroups.Value				as Name,
						adgroups.OriginalID			as OriginalID, -- the originalId on Facebook is null cause we R creating it then I inserted the adgroupname as an ID
						campaigns.CampaignGK		as CampaignGK,
						''-1''						as AdgroupGK
					FROM
						'+ @AdSegmentTable + ' Adgroups 
						inner join ' + @CampaignsTable + ' Campaigns on
							Campaigns.Name = Adgroups.Field1
					WHERE adgroups.SegmentID= -876
					GROUP BY
						Campaigns.AccountID,
						Campaigns.ChannelID	,
						Campaigns.CampaignGK,
						Adgroups.Value,
						Adgroups.OriginalID
				UNION ALL
				SELECT 	top 1	
						campaigns.AccountID			as AccountID,
						campaigns.ChannelID			as ChannelID,
						''Unknown''					as Name,
						''0''						as OriginalID,
						(-1) * Campaigns.AccountID	as CampaignGK,
						(-1) * Campaigns.AccountID	as AdgroupGK
					FROM ' + @CampaignsTable + ' campaigns
				
				-- create primary key for fast join
				alter table ' + @AdgroupsTable + ' with nocheck
				add constraint ' + @AdgroupsTable + 'pk_adgroup primary key clustered (AccountID, ChannelID, Name, OriginalID, CampaignGK)
				
				-- Create OriginalID index	
				CREATE NONCLUSTERED INDEX [' + @AdgroupsTable + '_OriginalID] 
				ON ' + @AdgroupsTable + '   ([OriginalID] ASC )ON [PRIMARY]
				'
			exec (@sql)
		
-- Update Gks for adgroups from GkManager_GetAdgroupGK_WithReturn SP
if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for adgroups from GkManager_GetAdgroupGK_WithReturn SP...'	+@newLine +@newLine 
	
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @name nvarchar(4000);
			Declare @OriginalID nvarchar(500);
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);


			DECLARE index_cursor CURSOR FOR 
					SELECT  [AccountID]
							,[ChannelID]
							,[Name]
							,[OriginalID]
							,[CampaignGK]
					FROM ' + @AdgroupsTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID ,@ChannelID  ,@Name ,@OriginalID , @CampaignGK

			WHILE @@FETCH_STATUS = 0
			BEGIN
						 		
				execute  @AdgroupGK =  '+ @OLTPDB +' .dbo.GkManager_GetAdgroupGK_WithReturn
					@account_id = @AccountID,
					@Channel_id = @ChannelID,
					@Adgroup = @Name,
					@AdgroupID = @OriginalID,
					@Campaign_GK = @CampaignGK
					
				--	print ''GetAdgroupGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
					
				Update ' + @AdgroupsTable + '
				set		AdgroupGK = @AdgroupGK
				from ' + @AdgroupsTable + ' adgroups
				where adgroups.Accountid = @AccountID and
					adgroups.Channelid = @ChannelID and
					adgroups.Name = @Name and
					IsNull(adgroups.OriginalID,0) = IsNull(@OriginalID,0) and
					adgroups.CampaignGK = @CampaignGK

			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID ,@ChannelID  ,@Name ,@OriginalID , @CampaignGK

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
			
			-- checks if there is a @MetricsUnifiedTable view
			IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@MetricsUnifiedTable) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop view ' + @MetricsUnifiedTable 
			exec (@sql)
		  END
				-- create Metrics unified view
				if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Creates metrics unified view...'	+@newLine +@newLine 
		
			set @sql = ''
			Set @sql = '
			CREATE VIEW ' + @MetricsUnifiedTable +'
				AS	
				Select *,
					case	
					when month(TargetPeriodStart) <10 and day(TargetPeriodStart) <10  then  
						convert(varchar(4),year(TargetPeriodStart))+  ''0'' + convert(varchar(2),month(TargetPeriodStart))+ ''0'' +convert(varchar(2),day(TargetPeriodStart))
					when  month(TargetPeriodStart) <10 and day(TargetPeriodStart) >9  then  
						convert(varchar(4),year(TargetPeriodStart))+  ''0'' + convert(varchar(2),month(TargetPeriodStart)) +convert(varchar(2),day(TargetPeriodStart))
					when  month(TargetPeriodStart) >9 and day(TargetPeriodStart) >9  then  
						convert(varchar(4),year(TargetPeriodStart))+  convert(varchar(2),month(TargetPeriodStart)) +convert(varchar(2),day(TargetPeriodStart))
					when month(TargetPeriodStart) >9 and day(TargetPeriodStart) <10  then  
						convert(varchar(4),year(TargetPeriodStart))+  convert(varchar(2),month(TargetPeriodStart))+ ''0'' +convert(varchar(2),day(TargetPeriodStart))		
					end as Day_Code
			from '+@MetricsTable
			exec (@sql)	
	
	-- create Creative unified view
						IF EXISTS
				 (SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@CreativeUnifiedTable ) 
				 BEGIN
					set @sql = ''
					set @sql = 'Drop view ' + @CreativeUnifiedTable 
					exec (@sql)
				  END
				
				if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create creative unified view...'	+@newLine +@newLine 
			
			set @sql = ''
			set @sql1 =''
		-- Add CreativeGK and PPCcreativeGK column to  @AdCreativeTable table in order to use it 
		-- as an input field to the creative unified view
			IF NOT EXISTS
				(SELECT distinct 1
				FROM dbo.sysobjects SO INNER JOIN dbo.syscolumns SC ON SO.id = SC.id  
				WHERE SO.xtype = 'U' 
					AND SO.NAME= @AdCreativeTable
					AND (SC.NAME = 'CreativeGK' OR SC.NAME = 'PPCCreativeGK'))
			BEGIN
					set @sql = ''
					set @sql = 'Alter table ' + @AdCreativeTable +' add [CreativeGK] [int] NULL, [PPCCreativeGK] [int] NULL'
					exec (@sql)
			END

	Set @sql = ' 
			CREATE VIEW ' + @CreativeUnifiedTable +'
				AS
			SELECT Creative1.[AdUsid]
			  ,Creative1.[OriginalID]
			  ,Creative1.[Name]
			  ,Creative1.[CreativeType]
			  ,Creative1.Title
			  ,Creative1.ImgSize
			  ,Creative2.Body
			  ,Creative2.Body2
			  ,Creative3.DisplayURL
			  ,Creative1.CreativeGK
			  ,Creative1.PPCCreativeGK
			  ,Adgroups.AccountID
			  ,Adgroups.ChannelID
			  ,Ad1.DestURL
			  ,Adgroups.AdgroupGK
			  ,Adgroups.CampaignGK
			From (
			SELECT [AdUsid]
			  ,[OriginalID]
			  ,[Name]
			  ,[CreativeType]
			  ,[Field2] as Title
			  ,[Field3] as ImgSize
			  ,[Field4]
			  ,	 CreativeGK 
			  ,  PPCCreativeGK
			FROM ' + @AdCreativeTable +'
			where (creativeType = 1 and Field1 = ''1'') OR (creativeType = 2)
		  ) Creative1 
		  
		  left outer join
		  (  SELECT  [AdUsid]
			  ,[OriginalID]
			  ,[Name]
			  ,[CreativeType]
			 , [Field2] as Body  -- should be desc1
			  ,[Field3] as Body2 -- should be desc2 valid only for Adwords current clients
			  ,[Field4]
		  FROM ' + @AdCreativeTable +'
		  where creativeType = 1 and Field1 = ''2''
		  ) Creative2 on creative1.[AdUsid] = creative2.[AdUsid]  
		   
		   left outer join
		  ( 
			SELECT  [AdUsid]
			  ,[OriginalID]
			  ,[Name]
			  ,[CreativeType]
			  ,[Field2] as DisplayURL
			  ,[Field3]
			  ,[Field4]
		  FROM ' + @AdCreativeTable +'
		  where (creativeType = 1 and Field1 = ''3'')
		  ) Creative3 on creative1.[AdUsid] = creative3.[AdUsid]  
		   left outer join
		  ( 			
		  	SELECT [AdUsid]
		  ,[Name]
		  ,[OriginalID]
		  ,[DestinationUrl] as DestURL
			FROM ' + @AdTable +'
		  ) ad1 on creative1.[AdUsid] = ad1.[AdUsid] 
		  left outer join (
			  SELECT [AdUsid]
			  ,[SegmentID]
			  ,[Value]
			  ,[OriginalID]
					FROM ' + @AdSegmentTable +'
					where SegmentID = -876
		  ) AdSegment on AdSegment.[AdUsid] = ad1.[AdUsid] 
		 
	  left outer join (
			SELECT [AccountID]
			  ,[ChannelID]
			  ,[Name]
			  ,[OriginalID]
			  ,[CampaignGK]
			  ,[AdgroupGK]
		  FROM  ' + @AdgroupsTable +'
	  ) Adgroups on Adgroups.[OriginalID] = AdSegment.OriginalID
	'
  exec (@sql+@sql1)
  
  			-- checks if there is a @TargetingUnifiedTable view
			IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@TargetingUnifiedTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop view ' + @TargetingUnifiedTable 
			exec (@sql)
		  END
			
			-- create Targeting unified view
			if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create targeting unified view...'	+@newLine +@newLine 
		
			set @sql = ''
			Set @sql = '
			CREATE VIEW ' + @TargetingUnifiedTable +'
				AS
		  
		  SELECT Targeting1.[AdUsid]
			  ,Targeting1.[OriginalID]
			  ,Targeting1.[TypeID]
			  ,Targeting1.[DestinationUrl]
			  ,Targeting1.TargetingGender
			  ,Targeting2.TargetingFromAge
			  ,Targeting2.TargetingToAge
		  FROM 
		(SELECT [AdUsid]
			  ,[OriginalID]
			  ,[TypeID]
			  ,[DestinationUrl]
			  ,[Field1] as TargetingGender
			  ,[Field2]
		  FROM ' + @AdTargetTable +'
		  where TypeID = 3 -- Gender
		 ) Targeting1
		  left outer join 
		 ( SELECT [AdUsid]
			  ,[OriginalID]
			  ,[TypeID]
			  ,[DestinationUrl]
			  ,[Field1] as TargetingFromAge
			  ,[Field2] as TargetingToAge
		  FROM ' + @AdTargetTable +'
		  where TypeID = 4 -- Age
		  ) Targeting2 
			on Targeting1.[AdUsid]= Targeting2.[AdUsid] 
		'
    exec (@sql)
 
 	-- Update Gks for Creatives from GkManager_GetcreativeGK_WithReturn & GkManager_GetPPCCreativeGK_WithReturn SP
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for Creatives from GkManager_GetcreativeGK_WithReturn & GkManager_GetPPCCreativeGK_WithReturn SP...'	+@newLine +@newLine 
	
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +' 
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @OriginalID nvarchar(500) ;
			Declare @name nvarchar(4000);
			Declare @CreativeDestURL nvarchar(4000);
			Declare @CreativeVisURL nvarchar(4000);
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);
			Declare @CreativeGK nvarchar(500);
			Declare @PPCCreativeGK nvarchar(500);
			Declare @Title nvarchar(4000);
			Declare @Body nvarchar(4000);
			Declare @Body2 nvarchar(4000);


			DECLARE index_cursor CURSOR FOR 
					SELECT  [AccountID]
							,[ChannelID]
							,[OriginalID]
							,[Name]
							,[DestURL]
							,[DisplayURL]
							,[CampaignGK]
							,[AdgroupGK]
							,[Title]
							,[Body]
							,[Body2]
					FROM ' + @CreativeUnifiedTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @OriginalID ,@name ,@CreativeDestURL , @CreativeVisURL ,@CampaignGK ,@AdgroupGK , @Title, @Body, @Body2
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				 			
				execute  @CreativeGK =  '+ @OLTPDB +' .dbo.GkManager_GetCreativeGK_WithReturn
					@account_id = @AccountID,
					@Creative_Title = @Title,
					@Creative_Desc1 = @Body,
					@Creative_Desc2 = @Body2
					
				
				execute  @PPCCreativeGK =  '+ @OLTPDB +' .dbo.GkManager_GetAdgroupCreativeGK_WithReturn			
					@Account_ID	 = @AccountID,		
					@Channel_ID	 = @ChannelID,		
					@Campaign_GK = @CampaignGK,
					@AdGroup_GK	 = @AdgroupGK,	
					@Creative_GK = @CreativeGK, 	
					@creativeDestUrl = @CreativeDestURL,
					@creativeVisUrl	= @CreativeVisURL	
				
				-- print ''GetCreativeGK*2 '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @CreativeUnifiedTable + '
				set		CreativeGK = @CreativeGK , PPCCreativeGK = @PPCCreativeGK
				from ' + @CreativeUnifiedTable + ' Creatives
				where Creatives.AccountID = @AccountID and
						Creatives.ChannelID = @ChannelID and
						IsNull(Creatives.Name,0) = IsNull(@Name,0) and
						IsNull(Creatives.OriginalID,0) = IsNull(@OriginalID,0) and
						Creatives.CampaignGK = @CampaignGK and
						Creatives.AdgroupGK = @AdgroupGK and					
						IsNull(Creatives.[DestURL],0) = IsNull(@CreativeDestURL,0) and
						IsNull(Creatives.[DisplayURL],0) = IsNull(@CreativeVisURL,0) and
						IsNull(Creatives.[Title],0) = IsNull(@Title,0) and
						IsNull(Creatives.[Body],0) = IsNull(@Body,0) and
						IsNull(Creatives.[Body2],0) = IsNull(@Body2,0)

			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @OriginalID ,@name ,@CreativeDestURL , @CreativeVisURL ,@CampaignGK ,@AdgroupGK , @Title, @Body, @Body2

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
			
				-- checks if there is a @TargetingMatchUnifiedTable view
			IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='v' AND name=@TargetingMatchUnifiedTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop view ' + @TargetingMatchUnifiedTable 
			exec (@sql)
		  END
		  IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='U' AND name=@TargetingMatchUnifiedTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @TargetingMatchUnifiedTable 
			exec (@sql)
		  END
			
	-- create Targeting unified view

		-- Add KeywordGK and PPCKeywordGK column to  @MetricsTargetMatchTable table in order to use it 
		-- as an input field to the Targeting unified view
			IF NOT EXISTS
				(SELECT distinct 1
				FROM dbo.sysobjects SO INNER JOIN dbo.syscolumns SC ON SO.id = SC.id  
				WHERE SO.xtype = 'U' 
					AND SO.NAME= @MetricsTargetMatchTable 
					AND (SC.NAME = 'KeywordGK' OR SC.NAME = 'PPCKeywordGK'))
			BEGIN
					set @sql = ''
					set @sql = 'Alter table ' + @MetricsTargetMatchTable +' add [KeywordGK] [int] NULL, [PPCKeywordGK] [int] NULL'
					exec (@sql)
			END

			if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create Targeting unified view...'	+@newLine +@newLine 
			
			set @sql = ''
			Set @sql = '
		  
		    SELECT TargetingMatch1.[AdUsid]
			  ,TargetingMatch1.[MetricsUsid]
			  ,TargetingMatch1.[OriginalID]
			  ,TargetingMatch1.[TypeID]
			  ,TargetingMatch1.DestinationUrl as KeywordDestUrl
			  ,TargetingMatch1.Keyword
			  ,TargetingMatch1.MatchType
			  ,TargetingMatch1.QualityScore
			  ,TargetingMatch1.KeywordGK 
			  ,TargetingMatch1.PPCKeywordGK 
			  ,Adgroups.AccountID
			  ,Adgroups.ChannelID
			  ,ad1.DestURL
			  ,Adgroups.AdgroupGK
			  ,Adgroups.CampaignGK
	     INTO ' + @TargetingMatchUnifiedTable +'
			  
		  FROM 
		(SELECT [AdUsid]
			  ,[MetricsUsid]
			  ,[OriginalID]
			  ,[TypeID]
			  ,[DestinationUrl]
			  ,[Field1] as Keyword
			  ,[Field2] as MatchType
			  ,[Field3] as QualityScore
			  ,KeywordGK 
			  ,PPCKeywordGK 
		  FROM ' + @MetricsTargetMatchTable +'
		  where TypeID in (2,5) and Field1 is not null -- Keyword + Managed Sites (the auto sites has field1=null)
		 ) TargetingMatch1
		 
		 Left outer join 
		(	  
		  	SELECT [AdUsid]
		  ,[Name]
		  ,[OriginalID]
		  ,[DestinationUrl] as DestURL
	  FROM ' + @AdTable + '
		  ) ad1 on TargetingMatch1.[AdUsid] = ad1.[AdUsid]
		  
		  left outer join (
			  SELECT distinct [AdUsid]
			  ,[SegmentID]
			  ,[Value]
			  ,[OriginalID]
					FROM '+ @AdSegmentTable +'
					where SegmentID = -876
		  ) AdSegment on AdSegment.[AdUsid] = ad1.[AdUsid] 
		 
	  left outer join (
			SELECT [AccountID]
			  ,[ChannelID]
			  ,[Name]
			  ,[OriginalID]
			  ,[CampaignGK]
			  ,[AdgroupGK]
		  FROM  '+ @AdgroupsTable +'
	  ) Adgroups on Adgroups.[OriginalID] = AdSegment.OriginalID
	 	
	 CREATE NONCLUSTERED INDEX [' + @TargetingMatchUnifiedTable +'_HeaderFields''] 
			ON ' + @TargetingMatchUnifiedTable +' 
			(
				[AccountID] ASC,
				[ChannelID] ASC,
				[CampaignGK] ASC,
				[AdgroupGK] ASC,
				[Keyword] ASC,
				[OriginalID] ASC,
				[KeywordDestUrl] ASC,
				[MatchType] ASC
			)ON [PRIMARY]
			
	CREATE CLUSTERED INDEX [' + @TargetingMatchUnifiedTable +'_pk''] 
			ON ' + @TargetingMatchUnifiedTable +' 
			(
			[AdUsid] ASC,
			[MetricsUsid] ASC
			)ON [PRIMARY]
	 	'
	 	
    exec (@sql)
 
 
 	-- Update Gks for Keywords from GkManager_GetkeywordGK_WithReturn & GkManager_GetPPCKeywordGK_WithReturn SP
		if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for Keywords from GkManager_GetkeywordGK_WithReturn & GkManager_GetPPCKeywordGK_WithReturn SP...'	+@newLine +@newLine 
	
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);
			Declare @KeywordOriginalID nvarchar(500) ;
			Declare @Keyword nvarchar(4000);
			Declare @KeywordDestURL nvarchar(4000);
			Declare @MatchType int;
			Declare @KeywordGK nvarchar(500);
			Declare @PPCKeywordGK nvarchar(500);

			DECLARE index_cursor CURSOR FOR 
					SELECT   [AccountID]
							,[ChannelID]
							,[CampaignGK]
							,[AdgroupGK]
							,[OriginalID]
							,[Keyword]
							,[KeywordDestURL]
							,[MatchType]	
					FROM ' + @TargetingMatchUnifiedTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @KeywordOriginalID, @Keyword, @KeywordDestURL, @MatchType
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				 			
				execute  @KeywordGK =  '+ @OLTPDB +' .dbo.GkManager_GetKeywordGK_WithReturn
								@account_id = @AccountID,
								@Keyword = @Keyword
					
				
				execute  @PPCKeywordGK =  '+ @OLTPDB +' .dbo.GkManager_GetAdgroupKeywordGK_WithReturn			
					@Account_ID	 = @AccountID,		
					@Channel_ID	 = @ChannelID,		
					@Campaign_GK = @CampaignGK,
					@AdGroup_GK	 = @AdgroupGK,	
					@Keyword_GK  = @KeywordGK , 	
					@KWDestUrl   = @KeywordDestURL,
					@MatchType	 = @MatchType
				
				-- print ''GetKeywordGK*2 '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @TargetingMatchUnifiedTable + '
				set		KeywordGK = @KeywordGK , PPCKeywordGK = @PPCKeywordGK
				from ' + @TargetingMatchUnifiedTable + ' Keywords
				where	Keywords.AccountID = @AccountID and
						Keywords.ChannelID = @ChannelID and
						Keywords.CampaignGK = @CampaignGK and
						Keywords.AdgroupGK = @AdgroupGK and	
						Keyword = @Keyword and
						IsNull(Keywords.OriginalID,0) = IsNull(@KeywordOriginalID,0) and
						IsNull(Keywords.[KeywordDestURL],0) = IsNull(@KeywordDestURL,0) and
						IsNull(Keywords.[MatchType],0) = IsNull(@MatchType,0) 

			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @KeywordOriginalID, @Keyword, @KeywordDestURL, @MatchType

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
			
			-- checks if there is a @TrackersTable 
				IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@TrackersTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @TrackersTable 
			exec (@sql)
		  END
		  
		  -- Create @TrackersTable table
		   if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create trackers table ...' +@newLine +@newLine
	
	set @sql = ''
	set @SQL =' USE '+ @DeliveryDB +' 
	CREATE TABLE ' + @TrackersTable + '(
		[AccountID] [int] NOT NULL,
		[ChannelID] [int] NOT NULL,
		[CampaignGK] [nvarchar](50) NOT NULL,
		[AdgroupGK] [nvarchar](50) NOT NULL,
		[TrackerName] [nvarchar](4000) NOT NULL,
		[TrackerID] [nvarchar](500) NOT NULL,
		[TrackerDestURL] [nvarchar](4000) NOT NULL,
		[CreativeGK] [nvarchar](50) NULL, -- as Reference GK
		[ReferenceType] [int] NULL , -- will be 0
		[TrackerGK] [nvarchar](50) NULL
		) ON [PRIMARY]'
		exec (@sql)
		  
		set @SQL = ''
		set @SQL1 = ''
		set @SQL = '
				insert into ' + @TrackersTable + '
				select distinct
					Adgroups.AccountID			as AccountID,
					Adgroups.ChannelID			as ChannelID,
					Adgroups.CampaignGK			as CampaignGK,
					Adgroups.AdgroupGK			as AdgroupGK,
					Trackers.Value				as TrackerName,
					Trackers.OriginalID			as TrackerID,
					Ads.DestinationUrl			as TrackerDestURL,
					Creatives.CreativeGK		as CreativeGK,
					0							as ReferenceType,
					Null						as TrackerGK
				from
					' + @AdSegmentTable +' Adsegment
					inner join 
					' + @AdSegmentTable +' Trackers on
						 Adsegment.AdUsid = Trackers.AdUsid
					inner join ' + @AdgroupsTable + ' Adgroups on
						Adsegment.OriginalID = Adgroups.OriginalID
					inner join ' + @CreativeUnifiedTable + ' Creatives on
						Creatives.AdUsid = Trackers.AdUsid
					inner join ' + @AdTable +' Ads on
						Ads.AdUsid = Trackers.AdUsid
				Where	Trackers.SegmentID=  -977 and
						Adsegment.SegmentID= -876
				union all		 
				select 	top 1	
					Adgroups.AccountID			as AccountID,
					-1							as ChannelID,
					(-1) * Adgroups.AccountID	as CampaignGK,
					(-1) * Adgroups.AccountID	as AdgroupGK,
					''Unknown''					as TrackerName,
					''0''						as TrackerID,
					''Unknown''					as TrackerDestURL,
					0							as CreativeGK,
					0 							as ReferenceType,
					NULL						as TrackerGK
				from ' + @AdgroupsTable + ' Adgroups	
				
			-- **** This part is the for Trackers keywords, will be activated later ****
				
				--insert into ' + @TrackersTable + '
				--  select distinct
				--	Adgroups.AccountID			as AccountID,
				--	Adgroups.ChannelID			as ChannelID,
				--	Adgroups.CampaignGK			as CampaignGK,
				--	Adgroups.AdgroupGK			as AdgroupGK,
				--	Trackers.Value				as TrackerName,
				--	Trackers.OriginalID	as TrackerID,
				--	TargetMatch.KeywordDestURL	as TrackerDestURL,
				--	TargetMatch.KeywordGK		as CreativeGK,
				--	1							as ReferenceType,
				--	Null						as TrackerGK
				--from
				--	 ' + @TargetingMatchSegmentTable + ' Trackers 
				--	inner join 
				--	' + @AdSegmentTable +' Adsegment
				--		on  Adsegment.AdUsid = Trackers.AdUsid
				--	inner join 
				--	 ' + @TargetingMatchUnifiedTable + ' TargetMatch
				--		on Trackers.AdUsid = TargetMatch.AdUsid
				--		and Trackers.MetricsUsid = TargetMatch.MetricsUsid
				--	inner join  ' + @AdgroupsTable + ' Adgroups on
				--		Adsegment.OriginalID = Adgroups.OriginalID
				--Where	Trackers.SegmentID = -977 
				--		and Adsegment.SegmentID = -876
				'
		set @SQL1 = '		
				-- create primary key for fast join
				-- alter table ' + @TrackersTable + ' with nocheck
				-- add constraint ' + @TrackersTable + 'pk_Tracker primary key clustered (AccountID, ChannelID, CampaignGK, AdgroupGK, TrackerID)
				
				-- Create OriginalID index	
				CREATE NONCLUSTERED INDEX [' + @TrackersTable + '_OriginalID] 
				ON ' + @TrackersTable + '   ([AccountID] ASC,
						[ChannelID] ASC,
						[CampaignGK] ASC,
						[AdgroupGK] ASC,
						[TrackerName] ASC,
						[CreativeGK] ASC,
						[ReferenceType] ASC,
						[TrackerDestURL] ASC,
						[TrackerID] ASC 
				) ON [PRIMARY]
									
				CREATE NONCLUSTERED INDEX [' + @TrackersTable + '_pk]  ON ' + @TrackersTable + '
				( [TrackerName] ASC,
					[TrackerDestURL] ASC,
					[CampaignGK] ASC,
					[AdgroupGK] ASC
				)ON [PRIMARY]
				
			'
			
			exec (@sql + @sql1)
			
				-- Update Tracker Gks
	 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Tracker Gks' +@newLine +@newLine
	
	
	set @sql = ''
	set @sql = '
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);
			Declare @TrackerName nvarchar(500) ; -- gateway_id
			Declare @CreativeGK nvarchar(500); -- referenceID
			Declare @ReferenceType int;
			Declare @destURL nvarchar(4000);
			Declare @TrackerGK as nvarchar(500);

			DECLARE index_cursor CURSOR FOR 
					SELECT  [AccountID]
							,[ChannelID]
							,[CampaignGK]
							,[AdgroupGK]
							,[TrackerName]
							,[CreativeGK]
							,[ReferenceType]
							,[TrackerDestURL]
					FROM ' + @TrackersTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK ,@AdgroupGK ,@TrackerName , @CreativeGK ,@ReferenceType ,@destURL
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				
				execute  @TrackerGK =  '+ @OLTPDB +' .dbo.GkManager_GetGatewayGK_WithReturn			
					@Account_ID	 = @AccountID ,		
					@Channel_ID	 = @ChannelID ,		
					@Campaign_GK = @CampaignGK ,
					@AdGroup_GK	 = @AdgroupGK ,
					@Gateway_ID  = @TrackerName ,
					@Reference_ID = @CreativeGK , 	
					@Reference_Type = @ReferenceType ,
					@Dest_URL	= @destURL	
				
				-- print ''GetTrackerGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @TrackersTable + '
				set		TrackerGK = @TrackerGK 
				from ' + @TrackersTable + ' Trackers
				where	Trackers.AccountID = @AccountID and
						Trackers.ChannelID = @ChannelID and
						Trackers.CampaignGK = @CampaignGK and
						Trackers.AdgroupGK = @AdgroupGK and		
						Trackers.TrackerName = @TrackerName and
						IsNull(Trackers.CreativeGK,0) = IsNull(@CreativeGK,0) and
						IsNull(Trackers.ReferenceType,0) = IsNull(@ReferenceType,0) and
						IsNull(Trackers.TrackerDestURL,0) = IsNull(@destURL,0)
			
			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK ,@AdgroupGK ,@TrackerName , @CreativeGK ,@ReferenceType ,@destURL

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
		
-- Gathering all the data from all the tables into FinalMetrics table

  			-- checks if there is a FinalMetrics table
			IF EXISTS
		(SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@FinalMetricsTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @FinalMetricsTable 
			exec (@sql)
		  END
		 
	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create final metrics table' +@newLine +@newLine  
		 
	set @sql = ''
	set @sql1 = ''
	set @sql = ' USE '+ @DeliveryDB +'
	select	'''+ @DeliveryID +''' as DeliveryID,''' +@DeliveryTablePrefix +''' as DeliveryFileName ,
	    Ads.Name as AdName, Ads.DestinationUrl as [destUrl] , 
		Ads.Account_OriginalID as AccountOriginalID,
	    Ads.OriginalID as AdOriginalID, Ads.ExtraField2 as AdVariation,
					Case 
					when TargetingMatchUnified.MatchType in (1,2,3) then ''Search Only'' 
					when TargetingMatchUnified.MatchType in (4,5) then ''Content Only'' 
					else NULL 
					end as NetworkType  ,
	    Adgroups.Name as Adgroup , Adgroups.AdgroupGK as adgroup_gk, Adgroups.OriginalID as AdgroupID,
	    Campaigns.AccountID as AccountID,  Campaigns.ChannelID as ChannelID, 
		Campaigns.CampaignGK as campaign_gk, 
	    Campaigns.Name as Campaign , Campaigns.OriginalID as CampaignID , Campaigns.[Status] as CampStatus,
	    CreativeUnified.CreativeType as CreativeType, CreativeUnified.Title as imgCreativeName, CreativeUnified.Title as Title,  
	    CreativeUnified.body as Body,
	    CreativeUnified.body2 as Body2, CreativeUnified.DisplayURL as DisplayURL,  
	    CreativeUnified.CreativeGK as CreativeGK, CreativeUnified.PPCCreativeGK as PPCCreativeGK, CreativeUnified.OriginalID as CreativeOriginalID,
	    TargetingUnified.TargetingGender as TargetingGender, TargetingUnified.TargetingFromAge as TargetingFromAge,
	    TargetingUnified.TargetingToAge as TargetingToAge,
	--  IsNull( KeywordTrackers.TrackerName ,Trackers.TrackerName) as TrackerName, 
	--	IsNull( KeywordTrackers.TrackerGK, Trackers.TrackerGK) as TrackerGK,
	--  IsNull( KeywordTrackers.ReferenceType ,Trackers.ReferenceType) as ReferenceType, 
		Trackers.TrackerName as TrackerName, 
		Trackers.TrackerGK as TrackerGK,
		Trackers.ReferenceType as ReferenceType,   
	    TargetingMatchUnified.Keyword, TargetingMatchUnified.MatchType , TargetingMatchUnified.QualityScore,
	    TargetingMatchUnified.KeywordGK, TargetingMatchUnified.PPCKeywordGK, TargetingMatchUnified.OriginalID as KeywordID, 
	    TargetingMatchUnified.KeywordDestURL as KeywordDestURL,
	    MetricsUnified.*
	into	' + @FinalMetricsTable + '
	from	'+	@MetricsUnifiedTable +' MetricsUnified '
	
	set @sql1 = '	inner join	'+	@AdTable +' Ads
			on MetricsUnified.AdUsid = Ads.AdUsid
		inner join '+	@AdSegmentTable +' Adsegments
			on Adsegments.AdUsid = MetricsUnified.AdUsid and Adsegments.segmentID = -876
		inner join  '+ @CreativeUnifiedTable +' CreativeUnified
			on CreativeUnified.AdUsid = MetricsUnified.AdUsid 
		inner join '+@AdgroupsTable +' Adgroups
			on Adgroups.OriginalID = Adsegments.OriginalID and Adsegments.segmentID = -876
		inner join '+@CampaignsTable +' Campaigns
			on Campaigns.CampaignGK = Adgroups.CampaignGK
		left outer join '+	@AdSegmentTable +' Adsegments1
			on Adsegments1.AdUsid = MetricsUnified.AdUsid and Adsegments1.segmentID = -977
		left outer join '+ @TrackersTable +' Trackers
			on Trackers.TrackerName = Adsegments1.Value 
			and Adsegments1.segmentID = -977
			and Trackers.ReferenceType = 0					-- AdTrackers Only
			and Trackers.TrackerDestURL =  Ads.DestinationUrl
			and Trackers.CampaignGK =  Campaigns.CampaignGK
			and Trackers.adgroupGK =  Adgroups.AdgroupGK
			and Trackers.CreativeGK = CreativeUnified.CreativeGK
		left outer join '+ @TargetingUnifiedTable +' TargetingUnified
			on TargetingUnified.AdUsid = MetricsUnified.AdUsid
		left outer join '+ @TargetingMatchUnifiedTable +' TargetingMatchUnified
			on TargetingMatchUnified.Adusid = MetricsUnified.AdUsid 
			and TargetingMatchUnified.MetricsUsid = MetricsUnified.MetricsUsid 
		--left outer join '+ @TargetingMatchSegmentTable	 +' TargetingMatchSegment
		--	on TargetingMatchUnified.Adusid = TargetingMatchSegment.AdUsid 
		--	and TargetingMatchUnified.MetricsUsid = TargetingMatchSegment.MetricsUsid 
		--	and TargetingMatchSegment.segmentID = -977
		--left outer join '+ @TrackersTable +' KeywordTrackers
		--	on KeywordTrackers.TrackerName = TargetingMatchSegment.Value 
		--	and TargetingMatchSegment.segmentID = -977
		--	and KeywordTrackers.ReferenceType = 1  							-- KeywordTrackers Only
		--	and KeywordTrackers.TrackerDestURL =  TargetingMatchUnified.KeywordDestUrl
		--	and KeywordTrackers.CampaignGK =  Campaigns.CampaignGK
		--	and KeywordTrackers.adgroupGK =  Adgroups.AdgroupGK
		--	and KeywordTrackers.CreativeGK = TargetingMatchUnified.KeywordGK
				'

exec (@sql+@sql1)


	print 'Final metrics creation ended'

		-- Set this delivery + signature to be Transformed in the delivery output table 
			set @SQL= ''
			set @SQL = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				SET [Status] = 2
				WHERE DeliveryID = ''' +@DeliveryID + ''''  
				
			Exec Sp_executesql @SQL
			print 'END'
	
		
END


