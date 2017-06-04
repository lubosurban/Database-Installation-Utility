# =============================================
# =============================================
# Script name: SQLServerExtensions.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: Import-SQLPSModule
# ---------------------------------------------
function Import-SQLPSModule
{
    # Loading SQL server snapin (valid only for SQL Server 2008 R2)
    Add-PSSnapIn SQLServerCmdletSnapin100 -ErrorAction SilentlyContinue

    # Loading SQL server module, in case snapin wasn`t loaded (valid for SQL Server 2012 and above)
    if (!(Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue))
    {
        # Specify the DisableNameChecking parameter if you want to suppress the warning about Encode-Sqlname and Decode-Sqlname.
        # https://msdn.microsoft.com/en-us/library/hh231286.aspx
        Import-Module sqlps -DisableNameChecking
    }
}

# ---------------------------------------------
# Function: Invoke-SQLQuery
# ---------------------------------------------
function Invoke-SQLQuery
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $query,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $database,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("Querytimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }

    return Invoke-Sqlcmd -Query "$query" -ServerInstance "$serverInstance" -Database "$database" -ErrorAction Stop @moreCmdParameters
}

# ---------------------------------------------
# Function: Invoke-SQLFile
# ---------------------------------------------
function Invoke-SQLFile
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $inputFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $database,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("Querytimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }


    Invoke-Sqlcmd -InputFile "$inputFile" -ServerInstance "$serverInstance" -Database "$database" -ErrorAction Stop @moreCmdParameters
}

# ---------------------------------------------
# Function: Invoke-SQLFileAtServerLevel
# ---------------------------------------------
function Invoke-SQLFileAtServerLevel
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $inputFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $serverInstance,
        [String] $userName,
        [String] $userPassword,
        [Int] $queryTimeout = $null,
        [switch] $verboseLog = $false
    )

    $moreCmdParameters = @{}

    if ($verboseLog)
    {
        $moreCmdParameters.Add("Verbose", $true)
    }

    if ($queryTimeout)
    {
        $moreCmdParameters.Add("Querytimeout", $queryTimeout)
    }

    if ($userName)
    {
        $moreCmdParameters.Add("Username", $userName)
        $moreCmdParameters.Add("Password", $userPassword)
    }


    Invoke-Sqlcmd -InputFile "$inputFile" -ServerInstance "$serverInstance" -ErrorAction Stop @moreCmdParameters
}
