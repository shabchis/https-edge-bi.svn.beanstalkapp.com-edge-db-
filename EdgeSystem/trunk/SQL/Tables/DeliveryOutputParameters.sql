CREATE TABLE [dbo].[DeliveryOutputParameters] (
    [DeliveryID] CHAR (32)      NOT NULL,
    [OutputID]   CHAR (32)      NOT NULL,
    [Key]        NVARCHAR (50)  NOT NULL,
    [Value]      NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_DeliveryOutputParameters] PRIMARY KEY CLUSTERED ([DeliveryID] ASC, [OutputID] ASC, [Key] ASC)
);

