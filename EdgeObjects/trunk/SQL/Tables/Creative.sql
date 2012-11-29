CREATE TABLE [dbo].[Creative] (
    [GK]            BIGINT          NOT NULL,
    [ObjectType]    NVARCHAR (50)   NOT NULL,
    [AccountID]     INT             NOT NULL,
    [OriginalID]    NVARCHAR (100)  NULL,
    [Name]          NVARCHAR (1000) NULL,
    [Status]        INT             NULL,
    [int_Field1]    INT             NULL,
    [int_Field2]    INT             NULL,
    [int_Field3]    INT             NULL,
    [int_Field4]    INT             NULL,
    [string_Field1] NVARCHAR (1000) NULL,
    [string_Field2] NVARCHAR (1000) NULL,
    [string_Field3] NVARCHAR (1000) NULL,
    [string_Field4] NVARCHAR (1000) NULL,
    CONSTRAINT [PK_Creative_1] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_Creative_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID])
);


GO
ALTER TABLE [dbo].[Creative] NOCHECK CONSTRAINT [FK_Creative_Account];




GO
ALTER TABLE [dbo].[Creative] NOCHECK CONSTRAINT [FK_Creative_Account];




GO
ALTER TABLE [dbo].[Creative] NOCHECK CONSTRAINT [FK_Creative_Account];

