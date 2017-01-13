# =============================================
# =============================================
# Script name: UpdateDatabase-cfg.ps1
# =============================================
# =============================================

# ----------------------
# Configuration
# ----------------------
# Available variables:
# * $rootDir - component root directory (location of "instal.bat" batch file)

# Component name used in various parts of console output
$cfg_componentName = "ProductName"

# Default values for server and database selection
$cfg_serverDefault = $null
$cfg_databaseDefault = "DatabaseName"

# SQL scripts storage folder
$cfg_updatesDir = Join-Path -Path $rootDir -ChildPath "updates"
# Temp folder - used for installation purposes only, it is removed after installation
$cfg_tempDir = Join-Path -Path $rootDir -ChildPath "temp"
# Configuration file where user data are stored
$cfg_configFile = Join-Path -Path $env:LOCALAPPDATA -ChildPath "$cfg_componentName\configuration.xml"

