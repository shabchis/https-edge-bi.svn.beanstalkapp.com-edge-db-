CREATE TABLE [dbo].[Connection] (
    [AccountID]       INT    NULL,
    [FromTypeID]      INT    NOT NULL,
    [FromGK]          BIGINT NOT NULL,
    [ConnectionDefID] INT    NOT NULL,
    [ToTypeID]        INT    NULL,
    [ToGK]            BIGINT NULL,
    CONSTRAINT [PK_Connection] PRIMARY KEY CLUSTERED ([FromTypeID] ASC, [FromGK] ASC, [ConnectionDefID] ASC),
    CONSTRAINT [FK_Connection_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_Connection_ConnectionDefinition] FOREIGN KEY ([ConnectionDefID]) REFERENCES [dbo].[ConnectionDefinition] ([ID]),
    CONSTRAINT [FK_Connection_EdgeType_From] FOREIGN KEY ([FromTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID]),
    CONSTRAINT [FK_Connection_EdgeType_To] FOREIGN KEY ([ToTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);


GO
ALTER TABLE [dbo].[Connection] NOCHECK CONSTRAINT [FK_Connection_ConnectionDefinition];




GO
ALTER TABLE [dbo].[Connection] NOCHECK CONSTRAINT [FK_Connection_ConnectionDefinition];

