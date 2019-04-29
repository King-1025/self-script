@echo off
set args=%1
if defined args (
  cd /d %1
) else (
  echo please specify a path.
) 