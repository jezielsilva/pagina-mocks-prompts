# Prompt — Meus documentos: investigação de falhas ao criar pasta/subpasta e ao enviar arquivo

> **MODO INVESTIGAÇÃO: não altere nenhum código agora.** Primeiro me entregue o diagnóstico (seção "Entrega"). Correção só depois que eu aprovar.

## Contexto (sintoma relatado)
Em **Meus documentos**, ao criar **pasta ou subpasta** (em qualquer nível), o comportamento é intermitente:
1. Às vezes salva normalmente.
2. Às vezes dá **erro** e, tentando de novo (2ª/3ª vez), salva.
3. Às vezes **salva, mas a pasta some da tela**; só aparece depois de atualizar a página.
4. Às vezes digito o nome, **clico fora do campo** (blur) e salva; outras vezes clicar fora **não** salva.

No **upload de arquivo** suspeito do mesmo problema: o item aparece na tela, mas ainda não está completo/consistente (falta informação ou ações falham logo depois).

**Hipótese (não confirmada):** a tela atualiza antes de o fluxo completo terminar (front → back → armazenamento na AWS/S3 → banco → resposta). Ou seja, uma condição de corrida/estado otimista. Confirme ou descarte com evidência do código.

## O que investigar (localize no código pelas funções; não suponha nomes)
### A. Criar pasta: front
- Onde fica o componente/serviço da criação de pasta inline (o campo de nome). Mapeie **todos os gatilhos** de salvar: Enter, blur, botão. Algum pode disparar **duas requisições** (ex.: Enter + blur em seguida)? Há trava de "salvando" (flag/disable) para evitar duplicidade?
- O blur tem regra condicional (nome vazio, nome igual, clique em outro elemento, timing de `setTimeout`)? Explique o porquê do "às vezes salva / às vezes não".
- Após a resposta, como a lista é atualizada: **inserção otimista** com id temporário, **push do retorno** ou **recarregar a listagem**? Se recarrega, a listagem pode chegar **antes** de a gravação estar visível (leitura em réplica, cache, eventual consistency do S3 em listagem, ordem das chamadas)?
- Existe item temporário que é **removido ao receber a resposta** e substituído por outro com chave diferente (`trackBy`/id)? Isso explicaria "some da tela".
- Há mais de uma assinatura/requisição concorrente (listagem anterior ainda em voo sobrescrevendo a nova)? Verifique se uma resposta antiga pode chegar depois e sobrescrever o estado (falta de `switchMap`/cancelamento).
- O que a tela faz em caso de erro (rollback do item, mensagem, estado travado do campo)?

### B. Criar pasta: back
- Fluxo completo do endpoint de criação: validações, gravação no banco, criação de "pasta"/prefixo no S3 (se houver), ordem das operações e **se tudo é aguardado** (`await` faltando, `async void`, tarefa disparada sem aguardar, `.Result`/`.Wait()`).
- O que é **retornado**: o objeto completo (id, caminho, permissões, datas) ou só sucesso? A tela precisa de algo que não vem?
- **Erros intermitentes:** colisão de nome (verificação de duplicidade x índice único), concorrência (duas requisições iguais quase simultâneas), timeout com a AWS, exceção engolida, transação/consistência entre banco e S3 (grava num e falha no outro?). Liste as exceções possíveis e qual status HTTP/mensagem cada uma gera.
- Permissões/herança da pasta pai calculadas na criação: alguma etapa assíncrona pode deixar a pasta "invisível" para a listagem por alguns instantes?

### C. Upload de arquivo
- Mesmo mapeamento: o front mostra o item **antes** do fim do upload/confirmação? Upload direto ao S3 (URL pré-assinada) + confirmação no back, ou passa pelo servidor? Em que momento o registro no banco é criado e marcado como concluído?
- Há estado "enviando/processando" no item? O que acontece se o usuário agir no item antes da conclusão?
- Pontos sem `await`, ausência de confirmação final, ou listagem que lê antes da gravação.

### D. Reprodução e evidência
- Indique como reproduzir cada sintoma (1 a 4 + upload) com passos exatos e o que olhar na aba **Network** do navegador (quantas requisições, ordem, status, corpo da resposta) e nos **logs** do back.
- Se faltar log para provar a causa, **proponha** (não implemente) onde colocar logs temporários: início/fim de cada etapa com id da operação e tempo decorrido.

## Entrega (só diagnóstico, sem código alterado)
1. **Mapa do fluxo** de criar pasta e de upload (front → back → S3 → banco → resposta → atualização da tela), com cada etapa e se é aguardada.
2. **Causas encontradas**, uma por sintoma (1–4 + upload): evidência no código (descreva o trecho por função), por que é intermitente, e grau de certeza (confirmado / provável / descartado).
3. **Hipótese da corrida de tempo**: confirmada ou descartada, com justificativa.
4. **Proposta de correção** (definitiva, sem gambiarra tipo `setTimeout`/retry cego), com mini-spec: o que muda no front, o que muda no back, e o que o back deve retornar para a tela não depender de recarregar.
5. **Explicações**: para cada conceito avançado citado (condição de corrida, atualização otimista, cancelamento de requisição, idempotência, consistência eventual do S3 etc.): o que é, por que importa aqui, versão simples equivalente e como debugar.

## Sigilo
Na resposta, pode citar arquivos/classes normalmente (fica só entre nós). Não inclua connection strings, chaves da AWS, tokens ou dados de clientes.

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
```
