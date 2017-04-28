GO
CREATE PROCEDURE addPersonalTrainer
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
CREATE PROCEDURE deletePersonalTrainer
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
CREATE PROCEDURE addTemplate
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
CREATE PROCEDURE updateTemplate
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
CREATE PROCEDURE deleteTemplate
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
CREATE PROCEDURE getWorkoutsForUser
	@UserID		INT

AS
SET NOCOUNT ON

SELECT * FROM Workouts WHERE userID = @UserID

GO
CREATE PROCEDURE getWorkoutsForUserInRange
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
CREATE PROCEDURE getActivitiesForWorkout
	@workoutID	int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Activities
	WHERE @workoutID = Activities.workoutID
END
GO
CREATE PROCEDURE getTypeByID
	@typeID		int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Types
	WHERE @typeID = Type.typeID
END
GO
CREATE PROCEDURE getAllTypes
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Type
END
GO
CREATE PROCEDURE getTrainerForUser
	@userID		int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TrainerID
	FROM PersonalTrainers
	WHERE @userID = PersonalTrainers.userID
END
GO
CREATE PROCEDURE getTraineesForUser
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
CREATE PROCEDURE searchUsers
	@query	varchar(30)
AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Users
	WHERE name+ '~' + email LIKE ('%' + @query + '%')
  
END