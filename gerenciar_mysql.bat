@echo off
setlocal enabledelayedexpansion

REM Define o caminho base do XAMPP MySQL.
set "BASE_PATH=C:\xampp\mysql"

REM -------------------------------------------------------------
REM 1. NAVEGA ATÉ O DIRETÓRIO
REM -------------------------------------------------------------
if not exist "%BASE_PATH%" (
    echo ERRO: O diretorio %BASE_PATH% nao foi encontrado.
    pause
    exit /b
)
cd /d "%BASE_PATH%"
echo Diretorio de trabalho definido para: %BASE_PATH%

REM -------------------------------------------------------------
REM 2. IDENTIFICA O PROXIMO SEQUENCIAL
REM -------------------------------------------------------------
set "NEXT_SEQ=0"
for /d %%D in (data_old*) do (
    set "FOLDER_NAME=%%D"
    set "CURRENT_SEQ=!FOLDER_NAME:data_old=!"
    if !CURRENT_SEQ! gtr !NEXT_SEQ! (
        set "NEXT_SEQ=!CURRENT_SEQ!"
    )
)
set /a NEXT_SEQ+=1
echo O proximo sequencial para a pasta de backup e: data_old%NEXT_SEQ%

REM -------------------------------------------------------------
REM 3. RENOVA A PASTA "data" PARA O PROXIMO SEQUENCIAL
REM -------------------------------------------------------------
if not exist "data\" (
    echo ERRO: A pasta "data" nao foi encontrada.
    pause
    exit /b
)
echo Renomeando "data" para "data_old%NEXT_SEQ%"...
ren "data" "data_old%NEXT_SEQ%"
if not exist "data_old%NEXT_SEQ%\" (
    echo ERRO: Falha ao renomear "data".
    pause
    exit /b
)
echo Renomeacao concluida.

REM -------------------------------------------------------------
REM 4. RENOVA A PASTA "backup" PARA "data"
REM -------------------------------------------------------------
if not exist "backup\" (
    echo ERRO: A pasta "backup" nao foi encontrada.
    pause
    exit /b
)
echo Renomeando "backup" para "data"...
ren "backup" "data"
if not exist "data\" (
    echo ERRO: Falha ao renomear "backup".
    pause
    exit /b
)
echo Renomeacao concluida.

REM -------------------------------------------------------------
REM 5. COPIA O CONTEUDO DA PASTA ANTIGA PARA A NOVA, EXCLUINDO ITENS
REM -------------------------------------------------------------
echo Copiando conteudo da pasta "data_old%NEXT_SEQ%" para "data"...
echo Itens a serem excluidos:
echo Arquivos: aria_log*, ib_buffer_pool, ib_logfile*, multi-master.info, my.ini, mysql.pid, mysql_error.log
echo Pastas: mysql, performance_schema, phpmyadmin, test

REM Use ROBOCOPY para copiar tudo, exceto os itens especificados.
REM /E: Copia subdiretorios, incluindo os vazios.
REM /XF: Exclui arquivos.
REM /XD: Exclui diretorios.
robocopy "data_old%NEXT_SEQ%" "data" /E /XF aria_log.00000001 aria_log_control ib_buffer_pool ib_logfile0 ib_logfile1 multi-master.info my.ini mysql.pid mysql_error.log /XD mysql performance_schema phpmyadmin test
if %errorlevel% geq 8 (
    echo ERRO: Falha na copia de arquivos. O ROBOCOPY retornou um erro.
    pause
    exit /b
)

echo Processo de copia concluido.

echo.
echo Script finalizado com sucesso! O novo diretorio "data" esta pronto.
pause