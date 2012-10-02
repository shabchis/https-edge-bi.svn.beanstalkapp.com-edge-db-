CREATE TABLE [dbo].[DeliveryOutputChecksum] (
    [DeliveryID]  CHAR (32)     NOT NULL,
    [OutputID]    CHAR (32)     NOT NULL,
    [MeasureName] NVARCHAR (50) NOT NULL,
    [Total]       FLOAT (53)    NULL,
    CONSTRAINT [PK_CheckSum] PRIMARY KEY CLUSTERED ([DeliveryID] ASC, [OutputID] ASC, [MeasureName] ASC)
);

