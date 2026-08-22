$ErrorActionPreference = "Stop"

if (-not (Test-Path ".\qr.svg")) {
    throw "qr.svg not found. Run this script from the repository root."
}

python .\tools\prepare_qr.py

New-Item -ItemType Directory -Force -Path ".\out" | Out-Null

$parts = @("slot_test", "rack", "heartA", "dialA", "dialB")
foreach ($part in $parts) {
    Write-Host "Exporting $part..."
    & openscad -D "part=`"$part`"" -o ".\out\$part.stl" ".\rack.scad"
    if ($LASTEXITCODE -ne 0) {
        throw "OpenSCAD failed while exporting $part"
    }
}

Write-Host "Done. STL files are in .\out"
