<#
.SYNOPSIS
	SharePoint Central Admin - View active services across entire farm. No more select machine drop down dance!
.DESCRIPTION
	Create Desktop Icon to launch Office 365 with securely saved credentials

	Comments and suggestions always welcome!  spjeff@spjeff.com or @spjeff
.NOTES
	File Name		: office365-desktop-icon.ps1
	Author			: Jeff Jones - @spjeff
	Version			: 0.10
	Last Modified	: 07-14-2016
.LINK
	Source Code
		http://www.github.com/spjeff/o365/office365-desktop-icon.ps1
	
	Download PowerShell Plugins
		* SPO - SharePoint Online
		https://www.microsoft.com/en-us/download/details.aspx?id=35588
		
		* PNP - Patterns and Practices
		https://github.com/officedev/pnp-powershell
#>

# input
Write-Host "=== Make Office 365 PowerShell desktop icon  ==="
$url = Read-Host "Tenant - Admin URL"
$user = Read-Host "Tenant - Username"
$pw = Read-Host "Tenant - Password" -AsSecureString
$split = $url.Split(".")[0].Split("/")
$tenant = $split[$split.length - 1]

# save to registry
$hash = $pw | ConvertFrom-SecureString

# command
"Write-Host ""Connect to Office365 ..."" -NoNewLine`n`$h = ""$hash""`n`$secpw = ConvertTo-SecureString -String `$h`n`$c = New-Object System.Management.Automation.PSCredential (""$user"", `$secpw)`n`$pnp = Get-Module -ListAvailable SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue`nif (`$pnp) {`n	Import-Module -WarningAction SilentlyContinue SharePointPnPPowerShellOnline -Prefix P -ErrorAction SilentlyContinue`n`$pre=""M""`n}`nImport-Module -WarningAction SilentlyContinue Microsoft.Online.SharePoint.PowerShell -Prefix `$pre -ErrorAction SilentlyContinue`nConnect-MSPOService -URL $url -Credential `$c`n`$firstUrl = (Get-MSPOSite)[0].Url`n`$pnpurl = ""https://github.com/OfficeDev/PnP-PowerShell""`nif (`$pnp) {`n	Connect-PSPOnline -URL `$firstUrl -Credential `$c`n} else {`n	Write-Warning ""Missing PNP cmds. Download at $pnpurl""`n	start $pnpurl`n}`nWrite-Host ""[OK]"" -Fore Green`n""SPO commands: `$((get-command *-mspo*).count)""`n""PNP commands: `$((get-command *-pspo*).count)""`nGet-MSPOSite`n" | Out-File "$home\o365-icon-$tenant.ps1"

# create desktop shortcut
$folder = [Environment]::GetFolderPath("Desktop")
$Target = "c:\Windows\System32\cmd.exe"
$ShortcutFile = "$folder\Office365 $tenant.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.Arguments = "/c ""start powershell -noexit """"$home\o365-icon-$tenant.ps1"""""""
$Shortcut.IconLocation = "imageres.dll, 1";
$Shortcut.TargetPath = $Target
$Shortcut.Save()