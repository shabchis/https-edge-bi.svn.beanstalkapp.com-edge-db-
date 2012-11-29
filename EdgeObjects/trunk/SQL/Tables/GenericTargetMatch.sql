CREATE TABLE [dbo].[GenericTargetMatch] (
    [GK]                  BIGINT         NOT NULL,
    [TargetGK]            BIGINT         NULL,
    [ParentTargetMatchGK] BIGINT         NULL,
    [ObjectType]          NVARCHAR (50)  NOT NULL,
    [AccountID]           INT            NOT NULL,
    [OriginalID]          NVARCHAR (100) NULL,
    [Name]                NVARCHAR (50)  NULL,
    [Status]              INT            NOT NULL,
    [DestinationUrl]      NVARCHAR (50)  NULL,
    [int_Field1]          INT            NULL,
    [int_Field2]          INT            NULL,
    [int_Field3]          INT            NULL,
    [int_Field4]          INT            NULL,
    [string_Field1]       NVARCHAR (100) NULL,
    [string_Field2]       NVARCHAR (100) NULL,
    [string_Field3]       NVARCHAR (100) NULL,
    [string_Field4]       NVARCHAR (100) NULL,
    CONSTRAINT [PK_GenericTargetMatch] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_GenericTargetMatch_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_GenericTargetMatch_Target] FOREIGN KEY ([TargetGK]) REFERENCES [dbo].[Target] ([GK])
);


GO
ALTER TABLE [dbo].[GenericTargetMatch] NOCHECK CONSTRAINT [FK_GenericTargetMatch_Account];




GO
ALTER TABLE [dbo].[GenericTargetMatch] NOCHECK CONSTRAINT [FK_GenericTargetMatch_Account];

