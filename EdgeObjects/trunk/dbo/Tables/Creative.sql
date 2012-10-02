CREATE TABLE [dbo].[Creative] (
    [GK]            BIGINT         NOT NULL,
    [ObjectType]    NVARCHAR (50)  NOT NULL,
    [AccountID]     INT            NOT NULL,
    [OriginalID]    NVARCHAR (50)  NULL,
    [Name]          NVARCHAR (50)  NULL,
    [Status]        INT            NOT NULL,
    [int_Field1]    INT            NULL,
    [int_Field2]    INT            NULL,
    [int_Field3]    INT            NULL,
    [int_Field4]    INT            NULL,
    [string_Field1] NVARCHAR (100) NULL,
    [string_Field2] NVARCHAR (100) NULL,
    [string_Field3] NVARCHAR (100) NULL,
    [string_Field4] NVARCHAR (100) NULL,
    [DateCreated]   DATETIME       CONSTRAINT [DF_Creative_DateCreated] DEFAULT (getdate()) NULL,
    [DateModified]  DATETIME       CONSTRAINT [DF_Creative_DateModified] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Creative_1] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_Creative_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID])
);


GO
ALTER TABLE [dbo].[Creative] NOCHECK CONSTRAINT [FK_Creative_Account];

