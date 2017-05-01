GO
ALTER PROCEDURE loginUser
	@email varchar(255),
	@password varchar(255)
AS
	SET NOCOUNT ON
	IF NOT EXISTS(SELECT NULL FROM Users WHERE email = @email)
	BEGIN
		SELECT [errorMessage] = 'Sorry we could not find your email address'
	END ELSE IF EXISTS(SELECT NULL FROM Users WHERE (email = @email) AND
													([password] = PWDENCRYPT(@password)))
	BEGIN
		SELECT [name], email, birthday, [height], [weight], [message] = 'User has successfully logged in' FROM Users WHERE email = @email
	END ELSE BEGIN
		SELECT [errorMessage] = 'Could not find your password or email address'
	END


GO
ALTER PROCEDURE registerUser
	@name varchar(255),
	@email varchar(255),
	@password varchar(255)
AS 
	SET NOCOUNT ON
	IF EXISTS(SELECT NULL FROM Users WHERE @email = email)
	BEGIN
		SELECT [errorMessage] = 'Sorry that email is already in use'
	END ELSE BEGIN
		INSERT INTO Users([name], email, [password] )
		VALUES (@name, @email, PWDENCRYPT(@password))

		SELECT [userID] = @@IDENTITY, email, [name] FROM Users WHERE email = @email
	END


GO 
ALTER PROCEDURE updateUser            --ask about separate password update
	@userID int,
	@email varchar(255),
	@password varchar(255),
	@name varchar(255),
	@birthday date,
	@weight float,
	@height float,
	@trainer bit
AS
	SET NOCOUNT ON
	IF NOT EXISTS(SELECT NULL FROM Users WHERE userID = @userID)
	BEGIN
		SELECT [errorMessage] = 'Could not find user to update'
	END ELSE BEGIN
		UPDATE Users
		SET email = ISNULL(@email, email),
			[password] = ISNULL(PWDENCRYPT(@password), [password]),
			[name] = ISNULL(@name, [name]),
			birthday = ISNULL(@birthday, birthday),
			[weight] = ISNULL(@weight, [weight]),
			[height] = ISNULL(@height, [height]),
			trainer = ISNULL(@trainer, trainer)
		WHERE userID = @userID

		SELECT userID, email, [name], birthday, [weight], [height] FROM Users WHERE userID = userID
	END


GO
ALTER PROCEDURE addWorkout
	@userID int,
	@templateID int,
	@description varchar(MAX),
	@date date
AS
	SET NOCOUNT ON
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE userID = @userID) 
	BEGIN 
		SELECT [errorMessage] = 'This user does not exist'
	END ELSE  BEGIN
		INSERT INTO Workouts(userID, templateID, [description], [date])
		VALUES (@userID, @templateID, @description, @date) 

		SELECT [workoutID] = @@IDENTITY, [message] = 'Workout successfully created'
	END



GO 
ALTER PROCEDURE updateWorkout
	@workoutID int, 
	@userID int,
	@template int,
	@description varchar(255),
	@date date
AS
	SET NOCOUNT ON
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
	BEGIN 
		SELECT [errorMessage] = 'This workout does not exist'
	END ELSE BEGIN
		UPDATE Workouts
		SET userID = @userID,
			templateID = @template,
			[description] = @description,
			[date] = @date
		WHERE workoutID = @workoutID

		SELECT *, [message] = 'Workout was successfully updated' FROM Workouts WHERE workoutID = @workoutID
	END


GO
ALTER PROCEDURE deleteWorkout
	@workoutID int
AS
	SET NOCOUNT ON
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
	BEGIN 
		SELECT [errorMessage] = 'This workout does not exist'
	END ELSE IF NOT EXISTS(SELECT NULL FROM Activities WHERE workoutID = @workoutID)    --DON"T KNOW IF THIS IS NEEDED
	BEGIN
		SELECT [errorMessage] = 'There is an activity that has this workout'
	END ELSE BEGIN
		DELETE FROM Workouts
		WHERE workoutID = @workoutID

		SELECT [message] = 'Workout has been deleted'
END


GO
ALTER PROCEDURE addPersonalTrainer
	@UserID		INT
AS
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE userID LIKE @UserID) BEGIN
	RETURN RAISERROR('error',15,1)
