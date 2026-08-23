$ErrorActionPreference = "Stop"

if (-not (Test-Path ".\rack.scad")) {
    throw "rack.scad not found. Run this script from the repository root."
}

$python = Get-Command python -ErrorAction SilentlyContinue
if ($python -and (Test-Path ".\qr.svg")) {
    & $python.Source .\tools\prepare_qr.py
} else {
    Write-Host "Python not found; using the committed qr_data.scad."
}

$openScadCommand = Get-Command openscad -ErrorAction SilentlyContinue
$openScadCandidates = @(
    if ($openScadCommand) { $openScadCommand.Source }
    "C:\Program Files\OpenSCAD\openscad.com"
    "C:\Program Files (x86)\OpenSCAD\openscad.com"
    "C:\Program Files\OpenSCAD\openscad.exe"
    "C:\Program Files (x86)\OpenSCAD\openscad.exe"
)
$openScad = $openScadCandidates |
    Where-Object { $_ -and (Test-Path $_) } |
    Select-Object -First 1

if (-not $openScad) {
    throw "OpenSCAD not found. Install OpenSCAD 2021.01+ or add it to PATH."
}

New-Item -ItemType Directory -Force -Path ".\out" | Out-Null

$parts = @("slot_test", "slider_test", "heartA_stand", "rack", "heartA", "sliderA", "sliderB")
foreach ($part in $parts) {
    Write-Host "Exporting $part..."
    & $openScad -D "part=`"$part`"" -o ".\out\$part.stl" ".\rack.scad"
    if ($LASTEXITCODE -ne 0) {
        throw "OpenSCAD failed while exporting $part"
    }
}

Write-Host "Done. STL files are in .\out"
