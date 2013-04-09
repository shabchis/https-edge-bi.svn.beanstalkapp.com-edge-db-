CREATE TABLE [dbo].[Log_v3] (
    [ID]                BIGINT          IDENTITY (1000000001, 1) NOT NULL,
    [DateRecorded]      DATETIME        CONSTRAINT [DF_Log_v3_DateRecorded] DEFAULT (getdate()) NOT NULL,
    [MachineName]       NVARCHAR (50)   NOT NULL,
    [ProcessID]         INT             NOT NULL,
    [Source]            NVARCHAR (300)  NOT NULL,
    [ContextInfo]       NVARCHAR (1000) NOT NULL,
    [MessageType]       INT             NOT NULL,
    [Message]           NVARCHAR (MAX)  NULL,
    [ServiceInstanceID] CHAR (32)       NULL,
    [ServiceProfileID]  CHAR (32)       NULL,
    [IsException]       BIT             CONSTRAINT [DF_Log_v3_IsException] DEFAULT ((0)) NOT NULL,
    [ExceptionDetails]  NVARCHAR (MAX)  NULL
);

