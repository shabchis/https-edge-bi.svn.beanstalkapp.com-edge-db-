CREATE TABLE [dbo].[Goal] (
    [ObjectType] NVARCHAR (50)   NOT NULL,
    [AccountID]  INT             NOT NULL,
    [ChannelID]  INT             NOT NULL,
    [ObjectGK]   BIGINT          NOT NULL,
    [DateStart]  DATETIME        NOT NULL,
    [DateEnd]    DATETIME        NOT NULL,
    [MeasureID]  INT             NOT NULL,
    [Value]      DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_Goal] PRIMARY KEY CLUSTERED ([ObjectType] ASC, [ObjectGK] ASC, [DateStart] ASC, [DateEnd] ASC, [MeasureID] ASC)
);



