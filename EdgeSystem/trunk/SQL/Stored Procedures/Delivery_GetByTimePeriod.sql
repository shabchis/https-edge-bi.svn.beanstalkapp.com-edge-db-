-- =============================================
-- Author:		<Shay Bar-Chen>
-- Create date: <21/09/2011>
-- Description:	<getting delivery by account id , channel and target period,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delivery_GetByTimePeriod] 
@channelID int,
@accountID int,
@timePeriodStart datetime2,
@timePeriodEnd datetime2

AS
BEGIN
--DECLARE @query AS NVARCHAR(MAX);
/*set @query= 'SELECT DeliveryID FROM dbo.Delivery WHERE [AccountID]=' + @accountID + 
			'and ChannelID=' + @channelID + 'and TargetPeriodStart='+@targetPeriodStart+
			'and TargetPeriodEnd=' + @targetPeriodEnd
exec (@query)*/

SELECT DeliveryID FROM dbo.Delivery WHERE [Account_ID] = @accountID
and ChannelID = @channelID
and TimePeriodStart = @timePeriodStart
and TimePeriodEnd = @timePeriodEnd
END
