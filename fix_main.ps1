# ==========================================
# Final Fix: Restore main.dart + Re-apply UsersScreen link
# Using System.IO with proper UTF-8 (no BOM)
# Date: 2026-10-10
# ==========================================

$projectPath = "D:\albaraka\albaraka_pos"
Set-Location $projectPath

Write-Host "`n🔧 [1/5] استعادة main.dart من النسخة السليمة..." -ForegroundColor Cyan
Write-Host "=" * 70

# النسخة الأحدث (من أمس، قبل التلف)
$backupPath = "$projectPath\lib\main.dart.bak_20261009_081953"
$targetPath = "$projectPath\lib\main.dart"

if (-not (Test-Path $backupPath)) {
    Write-Host "❌ النسخة غير موجودة: $backupPath" -ForegroundColor Red
    exit
}

# قراءة النسخة السليمة وكتابتها بترميز UTF-8 صحيح (بدون BOM)
try {
    $content = [System.IO.File]::ReadAllText($backupPath, [System.Text.Encoding]::UTF8)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($targetPath, $content, $utf8NoBom)
    Write-Host "✅ تم استعادة main.dart" -ForegroundColor Green
    Write-Host "   حجم: $([Math]::Round((Get-Item $targetPath).Length / 1KB, 1)) KB" -ForegroundColor Gray
} catch {
    Write-Host "❌ خطأ: $_" -ForegroundColor Red
    exit
}

# ==========================================
Write-Host "`n🔧 [2/5] التحقق من الترميز..." -ForegroundColor Cyan
Write-Host "=" * 70

$verify = [System.IO.File]::ReadAllText($targetPath, [System.Text.Encoding]::UTF8)
$hasGarbled = $verify -match "ط§ظ„ط|ط·ط|ظ€ظ"
$hasArabic = $verify -match "[\u0600-\u06FF]"

if ($hasGarbled) {
    Write-Host "❌ الترميز لا يزال مشوّهاً!" -ForegroundColor Red
    Write-Host "   قد تحتاج نسخة أقدم" -ForegroundColor Yellow
    exit
} elseif ($hasArabic) {
    Write-Host "✅ الترميز سليم — النص العربي صحيح" -ForegroundColor Green
} else {
    Write-Host "⚠️ لا يوجد نص عربي" -ForegroundColor Yellow
}

# ==========================================
Write-Host "`n🔧 [3/5] إضافة استيراد users_screen..." -ForegroundColor Cyan
Write-Host "=" * 70

if ($content -match "users_screen\.dart") {
    Write-Host "ℹ️ الاستيراد موجود مسبقاً — لا حاجة للتعديل" -ForegroundColor Gray
    $modified = $content
} else {
    # إضافة الاستيراد بعد آخر import من screens/settings/
    $pattern = "(import 'screens/settings/[^']+';)"
    $match = [regex]::Match($content, $pattern)
    
    if ($match.Success) {
        $lastSettingsImport = $match.Value
        $newImport = "`r`nimport 'screens/settings/users_screen.dart';"
        $modified = $content -replace [regex]::Escape($lastSettingsImport), "$lastSettingsImport$newImport"
        Write-Host "✅ تم إضافة الاستيراد" -ForegroundColor Green
    } else {
        # إضافة بعد آخر import عادي
        $lines = $content -split "`r?`n"
        $lastImportIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^import ") { $lastImportIdx = $i }
        }
        if ($lastImportIdx -ge 0) {
            $lines = $lines[0..$lastImportIdx] + "import 'screens/settings/users_screen.dart';" + $lines[($lastImportIdx + 1)..($lines.Count - 1)]
            $modified = $lines -join "`r`n"
            Write-Host "✅ تم إضافة الاستيراد (بعد آخر import)" -ForegroundColor Green
        } else {
            Write-Host "❌ لم أجد مكاناً مناسباً للاستيراد" -ForegroundColor Red
            $modified = $content
        }
    }
}

# ==========================================
Write-Host "`n🔧 [4/5] ربط زر الإعدادات بـ UsersScreen..." -ForegroundColor Cyan
Write-Host "=" * 70

# البحث عن نمط: Icons.settings ثم _comingSoon
$settingsPattern = "_navBtn\(theme,\s*Icons\.settings,\s*'[^']+',\s*\(\)\s*=>\s*_comingSoon\('[^']+'\)\)"
$settingsMatch = [regex]::Match($modified, $settingsPattern)

if ($settingsMatch.Success) {
    $oldBlock = $settingsMatch.Value
    Write-Host "📋 النمط القديم: $oldBlock" -ForegroundColor Gray
    
    # استبدال بفتح UsersScreen
    $newBlock = "_navBtn(theme, Icons.settings, 'الإعدادات', () {`r`n              Navigator.push(`r`n                context,`r`n                MaterialPageRoute(builder: (_) => const UsersScreen()),`r`n              );`r`n            })"
    $modified = $modified -replace [regex]::Escape($oldBlock), $newBlock
    Write-Host "✅ تم ربط الإعدادات بـ UsersScreen" -ForegroundColor Green
} else {
    Write-Host "⚠️ النمط لم يُطابق — تحقق يدوياً من سطر 564" -ForegroundColor Yellow
    Write-Host "`n📋 عرض الأسطر 560-570:" -ForegroundColor Gray
    $lines = $modified -split "`r?`n"
    for ($i = 560; $i -lt [Math]::Min(570, $lines.Count); $i++) {
        Write-Host "  $($i+1): $($lines[$i])" -ForegroundColor DarkGray
    }
}

# ==========================================
Write-Host "`n🔧 [5/5] كتابة main.dart النهائي..." -ForegroundColor Cyan
Write-Host "=" * 70

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($targetPath, $modified, $utf8NoBom)

# التحقق النهائي
$final = [System.IO.File]::ReadAllText($targetPath, [System.Text.Encoding]::UTF8)
$finalGarbled = $final -match "ط§ظ„ط|ط·ط"
$finalHasUsersScreen = $final -match "UsersScreen"

Write-Host "`n📊 التحقق النهائي:" -ForegroundColor Cyan
Write-Host "   النص العربي سليم: $(if (-not $finalGarbled) { '✅' } else { '❌' })" -ForegroundColor Gray
Write-Host "   UsersScreen مُربط: $(if ($finalHasUsersScreen) { '✅' } else { '❌' })" -ForegroundColor Gray
Write-Host "   الحجم: $([Math]::Round((Get-Item $targetPath).Length / 1KB, 1)) KB" -ForegroundColor Gray

Write-Host "`n" + "=" * 70
Write-Host "🔍 شغّل الآن: flutter analyze" -ForegroundColor Cyan
Write-Host "ثم: flutter run -d windows" -ForegroundColor Cyan