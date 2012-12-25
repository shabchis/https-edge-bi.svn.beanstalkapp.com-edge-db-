CREATE TABLE [dbo].[CreativeCompositePart] (
    [CompositeGK] BIGINT        NOT NULL,
    [AccountID]   INT           NOT NULL,
    [PartRole]    NVARCHAR (50) NOT NULL,
    [PartTypeID]  INT           NOT NULL,
    [PartGK]      BIGINT        NOT NULL,
    CONSTRAINT [PK_CreativeCompositePart] PRIMARY KEY CLUSTERED ([CompositeGK] ASC, [PartRole] ASC),
    CONSTRAINT [FK_CreativeCompositePart_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_CreativeCompositePart_Creative_Composite] FOREIGN KEY ([CompositeGK]) REFERENCES [dbo].[Creative] ([GK]),
    CONSTRAINT [FK_CreativeCompositePart_Creative_Part] FOREIGN KEY ([PartGK]) REFERENCES [dbo].[Creative] ([GK]),
    CONSTRAINT [FK_CreativeCompositePart_EdgeType] FOREIGN KEY ([PartTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);

