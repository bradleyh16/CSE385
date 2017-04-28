GO
CREATE PROCEDURE addPersonalTrainer
	@UserID		INT
AS
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM PersonalTrainers WHERE userID LIKE @UserID) BEGIN
	RETURN RAISEERROR()
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
	RETURN RAISEERROR()
END
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
GO
CREATE PROCEDURE addTemplate
	@CreatorID		INT,
	@Name			varchar(255),
	@Description	description(255)
AS 
SET NOCOUNT ON

IF EXISTS(SELECT NULL FROM Templates WHERE	(creatorID		LIKE @CreatorID) AND 
											(name			LIKE @Name) AND
											([description]	like @Description)) BEGIN
		RETURN RAISEERROR()
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
	RETURN RAISEERROR()
END

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
GO
CREATE PROCEDURE deleteTemplate
	@Template	INT
AS
SET NOCOUNT ON

IF EXISTS (SELECT NULL FROM Templates WHERE templateID = @TemplateID) BEGIN
	DELETE Templates
	FROM Templates
	WHERE templateID = @TemplateID
END ELSE BEGIN
	RETURN RAISEERROR()
END


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
GO
CREATE PROCEDURE getWorkoutsForUser
	@UserID		INT

AS
SET NOCOUNT ON

SELECT * FROM Workouts WHERE userID = @UserID