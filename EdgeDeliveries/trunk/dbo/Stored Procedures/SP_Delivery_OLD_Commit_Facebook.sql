﻿-- =============================================
-- Author:		Amit Bluman
-- Create date: June 22nd 2011
-- Last Updated: Jan 4th 2012
-- Description:	This SP will create 2 additional tables in order to save the adgroup & campaigns data
-- , create indexes on all tables
-- , create 2 additional views in order to gather the creative, keywords ,targeting & Metrics data
-- and then will create GKs for all the units. the output will be a final metrics table which will be inserted to Paid_api_allcolumns table
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delivery_OLD_Commit_Facebook]
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
	
	Declare @SQL as nvarchar(4000)
	Declare @SQL1 as nvarchar(4000)
	Declare @DebugMode as bit
	Declare @newLine as nvarchar(50)
	Declare @DislayTime as nvarchar(50)
	
	set @DeliveryDB = 'Deliveries'
	set @OLTPDB = 'testdb'	
	set @CommitTableName = 'Paid_API_AllColumns_v29'
	
	set @AdTable = @DeliveryTablePrefix + '_Ad' 
	set @AdCreativeTable = @DeliveryTablePrefix + '_AdCreative' 
	set @AdSegmentTable = @DeliveryTablePrefix + '_AdSegment' 
	set @AdTargetTable = @DeliveryTablePrefix + '_AdTarget' 
	set @MetricsTargetMatchTable = @DeliveryTablePrefix + '_MetricsTargetMatch' 
	set @MetricsTable = @DeliveryTablePrefix + '_Metrics' 
	set @MetricsUnifiedTable = @DeliveryTablePrefix + '_Commit_MetricsUnified' 
	set @CreativeUnifiedTable = @DeliveryTablePrefix + '_Commit_CreativeUnified' 
	set @TargetingUnifiedTable = @DeliveryTablePrefix + '_Commit_TargetingUnified' 
	set @TargetingMatchUnifiedTable = @DeliveryTablePrefix + '_Commit_TargetingMatchUnified' 
	set @FinalMetricsTable = @DeliveryTablePrefix + '_Commit_FinalMetrics' 
	set @CampaignsTable = @DeliveryTablePrefix +'_Commit_Campaigns' 
	set @AdgroupsTable = @DeliveryTablePrefix +'_Commit_Adgroups' 
	set @TrackersTable = @DeliveryTablePrefix +'_Commit_Trackers' 
	
	set @DislayTime = convert(nvarchar(40),CONVERT (time, GETDATE()))
	set @newLine = CHAR(13)+CHAR(10)
	--  Debug Parameter, this will display message on the message board
	Set @DebugMode = 1 
		
	if (@DebugMode=1)
		/*
		Begin			
				--declare @DeliveryID as nvarchar(4000)
				--declare @DeliveryTablePrefix as nvarchar(4000)
				set @DeliveryTablePrefix = 'D1007_20110629_055826_32e80326a6ab4a2ea841cc9ae95658fc'
				set @DeliveryID = '32e80326a6ab4a2ea841cc9ae95658fc'
				
		End
		*/
	
	-- Check if the DeliveryID is empty
	if	(@DeliveryTablePrefix is null)
		return; 		 

	-- Create indexes on the deliveries tables (origin)
		if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create indexes on the deliveries tables...' + @newLine 
		
			set @SQL = ''
			set @SQL = 
			
			' USE '+ @DeliveryDB +'
			
				IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE name = ''' + @AdTable +'_HeaderFields'')
				DROP INDEX [' + @AdTable +'_HeaderFields] ON ' + @AdTable +' WITH ( ONLINE = OFF )
							
			CREATE CLUSTERED INDEX [' + @AdTable +'_HeaderFields] ON ' + @AdTable +'
			(
				[AdUsid] ASC
			) ON [PRIMARY]
			
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE name = ''' + @AdCreativeTable +'_HeaderFields'')
					DROP INDEX [' + @AdCreativeTable +'_HeaderFields] ON ' + @AdCreativeTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX [' + @AdCreativeTable + '_HeaderFields] ON ' + @AdCreativeTable + '
			(
				[AdUsid] ASC,
				[OriginalID] ASC,
				[CreativeType] ASC,
				[Field1] ASC
			) ON [PRIMARY]
			
			IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE name = ''' + @MetricsTargetMatchTable +'_HeaderFields'')
					DROP INDEX [' + @MetricsTargetMatchTable +'_HeaderFields] ON ' + @MetricsTargetMatchTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX [' + @MetricsTargetMatchTable + '_HeaderFields] ON ' + @MetricsTargetMatchTable + '
			(
				[AdUsid] ASC,
				[OriginalID] ASC,
				[TargetType] ASC,
				[DestinationUrl] ASC,
				[Field1] ASC,
				[Field2] ASC
			) ON [PRIMARY]	
				  
			  
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE  name = ''' + @AdSegmentTable +'_HeaderFields'')
					DROP INDEX [' + @AdSegmentTable +'_HeaderFields] ON ' + @AdSegmentTable +' WITH ( ONLINE = OFF )
					
		
			CREATE CLUSTERED INDEX [' + @AdSegmentTable + '_HeaderFields] ON ' + @AdSegmentTable + '
			(
				[AdUsid] ASC,
				[ValueOriginalID] ASC
			) ON [PRIMARY]
			
	
				IF  EXISTS 
						(SELECT 1 FROM sys.indexes WHERE  name = ''' + @MetricsTable +'_HeaderFields'')
					DROP INDEX [' + @MetricsTable +'_HeaderFields] ON ' + @MetricsTable +' WITH ( ONLINE = OFF )
					
		
			CREATE CLUSTERED INDEX  [' + @MetricsTable + '_HeaderFields] ON ' + @MetricsTable + '
			(
				[AdUsid] ASC,
				[MetricsUnitGuid] ASC
			) ON [PRIMARY]
			
			'
			exec (@sql)
			
	-- Check if _campaigns table exists	
	    
	IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@CampaignsTable) 
     BEGIN
		set @sql = ''
		set @sql = 'Drop table ' + @CampaignsTable 
	    exec (@sql)
	  END
    
    if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create _campaigns table...'+@newLine +@newLine 
	-- Create _campaigns table
	set @sql = 
	' USE '+ @DeliveryDB +'
	
	CREATE TABLE ' + @CampaignsTable + '(
	[AccountID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[Name] [nvarchar](4000) NOT NULL,
	[OriginalID] [nvarchar](4000) NOT NULL,
	[CampaignGK] [nvarchar](50) NOT NULL,
	[Status] [int] NULL
	) ON [PRIMARY]'
	exec (@sql)

	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
		insert into '+@CampaignsTable+'
		select
			Campaign_Account_ID			as AccountID,
			Campaign_Channel			as ChannelID,
			Campaign_Name				as Name,
			Campaign_OriginalID			as OriginalID,
			''-1''						as CampaignGK,
			Campaign_Status				as [Status] 
		from '+ @AdTable +'
		group by
			Campaign_Account_ID,
			Campaign_Channel,
			Campaign_Name,
			Campaign_OriginalID,
			Campaign_Status
		union all
				select 	top 1	
					Campaign_Account_ID			as AccountID,
					Campaign_Channel			as ChannelID,
					''Unknown''					as Name,
					''0''						as OriginalID,
					(-1) * Campaign_Account_ID	as CampaignGK,
					0	as [Status] 
				from  '+ @AdTable +'
			
		-- create primary key for fast join
		alter table ' + @CampaignsTable + ' with nocheck
		add constraint ' + @CampaignsTable + '_pk_campaign primary key clustered (AccountID, ChannelID, Name, OriginalID)'

	exec (@sql)
		
	 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for campaigns from GkManager_GetCampaignGK_WithReturn SP...'	+@newLine +@newLine 
	 	-- Update Gks for campaigns from GkManager_GetCampaignGK_WithReturn SP
	set @sql = ''
	set @sql = '
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
		IF EXISTS
		 (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@AdgroupsTable) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @AdgroupsTable 
			exec (@sql)
		  END

 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create _Adgroups table...'	+@newLine +@newLine
  -- Create _Adgroups table
		set @sql = 
		'CREATE TABLE ' + @AdgroupsTable + '(
		[AccountID] [int] NOT NULL,
		[ChannelID] [int] NOT NULL,
		[Name] [nvarchar](4000) NOT NULL,
		[OriginalID] [nvarchar](500) NOT NULL,
		[CampaignGK] [nvarchar](50) NOT NULL,
		[AdgroupGK] [nvarchar](50) NULL,
		) ON [PRIMARY]'
		exec (@sql)
		  
		set @SQL = ''
		set @SQL = '
				insert into ' + @AdgroupsTable + '
				select 
					campaigns.AccountID						as AccountID,
					campaigns.ChannelID						as ChannelID,
					adgroups.Value							as Name,
					adgroups.ValueOriginalID				as OriginalID, -- the originalId on Facebook is null cause we R creating it then I inserted the adgroupname as an ID
					campaigns.CampaignGK					as CampaignGK,
					''-1''									as AdgroupGK
					
				from
					' + @AdTable +' Ad
					inner join ' + @AdSegmentTable + ' adgroups on
						adgroups.AdUsid = Ad.AdUsid
					inner join ' + @CampaignsTable + ' campaigns on
						campaigns.AccountID = Ad.Campaign_Account_ID and
						campaigns.ChannelID = Ad.Campaign_Channel and
						campaigns.Name = Ad.Campaign_Name
				Where adgroups.SegmentID= -876
				group by
					campaigns.AccountID,
					campaigns.ChannelID	,
					campaigns.CampaignGK,
					adgroups.Value,
					adgroups.ValueOriginalID
				Union all
				select 	top 1	
					campaigns.AccountID			as AccountID,
					campaigns.ChannelID			as ChannelID,
					''Unknown''					as Name,
					''0''						as OriginalID,
					(-1) * campaigns.AccountID	as CampaignGK,
					(-1) * campaigns.AccountID	as AdgroupGK
				from ' + @CampaignsTable + ' campaigns
				
				-- create primary key for fast join
				alter table ' + @AdgroupsTable + ' with nocheck
				add constraint ' + @AdgroupsTable + 'pk_adgroup primary key clustered (AccountID, ChannelID, Name, OriginalID, CampaignGK)
				
				-- Create OriginalID index	
				CREATE NONCLUSTERED INDEX [' + @AdgroupsTable + '_OriginalID] 
				ON ' + @AdgroupsTable + '   ([OriginalID] ASC )ON [PRIMARY]
				'
			exec (@sql)
			
		if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for adgroups from GkManager_GetAdgroupGK_WithReturn SP...'	+@newLine +@newLine 
	-- Update Gks for adgroups from GkManager_GetAdgroupGK_WithReturn SP
	set @sql = ''
	set @sql = '
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @name nvarchar(4000);
			Declare @OriginalID nvarchar(500);
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);
			Declare @debugSTR as nvarchar(4000);


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
					
			--	set @debugSTR	= ''|''+ convert(nvarchar(300),@AdgroupGK) +''|''+ convert(nvarchar(300),@AccountID)
			--			 +''|''+convert(nvarchar(300),@ChannelID)  +''|''+ convert(nvarchar(300),@Name) +''|''+convert(nvarchar(300),@OriginalID)
			--			  +''|''+ convert(nvarchar(300),@CampaignGK)
						  
			--		print ''GetAdgroupGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
			--		print ''Adgroup_gk params: ''+ @debugSTR
					
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
	
				-- checks if there is a @CreativeUnifiedTable view
				IF EXISTS
				 (SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@CreativeUnifiedTable ) 
				 BEGIN
					set @sql = ''
					set @sql = 'Drop view ' + @CreativeUnifiedTable 
					exec (@sql)
				  END
				-- create Creative unified view
				if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create creative unified view...'	+@newLine +@newLine 
				-- ***Add Keyword GK + PPC keyword GK
			
			set @sql = ''
			Set @sql = ' 
				CREATE VIEW ' + @CreativeUnifiedTable +'
				AS
		  
			SELECT Creative1.[AdUsid]
			  ,Creative1.[OriginalID]
			  ,Creative1.[Name]
			  ,Creative1.[CreativeType]
			  ,Creative1.Title
			  ,Creative2.Body
			  ,Creative2.Body2
			  ,Creative3.DisplayURL
			  ,Creative4.ImageURL
			  ,Creative1.CreativeGK
			  ,Creative1.PPCCreativeGK
			  ,ad1.AccountID
			  ,ad1.ChannelID
			  ,Ad1.DestURL
			  ,Adgroups.AdgroupGK
			  ,Adgroups.CampaignGK
			From (
			SELECT [AdUsid]
			  ,[OriginalID]
			  ,[Name]
			  ,[CreativeType]
			  ,[Field2] as Title
			  ,[Field3]
			  ,[Field4]
			  ,	CreativeGK
			  , PPCCreativeGK
			FROM ' + @AdCreativeTable +'
			where creativeType = 1 and Field1 = 1
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
		  where creativeType = 1 and Field1 = 2
		  ) Creative2 on creative1.[AdUsid] = creative2.[AdUsid] and creative1.[OriginalID] = creative2.[OriginalID] 
		   
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
		  where creativeType = 1 and Field1 = 3
		  ) Creative3 on creative1.[AdUsid] = creative3.[AdUsid] and creative1.[OriginalID] = Creative3.[OriginalID] 
		   left outer join
		  ( 

		  SELECT  [AdUsid]
			  ,[OriginalID]
			  ,[Name]
			  ,[CreativeType]
			   ,[Field2] as ImageURL
			  ,[Field3]
			  ,[Field4]
		  FROM ' + @AdCreativeTable +'
		  where creativeType = 2
		  ) Creative4 on creative1.[AdUsid] = creative4.[AdUsid] and creative1.[OriginalID] = Creative4.[OriginalID] 
			left outer join 
		(	
			
			SELECT [AdUsid]
		  ,[Name]
		  ,[OriginalID]
		  ,[DestinationUrl] as DestURL
		  ,[Campaign_Account_ID] as AccountID
		  ,[Campaign_Channel] as ChannelID
		  ,[Campaign_Name]
		  ,[Campaign_OriginalID]
		  ,[Campaign_Status]
	  FROM ' + @AdTable +'
		  ) ad1 on creative1.[AdUsid] = ad1.[AdUsid] --and creative1.[OriginalID] = ad1.[OriginalID] 
		  left outer join (
			  SELECT [AdUsid]
			  ,[SegmentID]
			  ,[Value]
			  ,[ValueOriginalID]
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
	  ) Adgroups on Adgroups.[OriginalID] = AdSegment.ValueOriginalID
	 	
	  '
	 --	This is the list of fields (+ the order) that we should have an index on
	 --	(AccountID, ChannelID, Name, OriginalID, CampaignGK ,AdgroupGK, DestURL, DisplayURL ,Title, Body, Body2 ) 
  exec (@sql)
  
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
			  ,Targeting1.[TargetType]
			  ,Targeting1.[DestinationUrl]
			  ,Targeting1.TargetingGender
			  ,Targeting2.TargetingFromAge
			  ,Targeting2.TargetingToAge
		  FROM 
		(SELECT [AdUsid]
			  ,[OriginalID]
			  ,[TargetType]
			  ,[DestinationUrl]
			  ,[Field1] as TargetingGender
			  ,[Field2]
		  FROM ' + @AdTargetTable +'
		  where targetType = 3 -- Gender
		 ) Targeting1
		  left outer join 
		 ( SELECT [AdUsid]
			  ,[OriginalID]
			  ,[TargetType]
			  ,[DestinationUrl]
			  ,[Field1] as TargetingFromAge
			  ,[Field2] as TargetingToAge
		  FROM ' + @AdTargetTable +'
		  where targetType = 4 -- Age
		  ) Targeting2 
			on Targeting1.[AdUsid]= Targeting2.[AdUsid] 
		'
    exec (@sql)
 
 	-- Update Gks for Creatives from GkManager_GetcreativeGK_WithReturn & GkManager_GetPPCCreativeGK_WithReturn SP
 	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for Creatives from GkManager_GetcreativeGK_WithReturn & GkManager_GetPPCCreativeGK_WithReturn SP...'	+@newLine +@newLine 
	set @sql = ''
	set @sql = '
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
							,[ImageURL]
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
				
				 --print ''GetCreativeGK*2 '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				 --print @CreativeGK
				
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
						IsNull(Creatives.[ImageURL],0) = IsNull(@CreativeVisURL,0) and
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
     (SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@TargetingMatchUnifiedTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop view ' + @TargetingMatchUnifiedTable 
			exec (@sql)
		  END
			-- create Targeting unified view
			if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create Targeting unified view...'	+@newLine +@newLine 
			
			set @sql = ''
			Set @sql = '
			CREATE VIEW ' + @TargetingMatchUnifiedTable +'
				AS
		  
		    SELECT TargetingMatch1.[AdUsid]
			  ,TargetingMatch1.[MetricsUnitGuid]
			  ,TargetingMatch1.[OriginalID]
			  ,TargetingMatch1.[TargetType]
			  ,	TargetingMatch1.[DestinationUrl]
			  ,TargetingMatch1.[Keyword]
			  ,	TargetingMatch1.[MatchType]
			  ,	TargetingMatch1.[KeywordGK] 
			  ,	TargetingMatch1.[PPCKeywordGK] 
			  ,	ad1.[AccountID]
			  ,	ad1.[ChannelID]
			  ,Ad1.[DestURL]
			  ,	Adgroups.[AdgroupGK]
			  ,	Adgroups.[CampaignGK]
			  
		  FROM 
		(SELECT [AdUsid]
				,[MetricsUnitGuid]
			  ,[OriginalID]
			  ,[TargetType]
			  ,[DestinationUrl]
			  ,''Unknown'' as Keyword	-- This is for backwords Compatibility
			  ,''1'' as MatchType		-- This is for backwords Compatibility
			  ,''0'' as KeywordGK		-- This is for backwords Compatibility
			  ,PPCKeywordGK				-- Will be calculated per each campaign & adgroup for keyword_gk 0
		  FROM ' + @MetricsTargetMatchTable +'
		  where targetType = 2 -- Keyword
		 ) TargetingMatch1
		 		 
		 Left outer join 
		(	  
		  	SELECT  [AdUsid]
		  ,[Name]
		  ,[OriginalID]
		  ,[DestinationUrl] as DestURL
		  ,[Campaign_Account_ID] as AccountID
		  ,[Campaign_Channel] as ChannelID
		  ,[Campaign_Name]
		  ,[Campaign_OriginalID]
		  ,[Campaign_Status]
	  FROM ' + @AdTable + '
		  ) ad1 on TargetingMatch1.[AdUsid] = ad1.[AdUsid]
		  
		  left outer join (
			  SELECT [AdUsid]
			  ,[SegmentID]
			  ,[Value]
			  ,[ValueOriginalID]
					FROM '+ @AdSegmentTable +'
		  ) AdSegment on AdSegment.[AdUsid] = ad1.[AdUsid] 
		 
	  left outer join (
			SELECT [AccountID]
			  ,[ChannelID]
			  ,[Name]
			  ,[OriginalID]
			  ,[CampaignGK]
			  ,[AdgroupGK]
		  FROM  '+ @AdgroupsTable +'
	  ) Adgroups on Adgroups.[OriginalID] = AdSegment.ValueOriginalID
	 	'
    exec (@sql)
 
 	-- Update Gks for Keywords from GkManager_GetkeywordGK_WithReturn & GkManager_GetPPCKeywordGK_WithReturn SP
 	if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for Keywords from GkManager_GetkeywordGK_WithReturn & GkManager_GetPPCKeywordGK_WithReturn SP...'	+@newLine +@newLine 
	set @sql = ''
	set @sql = '
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
							--,[OriginalID]
							--,[Keyword]
							,[DestinationURL]
							,[MatchType]	
					FROM ' + @TargetingMatchUnifiedTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @KeywordDestURL, @MatchType
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 			
				execute  @PPCKeywordGK =  '+ @OLTPDB +' .dbo.GkManager_GetAdgroupKeywordGK_WithReturn			
					@Account_ID	 = @AccountID,		
					@Channel_ID	 = @ChannelID,		
					@Campaign_GK = @CampaignGK,
					@AdGroup_GK	 = @AdgroupGK,	
					@Keyword_GK  = @KeywordGK , 	
					@KWDestUrl   = @KeywordDestURL,
					@MatchType	 = @MatchType
				
				 print ''GetPPCKeywordGK '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @TargetingMatchUnifiedTable + '
				set		PPCKeywordGK = @PPCKeywordGK
				from ' + @TargetingMatchUnifiedTable + ' Keywords
				where	Keywords.AccountID = @AccountID and
						Keywords.ChannelID = @ChannelID and
						Keywords.CampaignGK = @CampaignGK and
						Keywords.AdgroupGK = @AdgroupGK and	
						--	Keyword = @Keyword and
						--	IsNull(Keywords.OriginalID,0) = IsNull(@KeywordOriginalID,0) and
						IsNull(Keywords.[DestinationURL],0) = IsNull(@KeywordDestURL,0) and
						IsNull(Keywords.[MatchType],0) = IsNull(@MatchType,0) 

			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @KeywordDestURL, @MatchType

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
			
			-- Check if @TrackersTable exists
	IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='u' AND name=@TrackersTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop table ' + @TrackersTable 
			exec (@sql)
		  END
		  -- Create trackers table
		  if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create trackers table' +@newLine +@newLine
	
	set @sql = ''
	set @SQL ='
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
					Trackers.ValueOriginalID	as TrackerID,
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
						Adsegment.ValueOriginalID = Adgroups.OriginalID
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
				'
			set @SQL1 = '	
				-- create primary key for fast join
				--alter table ' + @TrackersTable + ' with nocheck
				--add constraint ' + @TrackersTable + 'pk_Tracker primary key clustered (AccountID, ChannelID, CampaignGK, AdgroupGK, TrackerName)
				
				-- Create OriginalID index	
				CREATE NONCLUSTERED INDEX [' + @TrackersTable + '_OriginalID] 
				ON ' + @TrackersTable + '    ([AccountID] ASC,
						[ChannelID] ASC,
						[CampaignGK] ASC,
						[AdgroupGK] ASC,
						[TrackerName] ASC,
						[CreativeGK] ASC,
						[ReferenceType] ASC,
						[TrackerDestURL] ASC,
						[TrackerID] ASC)ON [PRIMARY]
				'
			 if (@DebugMode=1)	print @newLine +@sql + @sql1 +@newLine	
			exec (@sql+@sql1)
	
	-- Update Tracker Gks
	 if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Tracker Gks...' +@newLine +@newLine
	--*******************************************************
	
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
	set @sql = '

	select	distinct '''+ @DeliveryID +''' as DeliveryID,''' +@DeliveryTablePrefix +''' as DeliveryFileName ,
	    Ads.DestinationUrl as [destUrl] , Ads.Campaign_Account_OriginalID as AccountOriginalID,
	    Ads.OriginalID as AdOriginalID,
	    Adgroups.Name as Adgroup , Adgroups.AdgroupGK as adgroup_gk, Adgroups.OriginalID as AdgroupID,
	    Campaigns.AccountID as AccountID,  Campaigns.ChannelID as ChannelID, 
		Campaigns.CampaignGK as campaign_gk, 
	    Campaigns.Name as Campaign , Campaigns.OriginalID as CampaignID , Campaigns.[Status] as CampStatus,
	    CreativeUnified.CreativeType CreativeType, CreativeUnified.ImageURL as IMGCreativeName, CreativeUnified.Title as Title,  CreativeUnified.body as Body,
	    CreativeUnified.body2 as Body2, CreativeUnified.DisplayURL as DisplayURL,  CreativeUnified.ImageURL as ImageURL,
	    CreativeUnified.CreativeGK as CreativeGK, CreativeUnified.PPCCreativeGK as PPCCreativeGK, CreativeUnified.OriginalID as CreativeOriginalID,
	    TargetingUnified.TargetingGender as TargetingGender, TargetingUnified.TargetingFromAge as TargetingFromAge,
	    TargetingUnified.TargetingToAge as TargetingToAge,
	    Trackers.TrackerName, Trackers.TrackerGK,
	    --TargetingMatchUnified.Keyword, TargetingMatchUnified.MatchType ,
	    --TargetingMatchUnified.KeywordGK, TargetingMatchUnified.PPCKeywordGK, TargetingMatchUnified.OriginalID as KeywordID, 
	    MetricsUnified.*
	into	' + @FinalMetricsTable + ' 
	    
	from			'+	@MetricsUnifiedTable +' MetricsUnified
		inner join	'+	@AdTable +' Ads
			on MetricsUnified.AdUsid = Ads.AdUsid
		inner join '+	@AdSegmentTable +' Adsegments
			on Adsegments.AdUsid = MetricsUnified.AdUsid and Adsegments.segmentID = -876
		inner join '+@CampaignsTable +' Campaigns
			on Campaigns.originalID = Ads.Campaign_OriginalID
		inner join  '+ @CreativeUnifiedTable +' CreativeUnified
			on CreativeUnified.AdUsid = MetricsUnified.AdUsid 
		inner join '+@AdgroupsTable +' Adgroups
			on Adgroups.OriginalID = Adsegments.ValueOriginalID and Adsegments.segmentID = -876
		left outer join '+	@AdSegmentTable +' Adsegments1
			on Adsegments1.AdUsid = MetricsUnified.AdUsid and Adsegments1.segmentID = -977
		left outer join '+ @TrackersTable +' Trackers
			on Trackers.TrackerName = Adsegments1.Value 
			and Adsegments1.segmentID = -977
			and Trackers.TrackerDestURL =  Ads.DestinationUrl
			and Trackers.CampaignGK =  Campaigns.CampaignGK
			and Trackers.adgroupGK =  Adgroups.AdgroupGK
			and Trackers.CreativeGK = CreativeUnified.CreativeGK
		left outer join '+ @TargetingUnifiedTable +' TargetingUnified
			on TargetingUnified.AdUsid = MetricsUnified.AdUsid
		left outer join '+ @TargetingMatchUnifiedTable +' TargetingMatchUnified
			on TargetingMatchUnified.Adusid = MetricsUnified.AdUsid 
			and TargetingMatchUnified.MetricsUnitGuid = MetricsUnified.MetricsUnitGuid 	
			'
		
		exec (@sql)
		
		-- Execute Insert to Paid_API_allcolumns table for Facebook data only 
		--  if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Insert the data to commit table...' +@newLine +@newLine  
			
		-- Execute SP_Delivery_Insert_Facebook @DeliveryTablePrefix, @CommitTableName, @MeasuresNamesSQL, @MeasuresFieldNamesSQL


END
