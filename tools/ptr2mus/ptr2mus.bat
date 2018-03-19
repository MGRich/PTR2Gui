@echo off
setlocal enableextensions
setlocal enabledelayedexpansion
set run=%~dp0
set mf="%run%mfaudio.exe"
set sx="%run%sox\sox.exe"
set drdp="%~1"
set type=%drdp:~-3,-1%
set wvt=%drdp:~-6,-5%
set wpt=%drdp:~-6,-5%
if %drdp%=="" goto click
if /I "%type%"=="av" (  
    if /I "%wvt%"=="2" (
        call :mf wp2c
        exit
    ) ELSE (
        echo PRECAUTION: This will give you the compressed ver. You have to hex-edit the actual sound in yourself.
        pause
        call :mf bdc
        exit
    )
)
if /I "%type%"=="p2" ( 
    set "pth=%~1"
    set nm=!pth:~-12,-5!
    set chk=!nm:~0,3!
    set vsck=!nm:~5,6!
    if /I not !chk!==ST0 (
        if /I !vsck!==VS (
            set nm=!pth:~-11,-5!
            set "pth=!pth:~0,-11!"
            set wp0="!pth!!nm!0.WP2"
            set wp1="!pth!!nm!1.WP2"
            set wp2="!pth!!nm!2.WP2"
            call :vse
            exit
        )
        call :mf wp2e
        exit
    )
    set "pth=!pth:~0,-12!"
    set wpn="!pth!!nm!N.WP2"
    set wpg="!pth!!nm!G.WP2"
    set wpc="!pth!!nm!C.WP2"
    call :wp2e
    exit
)
    python --version  >nul
    if NOT ERRORLEVEL 1 goto nex
    py -2 --version  >nul
    if NOT ERRORLEVEL 1 goto nex
    echo Due to you not having python 2 installed,  
    set /p of="Offset: "
    call :mf bde2
    exit
