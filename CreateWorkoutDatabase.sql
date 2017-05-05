USE master;
GO

IF  DB_ID('WorkoutDatabase') IS NOT NULL
    DROP DATABASE WorkoutDatabase;
GO

CREATE DATABASE WorkoutDatabase;
GO

USE WorkoutDatabase;

CREATE TABLE Users (
	userID     int              PRIMARY KEY    IDENTITY(0,1),
	name       varchar(255)     NOT NULL,
	email      varchar(255)     NOT NULL,
	[password] varbinary(128) NOT NULL,
	birthday   date,
	height     float,
	[weight]   float,
	trainer    bit,
	deleted	   bit				DEFAULT(0)	
);


CREATE TABLE PersonalTrainers (
	trainerID int PRIMARY KEY	IDENTITY(0,1),
	userID    int REFERENCES Users (userID)
);


CREATE TABLE Templates (
	templateID int    PRIMARY KEY IDENTITY(0,1),
	creatorID int     REFERENCES Users (userID),
	name varchar(255) NOT NULL,
	[description] varchar(255)
);


CREATE TABLE Workouts (
	workoutID     int            PRIMARY KEY IDENTITY(0,1),
	userID        int            REFERENCES Users (userID),
	templateID    int            REFERENCES Templates (templateID),
	[description] varchar(255),
	[date]        date
);


CREATE TABLE [Types] (
	typeID        int PRIMARY KEY IDENTITY(0,1),
	name          varchar(255) NOT NULL,
	[description] varchar(255)
);


CREATE TABLE Activities (
	activityID int   PRIMARY KEY IDENTITY(0,1),
	workoutID  int   REFERENCES workouts (workoutID),
	templateID int   REFERENCES Templates (templateID),
	typeID     int   REFERENCES [Types] (typeID),
	reps       int,
	[sets]     int,
	[weight]   float,
	rest       int,
	distance   float,
	[time]     int
);



