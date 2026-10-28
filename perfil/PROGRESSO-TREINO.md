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
| Mongo: $set × ReplaceOne, índices | 1 | 26/10: não sabia que ReplaceOne troca o documento inteiro — PRIORIDADE (incidente de clientes) |
| async/await e Task.WhenAll | 1 | 28/10: percebeu o efeito de Task sem await, mas corrigiria com try/catch em vez de await |
| RxJS pipe + map/filter/tap | 2 | Confortável |
| RxJS switchMap/combineLatest/forkJoin/debounce/takeUntil | 0 | 26/10: escolheu subscribe aninhado por não entender B/C; entendeu o risco da resposta atrasada |
| Signals / async pipe | 1 | Usa variáveis + subscribe |
| Unsubscribe / takeUntilDestroyed (memory leak) | 0 | 26/10: viu o sintoma (push repetido), não a causa (inscrição nunca cancelada) |
| Lógica no template × componente | 2 | Template simples |
| Constantes × valores mágicos | 1 | Coloca valores direto no código |

## Histórico de treinos
| Data | Acertos | Temas | Observações |
|---|---|---|---|
| 2026-10-28 | (aguardando resposta) | switch expression+LINQ, switchMap/debounce, async sem await, unsubscribe (3º round), ?./??+guard clauses | Gerado; corrigir no próximo treino. |
| 2026-10-28 | ~2,5/5 (q1 ½, q2 ✓, q3 ≈✓, q4 ≈¼, q5 ½) | switch expression+LINQ, switchMap, async sem await, takeUntilDestroyed, ?./?? + guard clauses | Melhor resultado até agora. Escolheu switchMap certo; entendeu que Task sem await 'dá sucesso e continua executando'. Unsubscribe ainda errado (3º dia): marcou o HTTP e esqueceu Subject/BehaviorSubject. Escreveu guard clauses, mas com else if desnecessário. Ainda não dá o resultado concreto pedido. |
| 2026-10-27 | ~1,5/5 (q1 ≈½, q2 ✓ parcial, q3 ✗, q4 ≈⅓, q5 ≈¼) | forkJoin/?./??, ReplaceOne×$set, unsubscribe, guard clauses, genéricos/extension | Acertou a escolha do $set (evolução vs 26/10). Unsubscribe errado pela 2ª vez → prioridade máxima. Não conhecia o termo 'guard clause' (já usa a ideia). Confundiu 'where' de genérico com LINQ. |
| 2026-10-26 | ~1,5/5 (q1 ½, q2 ✗, q3 ¼, q4 ¼, q5 ½) | GroupBy, switchMap, unsubscribe, ReplaceOne×$set, switch expression | Lê a intenção geral, mas falta precisão no resultado. Repetir: ReplaceOne×$set, takeUntilDestroyed, switchMap (com versão sem pipe ao lado) |

## Ajustes feitos no PERFIL-DE-CODIGO.md por causa do treino
(nenhum ainda)

## Feedback para o próximo treino (usar em feedbackAnterior)
- 26/10: reforçar com exercícios curtos e versão "simples equivalente" ao lado: (1) ReplaceOne apaga campos que não vieram → usar UpdateOne + $set; (2) Observable de hub/Subject nunca completa → takeUntilDestroyed; (3) switchMap cancela a busca anterior; (4) ler switch expression como switch clássico; (5) sempre dizer o RESULTADO concreto pedido no enunciado.
- 27/10: (1) unsubscribe/takeUntilDestroyed errado 2 dias seguidos → repetir com desenho do 'Subject vivo × componente morto'; (2) guard clause = 'if de erro no topo + return' (ele já usa, só não sabe o nome); (3) forkJoin roda UMA vez quando todos completam; (4) ?? não troca texto vazio; (5) filter em lista vazia dá 0, não erro; (6) 'where T :' é restrição do genérico, não LINQ.
- 28/10: (1) unsubscribe 3º dia errado → exercício de classificar Observables em 'termina sozinho' (HTTP) x 'vive no serviço/timer' (Subject, BehaviorSubject, interval); (2) Task sem await = fire-and-forget, correção é await (try/catch não pega exceção de Task não aguardada); (3) guard clause não precisa de else depois de return; (4) treinar 'dar o resultado concreto' (lista final, valor retornado); (5) ?. com null + ?? "" → string vazia, não 'null'.
