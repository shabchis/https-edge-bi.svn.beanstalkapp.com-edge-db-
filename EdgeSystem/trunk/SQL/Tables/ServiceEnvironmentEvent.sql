CREATE TABLE [dbo].[ServiceEnvironmentEvent] (
    [EventType]       NVARCHAR (50)  NOT NULL,
    [EndpointName]    NVARCHAR (100) NOT NULL,
    [EndpointAddress] NVARCHAR (500) NOT NULL,
    [TimeStarted]     DATETIME       CONSTRAINT [DF_ServiceEnvironmentEvent_TimeStarted] DEFAULT (getdate()) NOT NULL
);

