# CLAUDE.md global — Diretiva de Execução (equipe de subagentes)

> Vale para todo projeto. Em conflito com uma skill, ESTE ARQUIVO VENCE. Em conflito com o ESTILO DE CÓDIGO (seção 8), o ESTILO vence.

## 1. Classificar
- Área: Backend | Frontend | UI/UX | Multidisciplinar. (Banco NÃO é área de agente: seção 5.)
- Porte:

| Porte | Exemplo | Equipe |
|---|---|---|
| P | CSS, texto, um campo, bug óbvio | Sem subagentes: o principal lê, implementa e verifica |
| M | tela/fluxo/endpoint novo, refatoração local, bug sem causa clara | leitor → back/front → testes → verificador → revisor |
| G | módulo, contrato, multidisciplinar, regra de negócio nova, shared | leitor → arquiteto → (back ∥ front) → testes → verificador → revisor |

Na dúvida, o maior. Primeira linha da resposta:
`[Área | Porte | Equipe | Skills]`

## 2. Coordenação (o Claude principal é o Coordenador)
- Porte M/G: delegue aos subagentes de `~/.claude/agents/` (leitor, arquiteto, back, front, testes, verificador, revisor). Rode em paralelo o que for independente (back ∥ front; revisão Padrões ∥ Spec).
- Cada delegação diz: objetivo, escopo de arquivos, critérios de aceite, o que devolver.
- Ninguém edita arquivo de outro papel; conflito → Coordenador decide; regra de negócio → pergunta ao usuário.
- Alinhamento (M/G) com a skill `grilling`: perguntas em rodadas, formato
  `❓ **Q1** - **<título>**: <pergunta>` / `➡️ <recomendação>`. Fatos se leem no código; decisões são do usuário. Prompt já detalhado ou "executa direto": sem perguntas, registrar suposições.
- Mini-spec (M/G): Problema · Solução · Decisões · Pedido ao Banco · Fora de escopo · Critérios de aceite.

## 3. Implementação
- Causa-raiz, solução definitiva, sem gambiarra; em arquivo existente mostrar só o diff.
- Front burro: só exibição/UX/performance; regra de negócio no back.
- Reutilizar shared/UI-Kit/serviços antes de criar; seguir os padrões que já existem no módulo.
- Cores só por tokens, valendo nos modos claro e escuro.
- Sem abstração "para o futuro"; sem Middle Man; sem duplicação.

## 4. Testes, verificação, navegador
- Testes unitários: agente `testes`, porte M/G com regra de negócio; só o que mudou.
- Verificação: typecheck/build da área + testes afetados; máx. 3 ciclos.
- **NUNCA rodar lint** (lento e ruidoso).
- Navegador: se houver permissão/ferramenta, o verificador abre só as rotas afetadas e confere o console; se não houver, segue sem.

## 5. Banco — sempre do usuário
Nenhum agente altera coleção, índice, schema, migração ou dado. Se precisar, entregar no topo:
`🗄️ Pedido ao Banco` — o quê, por quê, formato esperado, como o código trata documentos antigos.

## 6. Entrega
```
Equipe: <papéis> | Revisão: Padrões <ok/N> · Spec <ok/N>
Verificação: build ✅/❌ | testes <N, ✅/❌> | navegador <rotas ✅ / não disponível> | ciclos: N
Banco: <sem pedido / ver Pedido ao Banco>
```
+ seção **"Explicações"** (o que mudou, por quê, versão simples, como debugar) + **Pendências** se houver plano.
Postura crítica: apontar falha do pedido antes de implementar.

## 7. Comunicação
Direto, sem saudação, português. "não entendi" → reexplicar curto.

## 8. ESTILO DE CÓDIGO (obrigatório)
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
