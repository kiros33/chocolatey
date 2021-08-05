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

Write-Host "Begin installation"

Install-ChocolateyPackage @packageArgs
Remove-Item $toolsDir\*.msi -ea 0 -force

#$installLocation = Get-AppInstallLocation $packageArgs.softwareName
$installLocation = "C:\Program Files\redis"

if (!$installLocation)  { 
  Write-Warning "Can't find $packageArgs.softwareName install location"; return 
}
Write-Host "$packageArgs.softwareName installed to '$installLocation'"

Write-Host "Install bin redis-cli.exe"
Install-BinFile 'redis-cli' $installLocation\redis-cli.exe

Write-Host "Install bin redis-server.exe"
Install-BinFile 'redis-server' $installLocation\redis-server.exe