@echo off
set opt=
set /p opt="你要马上关闭系统吗？（Y/n）"
if defined opt (
  if "%opt%" neq "Y" (
      goto stopped
  )
)

shutdown /s /t 0
exit 0

:stopped
echo 撤销操作！