
-- =============================================
-- Author:		<Alon Yaari>
-- Create date: <14/09/2011>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].DeliveryOutput_GetBySignature 
@signature NvarChar(400),
@exclude char(32)
AS
BEGIN
select OutputID FROM dbo.DeliveryOutput WHERE [Signature] = @signature and
(@exclude is null or OutputID != @exclude);
END

