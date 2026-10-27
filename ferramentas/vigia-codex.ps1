<#
  Vigia do portal -> Codex
  - Faz git pull no portal a cada execução (o Agendador chama a cada 2 min).
  - Achou prompt novo com "executar": true no itens.json -> abre uma janela do Codex já com o prompt.
  - Quando o Codex salva a entrega em retornos\<id>.md -> abre uma Issue no portal com o conteúdo.
  Uso:
    .\vigia-codex.ps1            (roda uma vez — é o que o Agendador chama)
    .\vigia-codex.ps1 -Instalar  (cria a tarefa no Agendador, a cada 2 minutos)
    .\vigia-codex.ps1 -Remover   (remove a tarefa)
#>
param([switch]$Instalar, [switch]$Remover)

# ===== Configuração (caminhos do Jeziel) =====
$Portal   = 'C:\Users\jeziel.santos\Documents\Portal Claude\pagina-mocks-prompts'
$Projetos = 'C:\Users\jeziel.santos\elawadv'          # contém web-proadv e api-proadv
$Repo     = 'jezielsilva/pagina-mocks-prompts'
$Base     = Join-Path $env:USERPROFILE 'vigia-codex'   # estado local (fora do portal)
$Retornos = Join-Path $Base 'retornos'
$Enviados = Join-Path $Base 'enviados'
$Estado   = Join-Path $Base 'executados.txt'
$Log      = Join-Path $Base 'vigia.log'
$Tarefa   = 'Vigia Codex (portal)'

# Cria as pastas de trabalho
foreach ($p in @($Base, $Retornos, $Enviados)) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }
if (-not (Test-Path $Estado)) { New-Item -ItemType File -Path $Estado | Out-Null }

# Escreve uma linha no log com data/hora
function Registrar($texto) { Add-Content -Path $Log -Value ("{0:yyyy-MM-dd HH:mm:ss}  {1}" -f (Get-Date), $texto) }

# ===== Instalar / remover a tarefa agendada =====
if ($Instalar) {
    $acao    = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $gatilho = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 2)
    $config  = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable
    Register-ScheduledTask -TaskName $Tarefa -Action $acao -Trigger $gatilho -Settings $config -Force | Out-Null
    Write-Host "Tarefa '$Tarefa' instalada (a cada 2 minutos, só com você logado)."
    return
}
if ($Remover) {
    Unregister-ScheduledTask -TaskName $Tarefa -Confirm:$false
    Write-Host "Tarefa '$Tarefa' removida."
    return
}

# ===== 1) Atualiza o portal =====
git -C $Portal pull -q 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Registrar 'git pull falhou'; return }

# ===== 2) Retornos prontos -> Issue no portal =====
foreach ($arquivo in Get-ChildItem -Path $Retornos -Filter '*.md') {
    $id = $arquivo.BaseName
    gh issue create --repo $Repo --title "Retorno Codex: $id" --body-file $arquivo.FullName | Out-Null
    if ($LASTEXITCODE -ne 0) { Registrar "falhou ao abrir issue de $id"; continue }
    Move-Item -Path $arquivo.FullName -Destination (Join-Path $Enviados ("{0}-{1:yyyyMMddHHmm}.md" -f $id, (Get-Date))) -Force
    Registrar "issue aberta: $id"
}

# ===== 3) Prompt novo para executar? =====
$indice = Get-Content -Path (Join-Path $Portal 'itens.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$executados = Get-Content -Path $Estado
$pendentes = $indice.itens | Where-Object { $_.tipo -eq 'prompt' -and $_.executar -eq $true }

foreach ($item in $pendentes) {
    # Chave = id + data: se eu republicar o mesmo prompt com data nova, ele roda de novo
    $chave = "$($item.id)|$($item.data)"
    if ($executados -contains $chave) { continue }

    # Já existe um Codex rodando um prompt (retorno ainda não chegou)? Espera.
    $emAndamento = Join-Path $Base 'em-andamento.txt'
    if (Test-Path $emAndamento) {
        $atual = Get-Content $emAndamento
        $retornoAtual = Join-Path $Retornos "$atual.md"
        $jaEnviado = Get-ChildItem -Path $Enviados -Filter "$atual-*.md" -ErrorAction SilentlyContinue
        if (-not (Test-Path $retornoAtual) -and -not $jaEnviado) { Registrar "aguardando retorno de $atual"; return }
        Remove-Item $emAndamento
    }

    $arquivoPrompt = Join-Path $Portal $item.arquivo
    if (-not (Test-Path $arquivoPrompt)) { Registrar "arquivo não encontrado: $($item.arquivo)"; continue }
    $arquivoRetorno = Join-Path $Retornos "$($item.id).md"

    # Mensagem curta para o Codex: ele lê o prompt inteiro do arquivo (evita limite de tamanho da linha de comando)
    $mensagem = "Leia e execute integralmente as instruções do arquivo '$arquivoPrompt'. " +
                "Os projetos ficam em '$Projetos' (web-proadv e api-proadv). " +
                "Ao terminar (inclusive se parar por erro ou precisar de aprovação minha), salve a ENTREGA completa em markdown no arquivo '$arquivoRetorno'."

    # Abre uma janela nova com o Codex interativo (você acompanha tudo; /app leva a sessão para o app desktop)
    $comando = "Set-Location '$Projetos'; codex -C '$Projetos' `"$($mensagem.Replace('"','\"'))`""
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $comando)

    Add-Content -Path $Estado -Value $chave
    Set-Content -Path $emAndamento -Value $item.id
    Registrar "Codex iniciado: $($item.id)"
    return   # um prompt por vez
}
