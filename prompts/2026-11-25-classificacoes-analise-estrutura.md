# Prompt — Análise da estrutura atual de Classificações (antes do plano da nova versão)

**MODO ANÁLISE: NÃO altere nenhum código.** Só leia, mapeie e me devolva o relatório abaixo. O plano de mudança será feito depois, em cima deste relatório.

## Contexto — o que vai mudar

Hoje existe no sistema uma estrutura de **classificações** (categorias / subcategorias / tipos, usada para classificar modelos/arquivos — localize onde ela é usada: Gerador de peças, Meus documentos ou ambos).

A nova versão:
1. **Dois níveis:** Categoria (ex.: "Direito Civil") → Subcategoria (ex.: "Direito de Família").
2. **Categorias padrão do sistema** (lista fixa, ~30 áreas do Direito). Algumas vêm com subcategorias padrão, outras vêm **sem nenhuma** (ex.: "Direito Trabalhista", "Direito Penal").
3. **Usuários podem cadastrar novas subcategorias** dentro de qualquer categoria.
4. **Diferente de hoje:** um arquivo pode ser classificado **só com a categoria** OU com **categoria + subcategoria**. A subcategoria é opcional.
5. **Reaproveitar** a estrutura atual ao máximo, mudando só o necessário.

### Lista padrão (referência para o plano — não cadastrar agora)
- **Direito Civil:** Direito das Pessoas; Direito das Obrigações; Direito Contratual; Responsabilidade Civil; Direito das Coisas (Direitos Reais); Direito Imobiliário; Direito Condominial; Direito Possessório; Direito de Família; Direito das Sucessões; Direito Notarial e Registral; Direitos da Personalidade
- **Direito Trabalhista:** (sem subcategorias)
- **Direito Previdenciário:** Aposentadoria; Pensão; Auxílio por incapacidade temporária; Auxílio por incapacidade permanente; BPC
- **Direito Empresarial (Comercial):** Direito Societário; Direito Cambiário e Títulos de Crédito; Direito Falimentar; Recuperação Judicial e Extrajudicial; Contratos Empresariais; Propriedade Intelectual; Propriedade Industrial; Direito Concorrencial; Direito Bancário; Direito do Mercado de Capitais
- **Direito do Consumidor:** Relações de consumo; Responsabilidade pelo fato do produto ou serviço; Vícios de produtos e serviços; Práticas comerciais abusivas; Contratos de consumo; Superendividamento; Publicidade enganosa; Proteção do consumidor bancário; Comércio eletrônico
- **Direito Internacional Privado:** Conflitos internacionais de leis; Contratos internacionais; Família e sucessões internacionais; Homologação de decisões estrangeiras; Arbitragem internacional
- **Sem subcategorias:** Direito Constitucional; Administrativo; Tributário; Penal; Eleitoral; Financeiro; Internacional Público; Econômico; Militar; Agrário; Médico; Desportivo; Marítimo; Aeronáutico; da Criança e do Adolescente; da Pessoa Idosa; da Pessoa com Deficiência; Migratório; Aduaneiro

## O que mapear (localize no código por função)

### A. Banco de dados
- Coleções/documentos que guardam categorias, subcategorias e tipos: campos, hierarquia (aninhado ou referência por id), índices.
- Como o arquivo/modelo guarda a classificação hoje (qual nível é obrigatório? guarda id, nome ou os dois?).
- O que é padrão do sistema x o que é cadastrado pelo escritório/usuário (há escopo por escritório? flag de "padrão"?).
- Seed: como as classificações iniciais são criadas hoje (migration, script, código de inicialização).
- Volume aproximado de dados já existentes que dependem da estrutura atual.

### B. Back-end
- Fluxo Controller → Business → Repository de: listar, criar, editar, excluir classificação; classificar arquivo; filtrar arquivos por classificação.
- Validações atuais (obrigatoriedade de nível, nome duplicado, exclusão bloqueada se em uso, permissões de quem pode cadastrar).
- DTOs e contratos expostos ao front.

### C. Front-end
- Telas/componentes que exibem, cadastram e escolhem classificação (árvore lateral, modal de gestão, select no upload/novo modelo, filtros, badges).
- Onde o front assume que existe o 3º nível ou que a subcategoria é obrigatória.
- Regras de negócio que estejam no front e deveriam estar no back.

### D. Impacto da mudança
- Para cada ponto acima: **manter / adaptar / remover**, com o motivo.
- O que acontece com o nível "tipo" (se existir): pode ser absorvido? quais arquivos usam?
- Riscos de migração dos dados existentes (arquivos classificados hoje em tipo/subcategoria) e proposta de mapeamento.
- Dúvidas de regra de negócio que eu preciso decidir antes do plano (ex.: usuário pode criar categoria ou só subcategoria? subcategoria criada vale para o escritório todo ou só para quem criou? pode editar/excluir as padrão?).

## Entrega
1. Mapa da estrutura atual (banco → back → front) em tópicos curtos.
2. Tabela de impacto (item | hoje | nova versão | manter/adaptar/remover).
3. Proposta de modelo de dados para a nova versão reaproveitando o atual.
4. Estratégia de migração + seed da lista padrão.
5. Lista de decisões pendentes para mim.
6. Seção **"Explicações"** para qualquer ponto técnico avançado encontrado.

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
