@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "log=!USERPROFILE!\.log\scripts\%~n0.log"
set "callers=%~nx0"
set "nocolor="

call :func :main %*
if not "!err!."=="." (
    call :func :notify "!err!"
    exit /b 1
)
exit /b 0

:: ---

:func <label> [arg [arg ...]]
    set "callers=%1`!callers!"
    call %*
    set "callers=!callers:*`=!"
exit /b

:main
    set "_gather="
    set "remaining="

    for %%a in (%*) do (
        if defined remaining (
            set "remaining=!remaining! %%a"
        ) else if defined _gather (
            set "!_gather!=%%~a"
            set "_gather"
        ) else (
            set "_"="%%~a"
            if "!_!"=="--" (
                set "remaining="
            ) else if "!_:~0,2!"=="--" (
                set "_=!_:~2!"
                if "!_!"=="help" (
                    call :show_help
                    exit /b 0
                ) else if "!_!"=="cron" (
                    set "nocolor=1"
                )
            ) else if "!_:~0,1!"=="-" (
                set "_=!_:~1!"
                if "!_!"=="h" (
                    call :show_help
                    exit /b 0
                ) else if "!_!"=="C" (
                    set "nocolor=1"
                )
            ) else (
                1>&2 echo(ERROR: Unexpected argument: %%~a
            )
        )
    )
    set "_gather="

    call :mkparent "!log!"
    copy nul "!log!"
exit /b

:mkparent <path>
    md "%~dp1"
exit /b

:log <level> <message> [...]
    for /F "delims=`" %%a in ("!callers!") do set "_name=%%a"

    set "rgb="
    if "%~1"=="emerg" (
        set "rgb=[1;31m"
        set "lvl=EMERGENCY"
    ) else if "%~1"=="alert" (
        set "rgb=[1;36m"
        set "lvl=ALERT    "
    ) else if "%~1"=="crit" (
        set "rgb=[1;36m"
        set "lvl=CRITICAL "
    ) else if "%~1"=="err" (
        set "rgb=[0;31m"
        set "lvl=ERROR    "
    ) else if "%~1"=="warn" (
        set "rgb=[0;33m"
        set "lvl=WARNING  "
    ) else if "%~1"=="notice" (
        set "rgb=[0;32m"
        set "lvl=NOTICE   "
    ) else if "%~1"=="info" (
        set "rgb=[1;37m"
        set "lvl=INFO     "
    ) else if "%~1"=="debug" (
        set "rgb=[1;35m"
        set "lvl=DEBUG    "
    )

    if "!nocolor!."=="." (
        set "rgb=!rgb!!lvl![0m"
    ) else (
        set "rgb=!lvl!"
    )

    set "_logs=%*"
    set "_logs=!_logs:*%1 =!"
    for %%a in (!_logs!) (
        set "stamp=!date:~10,4!-!date:~7,2!-!date:~4,2!T!time:~0,8!"
        echo(!stamp!^|!rgb!^|!_name:~0,20!^|%%~a
        >> "!log!" echo(!stamp!^|!lvl!^|!_name:~0,20!^|%%~a
    )
exit /b

:show_help
    echo(description
    echo(
    echo(USAGE: %~nx0 [OPTIONS]
    echo(
    echo(OPTIONS:
    echo(    -h, --help                Show this help message
    echo(    -C, --cron                Do not print colored status messages
exit /b

