# Perfil de código — Jeziel (C#/.NET + MongoDB + Angular)

> Objetivo: o código gerado por IA deve parecer escrito pelo Jeziel, para ele LER, DEBUGAR e MANTER sozinho.
> A qualidade técnica não se perde (performance, segurança, consultas eficientes, escalabilidade). Muda a FORMA.
> Quando a melhor prática exigir algo diferente do estilo abaixo: faça do jeito melhor, MAS explique (ver regra 0).

## 0. Regra de ouro — explicar o que for "avançado"
- Sempre que usar algo além do básico (LINQ avançado, RxJS além de map/filter/tap, padrão de projeto, genéricos, nova estrutura de pastas, nova camada), explique nos DOIS lugares:
  1. **No código**: comentário curto em português logo acima do trecho, dizendo o que ele faz e por que foi usado.
  2. **Na entrega**: seção "Explicações" com o porquê, uma versão simples equivalente (se existir) e como debugar aquele trecho.
- Decisões de clean code/boas práticas que mudem o jeito habitual (quebrar método, criar classe, interface, estrutura de pastas): explicar ANTES de implementar (no alinhamento/mini-spec) e de novo na entrega.

## 1. Nomes
- **Misto**: domínio em português, termos técnicos em inglês.
  - Classes/DTOs/variáveis de negócio em português: `ClienteDto`, `cliente`, `valorTotal`, `listaClientes`.
  - Verbos de método em português para regra de negócio: `ObterCliente`, `SalvarContatos`, `ValidarCliente`.
  - Termos técnicos consagrados podem ficar em inglês: `Repository`, `Controller`, `Service`, `GetById`, `Dto`, `Model`, `Hub`.
  - Siga o que já existe no arquivo quando houver padrão estabelecido.
- Nomes descritivos e completos. Nada de `c`, `x`, `tmp`, `res2` (exceto o parâmetro de lambda curta: `p => p.Valor`).

## 2. Comentários
- **Resumo no topo de cada método**: 1–3 linhas em português dizendo o que o método faz (e o que retorna, se não for óbvio).
  ```csharp
  // Salva os contatos do cliente. Valida todos antes e só grava se estiverem válidos.
  public async Task<Retorno> SalvarContatos(string clienteId, List<ContatoDto> contatos)
  ```
- Comentário extra só para regra de negócio e para trechos "avançados" (regra 0).
- Comentários sempre em português.

## 3. Fluxo e estrutura
- **Retorno antecipado** (guard clauses) nas validações, sem if/else aninhado:
  ```csharp
  if (cliente == null)
      return NotFound();

  if (!cliente.Ativo)
      return BadRequest("Inativo");

  return Ok(cliente);
  ```
- **if de uma linha SEM chaves**:
  ```csharp
  if (lista.Count == 0)
      return;
  ```
- **Nulos** (atualizado em 11/11/2026 pelo treino — ver seção 11):
  - `?.` e `??` LIBERADOS em C# e TypeScript em cadeia curta (até 2 `?.` + um `??` no fim), com comentário de 1 linha no código; sem seção "Explicações" obrigatória.
    ```csharp
    // cidade do cliente; "Não informada" se cliente/endereço/cidade forem null
    var cidade = cliente?.Endereco?.Cidade ?? "Não informada";
    ```
  - Quando o valor puder ser `""` ou `0` e isso importar, NÃO confiar no `??` (ele só troca null/undefined): usar if explícito (`string.IsNullOrEmpty`) e comentar.
  - No TypeScript, valor padrão com `??`, nunca `||` (o `||` troca 0 e "" por engano).
  - Cadeias maiores que isso: quebrar em if explícito.
