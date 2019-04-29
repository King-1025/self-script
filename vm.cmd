@echo off
set opt=
set unknown=
set opt=%1
if "%opt%" equ "debain" ( goto debain )
set unknown=yes
goto last

:debain
echo start debain
qs64 -m 2048 -hda %OO%\linux\debain\system.img

:last
if defined unknown (
  echo unknown option: %opt%
)