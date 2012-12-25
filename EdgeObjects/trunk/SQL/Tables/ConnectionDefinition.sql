CREATE TABLE [dbo].[ConnectionDefinition] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (50) NOT NULL,
    [AccountID] INT           NULL,
    [ChannelID] INT           NULL,
    [TypeID]    INT           NOT NULL,
    CONSTRAINT [PK_ConnectionDefinition] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ConnectionDefinition_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_ConnectionDefinition_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID]),
    CONSTRAINT [FK_ConnectionDefinition_EdgeType] FOREIGN KEY ([TypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);


GO
ALTER TABLE [dbo].[ConnectionDefinition] NOCHECK CONSTRAINT [FK_ConnectionDefinition_Channel];




GO
ALTER TABLE [dbo].[ConnectionDefinition] NOCHECK CONSTRAINT [FK_ConnectionDefinition_Channel];

