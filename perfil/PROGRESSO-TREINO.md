# Progresso do treino — Jeziel

> Atualizado pela rotina diária (seg–sex). Base: perfil/PERFIL-DE-CODIGO.md.
> Escala por tema: 0 = não conhece · 1 = reconhece com ajuda · 2 = lê e explica · 3 = escreve sozinho.

## Níveis por tema (início em 2026-10-23, estimados pelo perfil)
| Tema | Nível | Observação |
|---|---|---|
| Guard clauses / retorno antecipado | 2 | Prefere clean code; consolidar o porquê |
| Nulos (?., ??, null-coalescing) | 1 | Prefere if explícito; treinar leitura de ?. e ?? |
| LINQ básico (Where/Select/Any/Sum/OrderBy) | 2 | Usa encadeado |
| LINQ avançado (GroupBy/SelectMany/ToDictionary/Aggregate) | 1 | 26/10: entendeu Where/GroupBy/ToDictionary no geral; faltou dizer o resultado (Total=3, Pendentes=2) |
| switch expression / pattern matching | 1 | 26/10: leu ?. ?? certo; confundiu os cases do switch (cada linha = um status) |
| Genéricos / extension methods | 0 | Relatou que confundem |
| Padrões de projeto (Strategy, Factory, Mediator…) | 0 | Relatou que travam a leitura |
| Objeto de resultado × exceções | 2 | Prefere objeto de resultado |
| Mapeamento Model → DTO | 2 | Faz manual |
| Clean code: tamanho de método, responsabilidade única | 1 | Pede explicação ao aplicar |
| Mongo: $set × ReplaceOne, índices | 0 | 26/10: não sabia que ReplaceOne troca o documento inteiro — PRIORIDADE (incidente de clientes) |
| async/await e Task.WhenAll | 1 | Básico ok |
| RxJS pipe + map/filter/tap | 2 | Confortável |
| RxJS switchMap/combineLatest/forkJoin/debounce/takeUntil | 0 | 26/10: escolheu subscribe aninhado por não entender B/C; entendeu o risco da resposta atrasada |
| Signals / async pipe | 1 | Usa variáveis + subscribe |
| Unsubscribe / takeUntilDestroyed (memory leak) | 0 | 26/10: viu o sintoma (push repetido), não a causa (inscrição nunca cancelada) |
| Lógica no template × componente | 2 | Template simples |
| Constantes × valores mágicos | 1 | Coloca valores direto no código |

## Histórico de treinos
| Data | Acertos | Temas | Observações |
|---|---|---|---|
| 2026-10-26 | ~1,5/5 (q1 ½, q2 ✗, q3 ¼, q4 ¼, q5 ½) | GroupBy, switchMap, unsubscribe, ReplaceOne×$set, switch expression | Lê a intenção geral, mas falta precisão no resultado. Repetir: ReplaceOne×$set, takeUntilDestroyed, switchMap (com versão sem pipe ao lado) |

## Ajustes feitos no PERFIL-DE-CODIGO.md por causa do treino
(nenhum ainda)

## Feedback para o próximo treino (usar em feedbackAnterior)
- 26/10: reforçar com exercícios curtos e versão "simples equivalente" ao lado: (1) ReplaceOne apaga campos que não vieram → usar UpdateOne + $set; (2) Observable de hub/Subject nunca completa → takeUntilDestroyed; (3) switchMap cancela a busca anterior; (4) ler switch expression como switch clássico; (5) sempre dizer o RESULTADO concreto pedido no enunciado.
