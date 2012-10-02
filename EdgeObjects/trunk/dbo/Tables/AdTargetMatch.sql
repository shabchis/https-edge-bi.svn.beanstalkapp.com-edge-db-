CREATE TABLE [dbo].[AdTargetMatch] (
    [GK]                  BIGINT         NOT NULL,
    [AdGK]                BIGINT         NOT NULL,
    [TargetGK]            BIGINT         NULL,
    [ParentTargetMatchGK] BIGINT         NULL,
    [ObjectType]          NVARCHAR (50)  NOT NULL,
    [AccountID]           INT            NOT NULL,
    [OriginalID]          NVARCHAR (50)  NULL,
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
    CONSTRAINT [PK_AdTargetMatch] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_AdTargetMatch_Ad] FOREIGN KEY ([AdGK]) REFERENCES [dbo].[Ad] ([GK]),
    CONSTRAINT [FK_AdTargetMatch_Target] FOREIGN KEY ([TargetGK]) REFERENCES [dbo].[Target] ([GK])
);


GO
ALTER TABLE [dbo].[AdTargetMatch] NOCHECK CONSTRAINT [FK_AdTargetMatch_Ad];

