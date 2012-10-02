
CREATE PROCEDURE [dbo].[DeliveryOutput_Get]
@outputID as Char(32)
AS
BEGIN

   ----------DeliveryOutput
  SELECT[DeliveryID]
      ,[OutputID]
      ,[AccountID]
      ,[AccountOriginalID]
      ,[ChannelID]
      ,[Signature]
      ,[Status]      
      ,[TimePeriodStart]
      ,[TimePeriodEnd]
      ,[DateCreated]
      ,[DateModified]
      ,[PipelineInstanceID]
  FROM [dbo].[DeliveryOutput]
  WHERE [OutputID]=@outputID  
  ------------DeliveryOutputParameters------- 
SELECT [DeliveryID]
      ,[OutputID]
      ,[Key]
      ,[Value]
  FROM [dbo].[DeliveryOutputParameters]
  WHERE [OutputID]=@outputID  
  
  -----------OutputCheckSum--------
  SELECT [DeliveryID]
      ,[OutputID]
      ,[MeasureName]
      ,[Total]
  FROM [dbo].[DeliveryOutputChecksum]
  WHERE [OutputID]=@outputID  
  
 
 
  


















END


