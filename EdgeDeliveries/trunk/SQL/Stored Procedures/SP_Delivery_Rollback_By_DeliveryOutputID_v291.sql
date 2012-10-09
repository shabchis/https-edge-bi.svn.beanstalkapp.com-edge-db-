CREATE PROCEDURE [dbo].[SP_Delivery_Rollback_By_DeliveryOutputID_v291]
	@DeliveryOutputID	Nvarchar(4000),
	@TableName			Nvarchar(1000)
AS
BEGIN

	SET NOCOUNT ON;	
	/*
	-- Start Debug
				declare @DeliveryOutputID as nvarchar(4000)
				declare @tableName as nvarchar(1000)
				set @TableName = 'Paid_API_AllColumns_v29'
				set @DeliveryOutputID = '25e1bfc0965d4295949027bec2ef88af'
	
	-- End Debug
	*/
		
	-- Check if the DeliveryID is empty
	if	(@DeliveryOutputID is null)
		return ; 		 
	
			Declare @result int;
			Declare @SQL As nvarchar(4000);
			Declare @SQL1 As nvarchar(4000);
			Declare @CombinedResource nvarchar(400);
			Declare @OLTPDB as nvarchar(400);
			Declare @EdgeSystemDeliveryTablePath as nvarchar(400);
			
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
					-- Execute the code
					Set @SQL = 'delete from '+ @OLTPDB +'.dbo.'+@TableName+ ' where DeliveryOutputID = ''' +@DeliveryOutputID + ''''  
					-- print @SQL
					Exec Sp_executesql @SQL
					
					EXEC @result = sp_releaseapplock @Resource = @CombinedResource;
					
					-- Set this DeliveryOutputID to be UnCommited (Committed = False) in the delivery table 
					set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
						SET [Status] = 5 --Rolledback
						WHERE OutputID = ''' +@DeliveryOutputID + ''''  
						
					Exec Sp_executesql @SQL1


					COMMIT TRANSACTION;
					
					
				END
			
END
