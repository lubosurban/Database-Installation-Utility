-- ===============================================
-- ===============================================
-- TABLE dbo.InstalledUpdates
-- ===============================================
-- ===============================================
IF NOT EXISTS (SELECT 1
               FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo'
                 AND TABLE_NAME = 'InstalledUpdates')
BEGIN

  CREATE TABLE dbo.InstalledUpdates
  (
    Id           INTEGER IDENTITY(1,1),
    ScriptName   VARCHAR(255) NOT NULL,
    InstalledBy  VARCHAR(128) NOT NULL,
    InstalledOn  DATETIME NOT NULL,

    PRIMARY KEY (Id),
    CONSTRAINT UQ_InstalledUpdates_ScriptName UNIQUE (ScriptName)
  )

END

GO

-- ===============================================
-- ===============================================
-- PROCEDURE dbo.RegisterUpdateScript
-- ===============================================
-- ===============================================
IF EXISTS (SELECT 1
           FROM INFORMATION_SCHEMA.ROUTINES
           WHERE SPECIFIC_SCHEMA = 'dbo'
             AND SPECIFIC_NAME = 'RegisterUpdateScript'
             AND ROUTINE_TYPE = 'Procedure')
DROP PROCEDURE dbo.RegisterUpdateScript

GO

CREATE PROCEDURE dbo.RegisterUpdateScript
(
  @scriptName VARCHAR(255)
)
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.InstalledUpdates (ScriptName, InstalledBy, InstalledOn)
  VALUES (@scriptName, SUSER_NAME(), GetDate())
END

GO

-- ===============================================
-- ===============================================
-- FUNCTION dbo.ValidateUpdateScriptInstalled
-- ===============================================
-- ===============================================
IF EXISTS (SELECT 1
           FROM INFORMATION_SCHEMA.ROUTINES
           WHERE SPECIFIC_SCHEMA = 'dbo'
             AND specific_name = 'ValidateUpdateScriptInstalled'
             AND Routine_Type = 'Function')
DROP FUNCTION dbo.ValidateUpdateScriptInstalled

GO

CREATE FUNCTION dbo.ValidateUpdateScriptInstalled
(
  @scriptName VARCHAR(255)
)
RETURNS BIT
AS
BEGIN
  DECLARE @result BIT
  SET @result = 0

  IF EXISTS (SELECT 1
             FROM dbo.InstalledUpdates
             WHERE ScriptName = @scriptName)
  BEGIN
    SET @result = 1
  END

  RETURN(@result)
END

GO
