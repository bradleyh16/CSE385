CREATE PROCEDURE [dbo].[getWorkoutByID]
	@workoutID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Workouts
WHERE workoutID = @workoutID