$ErrorActionPreference = 'Stop';

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$fileLocation = if ((Get-OSArchitectureWidth 64) -and $env:chocolateyForceX86 -ne $true) {
  Write-Host "Installing 64 bit version" ; Get-Item $toolsDir\*-x64-*.msi
}
else { 
  Write-Host "Installing 32 bit version" ; Get-Item $toolsDir\*-x32-*.msi
}

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi' #only one of these: exe, msi, msu
  file         = $fileLocation
  softwareName  = 'redis-64*'
  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package

$installLocation = Get-AppInstallLocation $packageArgs.softwareName

if (!$installLocation)  { 
  Write-Warning "Can't find $packageArgs.softwareName install location"; return 
}
Write-Host "$packageArgs.softwareName installed to '$installLocation'"
