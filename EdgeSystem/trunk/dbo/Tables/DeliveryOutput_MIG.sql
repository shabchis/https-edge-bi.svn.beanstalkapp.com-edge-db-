﻿CREATE TABLE [dbo].[DeliveryOutput_MIG] (
    [DeliveryID]         CHAR (32)      NOT NULL,
    [OutputID]           CHAR (32)      NOT NULL,
    [AccountID]          INT            NULL,
    [ChannelID]          INT            NULL,
    [Signature]          NVARCHAR (400) NULL,
    [Status]             INT            NOT NULL,
    [PipelineInstanceID] BIGINT         NULL,
    [TimePeriodStart]    DATETIME2 (7)  NULL,
    [TimePeriodEnd]      DATETIME2 (7)  NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [DateModified]       DATETIME       NOT NULL,
    CONSTRAINT [PK_DeliveryOutput_MIG] PRIMARY KEY CLUSTERED ([DeliveryID] ASC, [OutputID] ASC)
);

