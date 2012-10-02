﻿CREATE TABLE [dbo].[Target] (
    [GK]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [ObjectType]     NVARCHAR (50)  NOT NULL,
    [AccountID]      INT            NOT NULL,
    [OriginalID]     NVARCHAR (50)  NULL,
    [Name]           NVARCHAR (50)  NULL,
    [Status]         INT            NOT NULL,
    [DestinationUrl] NVARCHAR (50)  NULL,
    [int_Field1]     INT            NULL,
    [int_Field2]     INT            NULL,
    [int_Field3]     INT            NULL,
    [int_Field4]     INT            NULL,
    [string_Field1]  NVARCHAR (100) NULL,
    [string_Field2]  NVARCHAR (100) NULL,
    [string_Field3]  NVARCHAR (100) NULL,
    [string_Field4]  NVARCHAR (100) NULL,
    CONSTRAINT [PK_Target_1] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_Target_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID])
);

