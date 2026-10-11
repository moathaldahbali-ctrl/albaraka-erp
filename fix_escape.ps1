$path = "D:\albaraka\albaraka_pos\lib\models\product_import_row.dart"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$content = $content -replace '\\\$', '$'
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "=== ESCAPE FIX DONE ===" -ForegroundColor Green
