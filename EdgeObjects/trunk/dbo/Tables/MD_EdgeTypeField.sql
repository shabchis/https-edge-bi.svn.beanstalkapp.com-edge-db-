CREATE TABLE [dbo].[MD_EdgeTypeField] (
    [FieldID]      INT           NOT NULL,
    [ParentTypeID] INT           NOT NULL,
    [ColumnName]   NVARCHAR (50) NOT NULL,
    [IsIdentity]   BIT           CONSTRAINT [DF_MD_EdgeTypeField_IsIdentity] DEFAULT ((0)) NOT NULL
);

