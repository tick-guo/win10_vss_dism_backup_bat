@echo off
:: 20230524-214055 v1.0 guoyh
@echo ��ʼ����ʱ�� %date% %time%
@echo �л�����Ŀ¼���ű�����Ŀ¼ %~dp0 
pushd %~dp0

@echo ������ԱȨ��
bcdedit > nul
IF %ERRORLEVEL% NEQ 0 @echo û�й���ԱȨ�� && goto eof

@echo ��������ļ�WimScript.ini
IF not EXIST WimScript.ini (
	@echo �����ļ�WimScript.ini ������
	goto eof
) ELSE (
	@echo ���ͨ��
)

set tmp_log=ret_tmp.log

@echo ����c�̿���
wmic shadowcopy call create volume=c:\  > %tmp_log%
IF %ERRORLEVEL% NEQ 0 @echo �������մ��� && goto eof
FOR /F "eol=; tokens=2,3* delims={|}" %%i in (%tmp_log%) do (
	@echo {%%i}
	set id={%%i}
)
@echo �鿴copy���
vssadmin List Shadows  /Shadow=%id% | findstr HarddiskVolumeShadowCopy > %tmp_log%
FOR /F "eol=; tokens=2,3* delims=: " %%i in (ret_tmp.log) do ( 
	@echo %%i
	set vs=%%i\
)

@echo ������D:\CĿ¼�£���Ϊ�ų���������Ԥ����CĿ¼
IF EXIST D:\C (
	@echo �Ѿ����� D:\C��Ŀ¼��ͻ����ɾ����������ԭ���� D:\C
	goto eof
) ELSE (
	@echo ���ͨ��
)

@echo ��������D:\C ָ�� %vs%
mklink /D D:\C  %vs%	
IF %ERRORLEVEL% NEQ 0 @echo �������Ӵ��� && goto eof

set name=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
@echo %name%
@echo ����пո񣬰ѿո��滻Ϊ0
set name=%name: =0%
@echo %name%

@echo ���Ŀ¼�µ��ļ�

if not EXIST d:\c\Windows (
@echo ���󣺿���Ŀ¼�µ��ļ�û��windowsĿ¼
goto eof
)

@echo ����ر�defenderʵʱ����,���ݺܿ�
IF EXIST Win10.wim (
 @echo ׷��wim   
 DISM /Append-Image /ImageFile:Win10.wim /CaptureDir:D:\C\ /Name:Win10-%name% /ConfigFile:WimScript.ini
) ELSE (
 @echo �½�wim   
 DISM /Capture-Image /ImageFile:Win10.wim /CaptureDir:D:\C\  /Compress:fast /Name:Win10-%name% /ConfigFile:WimScript.ini
)

@echo ɾ����ʱĿ¼����
rmdir d:\c
IF %ERRORLEVEL% NEQ 0 @echo ��������ʧ�ܣ����ֶ�ɾ�� rmdir d:\c

@echo ɾ������
vssadmin Delete Shadows /Shadow=%id% /Quiet
IF %ERRORLEVEL% NEQ 0 @echo ɾ������ʧ�ܣ����ֶ�ɾ��Shadow=%id%
@echo ����Ƿ�ɾ���˿��գ��Ҳ�������ȷ
vssadmin List Shadows  /Shadow=%id%
::ɾ�����п��յ������� vssadmin Delete Shadows /for=c: /Quiet
goto eof

:eof
@echo ��������ʱ�� %date% %time%
if EXIST %tmp_log% del /q %tmp_log%
@echo �����˳�
pause
 

