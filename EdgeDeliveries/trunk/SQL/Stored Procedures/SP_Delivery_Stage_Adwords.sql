CREATE PROCEDURE [dbo].[SP_Delivery_Stage_Adwords]
	@DeliveryFileName			Nvarchar(4000),
	@CommitTableName			Nvarchar(4000),
	@MeasuresNamesSQL			Nvarchar(4000) = NULL,
	@MeasuresFieldNamesSQL		Nvarchar(4000) = NULL,
	@DeliveryID					Nvarchar(4000),
	@OutputIDsPerSignature		Nvarchar(4000) OUTPUT
	
AS
BEGIN

	SET NOCOUNT OFF;	
	SET XACT_ABORT ON;
	-- Start Debug
	/*
				declare @DeliveryFileName		as nvarchar(4000)
				declare @CommitTableName		as nvarchar(4000)
				declare @MeasuresNamesSQL		as	Nvarchar(4000)
				declare @MeasuresFieldNamesSQL	as	Nvarchar(4000)
				declare @DeliveryID				as	Nvarchar(4000)
				declare @OutputIDsPerSignature as	Nvarchar(4000) 

				set @DeliveryFileName = 'AD_1240_20120603_144724_7ee8090f10c940dba71d38eca4832e04'
				set @CommitTableName = 'Paid_API_Content'
				set @MeasuresNamesSQL = ',Clicks, Cost'
				set @MeasuresFieldNamesSQL = ',Clicks, Cost'
				set @DeliveryID = '7ee8090f10c940dba71d38eca4832e04'
	*/
	/*
	public enum DeliveryOutputStatus
			 {
			  Empty  = 0,
			  Imported = 1,
			  Transformed = 2,
			  Staged  = 3,
			  Committed = 4,
			  RolledBack = 5,
			  Canceled = 6
			 }
	*/
	-- End Debug
	
		Declare @SQL As nvarchar(4000)
		Declare @SQL1 As nvarchar(4000)
		Declare @OLTPDB as Nvarchar(500)
		Declare @DeliveryDB as Nvarchar(500)
		Declare @EdgeSystemDeliveryTablePath as Nvarchar(500)
		Declare @Signatures	as	Nvarchar(4000) 
		
		set @DeliveryDB = 'Deliveries'
		set @OLTPDB = 'TestDB'
		set @EdgeSystemDeliveryTablePath = '[Edge_System291].[dbo].[DeliveryOutput]'
		
		
	-- Check if the DeliveryID is empty
	if	(@DeliveryFileName is null or @CommitTableName is null)
		return; 		 
	-- Set the signature into @Signatures based on the deliveryID
				set @Signatures = ''	
				set @SQL1 = ''	

				set @SQL1 = ' SELECT @Signatures = COALESCE(@Signatures+ '''', '''''''','''')+ISNULL([Signature]+'''''','''''','''')
							  FROM ' + @EdgeSystemDeliveryTablePath+' 
							  WHERE [DeliveryID] = '''+ @DeliveryID +''''	
							  
				Exec Sp_executesql @SQL1 ,N'@Signatures varchar(4000) OUTPUT',@Signatures = @Signatures  OUTPUT

				-- remove the last ',' in the COALESCE string
			IF (@Signatures != '')
			   set @Signatures= '''' + left(@Signatures,len(@Signatures)-2); 
			   

			-- The statement below group_concats all the delivery ids to 1 string
			IF LEN( @Signatures) > 0
			begin
				set @SQL1 = ''	

				set @SQL1 = ' SELECT @OutputIDsPerSignature = COALESCE(@OutputIDsPerSignature+'', '','''')+ISNULL([OutputID],'''')
							  FROM ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
							  WHERE [Status] in (3,4) AND [Signature] in ('+  @Signatures +') '	
							  
				Exec Sp_executesql @SQL1 ,N'@OutputIDsPerSignature varchar(4000) OUTPUT',@OutputIDsPerSignature = @OutputIDsPerSignature  OUTPUT
			END
			
	-- If there are commited outputs in the delivery output table than exit this SP

		IF LEN(@OutputIDsPerSignature) >0  RETURN 9;

	-- This section will insert the delivery data stored in the commited_final table to the @CommitTableName
	-- Starts transaction
			 BEGIN TRANSACTION	
			 BEGIN
			 
			Set @SQL = 
			' 	INSERT INTO '+@OLTPDB +'.dbo.'+ @CommitTableName+ '
				  (	[DeliveryOutputID]
				   ,[customerid] -- accountID source
				   ,[Account_ID_SRC]
				   ,[timezone] -- Time zone 
				   ,[currCode]
				   ,[Downloaded_Date]
				   ,[Account_ID]
				   ,[Channel_ID]
				   ,[Day_Code]
			            
				  ,[campaignid]
				  ,[campaign]
				  ,[Campaign_GK]
				  ,[campStatus]
			           
				  ,[adgroupid]
				  ,[adgroup]
				  ,[AdGroup_GK]

				  ,[headline]
				  ,[desc1]
				  ,[desc2]
				  ,[creativeVisUrl]
				  ,[destUrl]
				  ,[creativeid]
				  ,[creativeType]
				  ,[creativeStatus]
				  ,[adwordsType]
				  ,[adStatus]
				  ,[creativeDestUrl]
				  ,[PPC_Creative_GK]
				  ,[Creative_gk]
				  ,[AdVariation]
				  ,[imgCreativeName]
			             
				  ,[keywordid]
				  ,[kwSite]
				  ,[siteKwStatus] -- kw status
				  ,[MatchType]
				  ,[QualityScore]
				  ,[kwDestUrl]
				  ,[Keyword_GK]
				  ,[PPC_Keyword_GK]
			      
				  ,[Gateway]
				  ,[Gateway_id]
				  ,[Gateway_gk]
			     
				  -- will be delivered from the .NET as a list of OLTP measures names
				  '+@MeasuresFieldNamesSQL+'
				  )
				SELECT     
					OutputID,
					AccountOriginalID ,
					AccountOriginalID ,
					NULL as TimeZone ,
					Currency as CurrCode,
					DownloadedDate as Downloaded_date,
					AccountID as AccountID, 
					ChannelID as ChannelID , 
					Day_Code as Day_code,
					
					CampaignID ,
					Campaign , 
					campaign_GK, 
					CampStatus ,
						
					AdgroupID,
					Adgroup , 
					adgroup_GK , 
				
					Title  ,  
					body  ,
					body2  , 
					DisplayURL ,  
					destUrl ,
					AdOriginalID ,
					CreativeType , 
					NULL as CreativeStatus ,	-- No Ad Status 
					NetworkType ,				-- Adwords only
					NULL as AdStatus ,			-- Ad Status in FB is not downloaded
					DestUrl ,
					PPCCreativeGK ,
					CreativeGK , 
					AdVariation ,		
					ImgCreativeName as imgCreativeName,
					
					KeywordID ,		
					Keyword ,			
					Null as KeywordStatus ,		
					MatchType ,			
					QualityScore ,		
					keywordDestUrl ,	
					KeywordGK ,		
					PPCKeywordGK ,	
					 
					NULL as Gateway ,			
					Trackername as Gateway_id ,		
					TrackerGK as Gateway_GK 	
					
					'+@MeasuresNamesSQL+'  	

				FROM '+@DeliveryDB+'.dbo.'+ @DeliveryFileName +'_Commit_FinalMetrics
			'
		
			Exec (@SQL)
			 
			-- Set this delivery to be staged in the delivery output table 
			set @SQL1= ''
			set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				SET [Status] = 3
				WHERE DeliveryID = ''' +@DeliveryID + ''''  
				
			Exec Sp_executesql @SQL1
						
			-- Ends transaction
			COMMIT TRANSACTION
			END
			
			END

