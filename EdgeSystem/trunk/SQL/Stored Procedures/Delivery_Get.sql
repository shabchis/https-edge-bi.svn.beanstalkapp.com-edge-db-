
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delivery_Get]
@deliveryID as Char(32),
@deep as bit	
AS
BEGIN
--DELIVERY----------------
SELECT [DeliveryID]
      ,[Account_ID]
      ,[ChannelID]
      ,[Account_OriginalID]
      ,[DateCreated]
      ,[DateModified]     
      ,[Description]
      ,[FileDirectory]
      ,[TimePeriodDefinition]
      ,[TimePeriodStart]
      ,[TimePeriodEnd]     
  FROM [dbo].[Delivery]
  WHERE [DeliveryID]=@deliveryID
   ---------------DeliveryParameters---------
  
SELECT [DeliveryID]
      ,[Key]
      ,[Value]
  FROM [dbo].[DeliveryParameters]
   WHERE [DeliveryID]=@deliveryID
   
  ------------DELIVERY FILE---------------
  SELECT [DeliveryID]
      ,[FileID]
      ,[Name]
      ,[Status]      
      ,[DateCreated]
      ,[DateModified]
      ,[FileCompression]
      ,[SourceUrl]
      ,[Location]
      ,[FileSignature]
  FROM [dbo].[DeliveryFile]
   WHERE [DeliveryID]=@deliveryID
   ORDER BY [FileID]
   --------DeliveryFileParameters-----------
   SELECT [DeliveryID]
      ,[Name]
      ,[Key]
      ,[Value]
  FROM [dbo].[DeliveryFileParameters]
   WHERE [DeliveryID]=@deliveryID
  ORDER BY [Name]
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
  WHERE [DeliveryID]=@deliveryID
  ------------DeliveryOutputParameters------- 
SELECT [DeliveryID]
      ,[OutputID]
      ,[Key]
      ,[Value]
  FROM [dbo].[DeliveryOutputParameters]
  WHERE [DeliveryID]=@deliveryID
  -----------OutputCheckSum--------
  SELECT [DeliveryID]
      ,[OutputID]
      ,[MeasureName]
      ,[Total]
  FROM [dbo].[DeliveryOutputChecksum]
  WHERE [DeliveryID]=@deliveryID
  
  
  
  
 
 
  


















END

