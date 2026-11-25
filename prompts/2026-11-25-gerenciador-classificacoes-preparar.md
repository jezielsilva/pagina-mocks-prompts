# Prompt 1/2 — Gerenciador de Classificações: 2 níveis + reorganizar/mesclar + reset e seed

Projeto: **Gerenciador** (aplicação separada que administra o catálogo de classificações e os modelos de peças). Base: o relatório de análise que você já fez deste projeto. Localize tudo por função.

**Antes de codar:** me entregue uma **mini-spec** (arquivos que vai mexer, regras, contratos dos endpoints, telas) e **aguarde meu OK**.

## Modelo novo (vale para os dois sistemas — mesmo banco)
- **Só 2 níveis:** Categoria → Subcategoria. O nível **Tipo deixa de existir** (código, validações, telas e campos).
- Um arquivo/modelo é classificado com **só a categoria** OU **categoria + subcategoria** (subcategoria opcional). Vínculo **sempre por id**; nenhuma cópia de nome guardada no arquivo/modelo (o nome é lido do catálogo).
- **Catálogo padrão** (marcado como padrão do sistema, vale para todos os escritórios) + **subcategorias do escritório** (criadas no ADV, valem para o escritório inteiro, podem ficar dentro de categoria padrão).
- **Desativar** preserva os vínculos: o item some das opções de escolha, mas continua aparecendo nos arquivos já classificados, marcado como inativo.
- Ambiente em desenvolvimento, sem dados reais: **não há migração**. Classificações e vínculos antigos serão apagados e o catálogo recriado pelo seed.

## 1. Reduzir para 2 níveis
- Remover o nível Tipo do modelo de dados, Business, Repository, DTOs e telas do gerenciador.
- Modelos de peça: o vínculo passa a ser **categoriaId (obrigatório) + subcategoriaId (opcional)**. Remover o campo de id do tipo e a **cópia do nome do tipo** guardada no modelo; onde o nome for exibido/filtrado, ler do catálogo.
- Ajustar criação/edição de modelo (escolher categoria e, opcionalmente, subcategoria da categoria escolhida).
- Validação no back: subcategoria informada precisa pertencer à categoria informada e estar ativa.

## 2. Operações do catálogo (só itens padrão; tudo no back, front só envia e exibe)
- **Criar / renomear / desativar / reativar / excluir** categoria e subcategoria. Excluir **bloqueado** se houver arquivo ou modelo vinculado (mensagem com a contagem). Nome único por nível dentro do mesmo pai (comparar pelo nome normalizado).
- **Promover:** subcategoria vira categoria. Vínculos: arquivos/modelos que tinham (categoria pai + essa subcategoria) passam a ter **só a nova categoria**.
- **Rebaixar:** categoria vira subcategoria de outra categoria. **Bloqueado se ela tiver subcategorias** (mensagem: mova ou mescle as subcategorias antes). Vínculos: arquivos/modelos com essa categoria passam a ter (nova categoria pai + ela como subcategoria).
- **Mover:** subcategoria muda de categoria. Vínculos: categoriaId dos arquivos/modelos com essa subcategoria passa a ser a nova categoria.
- **Mesclar:** só itens do **mesmo nível** (categoria com categoria, subcategoria com subcategoria). O item de origem some; vínculos passam para o destino. Ao mesclar categorias, subcategorias da origem vão para o destino; se houver subcategoria de mesmo nome no destino, **mescla automaticamente** essas duas também.
- Cada operação de reorganização numa **transação Mongo** (estrutura + arquivos + modelos): ou aplica tudo, ou nada. Se o servidor não suportar transação, **pare e me avise** antes de implementar alternativa.
- Revalidar o estado no momento da confirmação (outro usuário pode ter mudado a árvore).
- Atualizar sempre o campo de data de atualização dos itens afetados.

## 3. Tela do catálogo
- Árvore categoria → subcategorias, com busca, contagem de vínculos por item e indicação de inativo.
- Ações por item (menu do item): renomear, desativar/reativar, excluir, promover/rebaixar/mover (conforme o nível), mesclar com… (seleção do destino filtrada pelo mesmo nível).
- Confirmação simples antes de promover/rebaixar/mover/mesclar/excluir, mostrando a contagem de arquivos e modelos afetados (vinda do back).
- Feedback de sucesso/erro com a mensagem do back; recarregar a árvore após cada operação.
- Prévia detalhada de impacto e log de auditoria: **fora do escopo agora**.

## 4. Reset + seed (script/rotina de desenvolvimento)
- Rotina que: (a) **apaga todas as classificações**; (b) **zera a classificação** de todos os arquivos e de todos os modelos (incluindo a cópia do nome do tipo nos modelos); (c) cadastra o catálogo padrão abaixo.
- Executada **só por ação explícita** (comando/endpoint protegido e desativado fora de desenvolvimento). Pedir confirmação e logar as contagens apagadas/criadas.
- O seed é **idempotente**: rodar de novo não duplica (reconhece pelo nome normalizado + nível + pai); respeita a ordem da lista.

### Lista padrão (seed)
- **Direito Civil:** Direito das Pessoas; Direito das Obrigações; Direito Contratual; Responsabilidade Civil; Direito das Coisas (Direitos Reais); Direito Imobiliário; Direito Condominial; Direito Possessório; Direito de Família; Direito das Sucessões; Direito Notarial e Registral; Direitos da Personalidade
- **Direito Trabalhista:** (sem subcategorias)
- **Direito Previdenciário:** Aposentadoria; Pensão; Auxílio por incapacidade temporária; Auxílio por incapacidade permanente; BPC
- **Direito Empresarial (Comercial):** Direito Societário; Direito Cambiário e Títulos de Crédito; Direito Falimentar; Recuperação Judicial e Extrajudicial; Contratos Empresariais; Propriedade Intelectual; Propriedade Industrial; Direito Concorrencial; Direito Bancário; Direito do Mercado de Capitais
- **Direito do Consumidor:** Relações de consumo; Responsabilidade pelo fato do produto ou serviço; Vícios de produtos e serviços; Práticas comerciais abusivas; Contratos de consumo; Superendividamento; Publicidade enganosa; Proteção do consumidor bancário; Comércio eletrônico
- **Direito Internacional Privado:** Conflitos internacionais de leis; Contratos internacionais; Família e sucessões internacionais; Homologação de decisões estrangeiras; Arbitragem internacional
- **Sem subcategorias:** Direito Constitucional; Direito Administrativo; Direito Tributário; Direito Penal; Direito Eleitoral; Direito Financeiro; Direito Internacional Público; Direito Econômico; Direito Militar; Direito Agrário; Direito Médico; Direito Desportivo; Direito Marítimo; Direito Aeronáutico; Direito da Criança e do Adolescente; Direito da Pessoa Idosa; Direito da Pessoa com Deficiência; Direito Migratório; Direito Aduaneiro

## 5. Fora do escopo
- Mudanças no sistema ADV (é o Prompt 2/2). Não alterar o ADV aqui.
- Permissão por papel: por enquanto, todo usuário autorizado no gerenciador pode operar o catálogo.

## Entrega
1. Mini-spec (aguardar OK). 2. Implementação completa. 3. Lista de arquivos alterados. 4. Como rodar o reset + seed. 5. Seção **"Explicações"** (transação, normalização de nome, cada operação e seu efeito nos vínculos).

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
