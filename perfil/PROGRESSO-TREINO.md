# Progresso do treino — Jeziel

> Atualizado pela rotina diária (seg–sex). Base: perfil/PERFIL-DE-CODIGO.md.
> Escala por tema: 0 = não conhece · 1 = reconhece com ajuda · 2 = lê e explica · 3 = escreve sozinho.

## Níveis por tema (início em 2026-10-23, estimados pelo perfil)
| Tema | Nível | Observação |
|---|---|---|
| Guard clauses / retorno antecipado | 1 | 27/10: não conhecia o nome 'guard clause' nem reescreveu; ensinar com antes/depois |
| Nulos (?., ??, null-coalescing) | 1 | Prefere if explícito; treinar leitura de ?. e ?? |
| LINQ básico (Where/Select/Any/Sum/OrderBy) | 2 | Usa encadeado |
| LINQ avançado (GroupBy/SelectMany/ToDictionary/Aggregate) | 1 | 26/10: entendeu Where/GroupBy/ToDictionary no geral; faltou dizer o resultado (Total=3, Pendentes=2) |
| switch expression / pattern matching | 1 | 26/10: leu ?. ?? certo; confundiu os cases do switch (cada linha = um status) |
| Genéricos / extension methods | 0 | 27/10: entende <T> como 'genérico'; achou que 'where T :' é LINQ; não conhece this de extension |
| Padrões de projeto (Strategy, Factory, Mediator…) | 0 | Relatou que travam a leitura |
| Objeto de resultado × exceções | 2 | Prefere objeto de resultado |
| Mapeamento Model → DTO | 2 | Faz manual |
| Clean code: tamanho de método, responsabilidade única | 1 | Pede explicação ao aplicar |
| Mongo: $set × ReplaceOne, índices | 1 | 29/10: filtra no banco certo (B) e sabe que A/C trazem dados demais; índice ainda visto como opcional |
| async/await e Task.WhenAll | 1 | 29/10: achou que as 3 tarefas rodam em sequência; não sabe que chamar sem await já dispara a tarefa (WhenAll = paralelo) |
| RxJS pipe + map/filter/tap | 2 | Confortável |
| RxJS switchMap/combineLatest/forkJoin/debounce/takeUntil | 0 | 29/10: trocou forkJoin por 2 subscribes soltos; ainda não lê forkJoin + map |
| Signals / async pipe | 1 | Usa variáveis + subscribe |
| Unsubscribe / takeUntilDestroyed (memory leak) | 0 | 29/10 (4º round): ainda acha que ter subscribe = termina sozinho; disse que interval termina sozinho |
| Lógica no template × componente | 2 | Template simples |
| Constantes × valores mágicos | 2 | 29/10: viu os 3 lugares, o risco e que o dono é o back; faltou escrever 25 * 1024 * 1024 |

## Histórico de treinos
| Data | Acertos | Temas | Observações |
|---|---|---|---|
| 2026-10-29 | ~1,5/5 (q1 ¼, q2 ½, q3 ✗, q4 ¾, q5 ✗) | Task.WhenAll, Mongo filtro no banco + índice, unsubscribe (4º round), constantes × valores mágicos, forkJoin + ?./?? + async pipe | Bom em constantes e em filtrar no Mongo. Unsubscribe errado pelo 4º dia (acha que subscribe = termina). Não sabe que método async sem await já dispara (WhenAll paralelo). Contou 'PENDENTE' sem perceber o minúsculo. ?? com '' ainda confuso. |
| 2026-10-28 | ~2,5/5 (q1 ½, q2 ✓, q3 ≈✓, q4 ≈¼, q5 ½) | switch expression+LINQ, switchMap, async sem await, takeUntilDestroyed, ?./?? + guard clauses | Melhor resultado até agora. Escolheu switchMap certo; entendeu que Task sem await 'dá sucesso e continua executando'. Unsubscribe ainda errado (3º dia): marcou o HTTP e esqueceu Subject/BehaviorSubject. Escreveu guard clauses, mas com else if desnecessário. Ainda não dá o resultado concreto pedido. |
| 2026-10-27 | ~1,5/5 (q1 ≈½, q2 ✓ parcial, q3 ✗, q4 ≈⅓, q5 ≈¼) | forkJoin/?./??, ReplaceOne×$set, unsubscribe, guard clauses, genéricos/extension | Acertou a escolha do $set (evolução vs 26/10). Unsubscribe errado pela 2ª vez → prioridade máxima. Não conhecia o termo 'guard clause' (já usa a ideia). Confundiu 'where' de genérico com LINQ. |
| 2026-10-26 | ~1,5/5 (q1 ½, q2 ✗, q3 ¼, q4 ¼, q5 ½) | GroupBy, switchMap, unsubscribe, ReplaceOne×$set, switch expression | Lê a intenção geral, mas falta precisão no resultado. Repetir: ReplaceOne×$set, takeUntilDestroyed, switchMap (com versão sem pipe ao lado) |

## Ajustes feitos no PERFIL-DE-CODIGO.md por causa do treino
(nenhum ainda)

## Feedback para o próximo treino (usar em feedbackAnterior)
- 26/10: reforçar com exercícios curtos e versão "simples equivalente" ao lado: (1) ReplaceOne apaga campos que não vieram → usar UpdateOne + $set; (2) Observable de hub/Subject nunca completa → takeUntilDestroyed; (3) switchMap cancela a busca anterior; (4) ler switch expression como switch clássico; (5) sempre dizer o RESULTADO concreto pedido no enunciado.
- 27/10: (1) unsubscribe/takeUntilDestroyed errado 2 dias seguidos → repetir com desenho do 'Subject vivo × componente morto'; (2) guard clause = 'if de erro no topo + return' (ele já usa, só não sabe o nome); (3) forkJoin roda UMA vez quando todos completam; (4) ?? não troca texto vazio; (5) filter em lista vazia dá 0, não erro; (6) 'where T :' é restrição do genérico, não LINQ.
- 28/10: (1) unsubscribe 3º dia errado → exercício de classificar Observables em 'termina sozinho' (HTTP) x 'vive no serviço/timer' (Subject, BehaviorSubject, interval); (2) Task sem await = fire-and-forget, correção é await (try/catch não pega exceção de Task não aguardada); (3) guard clause não precisa de else depois de return; (4) treinar 'dar o resultado concreto' (lista final, valor retornado); (5) ?. com null + ?? "" → string vazia, não 'null'.
- 29/10: (1) unsubscribe 4º dia errado → mudar a abordagem: exercício prático 'console.log dentro do interval, abre/fecha a tela 3x e conta os logs' + tabela fixa: HTTP termina; Subject/BehaviorSubject/hub/interval/valueChanges NÃO terminam (ter .subscribe não faz terminar); (2) método async chamado sem await já começa a rodar → guardar as Tasks e dar await Task.WhenAll = paralelo, tempo da mais lenta; (3) comparação de texto diferencia maiúsculas ('pendente' ≠ 'PENDENTE'); (4) índice composto = 'sumário' (IXSCAN × COLLSCAN); (5) ?? só troca null/undefined, '' passa direto; (6) forkJoin = 1 emissão com os 2 resultados juntos; (7) MB em bytes = 25 * 1024 * 1024.
