CREATE TABLE [dbo].[MetaProperty] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50) NOT NULL,
    [AccountID]     INT           NULL,
    [ChannelID]     INT           NULL,
    [BaseValueType] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MetaProperty] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MetaProperty_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID])
);


GO
ALTER TABLE [dbo].[MetaProperty] NOCHECK CONSTRAINT [FK_MetaProperty_Channel];

