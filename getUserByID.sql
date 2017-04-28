CREATE PROCEDURE [dbo].[getUserByID]
	@userID int

	AS
	SET NOCOUNT ON

SELECT userID
FROM Users
WHERE userID = @userID

