CREATE TABLE [dbo].[TargetMatch] (
    [GK]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [TypeID]             INT             NOT NULL,
    [ObjectTypeID]       INT             NULL,
    [ObjectGK]           BIGINT          NOT NULL,
    [TargetTypeID]       INT             NULL,
    [TargetGK]           BIGINT          NULL,
    [TargetDefinitionGK] BIGINT          NULL,
    [AccountID]          INT             NOT NULL,
    [ChannelID]          INT             NULL,
    [OriginalID]         NVARCHAR (100)  NULL,
    [Name]               NVARCHAR (50)   NULL,
    [DestinationUrl]     NVARCHAR (1000) NULL,
    [int_Field1]         INT             NULL,
    [int_Field2]         INT             NULL,
    [int_Field3]         INT             NULL,
    [int_Field4]         INT             NULL,
    [string_Field1]      NVARCHAR (1000) NULL,
    [string_Field2]      NVARCHAR (1000) NULL,
    [string_Field3]      NVARCHAR (1000) NULL,
    [string_Field4]      NVARCHAR (1000) NULL,
    [float_Field1]       DECIMAL (18, 3) NULL,
    [float_Field2]       DECIMAL (18, 3) NULL,
    [float_Field3]       DECIMAL (18, 3) NULL,
    [float_Field4]       DECIMAL (18, 3) NULL,
    CONSTRAINT [PK_TargetMatch] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_TargetMatch_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_TargetMatch_EdgeType] FOREIGN KEY ([ObjectTypeID]) REFERENCES [dbo].[EdgeType] ([TypeID]),
    CONSTRAINT [FK_TargetMatch_Target] FOREIGN KEY ([TargetGK]) REFERENCES [dbo].[Target] ([GK]),
    CONSTRAINT [FK_TargetMatch_TargetDefinition] FOREIGN KEY ([TargetDefinitionGK]) REFERENCES [dbo].[TargetDefinition] ([GK])
);



