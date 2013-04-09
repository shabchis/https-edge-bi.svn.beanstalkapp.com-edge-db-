CREATE TABLE [dbo].[DeliveryTicket] (
    [DeliverySignature]  NVARCHAR (400) NOT NULL,
    [WorkflowInstanceID] BIGINT         NOT NULL,
    [DeliveryID]         NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_DeliveryTicket] PRIMARY KEY CLUSTERED ([DeliverySignature] ASC, [WorkflowInstanceID] DESC)
);

