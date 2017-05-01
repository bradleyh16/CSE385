GO
CREATE PROCEDURE loginUser
	@email varchar(255),
	@password varchar(255)
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Users WHERE email = @email)
		BEGIN
			SELECT [errorMessage] = 'Sorry we could not find your email address'
		END 
	ELSE IF EXISTS(SELECT NULL FROM Users WHERE (email = @email) AND [password] = PWDENCRYPT(@password) AND deleted = 0)
		BEGIN
			SELECT [name], email, birthday, [height], [weight], [message] = 'User has successfully logged in' FROM Users WHERE email = @email
		END 
	ELSE 
		BEGIN
			SELECT [errorMessage] = 'Could not find your password or email address'
		END


GO
CREATE PROCEDURE registerUser
	@name varchar(255),
	@email varchar(255),
	@password varchar(255)
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
			SELECT [userID] = @@IDENTITY, email, [name] FROM Users WHERE email = @email
		END


GO 
CREATE PROCEDURE updateUser
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
		END 
	ELSE
		BEGIN
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
CREATE PROCEDURE deleteUser
	@userID		int
AS
	SET NOCOUNT ON

	IF(@userID NOT IN (SELECT trainerID FROM PersonalTrainers))
	BEGIN
		UPDATE Users
		SET deleted = 1
		WHERE userID = @userID
		SELECT [successfulDelete] = 'User was successfully deleted.'
	END 
	ELSE BEGIN
 		SELECT [errorMessage] = 'User must be a trainer, so could not be deleted.'
	END
GO
CREATE PROCEDURE addWorkout
	@userID int,
	@templateID int,
	@description varchar(MAX),
	@date date
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Users WHERE @userID IN (SELECT userID FROM Users WHERE deleted = 0)) 
		BEGIN 
			SELECT [errorMessage] = 'This user does not exist'
		END 
	ELSE
		BEGIN
			INSERT INTO Workouts(userID, templateID, [description], [date])
			VALUES (@userID, @templateID, @description, @date) 

			SELECT [workoutID] = @@IDENTITY, [message] = 'Workout successfully created'
		END



GO 
CREATE PROCEDURE updateWorkout
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
		END 
	ELSE 
		BEGIN
			UPDATE Workouts
			SET userID = @userID,
				templateID = @template,
				[description] = @description,
				[date] = @date
			WHERE workoutID = @workoutID

			SELECT * , [message] = 'Workout was successfully updated' FROM Workouts WHERE workoutID = @workoutID
		END


GO
CREATE PROCEDURE deleteWorkout
	@workoutID int
AS
	SET NOCOUNT ON
	
	IF NOT EXISTS(SELECT NULL FROM Workouts WHERE workoutID = @workoutID)
		BEGIN 
			SELECT [errorMessage] = 'This workout does not exist'
		END 
	ELSE IF NOT EXISTS(SELECT NULL FROM Activities WHERE workoutID = @workoutID)
		BEGIN
			SELECT [errorMessage] = 'There is an activity that has this workout'
		END 
	ELSE 
		BEGIN
			DELETE FROM Workouts
			WHERE workoutID = @workoutID

			SELECT [message] = 'Workout has been deleted'
		END


GO
CREATE PROCEDURE addPersonalTrainer
	@UserID		int
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE userID LIKE @UserID)
		BEGIN
			RETURN RAISERROR('error',15,1)
		END 
	ELSE
		BEGIN
			INSERT INTO PersonalTrainers(userID)
			VALUES(@UserID)
			SELECT [trainerID] = @@IDENTITY
		END


GO
CREATE PROCEDURE deletePersonalTrainer
	@TrainerID	int,
	@UserID		int
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE trainerID LIKE @TrainerID AND userID LIKE @UserID)
		BEGIN
			DELETE PersonalTrainers
			FROM PersonalTrainers
			WHERE @TrainerID LIKE trainerID
		END 
	ELSE
		BEGIN
			RETURN RAISERROR('error',15,1)
		END


GO
CREATE PROCEDURE addTemplate
	@CreatorID		int,
	@Name			varchar(255),
	@Description	varchar(255)
