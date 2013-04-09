-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delivery_Get_OLD]
@deliveryID as Char(32),
@deep as bit	
AS
BEGIN
--DELIVERY----------------
SELECT [DeliveryID]
      ,[AccountID]
      ,[ChannelID]
      ,[OriginalID]
      ,[DateCreated]
      ,[DateModified]
      ,[Signature]
      ,[Description]
      ,[TargetLocationDirectory]
      ,[TargetPeriodDefinition]
      ,[TargetPeriodStart]
      ,[TargetPeriodEnd]
      ,[Committed]
  FROM [Edge_System291].[dbo].[Delivery]
  WHERE [DeliveryID]=@deliveryID
   ---------------DeliveryParameters---------
  
SELECT [DeliveryID]
      ,[Key]
      ,[Value]
  FROM [Edge_System291].[dbo].[DeliveryParameters]
   WHERE [DeliveryID]=@deliveryID
   -------------DeliveryHistory-----------------------
  SELECT [DeliveryID]
      ,[ServiceInstanceID]
      ,[Index]
      ,[Operation]
      ,[DateRecorded]
  FROM [Edge_System291].[dbo].[DeliveryHistory]
  WHERE [DeliveryID]=@deliveryID
  ORDER BY [Index]
   ---------------DeliveryHistoryParameters----------
SELECT [DeliveryID]
      ,[Index]
      ,[Key]
      ,[Value]
  FROM [Edge_System291].[dbo].[DeliveryHistoryParameters]
   WHERE [DeliveryID]=@deliveryID
  ORDER BY [Index]
  ------------DELIVERY FILE---------------
  SELECT [DeliveryID]
      ,[FileID]
      ,[Name]
      ,[AccountID]
      ,[ChannelID]
      ,[DateCreated]
      ,[DateModified]
      ,[FileCompression]
      ,[SourceUrl]
      ,[Location]
  FROM [Edge_System291].[dbo].[DeliveryFile]
   WHERE [DeliveryID]=@deliveryID
   ORDER BY [FileID]
   --------DeliveryFileParameters-----------
   SELECT [DeliveryID]
      ,[Name]
      ,[Key]
      ,[Value]
  FROM [Edge_System291].[dbo].[DeliveryFileParameters]
   WHERE [DeliveryID]=@deliveryID
  ORDER BY [Name]
   ------------DeliveryFileHistory---------------
SELECT [DeliveryID]
      ,[Name]
      ,[ServiceInstanceID]
      ,[Index]
      ,[Operation]
      ,[DateRecorded]
  FROM [Edge_System291].[dbo].[DeliveryFileHistory]
  WHERE [DeliveryID]=@deliveryID
  ORDER BY [Name],[Index]
  ------------DeliveryFileHistoryParameters---------------
SELECT [DeliveryID]
      ,[Name]
      ,[Index]
      ,[Key]
      ,[Value]
  FROM [Edge_System291].[dbo].[DeliveryFileHistoryParameters]
   WHERE [DeliveryID]=@deliveryID
   ORDER BY [Name],[Index]
 
 
  


















END