CREATE TABLE [dbo].[ServiceEnvironmentEvent] (
    [ListenerID]      CHAR (32)      NOT NULL,
    [EventType]       NVARCHAR (50)  NOT NULL,
    [EndpointName]    NVARCHAR (100) NOT NULL,
    [EndpointAddress] NVARCHAR (500) NOT NULL,
    [TimeStarted]     DATETIME       CONSTRAINT [DF_ServiceEnvironmentEvent_TimeStarted] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ServiceEnvironmentEvent] PRIMARY KEY CLUSTERED ([ListenerID] ASC, [EventType] ASC)
);



