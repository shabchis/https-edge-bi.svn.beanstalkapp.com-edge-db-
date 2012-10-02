
-- =============================================
Create PROCEDURE [dbo].[DeliveryFile_GetBySignature] 
@signature NvarChar(400)
AS
BEGIN
SELECT Delivery.DeliveryID,Delivery.Account_ID,Delivery.FileDirectory
  FROM [dbo].[Delivery] Delivery
  Inner join [dbo].[DeliveryFile] Files
  on Files.DeliveryID = Delivery.DeliveryID
  where Files.FileSignature = @signature

END

