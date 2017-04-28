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
	WHERE (@userID = Workouts.userID) AND (Workout.date BETWEEN @start AND @end)
  
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