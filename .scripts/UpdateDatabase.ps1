# =============================================
# =============================================
# Script name: UpdateDatabase.ps1
# =============================================
# =============================================

$ErrorActionPreference = "Stop"

# ---------------------------------------------
# Script initialization
# ---------------------------------------------
$scriptDir = Split-Path -Path $myInvocation.MyCommand.Definition
$rootDir = Resolve-Path "$scriptDir\.."

# ---------------------------------------------
# Includes
# ---------------------------------------------
. "$scriptDir\common\ConsoleInput.ps1"
. "$scriptDir\common\SQLServerExtensions.ps1"
. "$scriptDir\common\Configuration.ps1"
. "$scriptDir\UpdateDatabase-cfg.ps1"

# ---------------------------------------------
# Function: Get-FileWReplacedPlaceholders
# ---------------------------------------------
function Get-FileWReplacedPlaceholders
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $inputFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $tempDir,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $database
    )

    $outputFile = Join-Path -Path $tempDir -ChildPath ([guid]::NewGuid().ToString() + ".sql")
    (Get-Content -Path "$inputFile" -Force).Replace("<%DatabaseName%>", $database) | Set-Content -Path "$outputFile" -Force

    return ($outputFile)
}

# ================================================
# Script body
# ================================================
$internalDbStructuresSqlScript = Join-Path -Path $scriptDir -ChildPath "sqlScripts\InternalDbStructures.sql"

$errorOccurred = $false
$restoreFromBackupNecessary = $false
$queryTimeout = 600

# ---------------------------------------------
# Welcome message and user input (if necessary)
# ---------------------------------------------
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "Welcome to $cfg_componentName Database Installation Utility" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "This tool is going to instal/upgrade your $cfg_componentName database to latest version."
Write-Host "Please enter database server connection details to proceed."
# Loading last used values
$lastUsedValues = Load-Configuration -ConfigFile "$cfg_configFile"
if($lastUsedValues)
{
    $cfg_serverDefault = $lastUsedValues.Server
    $cfg_databaseDefault = $lastUsedValues.Database
}

# Gathering user input
Write-Host "`n=======================================================" -ForegroundColor Yellow
Write-Host "Database backup" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "Perform a backup of your database now."
Write-Host "It is extremely important to backup your database before beginning the installation."
Write-Host "If, for some reason, you find it necessary to revert back to the previous version of "
Write-Host "$cfg_componentName database, you may have to restore your database from these backup."
Write-Host "Press any key to continue..."
$dummyVariable = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
Write-Host "`n=======================================================" -ForegroundColor Yellow
Write-Host "Connection details" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
$server = Read-HostDefVal -Prompt "SQL server" -DefaultValue $cfg_serverDefault -IsMandatory
$database = Read-HostDefVal -Prompt "Database" -DefaultValue $cfg_databaseDefault -IsMandatory
Write-Host "`n=======================================================" -ForegroundColor Yellow
Write-Host "Installation" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow

try
{
    if(Test-Path -Path "$cfg_tempDir")
    {
        Remove-Item -Path "$cfg_tempDir" -Force -Recurse
    }
    else
    {
        New-Item -Path "$cfg_tempDir" -ItemType directory -Force > $null
    }

    # ---------------------------------------------
    # SQL Server PS module
    # ---------------------------------------------
    Write-Host "Loading SQL Server PowerShell module..." -NoNewline
    Import-SQLPSModule
    Write-Host "OK" -ForegroundColor Green

    # ---------------------------------------------
    # Metadata (update tracking) structures
    # ---------------------------------------------
    Write-Host "Creating update tracking table if not exists..." -NoNewline
    Invoke-SqlFile -InputFile "$internalDbStructuresSqlScript" -ServerInstance $server -Database $database -QueryTimeout $queryTimeout
    Write-Host "OK" -ForegroundColor Green

    # ---------------------------------------------
    # Pre-apply script
    # ---------------------------------------------
    if ($preApplyScript)
    {
        Write-Host "Executing pre-apply script..." -NoNewline

        $restoreFromBackupNecessary = $true
        $scriptFile = Get-FileWReplacedPlaceholders -inputFile "$preApplyScript" -TempDir "$cfg_tempDir" -Database $database
        Invoke-SqlFile -InputFile "$preApplyScript" -ServerInstance $server -Database $database -QueryTimeout $queryTimeout

        Write-Host "OK" -ForegroundColor Green
    }

    # ---------------------------------------------
    # Migrations
    # ---------------------------------------------
    foreach($file in (Get-ChildItem -Path "$cfg_updatesDir" -Recurse -Filter "*.sql" -File -Force | Sort-Object DirectoryName, Name))
    {
        $fileId = $file.FullName.Replace("$cfg_updatesDir\", "")

        $fileAlreadyApplied = Invoke-SqlQuery -Query "SELECT dbo.ValidateUpdateScriptInstalled('$fileId') as Result" -ServerInstance $server -Database $database
        if($fileAlreadyApplied.Result -eq 0)
        {
            Write-Host ("Installing file `"" + $fileId + "`"...") -NoNewline

            $restoreFromBackupNecessary = $true
            $scriptFile = Get-FileWReplacedPlaceholders -inputFile $file.FullName -TempDir "$cfg_tempDir" -Database $database
            Invoke-SqlFile -InputFile "$scriptFile" -ServerInstance $server -Database $database -QueryTimeout $queryTimeout
            Invoke-SqlQuery -Query "EXECUTE dbo.RegisterUpdateScript '$fileId'" -ServerInstance $server -Database $database

            Write-Host "OK" -ForegroundColor Green
        }
    }

    # ---------------------------------------------
    # Post-apply script
    # ---------------------------------------------
    if ($postApplyScript)
    {
        Write-Host "Executing post-apply script..." -NoNewline

        $restoreFromBackupNecessary = $true
        $scriptFile = Get-FileWReplacedPlaceholders -inputFile "$postApplyScript" -TempDir "$cfg_tempDir" -Database $database
        Invoke-SqlFile -InputFile "$scriptFile" -ServerInstance $server -Database $database -QueryTimeout $queryTimeout

        Write-Host "OK" -ForegroundColor Green
    }

    # ---------------------------------------------
    # Save user input (for next run)
    # ---------------------------------------------
    Save-Configuration -configFile "$cfg_configFile" -configValues (@{"Server"=$server; "Database"=$database})
}
catch
{
    $exception = $_
    $errorOccurred = $true
}
finally
{
    Write-Host "`n=======================================================" -ForegroundColor Yellow
    Write-Host "Summary" -ForegroundColor Yellow
    Write-Host "=======================================================" -ForegroundColor Yellow
    if ($errorOccurred)
    {
        if($restoreFromBackupNecessary)
        {
            Write-Host ("We are sorry, but database installation failed. It is necessary to RESTORE YOUR DATABASE FROM BACKUP!!!") -ForegroundColor Red
            Write-Host ("Error:`n" + $exception) -ForegroundColor Red
        }
        else
        {
            Write-Host ("We are sorry, but database installation failed. ") -ForegroundColor Magenta
            Write-Host ("Error:`n" + $exception) -ForegroundColor Magenta
        }
    }
    else
    {
        Write-Host "Installation successfully finished." -ForegroundColor Green
    }

    Remove-Item -Path "$cfg_tempDir" -Force -Recurse
}