END ELSE BEGIN
	INSERT INTO PersonalTrainers(userID)
	VALUES(@UserID)
	SELECT [trainerID] = @@IDENTITY
END

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

GO
ALTER PROCEDURE deletePersonalTrainer
	@TrainerID	INT,
	@UserID		INT
AS
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE trainerID LIKE @TrainerID AND userID LIKE @UserID) BEGIN
	DELETE PersonalTrainers
	FROM PersonalTrainers
	WHERE @TrainerID LIKE trainerID
END ELSE BEGIN
	RETURN RAISERROR('error',15,1)
END
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
GO
ALTER PROCEDURE addTemplate
	@CreatorID		INT,
	@Name			varchar(255),
	@Description	varchar(255)
AS 
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM Templates WHERE	(creatorID		LIKE @CreatorID) AND 
											(name			LIKE @Name) AND
											([description]	like @Description)) BEGIN
		RETURN RAISERROR('error',15,1)
END ELSE BEGIN
	INSERT INTO Templates(creatorID, name, [description])
	VALUES(@CreatorID, @Name, @Description)
	SELECT [templateID] = @@IDENTITY
END

GO
ALTER PROCEDURE updateTemplate
	@TemplateID		INT,
	@CreatorID		INT,
	@Name			varchar(255),
	@Description	varchar(255)

AS
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM Templates WHERE	(templateID LIKE @TemplateID)) BEGIN
	UPDATE Templates
	SET creatorID	= @CreatorID,
		name		= @Name,
		[description] = @Description
	WHERE templateID LIKE @TemplateID
END ELSE BEGIN
	RETURN RAISERROR('error',15,1)
END

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
GO
ALTER PROCEDURE deleteTemplate
	@TemplateID	INT
AS
SET NOCOUNT ON

IF EXISTS (SELECT NULL FROM Templates WHERE templateID = @TemplateID) BEGIN
	DELETE Templates
	FROM Templates
	WHERE templateID = @TemplateID
END ELSE BEGIN
	RETURN RAISERROR('error',15,1)
END


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
GO
ALTER PROCEDURE getWorkoutsForUser
	@UserID		INT

AS
SET NOCOUNT ON

SELECT * FROM Workouts WHERE userID = @UserID

GO
ALTER PROCEDURE getWorkoutsForUserInRange
	@userID		int,
	@start		date,
	@end		date
AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Workouts
	WHERE (@userID = userID) AND ([date] BETWEEN @start AND @end)
  
END
GO
ALTER PROCEDURE getActivitiesForWorkout
	@workoutID	int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Activities
	WHERE @workoutID = Activities.workoutID
END


GO
ALTER PROCEDURE getTypeByID
	@typeID		int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [Types]
	WHERE @typeID = [Types].typeID
END


GO
ALTER PROCEDURE getAllTypes
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Type
END
GO
ALTER PROCEDURE getTrainerForUser
	@userID		int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TrainerID
	FROM PersonalTrainers
	WHERE @userID = PersonalTrainers.userID
END
GO
ALTER PROCEDURE getTraineesForUser
	@userID		int
AS
BEGIN
	SET NOCOUNT ON;
	
	IF 1 = (SELECT trainer FROM Users WHERE @userID = Users.userID)
	BEGIN
		SELECT userID
		FROM PersonalTrainers
		WHERE PersonalTrainers.trainerID = @userID
	END
END
GO
ALTER PROCEDURE searchUsers
	@query	varchar(30)
AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Users
	WHERE name+ '~' + email LIKE ('%' + @query + '%')
  
END


GO
ALTER PROCEDURE [dbo].[getActivityByID]
	@activityID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Activities
WHERE activityID = @activityID


GO
ALTER PROCEDURE [dbo].[getTemplateByID]
	@templateID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Templates
WHERE templateID = @templateID

GO
ALTER PROCEDURE [dbo].[getTemplatesByUser]
	@creatorID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Templates
WHERE creatorID = @creatorID


GO
ALTER PROCEDURE [dbo].[getUserByID]
	@userID int

	AS
	SET NOCOUNT ON

SELECT userID
FROM Users
WHERE userID = @userID


GO
ALTER PROCEDURE [dbo].[getWorkoutByID]
	@workoutID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Workouts
WHERE workoutID = @workoutID
