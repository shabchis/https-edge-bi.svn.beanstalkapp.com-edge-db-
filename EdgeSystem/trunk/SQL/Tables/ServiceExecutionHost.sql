CREATE TABLE [dbo].[ServiceExecutionHost] (
    [HostName]        NVARCHAR (50)  NOT NULL,
    [HostGuid]        CHAR (32)      NOT NULL,
    [EndpointName]    NVARCHAR (100) NOT NULL,
    [EndpointAddress] NVARCHAR (500) NOT NULL,
    [TimeStarted]     DATETIME       CONSTRAINT [DF_ServiceExecutionHost_TimeStarted] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ServiceEnvironmentHost] PRIMARY KEY CLUSTERED ([HostName] ASC)
);

