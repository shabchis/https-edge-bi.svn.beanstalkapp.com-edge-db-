CREATE TABLE [dbo].[MD_StagingMetadata] (
    [TableName]     NVARCHAR (100) NOT NULL,
    [EdgeFieldName] NVARCHAR (100) NOT NULL,
    [MeasureName]   NVARCHAR (50)  NULL,
    [FieldDataType] NCHAR (20)     NULL,
    [FieldsCount]   INT            NULL,
    [EdgeTypeID]    INT            NULL
);

