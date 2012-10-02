-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/9/2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].Delivery_Delete
 @deliveryID char(32)

	
AS
BEGIN
	DELETE FROM [dbo].[Delivery]
      WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].[DeliveryFile]
       WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].[DeliveryFileParameters]
       WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].[DeliveryParameters]
      WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].DeliveryOutput
      WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].DeliveryOutputParameters
      WHERE DeliveryID=@deliveryID
DELETE FROM [dbo].DeliveryOutputChecksum
      WHERE DeliveryID=@deliveryID

END
