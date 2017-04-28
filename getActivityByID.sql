CREATE PROCEDURE [dbo].[getActivityByID]
	@activityID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Activities
WHERE activityID = @activityID