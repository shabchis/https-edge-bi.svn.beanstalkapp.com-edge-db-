CREATE PROCEDURE [dbo].[SP_Delivery_Rollback_By_DeliveryID_v291]
	@DeliveryID		Nvarchar(4000),
	@TableName      Nvarchar(1000)
AS
BEGIN

	SET NOCOUNT ON;	
	/*
	-- Start Debug
				declare @DeliveryID as nvarchar(4000)
				declare @tableName as nvarchar(1000)
				set @TableName = 'Paid_API_AllColumns_v29'
				set @DeliveryID = '7ee8090f10c940dba71d38eca4832e04'
	
	-- End Debug
	*/
		
	-- Check if the DeliveryID is empty
	if	(@DeliveryID is null)
		return ; 		 
	
			Declare @result int;
			Declare @SQL As nvarchar(4000);
			Declare @SQL1 As nvarchar(4000);
			Declare @SQLParams as nvarchar(4000);
			Declare @CombinedResource nvarchar(400);
			Declare @OLTPDB as nvarchar(400);
			Declare @EdgeSystemDeliveryTablePath as nvarchar(400);
			Declare @OutputIDsList As nvarchar(4000);
			
			BEGIN TRANSACTION;
			set @OLTPDB = 'testdb'
			set @EdgeSystemDeliveryTablePath = '[Edge_System291].[dbo].[DeliveryOutput]'
			set @CombinedResource = @TableName

			EXEC @result = sp_getapplock @Resource = @CombinedResource, 
						   @LockMode = 'Exclusive';

			IF @result < 0
				BEGIN
					ROLLBACK TRANSACTION;
					RAISERROR ('Unable to acquire lock', 16, 1)
				END
			ELSE
				BEGIN
				-- retrieve only the deliveryOutputID which are commited and related to this DeliveryID
					set @SQL = ''

					set @SQL = 'SELECT @OutputIDsList_out= COALESCE(@OutputIDsList_out+'''', '''''''','''')+ISNULL(OutputID+'''''','''''','''')
								FROM ' + @EdgeSystemDeliveryTablePath+' 
								WHERE DeliveryID = ''' +@DeliveryID + '''
									AND [Status] in (3,4) '  -- Status 4 = Commited
					SET @SQLParams = ''
					SET @SQLParams = '	@OutputIDsList_out Nvarchar(4000) OUTPUT'
					
					Print @SQL

					EXECUTE sp_executesql @SQL, @SQLParams, @OutputIDsList_out= @OutputIDsList OUTPUT
					
				-- Check if there are relevant outputs
				IF LEN(@OutputIDsList) > 0 
					BEGIN
						set @OutputIDsList= left(@OutputIDsList,len(@OutputIDsList)-2); -- remove the last ',' in the COALESCE string
					
						print @OutputIDsList
					
						-- Execute the code
						Set @SQL = ''
						Set @SQL = 'delete from '+ @OLTPDB +'.dbo.'+@TableName+ ' where DeliveryOutputID in (' +@OutputIDsList + ')'  
						 print @SQL
						Exec Sp_executesql @SQL
					
						EXEC @result = sp_releaseapplock @Resource = @CombinedResource;
					
						-- Set this DeliveryOutputID to be UnCommited (Committed = False) in the delivery table 
						set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
							SET [Status] = 5 --Rolledback
							WHERE OutputID in (' + @OutputIDsList + ')'  
						print @SQL1
						Exec Sp_executesql @SQL1


					END	
				ELSE RAISERROR ('No commited outputs found', 16, 1)
			
			COMMIT TRANSACTION;		-- Commit + release the lock
					
				END
			
END
