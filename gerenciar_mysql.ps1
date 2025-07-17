# SCRIPT DE GERENCIAMENTO DE DADOS DO MYSQL (XAMPP)

# --- CONFIGURAÇÕES ---
# Defina o caminho base do XAMPP MySQL.
# Modifique esta linha caso seu diretório de instalação seja diferente.
$basePath = "C:\xampp\mysql"

# Crie um array de itens a serem EXCLUÍDOS da cópia.
# Isso garante que arquivos e pastas críticos do sistema MySQL não sejam sobrescritos.
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

    # Pastas a serem excluídas (o asterisco * garante a exclusão de todo o seu conteúdo)
    "mysql",
    "performance_schema",
    "phpmyadmin",
    "test"
)

# --- FUNÇÃO PRINCIPAL DO SCRIPT ---
function GerenciarMySQLData {
    # Altere o diretório para o caminho do MySQL
    Set-Location -Path $basePath

    Write-Host "Verificando diretórios em: $basePath..." -ForegroundColor Yellow

    # 1. Encontrar o próximo número sequencial para a pasta 'data_old'
    # Esta linha encontra todas as pastas que seguem o padrão "data_old<numero>" e extrai o maior número.
    $existingOldDataFolders = Get-ChildItem -Path . -Directory | Where-Object { $_.Name -match "data_old(\d+)" }
    $nextSequence = 1
    if ($existingOldDataFolders) {
        $maxSequence = ($existingOldDataFolders | ForEach-Object { [int]($_.Name -replace "data_old") } | Sort-Object -Descending | Select-Object -First 1)
        $nextSequence = $maxSequence + 1
    }

    $newOldDataName = "data_old$nextSequence"
    Write-Host "O próximo nome sequencial para a pasta de backup será: $newOldDataName" -ForegroundColor Green

    # 2. Renomear a pasta 'data' para o novo nome sequencial
    if (Test-Path -Path ".\data" -PathType Container) {
        Write-Host "Renomeando 'data' para '$newOldDataName'..."
        Rename-Item -Path ".\data" -NewName $newOldDataName -Force
        Write-Host "Renomeação concluída." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'data' não foi encontrada. Verifique o caminho." -ForegroundColor Red
        return
    }

    # 3. Criar uma cópia da pasta 'backup'
    # Esta é a sua etapa de segurança, criando um 'snapshot' do backup antes de renomeá-lo.
    if (Test-Path -Path ".\backup" -PathType Container) {
        Write-Host "Criando uma cópia da pasta 'backup'..."
        Copy-Item -Path ".\backup" -Destination ".\backup_temp" -Recurse -Force
        Write-Host "Cópia de 'backup' criada em 'backup_temp'." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'backup' não foi encontrada. Verifique se o backup está pronto." -ForegroundColor Red
        return
    }

    # 4. Renomear a pasta 'backup' para 'data'
    if (Test-Path -Path ".\backup" -PathType Container) {
        Write-Host "Renomeando 'backup' para 'data'..."
        Rename-Item -Path ".\backup" -NewName "data" -Force
        Write-Host "Renomeação concluída." -ForegroundColor Green
    } else {
        Write-Host "A pasta 'backup' não foi encontrada. Verifique o caminho." -ForegroundColor Red
        return
    }

    # 5. Copiar o conteúdo da pasta 'data_old<n>' para 'data', excluindo itens específicos
    Write-Host "Copiando o conteúdo de '$newOldDataName' para 'data' (excluindo itens críticos)..."
    
    # Loop pelos itens da pasta antiga e copia apenas o que não está na lista de exclusão
    $itemsToCopy = Get-ChildItem -Path ".\$newOldDataName" -Force
    foreach ($item in $itemsToCopy) {
        # Verifica se o nome do item NÃO está na lista de exclusão
        if ($excludedItems -notcontains $item.Name) {
            # Se for um arquivo, copia o arquivo.
            if ($item.PSIsContainer -eq $false) {
                Write-Host "  -> Copiando arquivo: $($item.Name)"
                Copy-Item -Path $item.FullName -Destination ".\data\" -Force
            }
            # Se for uma pasta, copia a pasta inteira de forma recursiva.
            else {
                Write-Host "  -> Copiando pasta: $($item.Name)"
                Copy-Item -Path $item.FullName -Destination ".\data\" -Recurse -Force
            }
        }
        else {
            Write-Host "  -> Pulando item excluído: $($item.Name)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "Processo de cópia concluído." -ForegroundColor Green

    # Limpeza
    # Remove a pasta de backup temporária que foi criada no passo 3.
    Remove-Item -Path ".\backup_temp" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Script finalizado com sucesso! O novo diretório 'data' agora contém os arquivos e pastas corretos." -ForegroundColor Green
}

# Inicia a execução do script
GerenciarMySQLData