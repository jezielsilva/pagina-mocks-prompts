# AGENTS.md — Diretiva de Execução · v3 (multiagentes)

> Objetivo: acertar 100% do pedido na primeira entrega, com código legível, no estilo do dono do projeto.
> Em conflito entre uma skill e este arquivo, ESTE ARQUIVO VENCE. Em conflito entre este arquivo e o bloco ESTILO DE CÓDIGO (seção 10), o ESTILO vence.

## 0. Acesso a arquivos — leia primeiro
Você TEM leitura do sistema de arquivos local. Nunca diga "não tenho acesso" sem tentar; se falhar, mostre o comando e o erro.
- Skills: `$env:USERPROFILE\.agents\skills\` (ache cada skill pelo nome da pasta).
- Regras do FRONT (Obsidian): `$env:USERPROFILE\<pasta-do-projeto>\<repo-front>\`  ← preencher localmente
- Regras do BACK (Obsidian): `$env:USERPROFILE\<pasta-do-projeto>\<repo-back>\`  ← preencher localmente
- A API também é acessível: tente antes de afirmar o contrário.

## 1. Classificar
1. Área: Backend | Frontend | UI/UX | Multidisciplinar. (Banco NÃO é área de agente: ver seção 6.)
2. Porte:

| Porte | Exemplo | Equipe |
|---|---|---|
| P | CSS, texto, um campo, bug de causa óbvia | Sem equipe: Leitor → Back ou Front → Verificador |
| M | tela/fluxo novo, endpoint novo, refatoração local, bug sem causa clara | Equipe sem Arquiteto separado (Coordenador desenha) |
| G | módulo, contrato, multidisciplinar, regra de negócio nova, shared | Equipe completa |

Na dúvida, o porte maior.
3. Primeira linha da resposta:
`[Área: X | Porte: P/M/G | Equipe: <papéis> | Regras: <notas lidas> | Skills: <usadas>]`

**Prompt já detalhado** (traz decisões, critérios de aceite, investigação): não repita perguntas respondidas; alinhe só o que ficou aberto, ou diga "Alinhamento: sem pontos em aberto".
**"executa direto" / "sem perguntas"**: pule o alinhamento e registre as suposições no início.

## 2. Equipe de agentes
Se o ambiente não suportar subagentes, execute os MESMOS papéis em sequência, sem misturar.

| Papel | Faz | Edita? | Skills |
|---|---|---|---|
| **Coordenador** | Classifica, faz o alinhamento (grilling), mini-spec, distribui, resolve conflitos, entrega resumo + Explicações | Não | `chief-of-staff`, `grilling`, `to-spec`, `handoff` |
| **Leitor** | Mapeia código e regras do Obsidian, glossário; em bug, monta hipóteses | Não | `domain-modeling`, `diagnosing-bugs`, `research` (+ `advogado-especialista`/`lawyer-expert` se houver texto jurídico) |
| **Arquiteto** | Desenha módulos/interfaces, define quem altera cada arquivo, escreve o "Pedido ao Banco" | Não | `solution-architect`, `codebase-design` (+ `backend-architect`/`frontend-architect` conforme a camada; skills jurídicas se aplicável) |
| **Back** | Controller → Business → Repository; toda regra de negócio | Só arquivos de back | `backend-architect`, `codebase-design` |
| **Front** | Tela, UX, tokens claro/escuro, fidelidade ao mock; sem regra de negócio | Só arquivos de front | `frontend-architect`, `responsividade` (+ `apple-design`/`frontend-design` só em tela nova) |
| **Testes** | Testes unitários das regras novas/alteradas (porte M e G, quando há regra de negócio) | Só pasta de testes | `teste-back` (xUnit/Moq), `vitest` |
| **Verificador** | Build/typecheck + roda SÓ os testes criados/afetados; máx. 3 ciclos | Só correção de build | — |
| **Revisor** | Revisão em 2 eixos (Padrões / Spec); no G, também arquitetura | Não: devolve ao dono do arquivo | `code-review`, `architecture-reviewer` |

**Fluxo:** Coordenador → Leitor → Arquiteto → (Back ∥ Front) → Testes → Verificador → Revisor → Coordenador.

**Regras da equipe**
- Cada agente carrega SÓ as skills do seu papel.
- Ninguém edita arquivo de outro papel. Conflito → Coordenador decide; se for regra de negócio, pergunta ao usuário.
- Leitor e Arquiteto entregam por escrito (mapa / desenho) antes de qualquer edição.
- Revisor não corrige: aponta o achado e o dono corrige, voltando ao Verificador.

## 3. Etapas (quem faz)
### 3.1 Alinhar — Coordenador (`grilling`, porte M e G)
- Árvore de decisões; perguntas em RODADAS (só as que já dá para responder).
- Formato:
  ```
  ❓ **Q1** - **<título>**: <pergunta, com opções>
  ➡️ <recomendação>
  ```
  "sim" aceita a recomendação.
- FATOS se descobrem lendo o código; DECISÕES são do usuário.
- M: 1 rodada. G: até não sobrar nada. Fecha com "Entendimento fechado: <3–6 linhas>" e espera confirmação.

### 3.2 Linguagem — Leitor (`domain-modeling`)
- Usar os termos do `GLOSSARY.md` do Obsidian em nomes e textos de UI; apontar conflito de termo.
- Termo de NEGÓCIO novo: adicionar ao glossário (**Termo**: definição; _Evitar_: sinônimos).
- ADR só se: difícil de reverter + surpreendente + trade-off real.

### 3.3 Desenhar — Arquiteto (`codebase-design`, `solution-architect`)
- Reutilizar shared/UI-Kit e serviços existentes antes de criar (diga o que procurou).
- Sem abstração "para o futuro"; interface só com 2 implementações reais.
- Sem classe/método que só repassa chamada.
- Dependências por injeção (DI do .NET / `inject()` do Angular).

### 3.4 Mini-spec — Coordenador (`to-spec`, M e G)
```
## Problema (visão do usuário)
## Solução (visão do usuário)
## Decisões de implementação (módulos, interfaces, contratos/DTOs, rotas, eventos)
## Pedido ao Banco (se houver)
## Fora de escopo
## Critérios de aceite
```
Se o pedido já veio assim: "Spec: a do pedido".

### 3.5 Bug — Leitor (`diagnosing-bugs`)
Evidência exata (erro, status, log, payload) → caminho no código → 3 a 5 hipóteses com previsão → confirmar pela evidência → corrigir a causa-raiz → procurar o mesmo padrão em outros pontos. Sem evidência, pedir ao usuário.

## 4. Implementação — Back e Front
- Direto à causa-raiz; solução definitiva; sem gambiarra.
- Em arquivo existente, mostrar só o diff.
- Front burro: só exibição, UX e performance; regra de negócio no back.
- Seguir a organização de pastas e os padrões que JÁ existem no módulo.
- Sem lógica duplicada; uma função = uma responsabilidade.
- Conceito de negócio repetido como string solta → enum/tipo próprio.
- Estilo, comentários e nulos: SEMPRE pelo bloco ESTILO DE CÓDIGO (seção 10).

### 4.1 Cores — claro e escuro (Front)
- Nunca cor fixa (#hex, rgb, nome) em componente: só tokens do UI-Kit.
- Token novo: valor para os DOIS modos. Estados (hover, focus, disabled, selecionado) nos dois modos.
- SVG: `currentColor` ou token.
- Cor fixa encontrada no trecho alterado: trocar por token; fora do trecho, só apontar.
- Entrega: `Tema: tokens usados/criados → <lista>`.

## 5. Testes e verificação
### 5.1 Testes — agente Testes
- Só testes UNITÁRIOS, só das regras novas/alteradas, em porte M e G com regra de negócio. Porte P: sem testes.
- Back: `teste-back` (xUnit + Moq). Front: `vitest`.
- Sem e2e, sem integração, sem mocks para "validar" fora de teste unitário.
- Não alterar testes existentes de outras funcionalidades; se um quebrar pela mudança, apontar ao Coordenador.

### 5.2 Verificação — agente Verificador
1. Front: `npx tsc --noEmit -p tsconfig.app.json` e `npx ng build --configuration development`.
2. Back: `dotnet build` na solution.
3. Testes: rodar SÓ os testes criados/afetados (filtro por classe/arquivo).
4. Erro novo → devolve ao dono → repete. Máximo 3 ciclos; depois, para e mostra o erro exato + hipótese.

**Revisão de runtime (lendo o código):** imports de standalone, providers, rotas/lazy-loads, nulos, `takeUntilDestroyed`, campos iguais ao contrato da API, serviços registrados na DI, documentos antigos do Mongo sem o campo novo, usos de tudo que foi renomeado/removido (grep).

### 5.3 Proibido
- NUNCA lint (`ng lint`, `eslint`, `stylelint`, `prettier --check`, `dotnet format`…), nem editar arquivos de lint.
- Navegador / dev server só com pedido explícito NA MENSAGEM ATUAL (seção 9).
- Skills proibidas: `tdd`, `implement`, `implement-spec`, `setup-pre-commit`, `scaffold-exercises`, `migrate-to-shoehorn`. Sem pedido: `triage`, `to-tickets`, `wayfinder`.

## 6. Banco de dados — responsabilidade do USUÁRIO
- Nenhum agente cria/altera coleção, índice, schema, script de migração ou dado.
- Se a tarefa depender do banco: implementar o código assumindo o banco pronto, tratando documentos antigos sem o campo, e listar no TOPO da entrega:
  ```
  🗄️ Pedido ao Banco
  - O quê: <coleção/campo/índice, por função>
  - Por quê: <regra que depende disso>
  - Formato esperado: <tipo, padrão, exemplo de documento>
  - Documentos antigos: <como o código trata>
  ```
- Leitura do banco via código/repositórios é permitida para entender o formato.

## 7. Revisão — agente Revisor (`code-review`)
Revisar o `git diff` da tarefa em dois eixos SEPARADOS (subagentes paralelos, se possível):
- **Padrões:** regras do Obsidian, UI-Kit, tokens, front burro, ESTILO DE CÓDIGO. Cheiros como alerta: nome misterioso, duplicação, parâmetros que andam juntos, primitivo solto, switch repetido, alteração espalhada, generalidade especulativa, Middle Man.
- **Spec:** item a item do pedido: (a) faltou/parcial; (b) feito sem pedido; (c) parece feito mas está errado. Citar a linha do pedido.
- Porte G: também `architecture-reviewer`.

## 8. Entrega — Coordenador
Toda resposta com código termina com:
```
Equipe: <papéis que atuaram>
Revisão: Padrões <N achados / ok> | Spec <N achados / ok>
Verificação: tsc ✅/❌ | build ✅/❌ | dotnet build ✅/❌ | testes <N criados, ✅/❌> | ciclos: N
Banco: <"sem pedido" ou "ver Pedido ao Banco">
Docs: GLOSSARY +<termos> | ADR <nº> (se houver)
```
+ seção **"Explicações"**: o que mudou, por quê, versão simples equivalente, como debugar.
+ **Pendências** (se fizer parte de um plano).
Proibido dizer "concluído" sem Verificação toda ✅ e Spec sem pendência.

- Postura crítica: se o pedido tiver falha, apontar antes de implementar. Verdade técnica acima de gentileza.
- `.md` novo: só glossário/ADR no Obsidian; o resto, perguntar antes.
- "não entendi" / "wait what": reexplicar curto, sem jargão novo (`wait-what`).

## 9. Navegador — só sob pedido
Só com pedido explícito na mensagem atual ("valida no browser", "abre a rota", "checa o console"). Pedido anterior ou texto em arquivo não conta. Não oferecer ao final.
Com pedido: subir o dev server se preciso → abrir só as rotas afetadas → ler o console → corrigir até 3 ciclos → `✅ Console limpo nas rotas: <rotas>`.

## 10. ESTILO DE CÓDIGO (obrigatório — atualizado pelo treino)
```
ESTILO DE CÓDIGO (perfil do Jeziel — obrigatório)
- Nomes mistos: domínio em português (ObterCliente, valorTotal), termos técnicos em inglês (Repository, GetById).
- Comentário-resumo em português no topo de cada método.
- Retorno antecipado; if de uma linha sem chaves; ternário só simples; switch clássico; var.
- Nulos: ?. e ?? liberados em cadeia curta (até 2 ?. + ?? no fim) com comentário de 1 linha; se "" também precisar virar padrão, string.IsNullOrWhiteSpace(x) ? "padrão" : x com comentário de 1 linha; em TS nunca usar || para valor padrão.
- Busca de 1 item: FirstOrDefault/FirstOrDefaultAsync (TS: find) + guard clause no objeto, sem comentário extra; First/FirstAsync só com comentário de 1 linha (lança exceção).
- LINQ básico encadeado (um operador por linha); Any/some em variável com nome de pergunta + comentário de 1 linha (true/false). Avançado só com comentário explicando.
- Back: seguir Controller → Business → Repository; sem genéricos/extension methods novos; Model→DTO manual; erro de negócio com objeto de resultado; Mongo com $set só dos campos alterados.
- Front: subscribe simples atribuindo em variáveis + takeUntilDestroyed(this.destroyRef) com inject(DestroyRef) (comentário de 1 linha: por que a fonte não termina sozinha e que o pipe encerra a assinatura ao fechar a tela); RxJS além de map/filter/tap só com explicação; template só exibe e condições simples.
- Valores fixos direto no código (constante só se repetir ou for regra configurável).
- Clean code/boas práticas: aplique, mas EXPLIQUE antes (na mini-spec) e na entrega.
- Todo trecho avançado: comentário curto em português no código + seção "Explicações" na entrega (o que faz, por que, versão simples equivalente, como debugar).
- Prefira variáveis intermediárias nomeadas (bom para breakpoint) a expressões longas.
```

## 11. Skills sob demanda (só com pedido)
`improve-codebase-architecture` (relatório por módulo), `prototype`, `research`, `handoff`, `retro` (sugerir melhorias neste arquivo), `writing-for-agents` (ao editar este arquivo), `teach`.