- **Ternário só simples**: `var status = ativo ? "Ativo" : "Inativo";`. Ternário aninhado: NÃO.
- **switch clássico** (case/break) ou if, em vez de switch expression.
- **var** para declarar variáveis.
- **Valores fixos direto no código** (`if (tamanho > 50)`). Exceção de boa prática: se o mesmo valor aparecer em mais de um lugar ou for regra de negócio configurável, use constante com nome em português e explique (regra 0).
- **Tamanho de método/quebra em métodos/classes**: seguir clean code (métodos com uma responsabilidade, preferindo métodos privados com nomes claros no mesmo arquivo antes de criar classes novas), SEMPRE explicando a divisão antes e na entrega. Evitar espalhar demais: o fluxo principal deve ser lido de cima para baixo no método público.

## 4. LINQ
- LINQ encadeado é bem-vindo no nível BÁSICO: `Where`, `Select`, `Any`, `FirstOrDefault`, `Sum`, `OrderBy`, `Count`, `ToList`.
  ```csharp
  var total = pedidos
      .Where(p => p.Pago)
      .Sum(p => p.Valor);
  ```
- Um operador por linha quando encadear.
- Avançado (`GroupBy`, `SelectMany`, `ToDictionary`, `Aggregate`, `Join`, consultas aninhadas): permitido quando for mais rápido/eficiente, COM explicação (regra 0).
- Evitar encadeamentos longos (> 4 operações): quebrar em variáveis intermediárias com nome.

## 5. Back-end (.NET + Mongo)
- **Arquitetura**: seguir o padrão do projeto (Controller → Business → Repository, interfaces como já existem). Se uma boa prática pedir mudança, propor e explicar antes.
- **Genéricos**: EVITAR `BaseRepository<T>`, métodos `<T>` próprios e extension methods novos (confundem). Preferir código explícito por entidade. Se o projeto já usa um genérico existente, pode usar, explicando.
- **Model → DTO**: mapeamento MANUAL (objeto inicializado campo a campo). AutoMapper só se o trecho já usar, explicando.
  ```csharp
  return new ClienteDto
  {
      Id = cliente.Id,
      Nome = cliente.Nome
  };
  ```
- **Erros de regra de negócio**: OBJETO DE RESULTADO (sucesso + mensagem + dados), não exceção. Usar o tipo de retorno que o projeto já tiver (ex.: Retorno/Result). O controller converte em status HTTP (com errorId, no padrão da API). Exceção só para erro inesperado.
- **Mongo**: no update, `$set` só dos campos alterados (Builders.Update.Set), nunca substituir o documento a partir de DTO parcial.
- async/await normal. Recursos avançados (Task.WhenAll, SemaphoreSlim, Channels): com explicação.

## 6. Front-end (Angular)
- **HTTP**: `subscribe` simples, atribuindo em variáveis do componente:
  ```ts
  this.clienteService.obter(id).subscribe(res => {
    this.cliente = res;
    this.carregando = false;
  });
  ```
  Sempre com `takeUntilDestroyed` (ou o padrão de unsubscribe do projeto). O par `private destroyRef = inject(DestroyRef);` + `.pipe(takeUntilDestroyed(this.destroyRef))` está LIBERADO sem explicação (ele escreve de memória — treino 09/11). Ainda explicar em 1 linha POR QUE aquela fonte precisa (ex.: "Subject do hub não termina sozinho"); HTTP não precisa de comentário.
- **RxJS**: confortável com `pipe` + `map`/`filter`/`tap`. `switchMap`, `combineLatest`, `forkJoin`, `debounceTime`, `shareReplay` etc.: só quando necessário, com explicação (regra 0).
- **Estado**: variáveis simples + subscribe. Signals/Observable+async pipe: permitido quando melhorar, explicando.
- **Template**: só exibição + condições simples (`@if (x && y)`). Lógica maior vai para o `.ts` em getters/métodos com nome claro (ex.: `podeExcluir`). Se for preciso algo mais complexo no template, explicar.
- **Formulários e componentes**: seguir o padrão da tela/UI-Kit.

## 7. Arquivos e organização
- Seguir as melhores práticas e a estrutura existente. Ao criar pastas/arquivos novos, explicar onde ficou cada coisa e por quê.