:nex
"%run%offset.py" %drdp%>"%run%\offsets"
set ln=0
cd "%run%"
if not exist bd mkdir bd
copy "offsets" "bd\offsets"
set "ll=findstr /R /N "^^" offsets | find /C ":""
for /f %%a in ('!ll!') do set ll=%%a
set /a ll-=1
echo offset 0
set of=0
call :mf bde1
:ex
set /a ln+=1
:for
FOR /F "skip=%ln% delims=" %%i IN (offsets) DO set of=%%i & goto mfa
:mfa
if %ln%==%ll% (
    del "offsets"
    echo exit
    exit
)
echo offset %of%
set of=%of:~0,-1%
call :mf bde1
goto ex
:mf
if %1==bde1 %mf% /if24000 /ic1 /ii200 /ih%of% /otwavu /oi0 /of24000 /oc1 %drdp% "bd\%of%bd.wav"
if %1==bde2 %mf% /if24000 /ic1 /ii200 /ih%of% /otwavu /oi0 /of24000 /oc1 %drdp% "%run%%of%bd.wav"
if %1==wp2e %mf% /if48000 /ic2 /ii200 /otwavu /oi0 %drdp% "%run%wp2.wav"
if %1==wp2c %mf% /if48000 /ic2 /ii0 /otrawu /oi200 %drdp% "%run%create.WP2"
if %1==bdc %mf% /if24000 /ic1 /ii0 /otrawc /oi200 /of24000 /oc1 %drdp% "%run%create.bd"
exit /b
:wp2e
cd "%run%"
if not exist wp2 mkdir wp2
cd "%run%wp2"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 %wpg% "gudwp2.wav"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 %wpc% "colwp2.wav"
%mf% /if48000 /ic2 /ii400 /otwavu /oi0 %wpn% "wp2b.wav"
%sx% wp2b.wav wp2bl.wav remix 1
%sx% wp2b.wav wp2br.wav remix 2
%sx% wp2bl.wav wp2bl.raw
%sx% wp2br.wav wp2br.raw
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp2br.raw" "awfwp2.wav"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp2bl.raw" "badwp2.wav"
del wp2b*.* wp2b.wav
exit /b
:click
if not exist wp2 (
    if exist vs (
        if exist bd (
            choice /C wbx /M "Do you want to launch the VS (W)P2 creation, BETA (B)D creation, or just e(x)it"
            if !errorlevel!==3 exit
            if !errorlevel!==2 goto bdc
            if !errorlevel!==1 goto vsc
        )
        choice /M "Run the VS WP2 creation"
        if !errorlevel!==2 exit
        if !errorlevel!==1 goto vsc
    )
    if exist bd (
        choice /M "Run the (BETA) BD creation"
        if !errorlevel!==2 exit
        if !errorlevel!==1 goto bdc
    )
    echo It seems you simply clicked on the program by mistake.
    echo The run-only function is only for WP2 editing.
    echo The program will close itself now.
    pause
    exit
) ELSE (
    if exist bd (
        choice /C wbx /M "Do you want to launch the (W)P2 creation, BETA (B)D creation, or just e(x)it"
        if !errorlevel!==3 exit
        if !errorlevel!==2 goto bdc
        if !errorlevel!==1 goto wp2c
    )
    choice /M "Run the WP2 creation"
    if !errorlevel!==2 exit
    if !errorlevel!==1 goto wp2c
)
:wp2c
cd "%run%wp2"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 "gudwp2.wav" "good.wp2"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 "colwp2.wav" "cool.wp2"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "awfwp2.wav" "awfwp2.raw"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "badwp2.wav" "badwp2.raw"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "awfwp2.raw" "awfwp2mm.wav"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "badwp2.raw" "badwp2mm.wav"
%sx% awfwp2mm.wav awfwp2m.wav remix 1-2 >nul
%sx% badwp2mm.wav badwp2m.wav remix 1-2 >nul    
%sx% -M badwp2m.wav awfwp2m.wav badawf.wav
%mf% /if48000 /ic2 /ii0 /otrawu /oi400 /oc2 "badawf.wav" "badawf.wp2"
for %%i in (*.*) do if not "%%i"=="badwp2.wav" if not "%%i"=="awfwp2.wav" if not "%%i"=="badawf.wp2" if not "%%i"=="gudwp2.wav" if not "%%i"=="colwp2.wav" if not "%%i"=="cool.wp2" if not "%%i"=="good.wp2" del /q "%%i"
cd ..
if exist vs (
    choice /M "Run the VS WP2 creation"
    if !errorlevel!==2 exit
    if !errorlevel!==1 goto vsc
)
exit
:vse
cd "%run%"
if not exist vs mkdir vs
cd "%run%vs"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 %wp0% "0.wp2.wav"
%mf% /if48000 /ic2 /ii400 /otwavu /oi0 %wp1% "wp21.wav"
%sx% wp21.wav wp21l.wav remix 1
%sx% wp21.wav wp21r.wav remix 2
%sx% wp21l.wav wp21l.raw
%sx% wp21r.wav wp21r.raw
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp21r.raw" "1.1.wp2.wav"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp21l.raw" "1.2.wp2.wav"
%mf% /if48000 /ic2 /ii400 /otwavu /oi0 %wp2% "wp22.wav"
%sx% wp22.wav wp22l.wav remix 1
%sx% wp22.wav wp22r.wav remix 2
%sx% wp22l.wav wp22l.raw
%sx% wp22r.wav wp22r.raw
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp22r.raw" "2.1.wp2.wav"
%mf% /if48000 /ic2 /ii200 /otwavu /oi0 "wp22l.raw" "2.2.wp2.wav"
del wp22*.* wp21*.*
exit /b
:vsc
cd "%run%vs"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 "0.wp2.wav" "0.wp2"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "1.1.wp2.wav" "1.1.wp2.raw"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "1.2.wp2.wav" "1.2.wp2.raw"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "1.1.wp2.raw" "1.1.wp2mm.wav"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "1.2.wp2.raw" "1.2.wp2mm.wav"
%sx% 1.1.wp2mm.wav 1.1.wp2m.wav remix 1-2 >nul
%sx% 1.2.wp2mm.wav 1.2.wp2m.wav remix 1-2 >nul    
%sx% -M 1.2.wp2m.wav 1.1.wp2m.wav 1.wp2.wav
%mf% /if48000 /ic2 /ii0 /otrawu /oi400 /oc2 "1.wp2.wav" "1.wp2"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "2.1.wp2.wav" "2.1.wp2.raw"
%mf% /if48000 /ic2 /ii0 /otrawu /oi200 /of48000 "2.2.wp2.wav" "2.2.wp2.raw"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "2.1.wp2.raw" "2.1.wp2mm.wav"
%mf% /if48000 /ic1 /ii0 /otwavu /oi0 /oc2 "2.2.wp2.raw" "2.2.wp2mm.wav"
%sx% 2.1.wp2mm.wav 2.1.wp2m.wav remix 1-2 >nul
%sx% 2.2.wp2mm.wav 2.2.wp2m.wav remix 1-2 >nul    
%sx% -M 2.2.wp2m.wav 2.1.wp2m.wav 2.wp2.wav
%mf% /if48000 /ic2 /ii0 /otrawu /oi400 /oc2 "2.wp2.wav" "2.wp2"
for %%i in (*.*) do if not "%%i"=="1.1.wp2.wav" if not "%%i"=="1.2.wp2.wav" if not "%%i"=="2.1.wp2.wav" if not "%%i"=="2.2.wp2.wav" if not "%%i"=="0.wp2.wav" if not "%%i"=="2.wp2" if not "%%i"=="1.wp2" if not "%%i"=="0.wp2" del /q "%%i"
exit
:bdc
set ln=0
cd "%run%bd"
set "ll=findstr /R /N "^^" offsets | find /C ":""
for /f %%a in ('!ll!') do set ll=%%a
set /a ll-=1
echo offset 0
set of=0
%mf% /if24000 /ic1 /ii0 /otrawc /oi200 /of24000 /oc1 "%of%bd.wav" "%of%create.bd"
:exc
set /a ln+=1
:forc
FOR /F "skip=%ln% delims=" %%i IN (offsets) DO set of=%%i & goto mfac
:mfac
echo offset %of%
set of=%of:~0,-1%
if "!ln!" == "!ll!" goto bdchk
%mf% /if24000 /ic1 /ii0 /otrawc /oi200 /of24000 /oc1 "%of%bd.wav" "%of%create.bd"
goto exc
:bdchk
echo exit
copy /b *.bd output.bd
for %%i in (*create.bd) do if not "%%i"=="output.bd" del /q "%%i"
exit