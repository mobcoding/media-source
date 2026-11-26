@echo off
setlocal EnableExtensions DisableDelayedExpansion
pushd "%~dp0" || exit /b 1
if not exist ".git\HEAD" goto :wrongrepo
git symbolic-ref --quiet HEAD >nul || goto :failed
for %%F in (MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer) do if exist ".git\%%F" goto :busy
git status --short --branch || goto :failed
git add --all -- . || goto :failed
git diff --cached --quiet --exit-code
if errorlevel 2 goto :failed
if not errorlevel 1 goto :sync
git commit -m "Update media resources" || goto :failed

:sync
git pull --rebase || goto :failed
git push || goto :failed
echo Sync complete.
set "result=0"
goto :finish

:wrongrepo
echo Missing resource repository in the script directory.
goto :failed
:busy
echo Finish the current Git operation before syncing.
:failed
echo Sync stopped. Check the Git output above.
set "result=1"
:finish
popd
if /i not "%~1"=="--no-pause" pause
exit /b %result%
