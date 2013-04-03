CREATE TABLE [dbo].[MD_MetricsMetadata] (
    [TableName]     NVARCHAR (100) NOT NULL,
    [EdgeFieldID]   INT            NULL,
    [EdgeFieldName] NVARCHAR (50)  NULL,
    [EdgeTypeID]    INT            NULL,
    [MeasureName]   NVARCHAR (50)  CONSTRAINT [DF_MD_MetricsMetadata_IsMeasure] DEFAULT ((0)) NULL
);

