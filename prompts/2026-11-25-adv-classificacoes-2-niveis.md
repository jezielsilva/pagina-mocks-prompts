# Prompt 2/2 — Sistema web ADV: Classificações em 2 níveis (categoria / subcategoria)

Projeto: **sistema web ADV** (front Angular + API .NET + Mongo). Localize por função: o serviço/central de classificações de arquivos, o fluxo de classificar arquivo em Meus documentos, os filtros por classificação e a desativação de classificações do escritório.

**Antes de codar:** me entregue uma **mini-spec** (arquivos que vai mexer, regras, contratos, telas) e **aguarde meu OK**.

## Modelo novo (vale para os dois sistemas — mesmo banco)
- **Só 2 níveis:** Categoria → Subcategoria. O nível **Tipo deixa de existir** (código, validações, telas e campos).
- Um arquivo/modelo é classificado com **só a categoria** OU **categoria + subcategoria** (subcategoria opcional). Vínculo **sempre por id**; nenhuma cópia de nome guardada no arquivo/modelo (o nome é lido do catálogo).
- **Catálogo padrão** (marcado como padrão do sistema, vale para todos os escritórios) + **subcategorias do escritório** (criadas no ADV, valem para o escritório inteiro, podem ficar dentro de categoria padrão).
- **Desativar** preserva os vínculos: o item some das opções de escolha, mas continua aparecendo nos arquivos já classificados, marcado como inativo.
- Ambiente em desenvolvimento, sem dados reais: **não há migração**. Classificações e vínculos antigos serão apagados e o catálogo recriado pelo seed.

O catálogo padrão é mantido pelo **Gerenciador** (outro projeto, Prompt 1/2). O ADV **lê** o catálogo padrão e **mantém só as subcategorias do escritório**.

## 1. Modelo e back-end
- Remover o nível Tipo de modelos, DTOs, Business, Repository e validações.
- Classificação do arquivo passa a ser **categoriaId (obrigatório quando classificado) + subcategoriaId (opcional)**, mais a data em que foi classificado. Remover o id do tipo.
- Validação no back: categoria existe e está ativa; se vier subcategoria, ela pertence à categoria e é visível para o escritório (padrão ou do próprio escritório) e está ativa.
- Listar catálogo para o escritório: categorias padrão + subcategorias padrão + subcategorias do escritório, com flag de padrão, ativo e contagem de arquivos do escritório por item.
- **Subcategorias do escritório:** criar (dentro de qualquer categoria, padrão ou não), renomear, desativar/reativar, excluir (bloqueado se houver arquivo vinculado, mensagem com a contagem). Nome único dentro da categoria, considerando padrão + escritório (nome normalizado).
- **O escritório não pode criar categoria nem alterar itens padrão** (bloquear no back).
- **Desativação:** a operação atual que remove a classificação dos arquivos ao desativar deve **passar a preservar os vínculos**.
- Filtro de arquivos por classificação: por categoria (traz arquivos com só a categoria **e** com qualquer subcategoria dela) ou por subcategoria.

## 2. Front-end (só exibição; regras no back)
- Classificar arquivo (individual e em lote, onde já existir): escolher categoria e, opcionalmente, subcategoria da categoria escolhida; permitir "só categoria". Opções inativas não aparecem para escolha.
- Exibição (badge/coluna/detalhe): "Categoria" ou "Categoria › Subcategoria"; item inativo com marca "inativa".
- Central de classificações do escritório: árvore categoria → subcategorias, padrões identificados e somente leitura, ações só nas subcategorias do escritório.
- Filtros e árvore lateral (se houver) ajustados para 2 níveis.
- Recarregar o catálogo ao abrir a central/tela (não precisa aviso em tempo real de alterações feitas no Gerenciador).

## 3. Dados
- Não migrar nada: o reset + seed é feito pelo Gerenciador (Prompt 1/2). O ADV só precisa funcionar com o catálogo novo e com arquivos sem classificação.
- Garantir que nenhum ponto quebre se um arquivo tiver categoria sem subcategoria, ou se o id apontar para item inativo.

## 4. Fora do escopo
- Promover/rebaixar/mover/mesclar (só no Gerenciador).
- Alterações no projeto do Gerenciador.

## Entrega
1. Mini-spec (aguardar OK). 2. Implementação completa. 3. Lista de arquivos alterados. 4. Pontos que dependem do Prompt 1/2 estar aplicado. 5. Seção **"Explicações"**.

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
