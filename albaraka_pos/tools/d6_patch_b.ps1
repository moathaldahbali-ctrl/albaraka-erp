# tools/d6_patch_b.ps1
# D6e — إصلاح callback علىOpenProductList في main.dart
# يستخدم line insertion بدلاً من .Replace() — أكثر أماناً

$ErrorActionPreference = "Stop"
Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue

$mainFile = "D:\albaraka\albaraka_pos\lib\main.dart"

# [1] Backup
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "D:\albaraka\backups\v8383_d6b_$ts"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item $mainFile "$backupDir\main.dart.bak" -Force

Write-Host ""
Write-Host "=== [1] Backup ===" -ForegroundColor Green
Write-Host "  $backupDir"

# [2] قراءة السطور
$lines = [System.IO.File]::ReadAllLines($mainFile, [System.Text.Encoding]::UTF8)

# [3] البحث عن السطر المستهدف
$foundIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'onOpenProductImport: \(\) =>') {
        $foundIdx = $i
        break
    }
}

if ($foundIdx -lt 0) {
    Write-Host "ERROR: onOpenProductImport not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== [2] السطر المستهدف ===" -ForegroundColor Cyan
Write-Host "  Line: $foundIdx"

# [4] التحقق من عدم الإضافة مسبقاً
$alreadyAdded = $false
foreach ($l in $lines) {
    if ($l -match 'onOpenProductList:') {
        $alreadyAdded = $true
        break
    }
}

if ($alreadyAdded) {
    Write-Host ""
    Write-Host "WARNING: onOpenProductList already exists" -ForegroundColor Yellow
    exit 0
}

# [5] حساب المسافات البادئة من السطر الفعلي
$indent = $lines[$foundIdx].Substring(0, $lines[$foundIdx].Length - $lines[$foundIdx].TrimStart().Length)
Write-Host ""
Write-Host "=== [3] الإدراج ===" -ForegroundColor Cyan
Write-Host "  Indent: $($indent.Length) spaces"

# [6] بناء السطر الجديد
$newLine = $indent + 'onOpenProductList: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen())),'

# [7] إنشاء قائمة جديدة بسطر مُدرج
$newList = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) {
    $newList.Add($lines[$i])
    if ($i -eq $foundIdx) {
        $newList.Add($newLine)
    }
}

# [8] الكتابة
[System.IO.File]::WriteAllLines($mainFile, $newList.ToArray(), (New-Object System.Text.UTF8Encoding($false)))

Write-Host "  السطور: $($lines.Count) -> $($newList.Count)"

# [9] التحقق
Write-Host ""
Write-Host "=== [4] التحقق ===" -ForegroundColor Cyan
$after = [System.IO.File]::ReadAllText($mainFile, [System.Text.Encoding]::UTF8)

$checks = @(
    @{N='callback موجود'; P='onOpenProductList:'; S=$after},
    @{N='import موجود';   P="import 'screens/settings/product_list_screen.dart';"; S=$after}
)

$allOK = $true
foreach ($c in $checks) {
    if ($c.S.Contains($c.P)) {
        Write-Host "  OK  $($c.N)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL $($c.N)" -ForegroundColor Red
        $allOK = $false
    }
}

Write-Host ""
if ($allOK) {
    Write-Host "D6e ناجحة" -ForegroundColor Green
} else {
    Write-Host "بعض التعديلات ناقصة" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Rollback (إن احتجت) ===" -ForegroundColor Yellow
Write-Host "  Copy-Item '$backupDir\main.dart.bak' '$mainFile' -Force"