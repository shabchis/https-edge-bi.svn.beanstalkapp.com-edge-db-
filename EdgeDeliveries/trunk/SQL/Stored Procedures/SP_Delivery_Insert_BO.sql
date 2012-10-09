CREATE PROCEDURE [dbo].[SP_Delivery_Insert_BO]
	@DeliveryFileName			Nvarchar(4000),
	@CommitTableName			Nvarchar(4000),
	@MeasuresNamesSQL			Nvarchar(4000) = NULL,
	@MeasuresFieldNamesSQL		Nvarchar(4000) = NULL,
	@Signature					Nvarchar(4000),
	@DeliveryID					Nvarchar(4000),
	@DeliveryIDsPerSignature	Nvarchar(4000) OUTPUT
	
AS
BEGIN

	SET NOCOUNT OFF;	
	SET XACT_ABORT ON;
	-- Start Debug
	/*
				declare @DeliveryFileName	as nvarchar(4000)
				declare @CommitTableName	as nvarchar(4000)
				declare @MeasuresNamesSQL	as		Nvarchar(4000)
				declare @MeasuresFieldNamesSQL	as	Nvarchar(4000)
				declare @Signature					Nvarchar(4000)
				declare @DeliveryID					Nvarchar(4000)
				declare @DeliveryIDsPerSignature	Nvarchar(4000) 

				Set @DeliveryFileName = 'SEG_95_20120112_075601_0251b17a5f174e6da7cbe6fc7ca85576'
				Set @CommitTableName = '[BackOffice_Client_Gateway]' 
				Set @Signature = 'QmFja09mZmljZS1bOTVdLVt7c3RhcnQ6e2FsaWduOidTdGFydCcsZGF0ZTonMjAxMi0wMS0xMVQwMDowMDowMCd9LGVuZDp7YWxpZ246J0VuZCcsZGF0ZTonMjAxMi0wMS0xMVQyMzo1OTo1OS45OTk5OTk5J319XQ'
				Set @DeliveryID = '0251b17a5f174e6da7cbe6fc7ca85576'
	*/			
			
	
	-- End Debug
	
		Declare @SQL As nvarchar(4000)
		Declare @SQL1 As nvarchar(4000)
		Declare @OLTPDB as Nvarchar(500)
		Declare @DeliveryDB as Nvarchar(500)
		Declare @EdgeSystemDeliveryTablePath as Nvarchar(500)
				
		set @DeliveryDB = 'Deliveries'
		set @OLTPDB = 'TestDB'
		set @EdgeSystemDeliveryTablePath = '[Edge_System].[dbo].[Delivery]'
		
		-- WILL BE DELETED, the fields will be delivered by the .net
		
		-- set @MeasuresFieldNamesSQL= 
		-- 		'  ,[New_Users],[New_Active_Users],[ClientSpecific1],[HQActivation] '
		-- WILL BE DELETED
		-- set @MeasuresNamesSQL= 
		--		'  ,[Acquisition1],[Acquisition2],[ClientSpecific1],[GreatToolbars] '
				  
	-- Check if the DeliveryID is empty
	if	(@DeliveryFileName is null or @CommitTableName is null)
		return; 		 
	
			-- Check whether there is committed data for this signature in the delivery table  
			set @SQL1 = ' SELECT @DeliveryIDsPerSignature =
						 CASE	WHEN ISNULL(SUM(convert (int,[committed])),0) = 0  THEN	''0''
								WHEN ISNULL(SUM(convert (int,[committed])),0) = 1  THEN	''1''
						  ELSE ''9'' -- Means that there are more then 1 commited delivery 
						  END 
				  FROM ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				  WHERE [Signature] = '''+ @signature +''''
	
			Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
			  
			-- The lock above should lock the page till the end of the transaction
			
			-- If the @DeliveryIDsPerSignature value is 1 then there is only 1 commited delivery for this signature
			IF (@DeliveryIDsPerSignature) = '1'
			begin
				set @DeliveryIDsPerSignature = ''	
				set @SQL1 = ''	
															
				set @SQL1 = ' SELECT @DeliveryIDsPerSignature = DeliveryID 
							  FROM ' + @EdgeSystemDeliveryTablePath+' 
							  WHERE [committed] !=0 AND [Signature] = '''+ @signature +''''	
				Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
							  								
			    return 1;
			end
			
			-- If the @DeliveryIDsPerSignature value is 9 then there are more than 1 commited delivery for this signature
			-- The statement below group_concats all the delivery ids to 1 string
			IF (@DeliveryIDsPerSignature) = '9'
			begin
				set @DeliveryIDsPerSignature = ''	
				set @SQL1 = ''	

					set @SQL1 = ' SELECT @DeliveryIDsPerSignature = COALESCE(@DeliveryIDsPerSignature+'', '','''')+ISNULL(deliveryid,'''')
							  FROM ' + @EdgeSystemDeliveryTablePath+' 
							  WHERE [committed] != 0 AND [Signature] = '''+ @signature +''''	
							  
				Exec Sp_executesql @SQL1 ,N'@DeliveryIDsPerSignature varchar(4000) OUTPUT',@DeliveryIDsPerSignature = @DeliveryIDsPerSignature  OUTPUT
																							
			    return 9;
			end
	
	-- This section will insert the delivery data stored in the commited_final table to the @CommitTableName
	-- Starts transaction
			 BEGIN TRANSACTION	
			 BEGIN
			 
			Set @SQL = 
			' 	INSERT INTO '+@OLTPDB +'.dbo.'+ @CommitTableName+ '
				  (	[DeliveryID]
				   ,[DeliveryFileName]
				   ,[Downloaded_Date]
				   ,[Account_ID]
				   ,[Day_Code]

				   ,[Gateway_ID]
				   ,[Gateway_GK]
			     
				  -- will be delivered from the .NET as a list of OLTP measures names
				  '+@MeasuresFieldNamesSQL+'
				  )
				SELECT     
					DeliveryID,
					DeliveryFileName,
					DownloadedDate as Downloaded_date,
					AccountID as AccountID, 
					Day_Code as Day_code,
						
					TrackerID as Gateway_ID ,		
					TrackerGK as Gateway_GK 	
					
					'+@MeasuresNamesSQL+'  	

				FROM '+@DeliveryDB+'.dbo.'+ @DeliveryFileName +'_Commit_FinalMetrics
			'
		
			Exec (@SQL)
			 
			-- Set this delivery + signature to be UnCommited (Committed = False) in the delivery table 
			set @SQL1= ''
			set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
				SET [Committed] = 1
				WHERE DeliveryID = ''' +@DeliveryID + ''''  
				
			Exec Sp_executesql @SQL1

			
			-- Ends transaction
			COMMIT TRANSACTION
			END
			



	END

