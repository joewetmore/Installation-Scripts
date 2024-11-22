#!PS
#timeout=10000000

$LICENSE_KEY = "############"
$COMPANY_NAME = "My Company"
$LOCATION_NAME = "My City"
$ELEVATION_MODE = "audit"
$BLOCKER_MODE = "disabled"

# Set $DebugPrintEnabled = 1 to enabled debug log printing to see what's going on.
$DebugPrintEnabled = 0

# You don't need to change anything below this line...

$InstallerName = "AESetup.msi"
$InstallerPath = Join-Path $Env:TMP $InstallerName
$DownloadBase = "https://autoelevate-installers.s3.us-east-2.amazonaws.com"
$DownloadURL = $DownloadBase + "/current/" + $InstallerName
$ServiceName = "AutoElevateAgent"

$ScriptFailed = "Script Failed!"

function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

function Confirm-ServiceExists ($service) {
    if (Get-Service $service -ErrorAction SilentlyContinue) {
        return $true
    }
    
    return $false
}

function Debug-Print ($msg) {
    if ($DebugPrintEnabled -eq 1) {
        Write-Host "$(Get-TimeStamp) [DEBUG] $msg"
    }
}

function Get-Installer {
    Debug-Print("Downloading installer...")
    $WebClient = New-Object System.Net.WebClient
    
    try {
        $WebClient.DownloadFile($DownloadURL, $InstallerPath)
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$(Get-TimeStamp) $ErrorMessage"
    }
    
    if ( ! (Test-Path $InstallerPath)) {
        $DownloadError = "Failed to download the AutoElevate Installer from $DownloadURL"
        Write-Host "$(Get-TimeStamp) $DownloadError"
        throw $ScriptFailed
    }
    
    Debug-Print("Installer downloaded to $InstallerPath...")
}

function Install-Agent () {
    Debug-Print("Checking for AutoElevateAgent service...")
    
    if (Confirm-ServiceExists($ServiceName)) {
        Write-Host "$(Get-TimeStamp) Service exists. Continuing with possible upgrade..."
    }
    else {
        Write-Host "$(Get-TimeStamp) Service does not exist. Continuing with initial installation..."
    }

    Debug-Print("Checking for installer file...")
    
    if ( ! (Test-Path $InstallerPath)) {
        $InstallerError = "The installer was unexpectedly removed from $InstallerPath"
        Write-Host "$(Get-TimeStamp) $InstallerError"
        Write-Host ("$(Get-TimeStamp) A security product may have quarantined the installer. Please check " +
                               "your logs. If the issue continues to occur, please send the log to the AutoElevate " +
                               "Team for help at support@autoelevate.com")
        throw $ScriptFailed
    }

    Debug-Print("Executing installer...")
    
    $Arguments = "/i {0} /quiet /lv C:\AEInstallLog.log LICENSE_KEY=""{1}"" COMPANY_NAME=""{2}"" LOCATION_NAME=""{3}"" ELEVATION_MODE=""{4}"" BLOCKER_MODE=""{5}""" -f $InstallerPath, $LICENSE_KEY, $COMPANY_NAME, $LOCATION_NAME, $ELEVATION_MODE, $BLOCKER_MODE
  
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList $Arguments -Wait
}

function Verify-Installation () {
    Debug-Print("Verifying Installation...")
    
    if ( ! (Confirm-ServiceExists($ServiceName))) {
        $VerifiationError = "The AutoElevateAgent service is not running. Installation failed!"
        Write-Host "$(Get-TimeStamp) $VerificationError"
        
        throw $ScriptFailed
    }
}

function main () {
    Debug-Print("Checking for LICENSE_KEY...")
    
    if ($LICENSE_KEY -eq "__LICENSE_KEY_HERE__" -Or $LICENSE_KEY -eq "") {
        Write-Warning "$(Get-TimeStamp) LICENSE_KEY not set, exiting script!"
        exit 1
    }
     
    if ($COMPANY_NAME -eq "__COMPANY_NAME_HERE___" -Or $COMPANY_NAME -eq "") {
        Write-Warning "$(Get-TimeStamp) COMPANY_NAME not specified, exiting script!"
        exit 1
    }
	
	if ($LOCATION_NAME -eq "__LOCATION_NAME_HERE__" -Or $LOCATION_NAME -eq "") {
        Write-Warning "$(Get-TimeStamp) LOCATION_NAME not specified, exiting script!"
        exit 1
    }
		
    Write-Host "$(Get-TimeStamp) CompanyName: " $COMPANY_NAME
    Write-Host "$(Get-TimeStamp) LocationName: " $LOCATION_NAME
    Write-Host "$(Get-TimeStamp) ElevationMode: " $ELEVATION_MODE
	Write-Host "$(Get-TimeStamp) BlockerMode: " $BLOCKER_MODE
    
    Get-Installer
    Install-Agent
    Verify-Installation
    
    Write-Host "$(Get-TimeStamp) AutoElevate Agent successfully installed!"
}

try
{
    main
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "$(Get-TimeStamp) $ErrorMessage"
    exit 1
}
