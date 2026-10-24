@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo VOLTARA needs Node.js 22.18 or newer.
  echo Install Node.js from https://nodejs.org/ and double-click this file again.
  start "" "https://nodejs.org/"
  pause
  exit /b 1
)

node -e "const [major,minor]=process.versions.node.split('.').map(Number); process.exit(major<22||(major===22&&minor<18)?1:0)"
if errorlevel 1 (
  echo VOLTARA needs Node.js 22.18 or newer. Update Node.js from https://nodejs.org/.
  start "" "https://nodejs.org/"
  pause
  exit /b 1
)

where pnpm >nul 2>nul
if not errorlevel 1 goto use_pnpm
where corepack >nul 2>nul
if not errorlevel 1 goto use_corepack
where npm >nul 2>nul
if errorlevel 1 (
  echo No pnpm, Corepack, or npm command was found. Install Node.js from https://nodejs.org/.
  pause
  exit /b 1
)
set "VOLTARA_PM=npm exec --yes --package=pnpm@9 -- pnpm"
goto package_manager_ready

:use_pnpm
set "VOLTARA_PM=pnpm"
goto package_manager_ready

:use_corepack
set "VOLTARA_PM=corepack pnpm"

:package_manager_ready

if not exist "node_modules\next\package.json" (
  echo Installing VOLTARA dependencies. This step needs an internet connection...
  call %VOLTARA_PM% install --frozen-lockfile
  if errorlevel 1 (
    echo Dependency installation failed. Check your connection and try again.
    pause
    exit /b 1
  )
)

if not exist ".env.local" copy /y ".env.example" ".env.local" >nul

echo Starting VOLTARA on http://localhost:3000 ...
start "VOLTARA app server" /D "%~dp0" cmd /k "node node_modules\next\dist\bin\next dev --hostname 127.0.0.1 --port 3000"
node "scripts\wait-for-local-server.mjs"
if errorlevel 1 (
  echo VOLTARA did not start. Check the VOLTARA app server window for details.
  pause
  exit /b 1
)
start "" "http://localhost:3000/"
exit /b 0
