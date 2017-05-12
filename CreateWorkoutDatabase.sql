USE master;
GO

IF  DB_ID('WorkoutDatabase') IS NOT NULL
    DROP DATABASE WorkoutDatabase;
GO

CREATE DATABASE WorkoutDatabase;
GO

USE WorkoutDatabase;

CREATE TABLE [dbo].[Users] (
    [userID]   INT             IDENTITY (1, 1) NOT NULL,
    [name]     VARCHAR (255)   NOT NULL,
    [email]    VARCHAR (255)   NOT NULL,
    [password] VARBINARY (128) NOT NULL,
    [birthday] DATE            NULL,
    [height]   FLOAT (53)      NULL,
    [weight]   FLOAT (53)      NULL,
    [trainer]  BIT             NULL,
    [deleted]  BIT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([userID] ASC)
);


CREATE TABLE [dbo].[PersonalTrainers] (
    [trainerID] INT NOT NULL,
    [userID]    INT NOT NULL,
    FOREIGN KEY ([userID]) REFERENCES [dbo].[Users] ([userID])
);

CREATE TABLE [dbo].[Templates] (
    [templateID]  INT           IDENTITY (1, 1) NOT NULL,
    [creatorID]   INT           NULL,
    [name]        VARCHAR (255) NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([templateID] ASC),
    FOREIGN KEY ([creatorID]) REFERENCES [dbo].[Users] ([userID])
);

CREATE TABLE [dbo].[Workouts] (
    [workoutID]   INT           IDENTITY (1, 1) NOT NULL,
    [userID]      INT           NULL,
    [templateID]  INT           NULL,
    [description] VARCHAR (255) NULL,
    [date]        DATE          NULL,
    PRIMARY KEY CLUSTERED ([workoutID] ASC),
    FOREIGN KEY ([templateID]) REFERENCES [dbo].[Templates] ([templateID]),
    FOREIGN KEY ([userID]) REFERENCES [dbo].[Users] ([userID])
);


CREATE TABLE [dbo].[Types] (
    [typeID]      INT           IDENTITY (1, 1) NOT NULL,
    [name]        VARCHAR (255) NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([typeID] ASC)
);


CREATE TABLE [dbo].[Activities] (
    [activityID] INT        IDENTITY (1, 1) NOT NULL,
    [workoutID]  INT        NULL,
    [templateID] INT        NULL,
    [typeID]     INT        NULL,
    [reps]       INT        NULL,
    [sets]       INT        NULL,
    [weight]     FLOAT (53) NULL,
    [rest]       INT        NULL,
    [distance]   FLOAT (53) NULL,
    [time]       INT        NULL,
    PRIMARY KEY CLUSTERED ([activityID] ASC),
    FOREIGN KEY ([templateID]) REFERENCES [dbo].[Templates] ([templateID]),
    FOREIGN KEY ([typeID]) REFERENCES [dbo].[Types] ([typeID]),
    FOREIGN KEY ([workoutID]) REFERENCES [dbo].[Workouts] ([workoutID])
);



