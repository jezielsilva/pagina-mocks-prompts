# Prompt — Análise do Gerenciador de Classificações (base para o plano da reforma)

**MODO ANÁLISE: NÃO altere nenhum código.** Só leia este projeto (o gerenciador de categorias/subcategorias criado para o Gerador de peças), mapeie e me devolva o relatório abaixo. O plano de implementação será montado depois, em cima deste relatório.

## Contexto — a reforma

**Hoje:** 3 níveis — Categoria → Subcategoria → Tipo. Só o **Tipo** é atribuído aos arquivos/modelos (ligação por id).

**Nova versão:**
1. **Só 2 níveis:** Categoria → Subcategoria. O nível Tipo deixa de existir na classificação.
2. **Tanto a categoria quanto a subcategoria podem ser atribuídas a um arquivo** (subcategoria é opcional). Essa atribuição é feita no **sistema web ADV**, não no gerenciador — mas o gerenciador precisa manter a estrutura coerente com isso.
3. Categorias padrão do sistema (~30 áreas do Direito), algumas com subcategorias padrão, outras sem nenhuma.
4. Arquivos continuam ligados **por id** (confirmar que é assim em todos os pontos).

**O gerenciador passa a ter estas operações de reorganização:**
- **Promover:** subcategoria vira categoria.
- **Rebaixar:** categoria vira subcategoria de outra categoria.
- **Mover:** subcategoria muda de categoria.
- **Mesclar:** duas viram uma; os vínculos da que some passam para a que fica.
- **Renomear / desativar / excluir** (excluir bloqueado se houver vínculo).
- **Prévia de impacto** antes de confirmar ("afeta X arquivos e Y modelos") e **registro (log)** de quem mudou o quê.
- Regras: tudo no **back-end**, em operação única (ou tudo aplica, ou nada muda); front só envia o pedido e exibe o resultado.

## O que mapear (localize no código por função)

### A. Arquitetura do projeto
- Stack, camadas (Controller → Business → Repository), como se autentica e quem pode acessar.
- Se o gerenciador escreve **no mesmo banco** que o sistema ADV lê, ou se há sincronização/API entre eles. Como o ADV fica sabendo de uma alteração.

### B. Banco de dados
- Coleções e campos de categoria, subcategoria e tipo; hierarquia (aninhado ou referência por id); índices.
- Onde ficam os **vínculos** (arquivo/modelo → tipo): coleção, campo, se guarda só id ou também nome (nome duplicado quebra renomear/mover).
- Padrão do sistema x cadastrado pelo escritório (flag/escopo).
- Existe suporte a transação no Mongo usado (replica set)? Necessário para promover/mesclar com segurança.

### C. Back-end
- Endpoints e regras atuais de listar/criar/editar/excluir; validações existentes (duplicidade, bloqueio por uso, permissões).
- Já existe algo parecido com mover/mesclar/log? O que pode ser reaproveitado.
- Pontos que assumem 3 níveis ou que só o Tipo é atribuível.

### D. Front-end
- Telas/componentes (árvore, modais, formulários, abas de Logs) e onde assumem 3 níveis.
- Regras de negócio que estão no front e precisam ir para o back.
- Onde caberiam as novas ações (menu de contexto, arrastar na árvore, modal de prévia de impacto).

### E. Impacto da reforma
- Para cada item: **manter / adaptar / remover / criar**, com motivo.
- O que fazer com os **Tipos existentes** e com os arquivos/modelos ligados a eles: opções de migração (virar subcategoria; subir o vínculo para a subcategoria pai; outro) com prós e contras.
- Como cada nova operação afeta os vínculos (ex.: ao rebaixar uma categoria que tem subcategorias, o que acontece com elas?).
- Riscos (concorrência, dados órfãos, cache no ADV, operação pela metade).

## Entrega
1. Mapa da estrutura atual (arquitetura → banco → back → front), em tópicos curtos.
2. Tabela de impacto (item | hoje | nova versão | manter/adaptar/remover/criar).
3. Proposta de modelo de dados de 2 níveis reaproveitando o atual (incluindo vínculo com categoria **ou** subcategoria).
4. Para cada operação (promover, rebaixar, mover, mesclar, renomear, desativar, excluir): regra proposta, efeito nos vínculos e o que a prévia de impacto deve mostrar.
5. Estratégia de migração dos Tipos + seed da lista padrão.
6. Lista de **decisões pendentes** para mim (ex.: quem pode reorganizar; subcategoria criada no ADV vale para o escritório todo?; padrões podem ser editados/excluídos?).
7. Seção **"Explicações"** para qualquer ponto técnico avançado (ex.: transação no Mongo).

> Sigilo: na resposta pode citar arquivos/classes normalmente (fica só entre nós).

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
