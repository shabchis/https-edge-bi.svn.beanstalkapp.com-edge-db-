CREATE TABLE [dbo].[Goal] (
    [ObjectTypeID] INT             NOT NULL,
    [AccountID]    INT             NOT NULL,
    [ChannelID]    INT             NOT NULL,
    [ObjectGK]     BIGINT          NOT NULL,
    [DateStart]    DATETIME        NOT NULL,
    [DateEnd]      DATETIME        NOT NULL,
    [MeasureID]    INT             NOT NULL,
    [Value]        DECIMAL (18, 3) NOT NULL,
    CONSTRAINT [PK_Goal] PRIMARY KEY CLUSTERED ([ObjectTypeID] ASC, [ObjectGK] ASC, [DateStart] ASC, [DateEnd] ASC, [MeasureID] ASC),
    CONSTRAINT [FK_Goal_EdgeType] FOREIGN KEY ([ObjectTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);





