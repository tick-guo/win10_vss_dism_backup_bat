@echo off
:: 20230524-214055 v1.0 guoyh
@echo 开始运行时间 %date% %time%
@echo 切换工作目录到脚本所在目录 %~dp0 
pushd %~dp0

@echo 检测管理员权限
bcdedit > nul
IF %ERRORLEVEL% NEQ 0 @echo 没有管理员权限 && goto eof

@echo 检测配置文件WimScript.ini
IF not EXIST WimScript.ini (
	@echo 配置文件WimScript.ini 不存在
	goto eof
) ELSE (
	@echo 检测通过
)

set tmp_log=ret_tmp.log

@echo 创建c盘快照
wmic shadowcopy call create volume=c:\  > %tmp_log%
IF %ERRORLEVEL% NEQ 0 @echo 创建快照错误 && goto eof
FOR /F "eol=; tokens=2,3* delims={|}" %%i in (%tmp_log%) do (
	@echo {%%i}
	set id={%%i}
)
@echo 查看copy编号
vssadmin List Shadows  /Shadow=%id% | findstr HarddiskVolumeShadowCopy > %tmp_log%
FOR /F "eol=; tokens=2,3* delims=: " %%i in (ret_tmp.log) do ( 
	@echo %%i
	set vs=%%i\
)

@echo 必须在D:\C目录下，因为排除规则里面预置了C目录
IF EXIST D:\C (
	@echo 已经存在 D:\C，目录冲突，请删除或重命名原来的 D:\C
	goto eof
) ELSE (
	@echo 检测通过
)

@echo 创建链接D:\C 指向 %vs%
mklink /D D:\C  %vs%	
IF %ERRORLEVEL% NEQ 0 @echo 创建链接错误 && goto eof

set name=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
@echo %name%
@echo 如果有空格，把空格替换为0
set name=%name: =0%
@echo %name%

@echo 检查目录下的文件

if not EXIST d:\c\Windows (
@echo 错误：快照目录下的文件没有windows目录
goto eof
)

@echo 如果关闭defender实时保护,备份很快
IF EXIST Win10.wim (
 @echo 追加wim   
 DISM /Append-Image /ImageFile:Win10.wim /CaptureDir:D:\C\ /Name:Win10-%name% /ConfigFile:WimScript.ini
) ELSE (
 @echo 新建wim   
 DISM /Capture-Image /ImageFile:Win10.wim /CaptureDir:D:\C\  /Compress:fast /Name:Win10-%name% /ConfigFile:WimScript.ini
)

@echo 删除临时目录链接
rmdir d:\c
IF %ERRORLEVEL% NEQ 0 @echo 创建链接失败，请手动删除 rmdir d:\c

@echo 删除快照
vssadmin Delete Shadows /Shadow=%id% /Quiet
IF %ERRORLEVEL% NEQ 0 @echo 删除快照失败，请手动删除Shadow=%id%
@echo 检查是否删除了快照，找不到则正确
vssadmin List Shadows  /Shadow=%id%
::删除所有快照的命令是 vssadmin Delete Shadows /for=c: /Quiet
goto eof

:eof
@echo 结束运行时间 %date% %time%
if EXIST %tmp_log% del /q %tmp_log%
@echo 程序退出
pause
 

