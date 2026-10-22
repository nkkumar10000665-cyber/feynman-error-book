$base = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$learnBase = "$base\我的学习"

Write-Host "===== 费曼错题本Pro 通用框架 系统验证 =====" -ForegroundColor Cyan
Write-Host ""

# 1. 检查核心配置文件
Write-Host "[1] 核心配置文件" -ForegroundColor Yellow
$coreFiles = @("AI设定.md", "README.md", "跟着做搭建教程.html", "使用说明.html")
foreach ($f in $coreFiles) {
    $p = "$base\$f"
    if (Test-Path $p) {
        $size = (Get-Item $p).Length
        Write-Host "  OK  $f ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "  MISS $f" -ForegroundColor Red
    }
}

# 2. 检查全局文件
Write-Host ""
Write-Host "[2] 全局学习文件" -ForegroundColor Yellow
$globalFiles = @("学情总览.md", "学情总览.html", "成长档案.md", "角色档案.md", "理科跨学科分析.md", "文理跨学科分析.md")
foreach ($f in $globalFiles) {
    $p = "$learnBase\$f"
    if (Test-Path $p) {
        $size = (Get-Item $p).Length
        Write-Host "  OK  $f ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "  MISS $f" -ForegroundColor Red
    }
}

# 3. 检查模板文件
Write-Host ""
Write-Host "[3] 模板文件" -ForegroundColor Yellow
$templateDir = "$base\模板文件"
if (Test-Path $templateDir) {
    $templateFiles = @("知识图谱_模板.md", "易错记录_模板.md", "错因分析_模板.md", "练习_模板.md")
    foreach ($f in $templateFiles) {
        $p = "$templateDir\$f"
        if (Test-Path $p) {
            $size = (Get-Item $p).Length
            Write-Host "  OK  $f ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "  MISS $f" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  MISS 模板文件/ 目录" -ForegroundColor Red
}

# 4. 检查AI设定中的规则数量
Write-Host ""
Write-Host "[4] AI规则检查" -ForegroundColor Yellow
$aiFile = "$base\AI设定.md"
if (Test-Path $aiFile) {
    $content = Get-Content $aiFile -Raw -Encoding UTF8
    $ruleCount = ([regex]::Matches($content, "### 规则\d+")).Count
    Write-Host "  规则总数: $ruleCount" -ForegroundColor $(if ($ruleCount -ge 11) {"Green"} else {"Yellow"})
    if ($ruleCount -lt 11) {
        Write-Host "  提示: 当前规则数不足11条，请确认AI设定.md已更新" -ForegroundColor Yellow
    }
    $hasRule10 = $content -match "规则10.*标准会话流程"
    $hasRule11 = $content -match "规则11.*知识图谱互联"
    Write-Host "  规则10(标准会话流程): $(if($hasRule10){'OK'}else{'MISS'})" -ForegroundColor $(if($hasRule10){"Green"}else{"Red"})
    Write-Host "  规则11(知识图谱互联): $(if($hasRule11){'OK'}else{'MISS'})" -ForegroundColor $(if($hasRule11){"Green"}else{"Red"})
}

# 5. 检查所有章节文件（搭建后才有）
Write-Host ""
Write-Host "[5] 各学科章节文件完整性" -ForegroundColor Yellow
$subjects = Get-ChildItem $learnBase -Directory | Where-Object { $_.Name -notin @("模板文件") } | Sort-Object Name

if ($subjects.Count -eq 0) {
    Write-Host "  (尚未搭建，搭建后显示章节完整性)" -ForegroundColor Gray
} else {
    $totalChapters = 0
    $totalKG = 0
    $totalEasy = 0
    $totalAnalysis = 0
    $totalPractice = 0

    foreach ($subj in $subjects) {
        $grades = Get-ChildItem $subj.FullName -Directory | Sort-Object Name
        foreach ($grade in $grades) {
            $chapters = Get-ChildItem $grade.FullName -Directory | Sort-Object Name
            $chCount = $chapters.Count
            $kgCount = 0; $easyCount = 0; $analysisCount = 0; $practiceCount = 0

            foreach ($ch in $chapters) {
                if (Test-Path "$($ch.FullName)\知识图谱.md") { $kgCount++ }
                if (Test-Path "$($ch.FullName)\易错记录.md") { $easyCount++ }
                if (Test-Path "$($ch.FullName)\错因分析.md") { $analysisCount++ }
                if (Test-Path "$($ch.FullName)\练习.md") { $practiceCount++ }
            }

            $totalChapters += $chCount
            $totalKG += $kgCount; $totalEasy += $easyCount
            $totalAnalysis += $analysisCount; $totalPractice += $practiceCount

            $status = if ($kgCount -eq $chCount -and $chCount -gt 0) { "OK" } elseif ($kgCount -eq 0) { "EMPTY" } else { "PARTIAL" }
            $color = if ($status -eq "OK") { "Green" } else { "Red" }
            Write-Host "  $status  $($subj.Name)/$($grade.Name): $chCount章, 知识图谱$kgCount/$chCount" -ForegroundColor $color
        }
    }

    Write-Host ""
    Write-Host "[6] 系统汇总" -ForegroundColor Cyan
    Write-Host "  总学科数:     $($subjects.Count)"
    Write-Host "  总章节数:     $totalChapters"
    Write-Host "  知识图谱:     $totalKG / $totalChapters" -ForegroundColor $(if ($totalKG -eq $totalChapters) {"Green"} else {"Yellow"})
    Write-Host "  易错记录:     $totalEasy / $totalChapters"
    Write-Host "  错因分析:     $totalAnalysis / $totalChapters"
    Write-Host "  练习文件:     $totalPractice / $totalChapters"
}

Write-Host ""
Write-Host "===== 验证完成 =====" -ForegroundColor Cyan
