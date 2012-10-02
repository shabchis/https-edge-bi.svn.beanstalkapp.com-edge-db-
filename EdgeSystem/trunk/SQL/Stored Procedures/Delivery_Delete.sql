-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/9/2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].Delivery_Delete
 @deliveryID char(32)

	
AS
BEGIN
	DELETE FROM [EdgeSystem].[dbo].[Delivery]
      WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].[DeliveryFile]
       WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].[DeliveryFileParameters]
       WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].[DeliveryParameters]
      WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].DeliveryOutput
      WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].DeliveryOutputParameters
      WHERE DeliveryID=@deliveryID
DELETE FROM [EdgeSystem].[dbo].DeliveryOutputChecksum
      WHERE DeliveryID=@deliveryID

END
