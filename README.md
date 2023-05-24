# win10_vss_dism_backup_bat
you can backup win10+ system when system is running, with simple cmd command 

# 优点
+ 可以在windows运行时备份系统
+ 只使用windows基本命令， vss快照和dism， 不用担心其他第三方软件的未知操作
+ 关闭defender实时保护或排除dism.exe进程，不然会备份很慢

#
+ 只能备份运行中的系统，dism虽然也可以离线，在pe中备份系统，但是不是本脚本的关注点

# 使用步骤
+ 将WimScript.ini，vss_backup_run.cmd 放到一个空间足够的目录
+ 用管理员权限运行vss_backup_run.cmd即可
