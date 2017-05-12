USE [WorkoutDatabase]
GO
/****** Object:  StoredProcedure [dbo].[spAddActivity]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAddActivity]       
	@workoutID		int,        
	@typeID			int,        
	@reps			int,        
	@sets			int,        
	@weight			float(53), 
	@rest			int,        
	@distance		float(53), 
	@timer			int        
AS
	SET NOCOUNT ON

	BEGIN
		INSERT INTO Activities(workoutID, typeID, reps, [sets], [weight], rest, distance, [time])
		VALUES (@workoutID,@typeID ,@reps ,@sets ,@weight ,@rest ,@distance , @timer)   
		SELECT [activityID] = @@IDENTITY, * FROM Activities WHERE activityID= @@IDENTITY
	END
GO
/****** Object:  StoredProcedure [dbo].[spAddPersonalTrainer]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAddPersonalTrainer]
	@UserID		int,
	@TrainerID	int
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE userID LIKE @UserID) 
		BEGIN
			SELECT [error] = 'This user already has a trainer'
		END 
	ELSE
	IF EXISTS(SELECT NULL FROM Users WHERE (userID LIKE @TrainerID) AND (trainer = 0))
		BEGIN
			SELECT [error] = 'trainer inputted is not a trainer'
		END
		ELSE
		BEGIN
			INSERT INTO PersonalTrainers(trainerID, userID)
			VALUES(@TrainerID, @UserID)
			SELECT * FROM PersonalTrainers WHERE trainerID LIKE @TrainerID
		END
GO
/****** Object:  StoredProcedure [dbo].[spAddTemplate]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAddTemplate]
	@CreatorID		int,
	@Name			varchar(255),
	@Description	varchar(255)
AS 
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM Templates WHERE	(creatorID LIKE @CreatorID) AND (name LIKE @Name) AND ([description] LIKE @Description)) 
		BEGIN
			SELECT [error] = 'This template already exists'
		END
	ELSE 
		BEGIN
			INSERT INTO Templates(creatorID, name, [description])
			VALUES(@CreatorID, @Name, @Description)
			SELECT [templateID] = @@IDENTITY, creatorID, [name], [description] FROM Templates WHERE templateID = @@IDENTITY
		END


GO
/****** Object:  StoredProcedure [dbo].[spAddType]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAddType]                  
    @name			nvarchar(255),
    @description	nvarchar(255)              
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT NULL FROM [Types] WHERE name = @name)
		BEGIN
			INSERT INTO [Types](name, [description])
			VALUES (@name, @description)  
			SELECT [newId] = @@IDENTITY, [error] = ''
		END	
	ELSE 
		BEGIN
			 SELECT [newId] = 0, [error] = 'This type name already exists'
		END


GO
/****** Object:  StoredProcedure [dbo].[spAddWorkout]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAddWorkout]
	@userID				int,
	@description		varchar(MAX)
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Users WHERE (@userID LIKE userID) AND (deleted = 0))
		BEGIN 
			SELECT [error] = 'This user does not exist'
		END 
	ELSE
		BEGIN
			INSERT INTO Workouts(userID, [description], [date])
			VALUES (@userID, @description, GETDATE()) 

			SELECT * FROM Workouts WHERE workoutID = @@IDENTITY
		END
GO
/****** Object:  StoredProcedure [dbo].[spDeletePersonalTrainer]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeletePersonalTrainer]
	@TrainerID		int,
	@UserID			int
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE trainerID LIKE @TrainerID AND userID LIKE @UserID)
		BEGIN
			DELETE PersonalTrainers
			FROM PersonalTrainers
			WHERE @TrainerID LIKE trainerID

			SELECT [success] = 'Personal Trainer has been successfully deleted'
		END 
	ELSE
		BEGIN
			SELECT [error] = 'User does not exist'
		END


GO
/****** Object:  StoredProcedure [dbo].[spDeleteTemplate]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteTemplate]
	@TemplateID 	int
AS
	SET NOCOUNT ON

	IF EXISTS (SELECT NULL FROM Templates WHERE templateID = @TemplateID) AND NOT EXISTS(SELECT NULL FROM Workouts WHERE templateID = @TemplateID)
		BEGIN
			DELETE
			FROM Templates
			WHERE templateID = @TemplateID 
			SELECT [success] = 'Template has been successfully deleted'
		END 
	ELSE 
		BEGIN
			SELECT [error] = 'Could not delete template'
		END


GO
/****** Object:  StoredProcedure [dbo].[spDeleteUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteUser]
	@userID		int
AS
	SET NOCOUNT ON

	IF(@userID NOT IN (SELECT trainerID FROM PersonalTrainers))
		BEGIN
			UPDATE Users
			SET deleted = 1
			WHERE userID = @userID
			SELECT [success] = 'User has been deleted'
		END 
	ELSE 
		BEGIN
 			SELECT [error] = 'User must be a trainer, so could not be deleted.'
		END

GO
/****** Object:  StoredProcedure [dbo].[spDeleteWorkout]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteWorkout]
	@workoutID		int
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
		BEGIN 
			SELECT [error] = 'This workout does not exist'
		END 
	ELSE IF NOT EXISTS(SELECT NULL FROM Activities WHERE workoutID = @workoutID)
		BEGIN
			SELECT [error] = 'There is an activity that has this workout'
		END 
	ELSE 
		BEGIN
			DELETE FROM Workouts
			WHERE workoutID = @workoutID

			SELECT [success] = 'Workout has been successfully deleted'
		END


GO
/****** Object:  StoredProcedure [dbo].[spGetActivitiesForWorkout]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetActivitiesForWorkout]
	@workoutID	int
AS
	SET NOCOUNT ON

	SELECT *, t.name
	FROM Activities a LEFT JOIN [Types] t
		ON a.typeID = t.typeID
	WHERE @workoutID = a.workoutID
GO
/****** Object:  StoredProcedure [dbo].[spGetActivityByID]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetActivityByID]
	@activityID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Activities
	WHERE activityID = @activityID


GO
/****** Object:  StoredProcedure [dbo].[spGetAllTypes]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAllTypes]
AS
	SET NOCOUNT ON

	SELECT *
	FROM [Types]



GO
/****** Object:  StoredProcedure [dbo].[spGetTemplateByID]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTemplateByID]
	@templateID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Templates
	WHERE templateID = @templateID


GO
/****** Object:  StoredProcedure [dbo].[spGetTemplatesByUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTemplatesByUser]
	@creatorID  	int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Templates
	WHERE creatorID = @creatorID



GO
/****** Object:  StoredProcedure [dbo].[spGetTraineesForUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTraineesForUser]
	@userID		int
AS
	SET NOCOUNT ON
	
	IF 1 = (SELECT trainer FROM Users WHERE @userID = Users.userID)
		BEGIN
			SELECT *
			FROM PersonalTrainers
			WHERE PersonalTrainers.trainerID = @userID
		END



GO
/****** Object:  StoredProcedure [dbo].[spGetTrainerForUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTrainerForUser]
	@userID		int
AS
	SET NOCOUNT ON
	
	SELECT [userID], name, email, birthday, [height], [weight], trainer, deleted 
	FROM Users
	WHERE Users.userID IN (
		SELECT trainerID 
		FROM PersonalTrainers
		WHERE @userID = PersonalTrainers.userID
	)
GO
/****** Object:  StoredProcedure [dbo].[spGetTypeByID]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTypeByID]
	@typeID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM [Types]
	WHERE @typeID = [Types].typeID



GO
/****** Object:  StoredProcedure [dbo].[spGetUserByID]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUserByID]
	@userID		int
AS
	SET NOCOUNT ON

	SELECT userID, name, email, birthday, height, [weight], trainer, deleted
	FROM Users
	WHERE userID = @userID



GO
/****** Object:  StoredProcedure [dbo].[spGetWorkoutByID]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetWorkoutByID]
	@workoutID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Workouts
	WHERE workoutID = @workoutID
	ORDER BY [date] DESC


GO
/****** Object:  StoredProcedure [dbo].[spGetWorkoutsForUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetWorkoutsForUser]
	@UserID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Workouts 
	WHERE userID = @UserID 
	ORDER BY [date] DESC


GO
/****** Object:  StoredProcedure [dbo].[spGetWorkoutsForUserInRange]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetWorkoutsForUserInRange]
	@userID		int,
	@start		date,
	@endd		date
AS
	SET NOCOUNT ON

	IF(@start > @endd) BEGIN
		SELECT [error] = 'start date cant be after end date'
	END ELSE BEGIN
		SELECT *
		FROM Workouts
		WHERE (@userID = userID) AND ([date] BETWEEN @start AND @endd)
		ORDER BY [date] DESC
	END


GO
/****** Object:  StoredProcedure [dbo].[spLoginUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLoginUser]
	@email			varchar(255),
	@password		varchar(255)
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Users WHERE email = @email)
		BEGIN
			SELECT [error] = 'Sorry we could not find your email address'
		END 
	ELSE IF EXISTS(SELECT NULL FROM Users WHERE (email = @email)  AND (Users.deleted = 0) AND (PWDCOMPARE(@password, Users.password) = 1))
		BEGIN
			SELECT [userID], name, email, birthday, [height], [weight], trainer, deleted FROM Users WHERE email = @email
		END 
	ELSE 
		BEGIN
			SELECT [error] = 'Could not find your password or email address'
		END

GO
/****** Object:  StoredProcedure [dbo].[spRegisterUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spRegisterUser]
	@name			varchar(255),
	@email			varchar(255),
	@password		varchar(255)
AS 
	SET NOCOUNT ON
	
	IF EXISTS(SELECT NULL FROM Users WHERE @email = email)
		BEGIN
			SELECT [errorMessage] = 'Sorry that email is already in use'
		END 
	ELSE 
		BEGIN
			INSERT INTO Users([name], email, [password] )
			VALUES (@name, @email, PWDENCRYPT(@password))
			SELECT [userID], name, email, birthday, [height], [weight], trainer, deleted FROM Users WHERE email = @email
		END

GO
/****** Object:  StoredProcedure [dbo].[spSearchUsers]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSearchUsers]
	@query		varchar(30)
AS
	SET NOCOUNT ON

	SELECT userID, name, email, birthday, height, [weight], trainer, deleted
	FROM Users
	WHERE name+ '~' + email LIKE ('%' + @query + '%')



GO
/****** Object:  StoredProcedure [dbo].[spUpdateActivity]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateActivity]       
	@activityID		int,
	@workoutID		int,        
	@templateID		int,        
	@typeID			int,        
	@reps			int,        
	@sets			int,        
	@weight			float(53), 
	@rest			int,        
	@distance		float(53), 
	@timer			int	        
AS
	SET NOCOUNT ON

	IF (EXISTS(SELECT NULL From Workouts where workoutID = @workoutID) AND 
	    EXISTS (SELECT NULL FROM Templates where templateID = @templateID) AND 
	    EXISTS(SELECT NULL FROM Types where typeID = @typeID)) 
		BEGIN
			UPDATE Activities
			SET workoutID = @workoutID, templateID = @templateID, typeID = @typeID, reps = @reps, [sets] = @sets, [weight] = @weight, rest = @rest, distance = @distance, [time] = @timer
			WHERE activityID = @activityID
			SELECT * FROM Activities WHERE activityID = @activityID 	
		END 
	ELSE 
		BEGIN
			SELECT [error] = 'invalid workoutID, templateID, or typeID'
		END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTemplate]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateTemplate]
	@TemplateID		int,
	@CreatorID		int,
	@Name			varchar(255),
	@Description	varchar(255)

AS
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM Templates WHERE	(templateID LIKE @TemplateID))
		BEGIN
			UPDATE Templates
			SET creatorID = @CreatorID,
				[name] = @Name,
				[description] = @Description
			WHERE templateID LIKE @TemplateID
			SELECT * FROM Templates WHERE templateID = @TemplateID
		END 
	ELSE 
		BEGIN
			SELECT [error] = 'Template could not be found'
		END


GO
/****** Object:  StoredProcedure [dbo].[spUpdateType]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateType]                  
    @typeID			int,
	@name			nvarchar(255),
    @description	nvarchar(255)              
AS
	SET NOCOUNT ON
	
	IF EXISTS(SELECT NULL FROM Types WHERE name = @name)
		BEGIN
			SELECT [error] = 'This type name already exists'
		END
	ELSE
		BEGIN
			UPDATE [Types]
			SET name = @name, [description] = @description
			WHERE typeID = @typeID
			SELECt * FROM [Types] WHERE typeID = @typeID
		END

GO
/****** Object:  StoredProcedure [dbo].[spUpdateUser]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateUser]
	@userID			int,
	@email			varchar(255),
	@name			varchar(255),
	@birthday		date,
	@weight			float,
	@height			float,
	@trainer		bit
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT NULL FROM Users WHERE userID = @userID)
		BEGIN
			SELECT [error] = 'Could not find user to update'
		END 
	ELSE
		BEGIN
			UPDATE Users
			SET email = ISNULL(@email, email),
				[name] = ISNULL(@name, [name]),
				birthday = ISNULL(@birthday, birthday),
				[weight] = ISNULL(@weight, [weight]),
				[height] = ISNULL(@height, [height]),
				trainer = ISNULL(@trainer, trainer)
			WHERE userID = @userID
			SELECT userID, email, [name], birthday, [weight], [height] FROM Users WHERE userID = @userID
		END

GO
/****** Object:  StoredProcedure [dbo].[spUpdateUserPassword]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateUserPassword]
	@userID				int,
	@oldPassword		varchar(255),
	@newPassword		varchar(255)
AS
	SET NOCOUNT ON 

	IF EXISTS(SELECT NULL FROM Users WHERE (userID = @userID) AND (PWDCOMPARE(@oldPassword, Users.password) = 1))
		BEGIN
			UPDATE Users
			SET [password] = PWDENCRYPT(@newPassword)
			WHERE userID = @userID

		END 
	ELSE 
		BEGIN
 			SELECT [error] = 'Password could not be updated'
		END


GO
/****** Object:  StoredProcedure [dbo].[spUpdateWorkout]    Script Date: 5/11/2017 9:49:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateWorkout]
	@workoutID			int, 
	@userID				int,
	@template			int,
	@description		varchar(255)
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
		BEGIN 
			SELECT [error] = 'This workout does not exist'
		END 
	ELSE IF NOT EXISTS(SELECT NULL FROM Templates WHERE (templateID = @template))
		BEGIN 
			SELECT [error] = 'This template does not exist'
		END 
	ELSE 
		BEGIN
			UPDATE Workouts
			SET userID = @userID,
				templateID = @template,
				[description] = @description
			WHERE workoutID = @workoutID

			SELECT * FROM Workouts WHERE workoutID = @workoutID
		END
GO
