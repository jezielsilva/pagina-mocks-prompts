# Instalar a equipe de subagentes no Claude Code (PC pessoal)

Rode no **PowerShell** do PC pessoal. Ajuste `$skillsOrigem` se a pasta de skills for outra.

## 1. Baixar o pacote do portal
```powershell
$base = "https://raw.githubusercontent.com/jezielsilva/pagina-mocks-prompts/main/claude-pack"
$dest = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force "$dest\agents","$dest\skills" | Out-Null
if (Test-Path "$dest\CLAUDE.md") { Copy-Item "$dest\CLAUDE.md" "$dest\CLAUDE.md.bak" -Force }
Invoke-WebRequest "$base/CLAUDE.md" -OutFile "$dest\CLAUDE.md"
foreach ($a in "leitor","arquiteto","back","front","testes","verificador","revisor") {
  Invoke-WebRequest "$base/agents/$a.md" -OutFile "$dest\agents\$a.md"
}
```

## 2. Ver quais skills existem
```powershell
$skillsOrigem = "C:\skills"
Get-ChildItem $skillsOrigem -Recurse -Filter "SKILL.md" | ForEach-Object { $_.Directory.Name }
```
Mande essa lista no chat para fechar o mapeamento.

## 3. Copiar só as skills usadas pela equipe
```powershell
$usadas = "grilling","to-spec","domain-modeling","diagnosing-bugs","research","solution-architect",
  "codebase-design","backend-architect","frontend-architect","responsividade","apple-design",
  "frontend-design","teste-back","vitest","code-review","architecture-reviewer","advogado-especialista","lawyer-expert"
foreach ($s in $usadas) {
  $dir = Get-ChildItem $skillsOrigem -Recurse -Directory -Filter $s | Select-Object -First 1
  if ($dir) { Copy-Item $dir.FullName "$dest\skills\$s" -Recurse -Force; "OK  $s" } else { "--  $s (não encontrada)" }
}
```

## 4. Conferir
Abra o Claude Code e digite `/agents`: devem aparecer os 7 agentes. Skills ficam em `~/.claude/skills`.

## 5. Preferências do claude.ai
Troque o texto das preferências pessoais por:
> Siga o `~/.claude/CLAUDE.md` (equipe de subagentes, estilo de código, entrega com Explicações). Banco é sempre meu. Nunca rodar lint.
