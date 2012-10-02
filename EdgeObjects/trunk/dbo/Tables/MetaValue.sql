CREATE TABLE [dbo].[MetaValue] (
    [ObjectType]      NVARCHAR (50)  NOT NULL,
    [ObjectGK]        BIGINT         NOT NULL,
    [PropertyID]      INT            NOT NULL,
    [ActualValueType] NVARCHAR (50)  NOT NULL,
    [Value]           NVARCHAR (MAX) NULL,
    [ValueGK]         BIGINT         NULL,
    CONSTRAINT [PK_MetaData] PRIMARY KEY CLUSTERED ([ObjectType] ASC, [ObjectGK] ASC, [PropertyID] ASC),
    CONSTRAINT [FK_MetaData_MetaProperty] FOREIGN KEY ([PropertyID]) REFERENCES [dbo].[MetaProperty] ([ID])
);


GO
ALTER TABLE [dbo].[MetaValue] NOCHECK CONSTRAINT [FK_MetaData_MetaProperty];

