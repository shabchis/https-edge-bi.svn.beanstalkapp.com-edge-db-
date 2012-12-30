CREATE TABLE [dbo].[EdgeField] (
    [FieldID]      INT            NOT NULL,
    [IsSystem]     BIT            NOT NULL,
    [AccountID]    INT            NOT NULL,
    [ChannelID]    INT            NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [DisplayName]  NVARCHAR (50)  NOT NULL,
    [ObjectTypeID] INT            NOT NULL,
    [FieldTypeID]  INT            NULL,
    [FieldClrType] NVARCHAR (100) NULL,
    [ColumnPrefix] NVARCHAR (50)  NOT NULL,
    [ColumnIndex]  INT            NOT NULL,
    CONSTRAINT [PK_EdgeField] PRIMARY KEY CLUSTERED ([FieldID] ASC)
);

