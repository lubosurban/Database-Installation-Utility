# =============================================
# =============================================
# Script name: Configuration.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: Save-Configuration
# ---------------------------------------------
function Save-Configuration
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $configFile,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable] $configValues
    )


    $configPath = Split-Path -Path $configFile -Parent
    if(!(Test-Path -Path $configPath))
    {
        New-Item -ItemType Directory -Force -Path $configPath | Out-Null
    }

    $configValues | Export-Clixml $configFile -Force
}

# ---------------------------------------------
# Function: Load-Configuration
# ---------------------------------------------
function Load-Configuration
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $configFile
    )

    $configValues = $null

    if(Test-Path -Path $configFile)
    {
        $configValues = Import-Clixml $configFile
    }

    return($configValues)
}