-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/9/2011>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[DeliveryOutput_Delete]
 @outputID char(32)

	
AS
BEGIN
DELETE FROM [dbo].DeliveryOutput
      WHERE DeliveryID=@outputID
DELETE FROM [dbo].DeliveryOutputParameters
      WHERE DeliveryID=@outputID
DELETE FROM [dbo].DeliveryOutputChecksum
      WHERE DeliveryID=@outputID

END
