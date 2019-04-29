@echo off
set args=%1
set base=%OO%\script
if not exist %base% (
  mkdir %base%
  echo create %base%
) else (
  rem echo exist %base%
)
if defined args (
  notepad %base%\%args% && echo file %base%\%args%
) else (
  notepad
)