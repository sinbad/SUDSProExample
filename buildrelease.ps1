$ErrorActionPreference = "Stop"

Write-Output "Packaging Demo"

# Zip parent folder
Write-Output "Root: $PSScriptRoot"
$zipsrc = (Get-Item $PSScriptRoot).FullName
$foldername = (Get-Item $PSScriptRoot).Name
$zipdst = Join-Path $zipsrc "SudsProExample_INSERTVERSION.zip"

Write-Output "Compressing to $zipdst"

$argList = [System.Collections.ArrayList]@()
$argList.Add("a") > $null
$argList.Add($zipdst) > $null
# Standard exclusions
$argList.Add("-x!$foldername\.git\*") > $null
$argList.Add("-x!$foldername\.git*") > $null
$argList.Add("-x!$foldername\.vscode") > $null
$argList.Add("-x!$foldername\buildrelease.ps1") > $null
$argList.Add("-x!$foldername\Binaries") > $null
$argList.Add("-x!$foldername\Build") > $null
$argList.Add("-x!$foldername\Intermediate") > $null
$argList.Add("-x!$foldername\DerivedDataCache") > $null
$argList.Add("-x!$foldername\Saved") > $null
$argList.Add("-x!$foldername\*.zip") > $null

# We include the built plugin but don't need the debug symbols
$argList.Add("-x!*.pdb") > $null

$argList.Add($zipsrc) > $null

Remove-Item $zipdst -Force -ErrorAction SilentlyContinue
$proc = Start-Process "7z.exe" $argList -Wait -PassThru -NoNewWindow
if ($proc.ExitCode -ne 0) {
    throw "7-Zip archive failed!"
}

$approvedFolderName = "SudsProExample"
if ($foldername -ne $approvedFolderName)
{
    # We now need to rename the root folder inside the zip
    $argList = [System.Collections.ArrayList]@()
    $argList.Add("rn") > $null
    $argList.Add($zipdst) > $null
    $argList.Add("$foldername\") > $null
    $argList.Add("$approvedFolderName\") > $null

    $proc = Start-Process "7z.exe" $argList -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        throw "7-Zip folder rename failed!"
    }
}

Write-Output "Demo packaging OK!"