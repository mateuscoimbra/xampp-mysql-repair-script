# XAMPP MySQL Repair Script

## ⚠️ Atenção\!

**Sempre faça um backup completo** do seu diretório `C:\xampp\mysql` antes de executar qualquer script que modifique seus arquivos de banco de dados. Este script é uma ferramenta poderosa e, embora segura quando usada corretamente, a cautela é a sua melhor aliada.

## 📝 O Problema

Muitos desenvolvedores que usam o XAMPP se deparam com o seguinte erro no painel de controle, impedindo que o MySQL seja iniciado:

```
00:00:00  [mysql]   Error: MySQL shutdown unexpectedly.
00:00:00  [mysql]   This may be due to a blocked port, missing dependencies, 
00:00:00  [mysql]   improper privileges, a crash, or a shutdown by another method.
00:00:00  [mysql]   Press the Logs button to view error logs and check
00:00:00  [mysql]   the Windows Event Viewer for more clues
00:00:00  [mysql]   If you need more help, copy and post this
00:00:00  [mysql]   entire log window on the forums
```

Esse problema é frequentemente causado por uma corrupção nos arquivos de log do banco de dados (como os arquivos `ib_logfile` e `aria_log`) ou em arquivos de sistema do MySQL. A solução manual é tediosa e propensa a erros: mover a pasta `data`, usar um backup, e então copiar de volta as tabelas de dados.

Este script automatiza esse processo de forma segura e confiável.

## 🚀 A Solução

O script realiza as seguintes ações de forma automatizada:

1.  **Backup Sequencial**: Renomeia o diretório `C:\xampp\mysql\data` para `data_old<NÚMERO>`, onde o `<NÚMERO>` é o próximo na sequência (ex: `data_old1`, `data_old2`, etc.), criando um backup histórico do estado do seu MySQL antes da falha.
2.  **Restauração Rápida**: Renomeia a sua pasta de backup (`C:\xampp\mysql\backup`) para `data`, restaurando um conjunto limpo de arquivos de sistema do MySQL.
3.  **Mesclagem Inteligente**: Copia todos os seus bancos de dados e tabelas da pasta de backup (`data_old<NÚMERO>`) para a nova pasta `data`.
4.  **Exclusão Seletiva**: Ignora e **não copia** arquivos e pastas que são conhecidos por causar corrupção ou que são criados automaticamente pelo MySQL, como arquivos de log e pastas de sistema (`mysql`, `performance_schema`, etc.).

### Itens que NÃO são copiados:

**Arquivos:**

  * `aria_log.00000001`
  * `aria_log_control`
  * `ib_buffer_pool`
  * `ib_logfile0`
  * `ib_logfile1`
  * `multi-master.info`
  * `my.ini`
  * `mysql.pid`
  * `mysql_error.log`

**Pastas:**

  * `mysql`
  * `performance_schema`
  * `phpmyadmin`
  * `test`

## ⚙️ Como Usar

### Pré-requisitos

  * Uma instalação do **XAMPP** no diretório padrão (`C:\xampp`).
  * Uma cópia limpa do diretório `C:\xampp\mysql\data` salva em `C:\xampp\mysql\backup`. Se você não tem uma, basta copiar a pasta `data` de uma nova instalação do XAMPP para a pasta `backup`.

### Instruções

1.  Baixe o arquivo de script. Você pode escolher entre a versão em **PowerShell (.ps1)** ou a versão em **Batch (.bat)**.
2.  Coloque o arquivo de script (`.ps1` ou `.bat`) diretamente no diretório `C:\xampp\mysql`.
3.  **Feche o XAMPP Control Panel.** Certifique-se de que nenhum serviço do XAMPP esteja em execução.
4.  Execute o script com **privilégios de administrador**.
      * **Para `.bat`**: Clique com o botão direito no arquivo `gerenciar_mysql.bat` e selecione **"Executar como administrador"**.
      * **Para `.ps1`**: Clique com o botão direito no arquivo `gerenciar_mysql.ps1` e selecione **"Executar com o PowerShell"**.
5.  O script exibirá o progresso no console. Aguarde a mensagem de "Script finalizado com sucesso\!".
6.  Abra o XAMPP Control Panel e inicie o MySQL. Se o processo for bem-sucedido, o problema estará resolvido.

## 🤝 Contribuições

Sinta-se à vontade para abrir uma *issue* para relatar um problema ou enviar uma *pull request* com melhorias.

-----

**Autor:** mateuscoimbra
