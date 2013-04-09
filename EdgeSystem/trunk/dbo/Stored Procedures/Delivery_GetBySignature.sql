-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/09/2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delivery_GetBySignature] 
@signature NvarChar(400),
@exclude char(32)
AS
BEGIN
select DeliveryID FROM dbo.Delivery WHERE [Signature] = @signature and
(@exclude is null or DeliveryID != @exclude);
END