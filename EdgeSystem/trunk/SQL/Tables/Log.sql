CREATE TABLE [dbo].[Log] (
    [ID]                BIGINT         IDENTITY (1000000001, 1) NOT NULL,
    [DateRecorded]      DATETIME       CONSTRAINT [DF_Log_DateRecorded] DEFAULT (getdate()) NOT NULL,
    [MachineName]       NVARCHAR (50)  NOT NULL,
    [ProcessID]         INT            NOT NULL,
    [Source]            NVARCHAR (255) NOT NULL,
    [MessageType]       INT            NOT NULL,
    [ServiceInstanceID] BIGINT         NULL,
    [AccountID]         INT            NULL,
    [Message]           NVARCHAR (MAX) NULL,
    [IsException]       BIT            CONSTRAINT [DF_Log_IsException] DEFAULT ((0)) NOT NULL,
    [ExceptionDetails]  NVARCHAR (MAX) NULL
);

