# SCRIPT DE GERENCIAMENTO DE DADOS DO MYSQL (XAMPP)

# --- CONFIGURAÇÕES ---
# Defina o caminho base do XAMPP MySQL.
# Modifique esta linha caso seu diretório de instalação seja diferente.
$basePath = "C:\xampp\mysql"

# Crie um array de itens a serem EXCLUÍDOS da cópia.
$excludedItems = @(
    # Arquivos a serem excluídos
    "aria_log.00000001",
    "aria_log_control",
    "ib_buffer_pool",
    "ib_logfile0",
    "ib_logfile1",
    "multi-master.info",
    "my.ini",
    "mysql.pid",
    "mysql_error.log",

    # Pastas a serem excluídas
    "mysql",
    "performance_schema",
    "phpmyadmin",
    "test"
)

# --- FUNÇÃO PRINCIPAL DO SCRIPT ---
function GerenciarMySQLData {
    Set-Location -Path $basePath

    Write-Host "Verificando diretórios em: $basePath..." -ForegroundColor Yellow

    # 1. Encontrar o próximo número sequencial
    $existingOldDataFolders = Get-ChildItem -Path . -Directory | Where-Object { $_.Name -match "data_old(\d+)" }
    $nextSequence = 1
    if ($existingOldDataFolders) {
        $maxSequence = ($existingOldDataFolders | ForEach-Object { [int]($_.Name -replace "data_old") } | Sort-Object -Descending | Select-Object -First 1)
        $nextSequence = $maxSequence + 1
    }

    $newOldDataName = "data_old$nextSequence"
    Write-Host "O próximo nome sequencial para o backup sera: $newOldDataName" -ForegroundColor Green

    # 2. Renomear 'data' para o novo nome sequencial
    if (Test-Path -Path ".\data" -PathType Container) {
        Write-Host "Renomeando 'data' para '$newOldDataName'..."
        Rename-Item -Path ".\data" -NewName $newOldDataName -Force
        Write-Host "Renomeacao concluida." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'data' nao foi encontrada. Verifique o caminho." -ForegroundColor Red
        return
    }

    # 3. Criar uma cópia da pasta 'backup' (para segurança, antes de renomeá-la)
    if (Test-Path -Path ".\backup" -PathType Container) {
        Write-Host "Criando uma copia da pasta 'backup'..."
        Copy-Item -Path ".\backup" -Destination ".\backup_temp" -Recurse -Force
        Write-Host "Copia de 'backup' criada em 'backup_temp'." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'backup' nao foi encontrada. Verifique se o backup esta pronto." -ForegroundColor Red
        return
    }

    # 4. Renomear 'backup' para 'data'
    if (Test-Path -Path ".\backup" -PathType Container) {
        Write-Host "Renomeando 'backup' para 'data'..."
        Rename-Item -Path ".\backup" -NewName "data" -Force
        Write-Host "Renomeacao concluida." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'backup' nao foi encontrada. Verifique o caminho." -ForegroundColor Red
        return
    }

    # 5. Copiar o conteudo da pasta antiga para a nova, excluindo itens especificos
    Write-Host "Copiando o conteudo de '$newOldDataName' para 'data' (excluindo itens criticos)..."
    $itemsToCopy = Get-ChildItem -Path ".\$newOldDataName" -Force
    foreach ($item in $itemsToCopy) {
        if ($excludedItems -notcontains $item.Name) {
            if ($item.PSIsContainer -eq $false) {
                Copy-Item -Path $item.FullName -Destination ".\data\" -Force
            } else {
                Copy-Item -Path $item.FullName -Destination ".\data\" -Recurse -Force
            }
        }
    }
    Write-Host "Processo de copia concluido." -ForegroundColor Green

    # A LINHA QUE APAGAVA A PASTA TEMPORÁRIA FOI REMOVIDA AQUI.
    # A pasta "backup_temp" agora deve ser apagada manualmente para garantir total segurança.

    Write-Host "Script finalizado com sucesso! O novo diretorio 'data' esta pronto." -ForegroundColor Green
}

GerenciarMySQLData