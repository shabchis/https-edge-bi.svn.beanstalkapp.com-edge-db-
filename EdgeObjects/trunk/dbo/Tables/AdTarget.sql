CREATE TABLE [dbo].[AdTarget] (
    [AccountID] INT    NOT NULL,
    [ChannelID] INT    NOT NULL,
    [AdGK]      BIGINT NOT NULL,
    [TargetGK]  BIGINT NOT NULL,
    CONSTRAINT [PK_AdTarget] PRIMARY KEY CLUSTERED ([AdGK] ASC, [TargetGK] ASC),
    CONSTRAINT [FK_AdTarget_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_AdTarget_Ad] FOREIGN KEY ([AdGK]) REFERENCES [dbo].[Ad] ([GK]),
    CONSTRAINT [FK_AdTarget_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID]),
    CONSTRAINT [FK_AdTarget_Target] FOREIGN KEY ([TargetGK]) REFERENCES [dbo].[Target] ([GK])
);


GO
ALTER TABLE [dbo].[AdTarget] NOCHECK CONSTRAINT [FK_AdTarget_Channel];


GO
ALTER TABLE [dbo].[AdTarget] NOCHECK CONSTRAINT [FK_AdTarget_Target];

