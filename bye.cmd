@echo off
set opt=
set /p opt="��Ҫ���Ϲر�ϵͳ�𣿣�Y/n��"
if defined opt (
  if "%opt%" neq "Y" (
      goto stopped
  )
)

shutdown /s /t 0
exit 0

:stopped
echo ����������