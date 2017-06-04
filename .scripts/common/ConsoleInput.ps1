# =============================================
# =============================================
# Script name: ConsoleInput.ps1
# =============================================
# =============================================

# ---------------------------------------------
# Function: Read-HostDefVal
# ---------------------------------------------
function Read-HostDefVal
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $prompt,
        [String] $defaultValue = "",
        [Switch] $isMandatory = $false
    )

    $promptMsg = "$prompt"
    if($defaultValue) { $promptMsg += " [$defaultValue]" }

    do
    {
        $value = Read-Host -Prompt $promptMsg
        $trimmedValue = $value.Trim()

        if((!$trimmedValue) -and ($defaultValue))
        {
            $value = $defaultValue
            $trimmedValue = $value.Trim()
        }
    }
    while(($isMandatory) -and (!$trimmedValue))

    return($value)
}

# ---------------------------------------------
# Function: Read-HostList
# ---------------------------------------------
function Read-HostList
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $prompt,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]] $allowedValues,
        [String] $defaultValue = ""
    )

    do
    {
        $value = Read-HostDef -Prompt $prompt -DefaultValue $defaultValue
    } while($allowedValues -notcontains $value)

    return($value)
}

# ---------------------------------------------
# Function: Write-HostColor
# ---------------------------------------------
function Write-HostColor
{
    Param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]] $text,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default", "Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray", "DarkGreen", "DarkMagenta", `
                     "DarkRed", "DarkYellow", "Gray", "Green", "Magenta", "Red", "White", "Yellow")]
        [String[]] $color
    )

    for ($i = 0; $i -lt $Text.Length; $i++)
    {
        if($color[$i] -ieq "Default")
        {
            Write-Host $text[$i] -NoNewLine
        }
        else
        {
            Write-Host $text[$i] -Foreground $color[$i] -NoNewLine
        }
    }

    Write-Host
}






