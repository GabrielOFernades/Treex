@echo off
chcp 65001 >nul

:: treex.bat - Arvore de diretorios estendida v5.4 - Filtro -P corrigido corretamente
set "MAX_DEPTH=999"
set "DIRS_ONLY=0"
set "FILES_ONLY=0"
set "SHOW_HIDDEN=0"
set "PATTERN="
set "EXCLUDE="
set "TARGET_DIR=."
set "GLOBAL_DIR_COUNT=0"
set "GLOBAL_FILE_COUNT=0"

:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="help" goto show_help
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="/?" goto show_help

if /i "%~1"=="-d" (
    set "DIRS_ONLY=1"
    shift
    goto parse_args
)
if /i "%~1"=="-f" (
    set "FILES_ONLY=1"
    shift
    goto parse_args
)
if /i "%~1"=="-a" (
    set "SHOW_HIDDEN=1"
    shift
    goto parse_args
)
if /i "%~1"=="-L" (
    if "%~2"=="" (
        echo Erro: -L requer um numero
        exit /b 1
    )
    set "MAX_DEPTH=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-P" (
    if "%~2"=="" (
        echo Erro: -P requer um padrao
        exit /b 1
    )
    set "PATTERN=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-p" (
    if "%~2"=="" (
        echo Erro: -p requer um padrao
        exit /b 1
    )
    set "PATTERN=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-I" (
    if "%~2"=="" (
        echo Erro: -I requer um padrao
        exit /b 1
    )
    set "EXCLUDE=%~2"
    shift
    shift
    goto parse_args
)
if "%~1" neq "" (
    set "first_char=%~1"
    set "first_char=!first_char:~0,1!"
    if "!first_char!"=="-" (
        echo Comando %~1 inexistente
        echo Tente treex -h para obter ajuda
        exit /b 1
    )
    set "TARGET_DIR=%~1"
)
shift
goto parse_args

:show_help
echo.
echo ================================================================
echo TREEX - Arvore de Diretorios Estendida v5.4
echo ================================================================
echo.
echo Usage: treex [OPTIONS] [DIRECTORY]
echo.
echo OPTIONS:
echo -d Somente diretorios
echo -f Somente arquivos
echo -a Inclui arquivos/pastas ocultos
echo -L ^<nivel^> Profundidade maxima
echo -P ^<padrao^> Mostra apenas pastas relevantes e arquivos que correspondem ao padrao
echo -I ^<excluir^> Exclui padrao
echo help, -h Mostra ajuda
echo.
echo Com -P *.pdf: mostra arvore com pastas que levam a PDFs e SOMENTE os .pdf
echo.
exit /b 0

:end_parse
if not exist "%TARGET_DIR%" (
    echo Comando "%TARGET_DIR%" inexistente
    echo Tente treex -h para obter ajuda
    exit /b 1
)
pushd "%TARGET_DIR%" 2>nul || (
    echo Comando "%TARGET_DIR%" inexistente
    echo Tente treex -h para obter ajuda
    exit /b 1
)
set "TARGET_DIR=%CD%"
popd

echo Listagem de caminhos de pasta
echo O numero de serie do volume e %DATE:~-4%%TIME:~0,2%%TIME:~3,2%
echo %TARGET_DIR%
echo.

call :print_tree "%TARGET_DIR%" "" 0

echo.
if "%DIRS_ONLY%"=="1" (
    echo Total: %GLOBAL_DIR_COUNT% diretorios
) else if "%FILES_ONLY%"=="1" (
    echo Total: %GLOBAL_FILE_COUNT% arquivos
) else (
    echo Total: %GLOBAL_DIR_COUNT% diretorios, %GLOBAL_FILE_COUNT% arquivos
)
exit /b 0

:print_tree
setlocal enabledelayedexpansion
set "current_path=%~1"
set "prefix=%~2"
set "depth=%~3"
if %depth% gtr %MAX_DEPTH% exit /b 0

set "dir_attr=/ad"
set "file_attr=/a-d"
if "%SHOW_HIDDEN%"=="0" (
    set "dir_attr=/ad-h-s"
    set "file_attr=/a-d-h-s"
)

:: --- Coleta Diretórios (só se relevantes quando há PATTERN) ---
set "dir_index=0"
if "%FILES_ONLY%"=="0" (
    for /f "delims=" %%D in ('dir /b /on !dir_attr! "%current_path%" 2^>nul') do (
        set "dir_name=%%D"
        set "full_dir_path=%current_path%\!dir_name!"
        set "skip_dir=0"
        if defined EXCLUDE (
            echo !dir_name! | findstr /i /c:"%EXCLUDE%" >nul 2>&1
            if not errorlevel 1 set "skip_dir=1"
        )
        if "!skip_dir!"=="0" (
            set "include_dir=1"
            if defined PATTERN (
                set /a remaining_depth=!MAX_DEPTH!-!depth!-1
                if !remaining_depth! lss 0 set "remaining_depth=0"
                call :contains_pattern "!full_dir_path!" "%PATTERN%" !remaining_depth!
                if errorlevel 1 set "include_dir=0"
            )
            if "!include_dir!"=="1" (
                set /a dir_index+=1
                set "dir_list[!dir_index!]=!dir_name!"
                set "dir_path[!dir_index!]=!full_dir_path!"
            )
        )
    )
)

:: --- Coleta Arquivos SOMENTE se corresponderem ao PATTERN (ou todos se não houver PATTERN) ---
set "file_index=0"
if "%DIRS_ONLY%"=="0" (
    set "file_pattern=*"
    if defined PATTERN (
        set "file_pattern=!PATTERN!"
    )
    for /f "delims=" %%F in ('dir /b /on !file_attr! "%current_path%\!file_pattern!" 2^>nul') do (
        set "file_name=%%F"
        set "full_file_path=%current_path%\!file_name!"
        set "skip_file=0"
        if defined EXCLUDE (
            echo !file_name! | findstr /i /c:"!EXCLUDE!" >nul 2>&1
            if not errorlevel 1 set "skip_file=1"
        )
        if "!skip_file!"=="0" (
            set /a file_index+=1
            set "file_list[!file_index!]=!file_name!"
        )
    )
)


:: --- Se não há itens visíveis neste nível e não é raiz, não imprime nada ---
set /a total_items=!dir_index! + !file_index!
if !total_items! equ 0 if %depth% gtr 0 exit /b 0

set "item_index=0"

:: --- Imprime Diretórios ---
for /L %%i in (1,1,!dir_index!) do (
    set /a item_index+=1
    set "item_name=!dir_list[%%i]!"
    set "item_path=!dir_path[%%i]!"
    if !item_index!==!total_items! (
        echo !prefix!└───!item_name!
        set "next_prefix=!prefix!    "
    ) else (
        echo !prefix!├───!item_name!
        set "next_prefix=!prefix!│   "
    )
    set /a GLOBAL_DIR_COUNT+=1
    set /a next_depth=!depth!+1
    call :print_tree "!item_path!" "!next_prefix!" !next_depth!
)

:: --- Imprime Arquivos ---
for /L %%i in (1,1,!file_index!) do (
    set /a item_index+=1
    set "item_name=!file_list[%%i]!"
    if !item_index!==!total_items! (
        echo !prefix!└───!item_name!
    ) else (
        echo !prefix!├───!item_name!
    )
    set /a GLOBAL_FILE_COUNT+=1
)

endlocal & set "GLOBAL_DIR_COUNT=%GLOBAL_DIR_COUNT%" & set "GLOBAL_FILE_COUNT=%GLOBAL_FILE_COUNT%"
exit /b 0

:contains_pattern
setlocal
set "check_dir=%~1"
set "check_pattern=%~2"
set "remaining_depth=%~3"
set "dir_attr=/ad"
set "file_attr=/a-d"
if "%SHOW_HIDDEN%"=="0" (
    set "dir_attr=/ad-h-s"
    set "file_attr=/a-d-h-s"
)
:: Verifica arquivos matching no diretório atual
for /f "delims=" %%F in ('dir /b !file_attr! "%check_dir%\%check_pattern%" 2^>nul') do (
    endlocal
    exit /b 0
)
:: Recursão em subdiretórios
if %remaining_depth% gtr 0 (
    set /a next_remaining=%remaining_depth%-1
    for /f "delims=" %%D in ('dir /b !dir_attr! "%check_dir%" 2^>nul') do (
        call :contains_pattern "%check_dir%\%%D" "%check_pattern%" !next_remaining!
        if !errorlevel!==0 (
            endlocal
            exit /b 0
        )
    )
)
endlocal
exit /b 1