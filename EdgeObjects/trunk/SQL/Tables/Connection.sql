CREATE TABLE [dbo].[Connection] (
    [FromObjectType]  NVARCHAR (50) NOT NULL,
    [FromObjectGK]    BIGINT        NOT NULL,
    [ConnectionDefID] INT           NOT NULL,
    [ToObjectType]    NVARCHAR (50) NULL,
    [ToObjectGK]      BIGINT        NULL,
    CONSTRAINT [PK_Connection] PRIMARY KEY CLUSTERED ([FromObjectType] ASC, [FromObjectGK] ASC, [ConnectionDefID] ASC),
    CONSTRAINT [FK_Connection_ConnectionDefinition] FOREIGN KEY ([ConnectionDefID]) REFERENCES [dbo].[ConnectionDefinition] ([ID])
);


GO
ALTER TABLE [dbo].[Connection] NOCHECK CONSTRAINT [FK_Connection_ConnectionDefinition];

