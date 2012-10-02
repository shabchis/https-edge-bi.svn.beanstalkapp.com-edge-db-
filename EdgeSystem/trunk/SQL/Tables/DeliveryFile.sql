CREATE TABLE [dbo].[DeliveryFile] (
    [DeliveryID]      CHAR (32)      NOT NULL,
    [FileID]          CHAR (32)      NOT NULL,
    [Name]            NVARCHAR (50)  NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [DateModified]    DATETIME       NOT NULL,
    [FileCompression] INT            NOT NULL,
    [SourceUrl]       NVARCHAR (MAX) NULL,
    [Location]        NVARCHAR (260) NULL,
    [Status]          INT            CONSTRAINT [DF_DeliveryFile_Status] DEFAULT ((0)) NOT NULL,
    [FileSignature]   NVARCHAR (400) NULL
);

