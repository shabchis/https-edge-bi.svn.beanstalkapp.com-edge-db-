CREATE TABLE [dbo].[ObjectTracking] (
    [AccountID]        INT           NOT NULL,
    [ChannelID]        INT           NULL,
    [ObjectTable]      NVARCHAR (50) NOT NULL,
    [ObjectGK]         BIGINT        NOT NULL,
    [DeliveryOutputID] CHAR (32)     NOT NULL
);

