param(
    [string]$ProductsCsv = "D:\albaraka\data\products_import_template.csv",
    [string]$OutputDir   = "D:\albaraka\data\import_validation",
    [string]$SqliteExe   = "D:\albaraka\data\sqlite3.exe",
    [string]$DbPath      = "D:\albaraka\data\albaraka_local.db"
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$validOut   = Join-Path $OutputDir "valid_rows.csv"
$errorOut   = Join-Path $OutputDir "error_rows.csv"
$summaryOut = Join-Path $OutputDir "summary.txt"
$raw = & $SqliteExe $DbPath "SELECT slug FROM categories_local WHERE parent_slug IS NOT NULL AND parent_slug != '';"
$validSlugs = $raw -split "`r?`n" | Where-Object { $_ -ne "" }
Write-Host ("Valid leaf slugs: " + $validSlugs.Count + " (expected 29)")
if (-not (Test-Path $ProductsCsv)) { Write-Host ("ERROR: not found: " + $ProductsCsv) -ForegroundColor Red; exit 1 }
$csvLines = [System.IO.File]::ReadAllLines($ProductsCsv, [System.Text.Encoding]::UTF8)
if ($csvLines.Count -lt 2) { Write-Host "ERROR: CSV empty" -ForegroundColor Red; exit 1 }
$expectedHeader = "sku,name,unit,standard_cost,sale_price,category,category_slug"
if ($csvLines[0] -ne $expectedHeader) { Write-Host "ERROR: header mismatch"; exit 1 }
function Parse-CsvLine([string]$line) {
    $fields = @(); $cur = ""; $inQ = $false
    foreach ($ch in $line.ToCharArray()) {
        if ($ch -eq [char]34) { $inQ = -not $inQ; continue }
        if ($ch -eq [char]44 -and -not $inQ) { $fields += $cur; $cur = ""; continue }
        $cur += $ch
    }
    $fields += $cur
    return ,$fields
}
$validRows = New-Object System.Collections.Generic.List[string]
$errorRows = New-Object System.Collections.Generic.List[string]
$seenSkus  = New-Object System.Collections.Generic.HashSet[string]
$errorRows.Add($expectedHeader + ",reason")
$totalValid = 0; $totalInvalid = 0
for ($i = 1; $i -lt $csvLines.Count; $i++) {
    $line = $csvLines[$i]
    if ($line.Trim() -eq "") { continue }
    $fields = Parse-CsvLine $line
    if ($fields.Count -ne 7) { $errorRows.Add($line + ",field_count_" + $fields.Count + "_expected_7"); $totalInvalid++; continue }
    $sku = $fields[0].Trim(); $name = $fields[1].Trim(); $unit = $fields[2].Trim()
    $cost = $fields[3].Trim(); $price = $fields[4].Trim(); $slug = $fields[6].Trim()
    $reasons = @()
    if ($sku  -eq "") { $reasons += "sku_empty" }
    if ($name -eq "") { $reasons += "name_empty" }
    if ($unit -eq "") { $reasons += "unit_empty" }
    if ($slug -eq "") { $reasons += "slug_empty" }
    $costN = 0.0; $priceN = 0.0
    $okCost  = [double]::TryParse($cost,  [ref]$costN)
    $okPrice = [double]::TryParse($price, [ref]$priceN)
    if (-not $okCost)  { $reasons += "cost_not_number" }
    if (-not $okPrice) { $reasons += "price_not_number" }
    if ($okCost -and $costN -lt 0)                     { $reasons += "cost_negative" }
    if ($okCost -and $okPrice -and $priceN -le $costN) { $reasons += "price_not_above_cost" }
    if ($sku -ne "" -and $seenSkus.Contains($sku)) { $reasons += "sku_duplicate_in_file" }
    if ($sku -ne "") { [void]$seenSkus.Add($sku) }
    if ($slug -ne "" -and ($validSlugs -notcontains $slug)) { $reasons += "unknown_category_slug" }
    if ($reasons.Count -eq 0) { $validRows.Add($line); $totalValid++ }
    else { $errorRows.Add($line + "," + ($reasons -join "|")); $totalInvalid++ }
}
$validCsv = $expectedHeader + "`r`n" + (($validRows -join "`r`n")) + "`r`n"
$errorCsv = ($errorRows -join "`r`n") + "`r`n"
[System.IO.File]::WriteAllText($validOut, $validCsv, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllText($errorOut, $errorCsv, (New-Object System.Text.UTF8Encoding($false)))
$summary = "Total: " + ($csvLines.Count - 1) + " | Valid: " + $totalValid + " | Invalid: " + $totalInvalid
[System.IO.File]::WriteAllText($summaryOut, $summary, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ("Total : " + ($csvLines.Count - 1))
Write-Host ("Valid : " + $totalValid) -ForegroundColor Green
Write-Host ("Errors: " + $totalInvalid) -ForegroundColor Red
Write-Host ""
Write-Host "--- Valid ---" -ForegroundColor Green
$validRows | ForEach-Object { Write-Host ("  " + $_) }
Write-Host ""
Write-Host "--- Errors ---" -ForegroundColor Red
$errorRows | Select-Object -Skip 1 | ForEach-Object { Write-Host ("  " + $_) }
