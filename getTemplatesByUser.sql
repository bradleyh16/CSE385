CREATE PROCEDURE [dbo].[getTemplatesByUser]
	@creatorID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Templates
WHERE creatorID = @creatorID
