CREATE PROCEDURE [dbo].[getTemplateByID]
	@templateID int

	AS
	SET NOCOUNT ON

SELECT *
FROM Templates
WHERE templateID = @templateID