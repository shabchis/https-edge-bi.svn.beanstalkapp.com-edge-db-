CREATE TABLE [dbo].[Delivery] (
    [DeliveryID]           CHAR (32)       NOT NULL,
    [Account_ID]           INT             NULL,
    [Account_OriginalID]   NVARCHAR (50)   NULL,
    [ChannelID]            INT             NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [DateModified]         DATETIME        NOT NULL,
    [Description]          NVARCHAR (500)  NULL,
    [FileDirectory]        NVARCHAR (1000) NULL,
    [TimePeriodDefinition] NVARCHAR (1000) NULL,
    [TimePeriodStart]      DATETIME2 (7)   NULL,
    [TimePeriodEnd]        DATETIME2 (7)   NULL,
    [TimePeriodSplit]      INT             NULL
);

