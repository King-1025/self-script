@echo off
set args=%*
if defined args (
  qemu-system-x86_64 %args%
) else (
  echo please give some arguments !
)