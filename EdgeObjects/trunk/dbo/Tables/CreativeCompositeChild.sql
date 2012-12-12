CREATE TABLE [dbo].[CreativeCompositeChild] (
    [AccountID]           INT            NOT NULL,
    [CompositeCreativeGK] BIGINT         NOT NULL,
    [ChildName]           NVARCHAR (100) NULL,
    [SingleCreativeGK]    BIGINT         NOT NULL,
    CONSTRAINT [FK_AdCreative_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_CreativeComposite_CompositeCreative] FOREIGN KEY ([CompositeCreativeGK]) REFERENCES [dbo].[Creative] ([GK]),
    CONSTRAINT [FK_CreativeComposite_SimpleCreative] FOREIGN KEY ([SingleCreativeGK]) REFERENCES [dbo].[Creative] ([GK])
);

