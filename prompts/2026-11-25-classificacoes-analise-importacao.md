# Prompt — Análise: como importar o catálogo padrão de classificações

**MODO ANÁLISE: NÃO altere código e NÃO grave nada no banco.** Só investigue e me devolva o relatório abaixo.

## Contexto
O catálogo de classificações passa a ter **2 níveis: Categoria → Subcategoria** (o nível Tipo deixa de existir). Montei o catálogo padrão em dois formatos neutros (baixar do portal):
- `classificacoes-padrao.json` — 25 categorias, 41 subcategorias. Cada item: `ordem`, `nome`, `nomeNormalizado` (minúsculo, sem acento), `padraoSistema: true`, `ativo: true`; subcategorias aninhadas dentro da categoria.
- `classificacoes-padrao.csv` — mesmo conteúdo, colunas `nivel;categoria;subcategoria;ordem` (UTF-8, separador `;`).

Esses arquivos **não** estão no formato do banco: são a fonte. A importação tem que convertê-los para a estrutura real.

## O que analisar (localize no código por função — Gerenciador e ADV)
1. **Estrutura de destino:** coleção e campos reais de categoria e subcategoria (como a subcategoria aponta para a categoria, campos obrigatórios, campos que o JSON não tem — cor, ícone, palavras-chave, usuário/escritório, datas — e qual valor padrão usar).
2. **Índices/unicidade:** o que impede duplicar (nome normalizado + nível + pai?). A regra de normalização do código é igual à do JSON (minúsculo, sem acento, trim)? Se não, qual usar.
3. **Mecanismo de importação existente:** já existe seed, rotina de inicialização, endpoint de importação ou script? Onde e como roda.
4. **Melhor forma de importar**, com prós e contras de cada opção:
   - (a) rotina/endpoint no Gerenciador que lê o JSON;
   - (b) script Mongo (mongosh) a partir do JSON;
   - (c) seed no código executado na inicialização.
   Recomende uma, considerando: idempotência (rodar de novo não duplica), ordem preservada, ids estáveis entre ambientes (dev/homolog/prod) e o reset (apagar classificações + zerar vínculos de arquivos e modelos antes).
5. **Mapeamento campo a campo:** JSON → documento do banco (tabela).
6. **Ajustes no arquivo fonte:** se faltar ou sobrar algo no JSON/CSV para importar sem gambiarra, diga exatamente o que mudar (eu regenero o arquivo).
7. **Validação pós-importação:** consultas de contagem (25 categorias, 41 subcategorias, nenhuma órfã, nenhuma duplicada) — só descreva, não execute.

## Entrega
1. Estrutura de destino (tópicos curtos). 2. Tabela de mapeamento JSON → banco. 3. Forma de importação recomendada + passo a passo. 4. Ajustes necessários no JSON/CSV. 5. Riscos. 6. Seção **"Explicações"**.

> Sigilo: na resposta pode citar arquivos/coleções normalmente (fica só entre nós).

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
