CREATE TABLE [dbo].[MD_EdgeType] (
    [TypeID]     INT            IDENTITY (1, 1) NOT NULL,
    [BaseTypeID] INT            NULL,
    [ClrType]    NVARCHAR (200) NOT NULL,
    [Name]       NVARCHAR (50)  NOT NULL,
    [IsAbstract] BIT            NULL,
    [TableName]  NVARCHAR (50)  NOT NULL,
    [AccountID]  INT            CONSTRAINT [DF_EdgeType_AccountID] DEFAULT ((-1)) NOT NULL,
    [ChannelID]  INT            CONSTRAINT [DF_EdgeType_ChannelID] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [PK_EdgeType] PRIMARY KEY CLUSTERED ([TypeID] ASC),
    CONSTRAINT [FK_EdgeType_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_EdgeType_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID])
);