## 8. O que mais trava a leitura (evitar)
- Encadeamentos longos de LINQ/RxJS, genéricos e extension methods.
- Padrões de projeto sem explicação (Strategy, Factory, Mediator, Decorator…). Se usar, explique o padrão em 2 linhas no comentário e na entrega.

## 9. Debug amigável
- O Jeziel debuga com breakpoint, console.log/Console.WriteLine, DevTools/Network e lendo o código. Então:
  - prefira variáveis intermediárias com nome (dá para inspecionar no breakpoint) a expressões longas numa linha só;
  - mensagens de erro e logs claros, em português, com o id da entidade;
  - não esconda fluxo em lambdas grandes ou callbacks aninhados.

## 10. Bloco para colar nos prompts (resumo)
```
ESTILO DE CÓDIGO (perfil do Jeziel — obrigatório)
- Nomes mistos: domínio em português (ObterCliente, valorTotal), termos técnicos em inglês (Repository, GetById).
- Comentário-resumo em português no topo de cada método.
- Retorno antecipado; if de uma linha sem chaves; ternário só simples; switch clássico; var.
- Nulos: ?. e ?? liberados em cadeia curta (até 2 ?. + ?? no fim) com comentário de 1 linha; se "" ou 0 importarem, if explícito (?? só troca null/undefined); em TS nunca usar || para valor padrão.
- LINQ básico encadeado (um operador por linha). Avançado só com comentário explicando.
- Back: seguir Controller → Business → Repository; sem genéricos/extension methods novos; Model→DTO manual; erro de negócio com objeto de resultado; Mongo com $set só dos campos alterados.
- Front: subscribe simples atribuindo em variáveis + takeUntilDestroyed(this.destroyRef) com inject(DestroyRef) (sem explicação; só 1 linha dizendo por que a fonte não termina sozinha); RxJS além de map/filter/tap só com explicação; template só exibe e condições simples.
- Valores fixos direto no código (constante só se repetir ou for regra configurável).
- Clean code/boas práticas: aplique, mas EXPLIQUE antes (na mini-spec) e na entrega.
- Todo trecho avançado: comentário curto em português no código + seção "Explicações" na entrega (o que faz, por que, versão simples equivalente, como debugar).
- Prefira variáveis intermediárias nomeadas (bom para breakpoint) a expressões longas.
```

## 11. Evolução pelo treino diário (atualizado a cada conceito entendido)
> Regra: sempre que o treino mostrar que ele ENTENDEU um conceito (acertou com o porquê, ou escreveu de memória), este perfil é atualizado no mesmo dia — o recurso passa de "evitar" → "liberado com comentário de 1 linha" → "liberado sem explicação". Erro no conceito básico volta um degrau. Histórico em perfil/PROGRESSO-TREINO.md.

| Data | Recurso | Antes | Agora | Evidência |
|---|---|---|---|---|
| 11/11/2026 | `?.` + `??` (C# e TS) | Evitar; if explícito | Liberado em cadeia curta, com comentário de 1 linha | 10–11/11: leu a cadeia, achou o `?.` faltando, traduziu `??` para if sem inverter |
| 11/11/2026 | `??` × `\|\|` com `""`/`0` | — | Ainda NÃO domina: if explícito quando vazio/0 importar | 10–11/11: achou que `??` troca `""` e `0` |
| 11/11/2026 | `inject(DestroyRef)` + `takeUntilDestroyed` | Com explicação | Liberado sem explicação (só 1 linha do porquê da fonte) | 09/11: escreveu as 2 linhas de memória |
| 11/11/2026 | Classificar "termina sozinho?" (HTTP × Subject/interval/valueChanges) | — | Ainda NÃO domina: manter comentário de 1 linha em cada subscribe de fonte infinita | 06/11 e 09/11 q1 |
| 27/10/2026 | Guard clauses / `$set` no Mongo | — | Já eram o padrão do perfil (ele usa e escolhe certo) | 27–28/10 |