AS 
	SET NOCOUNT ON

	IF EXISTS(SELECT NULL FROM Templates WHERE	(creatorID LIKE @CreatorID) AND (name LIKE @Name) AND ([description] LIKE @Description)) 
		BEGIN
				RETURN RAISERROR('error',15,1)
		END
	ELSE 
		BEGIN
			INSERT INTO Templates(creatorID, name, [description])
			VALUES(@CreatorID, @Name, @Description)
			SELECT [templateID] = @@IDENTITY
		END


GO
CREATE PROCEDURE updateTemplate
	@TemplateID		INT,
	@CreatorID		INT,
	@Name			varchar(255),
	@Description	varchar(255)

AS
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM Templates WHERE	(templateID LIKE @TemplateID))
	BEGIN
		UPDATE Templates
		SET creatorID	= @CreatorID,
			name		= @Name,
			[description] = @Description
		WHERE templateID LIKE @TemplateID
	END 
ELSE 
	BEGIN
		RETURN RAISERROR('error',15,1)
	END


GO
CREATE PROCEDURE deleteTemplate
	@TemplateID	INT
AS
	SET NOCOUNT ON

	IF EXISTS (SELECT NULL FROM Templates WHERE templateID = @TemplateID)
		BEGIN
			DELETE Templates
			FROM Templates
			WHERE templateID = @TemplateID
		END 
	ELSE 
		BEGIN
			RETURN RAISERROR('error',15,1)
		END


GO
CREATE PROCEDURE getWorkoutsForUser
	@UserID		INT

AS
	SET NOCOUNT ON

	SELECT [description], [date]
	FROM Workouts 
	WHERE userID = @UserID 
	ORDER BY [date] DESC

GO
CREATE PROCEDURE getWorkoutsForUserInRange
	@userID		int,
	@start		date,
	@endd		date
AS
	SET NOCOUNT ON;

	SELECT [description]
	FROM Workouts
	WHERE (@userID = userID) AND ([date] BETWEEN @start AND @endd)
	ORDER BY [date] DESC


GO
CREATE PROCEDURE getActivitiesForWorkout
	@workoutID	int
AS
	SET NOCOUNT ON;

	SELECT reps, [sets], [weight], rest, distance, [time]
	FROM Activities
	WHERE @workoutID = Activities.workoutID


GO
CREATE PROCEDURE getTypeByID
	@typeID		int
AS
	SET NOCOUNT ON;

	SELECT name, [description]
	FROM [Types]
	WHERE @typeID = [Types].typeID


GO
CREATE PROCEDURE getAllTypes
AS
	SET NOCOUNT ON;

	SELECT name, [description]
	FROM Type


GO
CREATE PROCEDURE getTrainerForUser
	@userID		int
AS
	SET NOCOUNT ON;
	
	SELECT TrainerID
	FROM PersonalTrainers
	WHERE @userID = PersonalTrainers.userID


GO
CREATE PROCEDURE getTraineesForUser
	@userID		int
AS
	SET NOCOUNT ON;
	
	IF 1 = (SELECT trainer FROM Users WHERE @userID = Users.userID)
	BEGIN
		SELECT userID
		FROM PersonalTrainers
		WHERE PersonalTrainers.trainerID = @userID
	END


GO
CREATE PROCEDURE searchUsers
	@query	varchar(30)
AS

	SET NOCOUNT ON;

	SELECT name, email, birthday, height, [weight], trainer
	FROM Users
	WHERE name+ '~' + email LIKE ('%' + @query + '%')


GO
CREATE PROCEDURE getActivityByID
	@activityID int

	AS
	SET NOCOUNT ON

	SELECT reps, [sets], [weight], rest, distance, [time]
	FROM Activities
	WHERE activityID = @activityID


GO
CREATE PROCEDURE getTemplateByID
	@templateID int

	AS
	SET NOCOUNT ON

	SELECT name, [description]
	FROM Templates
	WHERE templateID = @templateID

GO
CREATE PROCEDURE getTemplatesByUser
	@creatorID int

	AS
	SET NOCOUNT ON

	SELECT name, [description]
	FROM Templates
	WHERE creatorID = @creatorID


GO
CREATE PROCEDURE getUserByID
	@userID int

	AS
	SET NOCOUNT ON

	SELECT name, email, birthday, height, [weight], trainer
	FROM Users
	WHERE userID = @userID


GO
CREATE PROCEDURE getWorkoutByID
	@workoutID int

AS
	SET NOCOUNT ON

	SELECT [description], [date]
	FROM Workouts
	WHERE workoutID = @workoutID
	ORDER BY [date] DESC
