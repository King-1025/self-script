@echo off

set HOST=39.106.72.49
set PORT=21
set ACCOUNT=test0
set PASSWORD=test0
set TEMP_FILE=.tmp-%random%
rem set WORKSPACE=D:\OO\ftp\remote
set WORKSPACE=%cd%
set BASE_PATH=.tmp
set OPTION=help

:main
if "%1" == "get"      goto ftp_get
if "%1" == "put"      goto ftp_put
if "%1" == "view"    goto ftp_ls
if "%OPTION%" == "help" goto help

:help
echo Usage: %0 get/put file_list
goto last

:temp_error
echo Not found temp file !
goto last

:file_list_error
echo File list is empty !
goto last

:ftp_get
set OPTION=0
goto obtain_list

:ftp_put
set OPTION=1
goto obtain_list

:ftp_ls
set OPTION=2
set VIEW_PATH=%2
goto make_command

:obtain_list
shift /1
set FILE_LIST=%1 %2 %3 %4 %5 %6 %7 %8 %9
if "%FILE_LIST%" == "        " goto file_list_error
goto make_command

:make_command
echo open %HOST% %PORT%> %TEMP_FILE%
echo %ACCOUNT%>>               %TEMP_FILE%
echo %PASSWORD%>>             %TEMP_FILE%
echo prompt off>>                    %TEMP_FILE%
echo lcd %WORKSPACE%>>      %TEMP_FILE%
echo cd %BASE_PATH%>>         %TEMP_FILE%
if %OPTION% == 0 (
   echo mget %FILE_LIST%>>      %TEMP_FILE% 
)
if %OPTION% == 1 (
   echo mput %FILE_LIST%>>      %TEMP_FILE%
)
if %OPTION% == 2 (
   echo ls %VIEW_PATH%>>       %TEMP_FILE%
)
echo prompt on>>                    %TEMP_FILE%
echo bye>>                              %TEMP_FILE%
echo quit>>                              %TEMP_FILE%

:check_temp
if not exist %TEMP_FILE% goto temp_error

:exec_commmand
rem notepad %TEMP_FILE%
ftp -s:%TEMP_FILE%

:clean
rem copy %TEMP_FILE% 1.ftp
del %TEMP_FILE%

:last