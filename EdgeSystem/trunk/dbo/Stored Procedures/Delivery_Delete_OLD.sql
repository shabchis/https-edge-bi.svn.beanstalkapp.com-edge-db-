-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/9/2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delivery_Delete_OLD]
 @deliveryID char(32)

	
AS
BEGIN
	DELETE FROM [Edge_System291].[dbo].[Delivery]
      WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryFile]
       WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryFileHistory]
       WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryFileHistoryParameters]
      WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryFileParameters]
       WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryHistory]
      WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryHistoryParameters]
      WHERE DeliveryID=@deliveryID
DELETE FROM [Edge_System291].[dbo].[DeliveryParameters]
      WHERE DeliveryID=@deliveryID

END