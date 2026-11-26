# Prompt — Gerador de peças: scroll no modal de pré-visualização + investigação (rascunho, permissões, personalizações)

## PARTE 1 — Corrigir o scroll do modal "Pré-visualização do modelo"

### Problema
No modal de pré-visualização do modelo (cabeçalho roxo com o nome da peça, editor à esquerda, painel "Campos" no meio e "Classificação" à direita), o documento é cortado embaixo e NÃO aparece barra de rolagem. Uma tentativa anterior mexeu só no editor e não resolveu.

### Causa (é de layout da PÁGINA, não do editor)
O editor só mostra a própria rolagem quando recebe uma altura fixa. Hoje alguma caixa entre o modal e o editor tem altura automática ou falta `min-height: 0`, então o editor cresce do tamanho do documento e o modal corta o excesso.

### O que fazer (só front)
Localize o componente desse modal e monte uma "corrente de altura" do modal até o editor:
1. Modal: altura fixa (ex.: `height: calc(100vh - 48px)`, não só `max-height`), `display:flex; flex-direction:column`.
2. Cabeçalho do modal: `flex: none`.
3. Corpo do modal: `flex:1; min-height:0; display:flex` (o `min-height:0` é o ponto que costuma faltar).
4. Coluna do editor (barras de ferramentas + editor): `flex:1; min-height:0; display:flex; flex-direction:column`; barras `flex:none`.
5. Contêiner do editor: `flex:1; min-height:0`; se o componente de editor tiver propriedade de altura, usar `100%` (nunca `auto`). Se for o Document Editor da Syncfusion: altura explícita + chamar o redimensionamento do componente (`resize()`) logo depois do modal abrir/animar e ao redimensionar a janela.
6. Painel "Campos" e painel "Classificação": cada um com `min-height:0; overflow:auto` (rolam sozinhos; botões "Usar este modelo"/"Mais" fixos no rodapé do painel).
7. Revisar ancestrais com `height:auto` ou `overflow:hidden` que quebrem a corrente. Usar o DevTools: cada caixa do modal até o editor precisa ter altura calculada definida.

### Aceite
- Documento longo rola dentro do editor, com barra visível; régua e barras de ferramentas ficam fixas.
- Painéis laterais rolam independentes; nada é cortado em 1366×768 e em 1920×1080.

## PARTE 2 — INVESTIGAÇÃO (não alterar código; só responder)
Responda cada item com: **Implementado / Parcial / Não implementado**, onde está (descreva por função), como funciona hoje e o que falta.

1. **Peça vira rascunho?** Ao criar uma peça EM BRANCO e ao criar A PARTIR DE UM MODELO: ela é salva como rascunho automaticamente? Quando (ao abrir, ao primeiro edit, autosave periódico, ao fechar)? Aparece na lista "Rascunhos"? O que acontece se o usuário fechar sem salvar? Há diferença entre os dois fluxos?
2. **Permissões em Configurações:** as permissões exibidas na tela de Configurações do Gerador de peças estão ligadas de verdade no back-end (o serviço bloqueia a ação) ou são só visuais? Liste cada permissão da tela e diga se é aplicada no back, só no front, ou em nenhum.
3. **Personalizações do documento:** as personalizações (cabeçalho/rodapé, fonte, margens, dados do escritório etc.) são salvas numa coleção própria, separada dos modelos? Qual a estrutura (campos principais, sem dados reais), se é por escritório ou por usuário, e se os modelos/peças leem dessa coleção ao gerar.

Entregue a Parte 2 como tabela + detalhes curtos por item.

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

Na entrega, inclua a seção **"Explicações"** (o que mudou na Parte 1, por que, versão simples equivalente, como debugar).
