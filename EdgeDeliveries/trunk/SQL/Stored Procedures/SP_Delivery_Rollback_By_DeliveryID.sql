CREATE PROCEDURE [dbo].[SP_Delivery_Rollback_By_DeliveryID]
	@DeliveryID		Nvarchar(4000),
	@TableName      Nvarchar(1000)
AS
BEGIN

	SET NOCOUNT ON;	

	/*-- Start Debug
				declare @DeliveryID as nvarchar(4000)
				declare @tableName as nvarchar(1000)
				set @TableName = 'Paid_API_AllColumns'
				set @DeliveryID = '35ce9ec59e3848ea90e256250059ba6a'
	
	-- End Debug
	*/	
		
	-- Check if the DeliveryID is empty
	if	(@DeliveryID is null)
		return ; 		 
	
			Declare @result int;
			Declare @SQL As nvarchar(4000);
			Declare @SQL1 As nvarchar(4000);
			Declare @CombinedResource nvarchar(400);
			Declare @OLTPDB as nvarchar(400);
			Declare @EdgeSystemDeliveryTablePath as nvarchar(400);
			
			BEGIN TRANSACTION;
			set @OLTPDB = 'testdb'
			set @EdgeSystemDeliveryTablePath = '[Edge_System].[dbo].[Delivery]'
			set @CombinedResource = @TableName

			EXEC @result = sp_getapplock @Resource = @CombinedResource, 
						   @LockMode = 'Exclusive';

			IF @result < 0
				BEGIN
					ROLLBACK TRANSACTION;
					RAISERROR ('Unable to acquire lock', 16, 1 )
				END
			ELSE
				BEGIN
					-- Execute the code
					Set @SQL = 'delete from '+ @OLTPDB +'.dbo.'+@TableName+ ' where DeliveryID = ''' +@DeliveryID + ''''  

						Exec Sp_executesql @SQL
					
					EXEC @result = sp_releaseapplock @Resource = @CombinedResource;
					
					-- Set this delivery + signature to be UnCommited (Committed = False) in the delivery table 
					set @SQL1 = 'UPDATE ' + @EdgeSystemDeliveryTablePath+' with (paglock,XLOCK)
						SET [Committed] = 0
						WHERE DeliveryID = ''' +@DeliveryID + ''''  
						
					Exec Sp_executesql @SQL1


					COMMIT TRANSACTION;
					
					
				END
			
END
