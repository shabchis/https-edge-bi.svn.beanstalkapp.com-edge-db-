CREATE PROCEDURE [dbo].[DeliveryTicket_Get] 
	@deliverySignature nvarchar(400),
	@deliveryID Nvarchar(50),
	@workflowInstanceID bigint OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	begin transaction;

	DECLARE @found as int;
	DECLARE @claimedBy as int;
	SET @found = 2;
	
	SELECT
		@found =
			CASE
				WHEN ticket.WorkflowInstanceID != @workflowInstanceID THEN 0
				WHEN @found = 2 and ticket.WorkflowInstanceID = @workflowInstanceID THEN 1
			END
		,
		@claimedBy = ticket.WorkflowInstanceID
		
	FROM DeliveryTicket ticket WITH(XLOCK)
		INNER JOIN dbo.ServiceInstance instance ON
			instance.InstanceID = ticket.WorkflowInstanceID and
			instance.State != 6 and instance.State != 7
	WHERE
		ticket.DeliverySignature = @deliverySignature;
	;
	
	
	IF @found = 2
	BEGIN
		INSERT INTO dbo.DeliveryTicket
			(DeliverySignature,WorkflowInstanceID,DeliveryID)
		VALUES
			(@deliverySignature,@workflowInstanceID,@deliveryID);
	END;
	
	set @workflowInstanceID = @claimedBy;
	select @found;
		
	commit transaction;
		
END