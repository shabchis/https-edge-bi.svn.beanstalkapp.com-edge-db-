
-- =============================================
-- Author:		Amit Bluman
-- Create date:	Apr 2nd 2012 
-- update date: Apr 9nd 2012
-- Last update: Add campaign status
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delivery_Transform_Content]
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
	Declare @SegmentTable as nvarchar(4000)
	Declare @MetricsTable as nvarchar(4000)
	Declare @TargetTable as nvarchar(4000)
	Declare @FinalMetricsTable as nvarchar(4000)
	Declare @AdgroupsTable as nvarchar(4000)
	Declare @CampaignsTable as nvarchar(4000)
	Declare @MetricsUnifiedTable as nvarchar(4000)
	Declare @TargetUnifiedTable as nvarchar(4000)
	
	Declare @SQL as nvarchar(4000)
	Declare @SQL1 as nvarchar(4000)
	Declare @newLine as nvarchar(50)
	Declare @DislayTime as nvarchar(50)
	Declare @DebugMode as bit
	
	-- Start Debug
	/*			declare @DeliveryID as nvarchar(4000);
				declare @DeliveryTablePrefix as nvarchar(4000);
				declare @CommitTableName as nvarchar(4000);
				set @DeliveryTablePrefix = 'GEN_1006_20120408_113517_dbf4b7c7236a49c2b7aa042b29acf735'
				set @DeliveryID = 'dbf4b7c7236a49c2b7aa042b29acf735'
	*/
	-- End Debug
	set @DeliveryDB = 'Deliveries'
	set @OLTPDB = 'TestDB'		
	set @CommitTableName = 'Paid_API_Content_v29'
	set @EdgeSystemDeliveryTablePath = '[Edge_System291].[dbo].[DeliveryOutput]'

	set @SegmentTable = @DeliveryTablePrefix + '_MetricsDimensionSegment' 
	set @MetricsTable = @DeliveryTablePrefix + '_Metrics' 
	set @TargetTable  = @DeliveryTablePrefix + '_MetricsDimensionTarget' 
	set @FinalMetricsTable = @DeliveryTablePrefix + '_Commit_FinalMetrics' 
	set @CampaignsTable = @DeliveryTablePrefix +'_Commit_Campaigns' 
	set @AdgroupsTable = @DeliveryTablePrefix +'_Commit_Adgroups' 
	set @MetricsUnifiedTable = @DeliveryTablePrefix + '_Commit_MetricsUnified' 
	set @TargetUnifiedTable = @DeliveryTablePrefix + '_Commit_TargetUnified' 

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
				[OriginalID] ASC,
				[SegmentID] ASC
			) ON [PRIMARY]

		--  Metrics index
			IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE  name = ''' + @MetricsTable +'_HeaderFields'')
				DROP INDEX [' + @MetricsTable +'_HeaderFields] ON ' + @MetricsTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX  [' + @MetricsTable + '_HeaderFields] ON ' + @MetricsTable + '
			(				
				[Channel_ID] ASC,
				[Account_ID] ASC,
				[MetricsUsid] ASC,
				[DownloadedDate] ASC,
				[TargetPeriodStart] ASC,
				[TargetPeriodEnd] ASC
			) ON [PRIMARY]
			
			--  Target table index
			IF  EXISTS 
					(SELECT 1 FROM sys.indexes WHERE  name = ''' + @TargetTable +'_HeaderFields'')
				DROP INDEX [' + @TargetTable +'_HeaderFields] ON ' + @TargetTable +' WITH ( ONLINE = OFF )
					
			CREATE CLUSTERED INDEX  [' + @TargetTable + '_HeaderFields] ON ' + @TargetTable + '
			(
				[MetricsUsid] ASC,
				[TypeID] ASC,
				[OriginalID] ASC
			) ON [PRIMARY]
			'
			EXEC (@sql)
		
	
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
	[Status] [int] NULL,
	[OriginalID] [nvarchar](4000) NOT NULL,
	[CampaignGK] [nvarchar](50) NOT NULL
	) ON [PRIMARY]'
	exec (@sql)

	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
		INSERT INTO '+@CampaignsTable+'
			SELECT
				Account_ID			as AccountID,
				Channel_ID			as ChannelID,
				Value				as Name,
				Status				as Status,
				OriginalID			as OriginalID,
				''-1'' 				as CampaignGK
			FROM '+ @MetricsTable +' Metrics
				inner join '+ @SegmentTable +' Segment
					on Metrics.MetricsUsid = Segment.MetricsUsid
			WHERE Segment.SegmentID = -875 -- Campaign indicator
			GROUP BY
				Account_ID,
				Channel_ID,
				Value,
				Status,
				OriginalID
		UNION ALL
			SELECT 	top 1	
				Account_ID			as AccountID,
				Channel_ID			as ChannelID,
				''Unknown''			as Name,
				''0''				as Status,
				''0''				as OriginalID,
				(-1) * Account_ID	as CampaignGK			
			FROM '+ @MetricsTable +' Metrics
				inner join '+ @SegmentTable +' Segment
					on Metrics.MetricsUsid = Segment.MetricsUsid
			WHERE Segment.SegmentID = -875 -- Campaign indicator	
			
		-- create primary key for fast join
		alter table ' + @CampaignsTable + ' with nocheck
		add constraint ' + @CampaignsTable + '_pk_campaign 
			primary key clustered (AccountID, ChannelID, Name, OriginalID)'

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
					SELECT   [AccountID]
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
				INSERT INTO ' + @AdgroupsTable + '
					SELECT 
						campaigns.AccountID			as AccountID,
						campaigns.ChannelID			as ChannelID,
						adgroups.Value				as Name,
						adgroups.OriginalID	as OriginalID, -- the originalId on Facebook is null cause we R creating it then I inserted the adgroupname as an ID
						campaigns.CampaignGK		as CampaignGK,
						''-1''						as AdgroupGK
					FROM
						'+ @SegmentTable + ' Adgroups 
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
				add constraint ' + @AdgroupsTable + 'pk_adgroup 
					primary key clustered (AccountID, ChannelID, Name, OriginalID, CampaignGK)
				
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
					SELECT   [AccountID]
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

						-- create Metrics unified view
				if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Creates metrics unified view...'	+@newLine +@newLine 
			IF EXISTS
				(SELECT 1  FROM sysobjects WHERE xtype='V' AND name=@MetricsUnifiedTable) 
			 BEGIN
				set @sql = ''
				set @sql = 'Drop view ' + @MetricsUnifiedTable 
				exec (@sql)
			  END
			
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

	-- checks if there is a @TargetingUnifiedTable view
			IF EXISTS
     (SELECT 1  FROM sysobjects WHERE xtype='U' AND name=@TargetUnifiedTable ) 
		 BEGIN
			set @sql = ''
			set @sql = 'Drop Table ' + @TargetUnifiedTable 
			exec (@sql)
		  END
		  
			-- create Targeting unified view
			if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Create Target unified view...'	+@newLine +@newLine 
			
			set @sql = ''
			Set @sql = '  SELECT Target1.[MetricsUsid]
			  ,Target1.[OriginalID]
			  ,Target1.[TypeID]
			  ,Target1.DestinationUrl as SiteDestUrl
			  ,Target1.[Field1] as [Site]
			  ,Target1.[Field2] as MatchType
			  ,NULL as SiteGK
			  ,NULL as PPCSiteGK
			  ,Adgroups.AccountID
			  ,Adgroups.ChannelID
			  ,Adgroups.AdgroupGK
			  ,Adgroups.CampaignGK
	      INTO ' + @TargetUnifiedTable +'
		  FROM ' + @TargetTable +' Target1
			INNER JOIN 
			   '+ @SegmentTable +' Segment
					on Segment.MetricsUsid = Target1.MetricsUsid
			INNER JOIN 
			   ' + @AdgroupsTable + ' Adgroups
					on Adgroups.OriginalID = Segment.OriginalID					
		  where Target1.TypeID = 5 and Target1.Field2 = 4 -- TypeID = 5 means that this is content and Field2 =4 means that its auto content
				and Segment.SegmentID = -876
 
	 CREATE NONCLUSTERED INDEX [' + @TargetUnifiedTable +'_HeaderFields''] 
			ON ' + @TargetUnifiedTable +' 
			(
				[AccountID] ASC,
				[ChannelID] ASC,
				[CampaignGK] ASC,
				[AdgroupGK] ASC,
				[Site] ASC,
				[OriginalID] ASC,
				[SiteDestUrl] ASC,
				[MatchType] ASC
			)ON [PRIMARY]
			
	CREATE CLUSTERED INDEX [' + @TargetUnifiedTable +'_pk''] 
			ON ' + @TargetUnifiedTable +' 
			(
			[MetricsUsid] ASC
			)ON [PRIMARY]'
	 	
    exec (@sql)

	
 	-- Update Gks for Sites from GkManager_GetSiteGK_WithReturn & GkManager_GetPPCSiteGK_WithReturn SP
		if (@DebugMode=1)	print convert(nvarchar(40),CONVERT (time, GETDATE()))  +' ...Update Gks for Sites from GkManager_GetSiteGK_WithReturn & GkManager_GetPPCSiteGK_WithReturn SP...'	+@newLine +@newLine 
	
	set @sql = ''
	set @sql = ' USE '+ @DeliveryDB +'
			Declare @AccountID int;
			Declare @ChannelID int;
			Declare @CampaignGK nvarchar(500);
			Declare @AdgroupGK nvarchar(500);
			Declare @SiteOriginalID nvarchar(500) ;
			Declare @Site nvarchar(4000);
			Declare @SiteDestURL nvarchar(4000);
			Declare @MatchType int;
			Declare @SiteGK nvarchar(500);
			Declare @PPCSiteGK nvarchar(500);

			DECLARE index_cursor CURSOR FOR 
					SELECT   [AccountID]
							,[ChannelID]
							,[CampaignGK]
							,[AdgroupGK]
							,[OriginalID]
							,[Site]
							,[SiteDestURL]
							,[MatchType]	
					FROM ' + @TargetUnifiedTable + '
			OPEN index_cursor

			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @SiteOriginalID, @Site, @SiteDestURL, @MatchType
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 				 			
				execute  @SiteGK =  '+ @OLTPDB +' .dbo.GkManager_GetSiteGK_WithReturn
								@account_id = @AccountID,
								@Site = @Site
					
				execute  @PPCSiteGK =  '+ @OLTPDB +' .dbo.GkManager_GetAdgroupSiteGK_WithReturn			
					@Account_ID	 = @AccountID,		
					@Channel_ID	 = @ChannelID,		
					@Campaign_GK = @CampaignGK,
					@AdGroup_GK	 = @AdgroupGK,	
					@Site_GK  = @SiteGK , 	
					@kwDestUrl   = @SiteDestURL,
					@MatchType	 = @MatchType
				
				-- print ''GetSiteGK*2 '' + convert(nvarchar(400),CONVERT (time, GETDATE()))
				
				Update ' + @TargetUnifiedTable + '
				set		SiteGK = @SiteGK , PPCSiteGK = @PPCSiteGK
				from ' + @TargetUnifiedTable + ' Sites
				where	Sites.AccountID = @AccountID and
						Sites.ChannelID = @ChannelID and
						Sites.CampaignGK = @CampaignGK and
						Sites.AdgroupGK = @AdgroupGK and	
						Site = @Site and
						IsNull(Sites.OriginalID,0) = IsNull(@SiteOriginalID,0) and
						IsNull(Sites.[SiteDestURL],0) = IsNull(@SiteDestURL,0) and
						IsNull(Sites.[MatchType],0) = IsNull(@MatchType,0) 

			-- Get the next index.
			FETCH NEXT FROM index_cursor 
			INTO @AccountID , @ChannelID , @CampaignGK, @AdgroupGK, @SiteOriginalID, @Site, @SiteDestURL, @MatchType

			END 

			CLOSE index_cursor

			DEALLOCATE index_cursor'
					
			exec (@sql)
		
 
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
			SELECT	'''+ @DeliveryID +''' as DeliveryID,''' +@DeliveryTablePrefix +''' as DeliveryFileName ,      
				 Campaigns.[originalid]				as [CampaignID]
				,Campaigns.name						as [campaign]
				,Adgroups.OriginalID				as [adgroupid]
				,Adgroups.Name						as [adgroup]
				,TargetUnified.[Site]				as [Site]
				,''Content Only''					as [adwordsType]
				,Campaigns.Status					as [campStatus]
				,Campaigns.CampaignGK				as [Campaign_GK]
				,Adgroups.AdgroupGK					as [AdGroup_GK]
				,TargetUnified.MatchType			as [MatchType]
				,TargetUnified.SiteGK				as [site_gk] 
				,TargetUnified.PPCSiteGK			as [PPC_Site_gk]
				,MetricsUnified.*
			INTO	' + @FinalMetricsTable + '
			FROM '+ @MetricsUnifiedTable +' MetricsUnified
				INNER JOIN 
						'+ @TargetUnifiedTable +' TargetUnified
						on MetricsUnified.MetricsUsid = TargetUnified.MetricsUsid
				INNER JOIN 
						'+ @SegmentTable +' Segments1
						on 	Segments1.MetricsUsid = MetricsUnified.MetricsUsid
				INNER JOIN
						'+ @SegmentTable +' Segments2
						on 	Segments2.MetricsUsid = MetricsUnified.MetricsUsid
				INNER JOIN
						'+ @AdgroupsTable +' Adgroups
						on Adgroups.OriginalID = Segments1.OriginalID
				INNER JOIN
						'+ @CampaignsTable +' Campaigns
						on Campaigns.OriginalID = Segments2.OriginalID
			WHERE
				Segments1.SegmentID = -876 and Segments2.SegmentID = -875'
	

	exec (@sql+@sql1)

-- Set this delivery + signature to be Transformed in the delivery output table 
			set @SQL= ''
			set @SQL = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				SET [Status] = 2
				WHERE DeliveryID = ''' +@DeliveryID + ''''  
				
			Exec Sp_executesql @SQL
			
		
END


