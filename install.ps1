# nagisafetch Windows 一键安装（PowerShell）
# 用法：以普通用户打开 PowerShell，执行  powershell -ExecutionPolicy Bypass -File install.ps1
# 零第三方依赖：只需系统里有 Python 3.8+。

$ErrorActionPreference = "Stop"
$InstallDir = Join-Path $env:LOCALAPPDATA "nagisafetch"
$ScriptPath = Join-Path $InstallDir "nagisafetch.py"
$CmdPath    = Join-Path $InstallDir "nagisafetch.cmd"
$Src = Join-Path $PSScriptRoot "nagisafetch"

Write-Host "==> nagisafetch Windows 安装"

# 1) 找 Python
$py = $null
foreach ($cand in @("py", "python", "python3")) {
    try {
        $v = & $cand --version 2>&1
        if ($LASTEXITCODE -eq 0 -and "$v" -match "Python 3\.([89]|1\d)") { $py = $cand; break }
    } catch {}
}
if (-not $py) {
    Write-Error "没找到 Python 3.8+。先装一个：winget install Python.Python.3.12"
    exit 1
}
Write-Host "    Python: $py ($(& $py --version 2>&1))"

# 2) 建目录、拷贝脚本
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -Force $Src $ScriptPath
Write-Host "    脚本: $ScriptPath"

# 3) 写 .cmd 包装（放到同一目录，稍后加进 PATH）
@"
@echo off
"$py" "%~dp0nagisafetch.py" %*
"@ | Set-Content -Encoding ASCII $CmdPath
Write-Host "    启动器: $CmdPath"

# 4) 把安装目录加进用户 PATH（幂等）
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
    $sep = if ($userPath) { ";" } else { "" }
    [Environment]::SetEnvironmentVariable("Path", "$userPath$sep$InstallDir", "User")
    $env:Path += ";$InstallDir"
    Write-Host "    已把 $InstallDir 加入用户 PATH（新开终端生效）"
} else {
    Write-Host "    PATH 已包含安装目录"
}

# 5) 默认参数：sora 四色 + Nerd Font 方块 logo（Windows 无 kitty 图片协议，用 ASCII）
$cfgDir = Join-Path $env:APPDATA "nagisafetch"
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
$argsFile = Join-Path $cfgDir "default-args"
if (-not (Test-Path $argsFile)) {
    @"
-c sora --theme sora --bars on
"@ | Set-Content -Encoding ASCII $argsFile
    Write-Host "    默认参数: $argsFile"
}

# 6) 验证
Write-Host "==> 验证"
& $py $ScriptPath --version
& $py $ScriptPath --no-color | Select-Object -First 12

Write-Host "==> 完成。重开 Windows Terminal 后直接敲 nagisafetch"
Write-Host "    提示：字体用 JetBrainsMono NFM 时，方块 logo 与 ✦ 分组标记显示最佳"
