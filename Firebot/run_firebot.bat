@echo off
:: usage: 
::  run_firebot -fdsrepo name -altemail -email address -nomatlab -update -clean  
::  (all command arguments are optional)

set altemail=0
set update=0
set clean=0
set usematlab=1
set stopscript=0
set force=0
set installed=0
set lite=0

if NOT exist .fds_git (
   echo ***error: firebot not running in the bot\Firebot directory
   echo           firebot aborted
   exit /b
)

set emailto=
if not x%EMAILGIT% == x (
  set emailto=%EMAILGIT%
)

:: parse command line arguments

set stopscript=0
call :getopts %*
if %stopscript% == 1 (
  exit /b
)

:: normalize directory paths

call :normalise %CD%
set curdir=%temparg%

set repo=..\..
call :normalise %repo%
set repo=%temparg%

set fdsrepo=%repo%\fds
call :normalise %fdsrepo%
set fdsrepo=%temparg%

set smvrepo=%repo%\smv
call :normalise %smvrepo%
set smvrepo=%temparg%

call :normalise %repo%\bot\Firebot
set firebotdir=%temparg%

set running=%curdir%\firebot.running

:: get latest firebot

if %update% == 0 goto no_update
   echo getting latest firebot
   call :cd_repo %firebotdir% master
   git fetch origin
   git merge origin/master 1> Nul 2>&1
   cd %curdir%
:no_update

:: run firebot

  echo 1 > %running%
  call firebot.bat %repo% %clean% %update% %altemail% %usematlab% %installed% %lite% %emailto%
  if exist %running% erase %running%
  goto end_running
:skip_running
  echo ***Error: firebot is currently running. If this is
  echo           not the case rerun using the -force option
:end_running

goto eof

:getopts
 if (%1)==() exit /b
 set valid=0
 set arg=%1
 if /I "%1" EQU "-help" (
   call :usage
   set stopscript=1
   exit /b
 )
 if /I "%1" EQU "-email" (
   set emailto=%2
   set valid=1
   shift
 )
 if /I "%1" EQU "-altemail" (
   set valid=1
   set altemail=1
 )
 if /I "%1" EQU "-bot" (
   set valid=1
   set clean=1
   set update=1
 )
 if /I "%1" EQU "-clean" (
   set valid=1
   set clean=1
 )
 if /I "%1" EQU "-installed" (
   set valid=1
   set installed=1
 )
 if /I "%1" EQU "-update" (
   set valid=1
   set update=1
 )
 if /I "%1" EQU "-force" (
   set valid=1
   set force=1
 )
 if /I "%1" EQU "-lite" (
   set valid=1
   set lite=1
 )
 if /I "%1" EQU "-nomatlab" (
   set valid=1
   set usematlab=0
 )
 shift
 if %valid% == 0 (
   echo.
   echo ***Error: the input argument %arg% is invalid
   echo.
   echo Usage:
   call :usage
   set stopscript=1
   exit /b
 )
if not (%1)==() goto getopts
exit /b

:: -------------------------------------------------------------
:chk_repo
:: -------------------------------------------------------------

set repodir=%1

if NOT exist %repodir% (
  echo ***error: repo directory %repodir% does not exist
  echo           firebot aborted
  exit /b 1
)
exit /b 0

:: -------------------------------------------------------------
:cd_repo
:: -------------------------------------------------------------

set repodir=%1
set repobranch=%2

call :chk_repo %repodir% || exit /b 1

cd %repodir%
if "%repobranch%" == "" (
  exit /b 0
)
git rev-parse --abbrev-ref HEAD>current_branch.txt
set /p current_branch=<current_branch.txt
erase current_branch.txt
if "%repobranch%" NEQ "%current_branch%" (
  echo ***error: found branch %current_branch% was expecting branch %repobranch%
  echo           firebot aborted
  exit /b 1
)
exit /b 0

:usage  
echo run_firebot [options]
echo. 
echo -help           - display this message
echo -altemail       - use an alternate email server
echo -email address  - override "to" email addresses specified in repo 
if "%emailto%" NEQ "" (
echo       (default: %emailto%^)
)
echo -force          - force firebot to run
echo -nomatlab       - do not use matlab
echo -bot            - clean and update repository
echo -lite           - build and run only debug FDS
echo -clean          - clean repository
echo -installed      - use installed smokeview
echo -update         - update repository
exit /b

:normalise
set temparg=%~f1
exit /b

:eof

