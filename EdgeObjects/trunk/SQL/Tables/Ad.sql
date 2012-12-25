CREATE TABLE [dbo].[Ad] (
    [GK]             BIGINT          NOT NULL,
    [Name]           NVARCHAR (50)   NULL,
    [OriginalID]     NVARCHAR (100)  NULL,
    [AccountID]      INT             NOT NULL,
    [ChannelID]      INT             NOT NULL,
    [Status]         INT             NULL,
    [DestinationUrl] NVARCHAR (1000) NULL,
    [CreativeTypeID] INT             NULL,
    [CreativeGK]     BIGINT          NULL,
    CONSTRAINT [PK_Ad] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_Ad_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_Ad_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID]),
    CONSTRAINT [FK_Ad_Creative] FOREIGN KEY ([CreativeGK]) REFERENCES [dbo].[Creative] ([GK]),
    CONSTRAINT [FK_Ad_EdgeType] FOREIGN KEY ([CreativeTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);


GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel];




GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel];




GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel];




GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel];




GO
ALTER TABLE [dbo].[Ad] NOCHECK CONSTRAINT [FK_Ad_Channel];

