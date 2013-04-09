CREATE TABLE [dbo].[ServiceExecutionStatistics] (
    [ConfigName] NVARCHAR (255) NULL,
    [ConfigID]   CHAR (32)      NOT NULL,
    [ProfileID]  CHAR (32)      NOT NULL,
    [Percentile] INT            NOT NULL,
    [Value]      BIGINT         NULL,
    CONSTRAINT [PK_ServiceExecutionStatistics] PRIMARY KEY CLUSTERED ([ConfigID] ASC, [ProfileID] ASC, [Percentile] ASC)
);

