GO
CREATE PROCEDURE spLoginUser
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
CREATE PROCEDURE spRegisterUser
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
CREATE PROCEDURE spUpdateUser
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
CREATE PROCEDURE spUpdateUserPassword
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
CREATE PROCEDURE spDeleteUser
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
CREATE PROCEDURE spAddWorkout
	@userID				int,
	@templateID			int,
	@description		varchar(MAX),
	@date				date
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Users WHERE @userID IN (SELECT userID FROM Users WHERE deleted = 0)) 
		BEGIN 
			SELECT [error] = 'This user does not exist'
		END 
	ELSE
		BEGIN
			INSERT INTO Workouts(userID, templateID, [description], [date])
			VALUES (@userID, @templateID, @description, @date) 

			SELECT [workoutID] = @@IDENTITY, * FROM Workouts WHERE workoutID = @@IDENTITY
		END



GO 
CREATE PROCEDURE spUpdateWorkout
	@workoutID			int, 
	@userID				int,
	@template			int,
	@description		varchar(255),
	@date				date
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
		BEGIN 
			SELECT [error] = 'This workout does not exist'
		END 
	ELSE 
		BEGIN
			UPDATE Workouts
			SET userID = @userID,
				templateID = @template,
				[description] = @description,
				[date] = @date
			WHERE workoutID = @workoutID

			SELECT * FROM Workouts WHERE workoutID = @workoutID
		END

GO
CREATE PROCEDURE spDeleteWorkout
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
CREATE PROCEDURE spAddPersonalTrainer
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
		END

GO
CREATE PROCEDURE spDeletePersonalTrainer
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
CREATE PROCEDURE spAddTemplate
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
CREATE PROCEDURE spUpdateTemplate
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
CREATE PROCEDURE spDeleteTemplate
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
CREATE PROCEDURE spGetWorkoutsForUser
	@UserID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Workouts 
	WHERE userID = @UserID 
	ORDER BY [date] DESC

GO
CREATE PROCEDURE spGetWorkoutsForUserInRange
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
CREATE PROCEDURE spGetActivitiesForWorkout
	@workoutID	int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Activities
	WHERE @workoutID = Activities.workoutID


GO
CREATE PROCEDURE spGetTypeByID
	@typeID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM [Types]
	WHERE @typeID = [Types].typeID


GO
CREATE PROCEDURE spGetAllTypes
AS
	SET NOCOUNT ON

	SELECT *
	FROM [Types]


GO
CREATE PROCEDURE spGetTrainerForUser
	@userID		int
AS
	SET NOCOUNT ON
	
	SELECT *
	FROM PersonalTrainers
	WHERE @userID = PersonalTrainers.userID


GO
CREATE PROCEDURE spGetTraineesForUser
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
CREATE PROCEDURE spSearchUsers
	@query		varchar(30)
AS
	SET NOCOUNT ON

	SELECT userID, name, email, birthday, height, [weight], trainer, deleted
	FROM Users
	WHERE name+ '~' + email LIKE ('%' + @query + '%')


GO
CREATE PROCEDURE spGetActivityByID
	@activityID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Activities
	WHERE activityID = @activityID

GO
CREATE PROCEDURE spGetTemplateByID
	@templateID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Templates
	WHERE templateID = @templateID

GO
CREATE PROCEDURE spGetTemplatesByUser
	@creatorID  	int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Templates
	WHERE creatorID = @creatorID


GO
CREATE PROCEDURE spGetUserByID
	@userID		int
AS
	SET NOCOUNT ON

	SELECT userID, name, email, birthday, height, [weight], trainer, deleted
	FROM Users
	WHERE userID = @userID


GO
CREATE PROCEDURE spGetWorkoutByID
	@workoutID		int
AS
	SET NOCOUNT ON

	SELECT *
	FROM Workouts
	WHERE workoutID = @workoutID
	ORDER BY [date] DESC

GO
CREATE PROCEDURE spAddActivity       
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

	BEGIN
		INSERT INTO Activities(workoutID, templateID, typeID, reps, [sets], [weight], rest, distance, [time])
		VALUES (@workoutID, @templateID ,@typeID ,@reps ,@sets ,@weight ,@rest ,@distance , @timer)   
		SELECT [activityID] = @@IDENTITY, * FROM Activities WHERE activityID= @@IDENTITY
	END
GO
CREATE PROCEDURE spAddType                  
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
CREATE PROCEDURE spUpdateType                  
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
CREATE PROCEDURE spUpdateActivity       
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