@echo off
setlocal

set CURDIR=%CD%

if not exist ..\.gitbot goto skip1
   cd ..\..
   set FMROOT=%CD%
   cd %CURDIR%
   goto endif1
:skip1
   echo ***error: update_repos.bat must be run in the bot\Scripts directory
   exit /b
:endif1

call :getopts %*
if %stopscript% == 1 (
  exit /b
)

cd %FMROOT\bot
set allrepos=bot cfast cor exp fds out radcal smv
set BRANCH=master
set PUSH=0

set wc=%FMROOT%\bot\Scripts\wc
set grep=%FMROOT%\bot\Scripts\grep
set gawk=%FMROOT%\bot\Scripts\gawk

for %%x in ( %allrepos% ) do ( call :update_repo %%x )

cd %CURDIR%

goto eof

:update_repo
  set repo=%1
  echo
  set repodir=%FMROOT%\%repo%
  echo -----------------------------------------------------------
  if not exist %repodir% (
     echo %repo% does not exist, not updating
     exit /b
  )   
  cd %repodir%
  git rev-parse --abbrev-ref HEAD | head -1> %CURDIR%\gitbranch.out
  set /p CURRENT_BRANCH=<%CURDIR%\gitbranch.out
  if NOT "%CURRENT_BRANCH%" == "%BRANCH%" (
     echo %BRANCH% branch not checkout out in %repo%
     echo update skipped
     exit /b
  )
  echo updating %repo%/%BRANCH% from origin
  git fetch origin
  git merge origin/%BRANCH%
  git remote -v | %gawk% "{print $1}" | %grep% firemodels | %wc%  -l> %CURDIR%\have_central.out
  set /p have_central=<%CURDIR%\have_central.out

  if %have_central% GTR 0 (
     echo updating %repo%/%BRANCH% from firemodels
     git fetch firemodels
     git merge firemodels/%BRANCH%
     if "%PUSH%" == "1" (
        echo pushing changes in %repo% to origin"
        git push origin %BRANCH%
     )
  )
  exit /b

goto eof

:getopts
 set stopscript=0
 if (%1)==() exit /b
 set valid=0
 set arg=%1
 if /I "%1" EQU "-h" (
   call :usage
   set stopscript=1
   exit /b
 )
 if /I "%1" EQU "-p" (
   set valid=1
   set PUSH=1
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

:usage
echo Update the repos %allrepos% if they exist
echo.
echo Options:
echo -h - display this message
echo -p - push updates to remote origin
exit /b

:eof
erase %CURDIR%\gitbranch.out
erase %CURDIR%\have_central.out