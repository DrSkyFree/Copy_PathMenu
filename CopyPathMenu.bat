@echo off
rem ============================================================
rem  CopyPathMenu.bat v3 - 右键菜单 [复制路径] 安装 / 清除
rem  单文件版: 启动器 CopyPath.vbs 已内嵌，安装时自动释放
rem  范围: 当前用户(HKCU)，无需管理员权限，无 UAC 弹窗
rem  特性: 零窗口闪现(wscript 启动器)，不重启资源管理器
rem  编码: ANSI/GBK(936) + CRLF，请勿另存为 UTF-8
rem ============================================================
chcp 936 >nul
setlocal EnableExtensions
title 右键菜单 [复制路径] 安装/清除 v3

set "VDIR=%LOCALAPPDATA%\CopyPathMenu"
set "VBS=%VDIR%\CopyPath.vbs"
set "KROOT=HKCU\Software\Classes\AllFilesystemObjects\shell"
set "SROOT=HKCR\AllFilesystemObjects\shell"

:menu
cls
echo ============================================
echo      右键菜单 [复制路径] 安装 / 清除  v3
echo            (单文件版, 免管理员)
echo ============================================
echo.
echo   1. 添加  复制路径(带引号)      例: "D:\folder\file.txt"
echo   2. 添加  复制路径(不带引号)    例: D:\folder\file.txt
echo   3. 清除  复制路径 右键菜单项
echo   0. 退出
echo.
choice /c 1230 /n /m "请选择 [1/2/3/0]: "
if errorlevel 4 goto end
if errorlevel 3 goto clear
if errorlevel 2 goto plain
if errorlevel 1 goto quoted
goto end

:quoted
call :makevbs
if errorlevel 1 goto end
echo 正在写入注册表: 复制路径(带引号) ...
reg add "%KROOT%\CopyPathQuoted" /ve /d "复制路径(带引号)" /f >nul
if errorlevel 1 goto fail
reg add "%KROOT%\CopyPathQuoted" /v Icon /d "imageres.dll,-5302" /f >nul
reg add "%KROOT%\CopyPathQuoted\command" /ve /d "wscript.exe //nologo \"%VBS%\" quote \"%%1\"" /f >nul
if errorlevel 1 goto fail
echo [完成] 复制路径(带引号) 已添加，即时生效，无窗口闪现。
goto end

:plain
call :makevbs
if errorlevel 1 goto end
echo 正在写入注册表: 复制路径(不带引号) ...
reg add "%KROOT%\CopyPathPlain" /ve /d "复制路径(不带引号)" /f >nul
if errorlevel 1 goto fail
reg add "%KROOT%\CopyPathPlain" /v Icon /d "imageres.dll,-5302" /f >nul
reg add "%KROOT%\CopyPathPlain\command" /ve /d "wscript.exe //nologo \"%VBS%\" plain \"%%1\"" /f >nul
if errorlevel 1 goto fail
echo [完成] 复制路径(不带引号) 已添加，即时生效，无窗口闪现。
goto end

:clear
echo 正在清除右键菜单项 ...
reg delete "%KROOT%\CopyPathQuoted" /f >nul 2>&1
reg delete "%KROOT%\CopyPathPlain" /f >nul 2>&1
reg delete "%SROOT%\CopyPathQuoted" /f >nul 2>&1
reg delete "%SROOT%\CopyPathPlain" /f >nul 2>&1
reg delete "%SROOT%\CopyAsPath" /f >nul 2>&1
reg query "%SROOT%\CopyPathPlain" >nul 2>&1
if not errorlevel 1 echo [警告] 检测到系统级残留: 请右键本脚本选择[以管理员身份运行]后再次清除
if exist "%VBS%" del /f /q "%VBS%" >nul 2>&1
rd "%VDIR%" >nul 2>&1
echo [完成] 复制路径 菜单项已清除，即时生效。
goto end

:makevbs
if not exist "%VDIR%" mkdir "%VDIR%"
(for /f "usebackq delims=" %%L in (`findstr /b /l /c:"#:" "%~f0"`) do (
  set "line=%%L"
  setlocal EnableDelayedExpansion
  echo(!line:~2!
  endlocal
)) > "%VBS%"
if exist "%VBS%" exit /b 0
echo [错误] 启动器释放失败: %VBS%
exit /b 1

:fail
echo.
echo [错误] 注册表写入失败。
goto end

:end
echo.
pause
endlocal
exit /b 0

rem ======== 内嵌启动器载荷(勿删, 每行以 #: 开头) ========
#:Option Explicit
#:Dim mode, target, ps, cmd, sh, rc
#:If WScript.Arguments.Count < 2 Then
#:  MsgBox "CopyPath: missing arguments", 48, "CopyPath"
#:  WScript.Quit 1
#:End If
#:mode = LCase(WScript.Arguments(0))
#:target = WScript.Arguments(1)
#:If mode = "quote" Then target = Chr(34) & target & Chr(34)
#:ps = "Set-Clipboard -Value '" & Replace(target, "'", "''") & "'"
#:cmd = "powershell.exe -NoProfile -WindowStyle Hidden -Command " & Chr(34) & ps & Chr(34)
#:Set sh = CreateObject("WScript.Shell")
#:On Error Resume Next
#:rc = sh.Run(cmd, 0, True)
#:If Err.Number <> 0 Then
#:  MsgBox "CopyPath failed: " & Err.Description, 16, "CopyPath"
#:  WScript.Quit 1
#:End If
#:If rc <> 0 Then
#:  MsgBox "CopyPath failed, exit code: " & rc, 16, "CopyPath"
#:  WScript.Quit 1
#:End If
