CREATE TABLE [dbo].[MD_EdgeField] (
    [FieldID]     INT            NOT NULL,
    [AccountID]   INT            CONSTRAINT [DF_MD_EdgeField_AccountID] DEFAULT ((-1)) NOT NULL,
    [ChannelID]   INT            CONSTRAINT [DF_MD_EdgeField_ChannelID] DEFAULT ((-1)) NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [DisplayName] NVARCHAR (50)  NOT NULL,
    [FieldType]   NVARCHAR (100) NULL,
    [FieldTypeID] INT            NULL,
    CONSTRAINT [PK_EdgeField] PRIMARY KEY CLUSTERED ([FieldID] ASC)
);

