CREATE TABLE [dbo].[MeasureType] (
    [ID]      INT           NOT NULL,
    [Name]    NVARCHAR (50) NOT NULL,
    [Options] BIGINT        NULL,
    CONSTRAINT [PK_MeasureGroup] PRIMARY KEY CLUSTERED ([ID] ASC)
);

