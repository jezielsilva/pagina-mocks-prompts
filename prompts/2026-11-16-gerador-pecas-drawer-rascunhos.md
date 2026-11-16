# Prompt Codex — Gerador de peças: drawer da peça igual ao mock + confirmação ao excluir rascunho

> Cole tudo abaixo no Codex (Luna 6). Siga À RISCA. Não invente nada fora do que está escrito.

---

Você vai mexer em DUAS coisas no módulo **Gerador de peças** (front em Angular, back em .NET com Controller → Business → Repository). Não sei os nomes dos arquivos: **localize no código** pela função descrita. Antes de mudar qualquer coisa, escreva uma **mini-spec** curta: arquivos encontrados, o que vai mudar em cada um e por quê.

NÃO crie testes. NÃO rode testes. NÃO crie mocks de validação.

---

## ITEM 1 — Confirmação antes de excluir um rascunho

### Onde
Na tela **Rascunhos** do Gerador de peças. Cada rascunho aparece como um card (modo Grade) ou uma linha (modo Lista). No canto superior direito do card há um **botão vermelho com ícone de lixeira**.

### Problema
Hoje, ao clicar na lixeira, o rascunho é excluído **na hora**, sem perguntar nada.

### O que fazer
1. Ao clicar na lixeira (no modo Grade **e** no modo Lista), **não exclua ainda**. Abra um **diálogo de confirmação**.
2. Use o **mesmo componente de diálogo de confirmação que o sistema já usa** em outras exclusões (procure como a tela de Documentos ou outra tela do sistema confirma uma exclusão e reutilize). **NÃO crie um componente novo** se já existir um.
3. Conteúdo do diálogo:
   - Título: `Excluir rascunho?`
   - Texto: `O rascunho "<nome da peça>" será excluído e não poderá ser recuperado.` (troque `<nome da peça>` pelo nome da peça do rascunho, ex.: "Ação Declaratória de Inexistência de Relação Jurídico-Tributária").
   - Botões: `Cancelar` (secundário, contorno) e `Excluir` (vermelho/perigo, o mesmo estilo de botão de perigo do sistema).
4. **Cancelar** ou clicar fora/ESC: fecha o diálogo e **não faz nada**.
5. **Excluir**: chama a exclusão que já existe hoje (mesmo endpoint, não mude o back), remove o card da tela e mostra o aviso de sucesso (toast/snackbar padrão do sistema): `Rascunho excluído.`
6. Atualize o contador acima dos cards ("1 rascunho" → "0 rascunhos" / "Nenhum rascunho"), do mesmo jeito que já atualiza hoje.
7. Enquanto a exclusão está em andamento, desabilite o botão `Excluir` do diálogo para não disparar duas vezes.
8. Se der erro no back, mostre o toast de erro padrão do sistema e mantenha o card.

---

## ITEM 2 — Drawer de detalhes da peça: replicar EXATAMENTE o drawer do mock

### Onde
No Gerador de peças, ao clicar em uma peça da biblioteca (card da grade), abre hoje um **painel lateral (drawer)** com cabeçalho roxo, o texto da peça cru à esquerda (com `{{cliente.nome}}`, `{{processo.numero}}` etc.) e à direita "Modelos / Base / Usos / Versão", botões "Usar este modelo", "Criar minha versão", "Adicionar aos favoritos", um botão "⋯" e a lista "Campos do modelo".

### Problema
O drawer atual está diferente do mock aprovado. O usuário quer **o estilo exato do mock**, inclusive a **pré-visualização da folha** já com as **configurações de layout do usuário** (logo, cor, fonte, cabeçalho, rodapé, marca d'água, margens da folha).

### Layout final (copie medidas e cores exatamente)

#### 2.1 Painel (drawer)
- Abre pela **direita**, ocupando a altura toda da tela (top 0, bottom 0, right 0).
- Largura: `min(1240px, 76vw)`.
- Fundo branco `#fff`. Sombra: `-20px 0 40px -20px rgba(15,23,42,.4)`.
- Atrás dele, uma camada escura cobrindo a tela: `rgba(15,23,42,.35)`. Clicar nela fecha o drawer. ESC também fecha.
- Animação de entrada deslizando da direita (~0.2s).
- O painel é uma coluna (flex column): **cabeçalho** em cima, **grade de 2 colunas** embaixo ocupando o resto da altura.

#### 2.2 Cabeçalho (NÃO é mais roxo)
- **Remova o cabeçalho roxo.** O novo cabeçalho tem fundo **branco**, padding `20px 22px`, borda inferior `1px solid` na cor de borda do sistema (cinza claro, `#e2e8f0`).
- Conteúdo, à esquerda, empilhado:
  1. **Badge da categoria** (ex.: "Petição inicial"): pílula com fundo roxo bem claro e texto roxo, fonte pequena (~13px), cantos totalmente arredondados.
  2. **Nome da peça** (ex.: "Ação de Cobrança"): fonte **serifada** (Georgia), **negrito 700**, **21px**, cor do texto principal, margem superior 6px.
  3. Linha cinza pequena (~14px, cor de texto secundário `#64748b`): `<Área> · usado <N> vezes` (ex.: "Direito Civil · usado 48 vezes"). Se a peça for do escritório, acrescente ` · do escritório`.
- À direita: botão só com ícone **X** (fechar), sem fundo, cinza escuro.

#### 2.3 Grade do corpo
- Duas colunas: `grid-template-columns: minmax(0,1fr) 340px`. Altura: o resto do drawer (`flex:1; min-height:0`).
- Coluna esquerda = **pré-visualização da folha**. Coluna direita = **informações e ações**.
- Em telas estreitas (drawer com menos de 760px de largura), vira **uma coluna só**: a folha em cima (mínimo 70vh de altura) e as informações embaixo, com borda superior em vez de borda esquerda.

#### 2.4 Coluna esquerda — pré-visualização da folha
- Fundo **bege** `#efe9e0` (cor de mesa, para a folha branca destacar).
- **Barra superior** (padding `10px 16px`, borda inferior `1px solid #e3dccf`), com:
  - À esquerda, texto pequeno cinza: `Pré-visualização do modelo`.
  - À direita, o **controle de zoom em pílula**: fundo branco, borda `1px solid #e2e8f0`, `border-radius:999px`, padding 2px. Dentro: botão `−`, o percentual (`100%`, 14px, cinza, min-width 38px, centralizado), botão `+` e um botão com ícone de **camadas** (title "Ajustar à tela") que volta ao tamanho que cabe na tela. Botões sem borda, 34×30px, redondos, hover com fundo cinza clarinho `#f1f5f9`.
  - Zoom: passos de 10%, mínimo 50%, máximo 250%. A **folha inteira** escala (use `zoom` ou `transform: scale` na folha), não só a fonte.
- **Área de rolagem** abaixo da barra: `flex:1; overflow:auto; padding:12px`, a folha **centralizada horizontalmente** e alinhada no topo.
- **A folha (página A4)**:
  - Fundo branco, proporção **A4 retrato (210×297)**, largura base de 600px antes do zoom, sombra `0 4px 18px -6px rgba(15,23,42,.35)`.
  - Ao abrir o drawer, calcule um zoom inicial que faça a folha **caber inteira** na área (largura e altura), com mínimo de 30%, e multiplique pelo zoom escolhido.
  - Barra de rolagem vertical aparece se a folha passar da altura (como no mock).

##### O que vai DENTRO da folha (usar as configurações do usuário)
A folha deve ser renderizada **com as mesmas configurações de layout que o usuário salvou no modal Configurações do Gerador** (as mesmas usadas na geração do documento/download). Busque essas configurações do back (o endpoint que já existe para elas; se a tela já as carrega, reutilize). **Nada fixo no front.** Aplique:

1. **Margens da folha**: as margens configuradas (superior, inferior, esquerda, direita), proporcionais ao tamanho da folha. Se não houver configuração, use o padrão ABNT 3 cm / 2 cm / 3 cm / 2 cm (sup/inf/esq/dir).
2. **Fonte das peças**: a fonte configurada (ex.: Georgia/Times), tamanho proporcional, texto **justificado**, parágrafos com recuo de primeira linha de 2,5em, espaço de 10px entre parágrafos.
3. **Cabeçalho** (topo da folha):
   - À esquerda, o **logo do escritório** (imagem configurada). Se não tiver imagem, um quadrado de cantos arredondados (8px) na **Cor do logo** configurada, com as **iniciais** do escritório em branco e negrito.
   - Ao lado do logo: **nome do escritório** em negrito e, abaixo, em fonte menor e cinza (`#555`): `OAB/UF número · endereço · telefone` (dados do escritório configurados).
   - Embaixo do cabeçalho, uma **linha horizontal fina na Cor do logo**.
   - Logo abaixo, uma linha bem pequena e cinza: `Processo nº [Número do processo] · [Vara] · Cliente: [Nome]`.
4. **Corpo**: o texto do modelo. Os campos variáveis (hoje aparecem como `{{cliente.nome}}`, `{{processo.numero}}` etc.) **NÃO aparecem com chaves**. Mostre cada campo como uma **etiqueta legível** entre colchetes, em **itálico, sublinhada, cor laranja escura** (ex.: `[Nome]`, `[Número do processo]`, `[Vara]`, `[Comarca]`, `[UF]`, `[CPF]`, `[Valor da causa]`, `[Advogado(a)]`, `[OAB]`), com fundo amarelo bem claro. Use o **nome amigável** do campo (o mesmo rótulo que hoje aparece em "Campos do modelo", ex.: "Número do processo"), não a chave técnica. Títulos (ex.: "AÇÃO DE COBRANÇA") centralizados, negrito, maiúsculas.
5. **Marca d'água**: se o usuário configurou marca d'água, desenhe-a centralizada atrás do texto, ocupando ~55% da largura, com a opacidade configurada (padrão 8%). Se não configurou, não desenhe.
6. **Assinatura** (no fim): `[Comarca], [Data da peça].` centralizado; uma linha horizontal de assinatura; abaixo `[Advogado(a)]` e `[OAB]` centralizados.
7. **Rodapé**: linha horizontal fina na Cor do logo e, abaixo, centralizado e pequeno/cinza, o texto de rodapé configurado (ex.: e-mail · site do escritório).

> A pré-visualização tem que bater com o arquivo baixado: mesmo layout, mesmas margens, mesma fonte. Se já existe no back uma rotina que monta o HTML/documento da peça com essas configurações (a mesma do download), **reutilize ela** para gerar a pré-visualização (ex.: um endpoint que devolve o HTML da peça com o layout aplicado e os campos como etiquetas) em vez de duplicar a montagem no front. O front só exibe.

#### 2.5 Coluna direita — informações e ações
- Padding `18px`, borda esquerda `1px solid #e2e8f0`, rolagem própria (`overflow:auto`), coluna com espaço de `12px` entre blocos.
- Ordem dos blocos:
  1. Rótulo **"Classificação"** (rótulo de seção: negrito, ~15px, cor de texto principal).
  2. **Caixa da classificação**: fundo roxo bem claro (a cor "primary-lightest" do tema), texto roxo escuro (primary-dark), negrito 600, padding `10px 12px`, `border-radius:12px`, ícone de **etiqueta (tag)** à esquerda. Texto: o caminho completo `Categoria › Subcategoria › Tipo` (ex.: "Petições iniciais › Direito Civil › Ação de Cobrança"). Se não tiver, `Sem classificação`.
  3. **Lista de dados** em grade de 2 colunas (`grid-template-columns:auto 1fr; gap:6px 12px; font-size:14.5px`), rótulo cinza à esquerda e valor em negrito 600 à direita, nesta ordem:
     - `Origem` → `Sistema` ou `Escritório`
     - `Base` → `Processo` ou `Cliente`
     - `Usado` → `48 vezes`
     - `Versão` → `3 · atualizado em 28/10` (número da versão + data da última atualização em dd/MM)
     - `Obrigatórios` → nomes amigáveis dos campos obrigatórios separados por vírgula (ex.: `CPF, Valor da causa`), ou `—`
     - `Layout` → `Template do escritório` se o usuário tem layout configurado, senão `Padrão`
  4. Rótulo **"Preenche sozinho"**.
  5. **Pílulas** com os campos que o sistema preenche automaticamente nesse modelo: cada uma com ícone de ✓ pequeno + nome amigável (ex.: "Número do processo", "Vara e comarca", "Autores e réus", "Qualificação do cliente", "Valor por extenso", "Data por extenso", "Advogado e OAB"). Estilo: `display:inline-flex; gap:4px; font-size:14px; padding:4px 10px; border-radius:999px; background:#fff; border:1px solid #e2e8f0`. Quebram linha (`flex-wrap:wrap; gap:6px`). A lista vem do back (campos do modelo), o front só exibe.
  6. **Ações, coladas no fim da coluna** (`margin-top:auto`, coluna com gap 8px):
     - Botão principal **"Usar este modelo"** com ícone de caneta: roxo, largura total, **altura 48px**, fonte 16px, cantos bem arredondados.
     - Abaixo, uma linha com **2 botões de contorno lado a lado** (grade `1fr 1fr`, gap 8px):
       - **"Favoritar"** / **"Desfavoritar"** (com ícone de estrela, alterna conforme o estado).
       - **"Mais ⋮"** (ícone de 3 pontinhos verticais à direita do texto): abre o menu de opções.

- **Remova** do drawer: o bloco "Campos do modelo" (a lista com "Número do processo / Processo · NumeroProcesso" etc.), o botão "Criar minha versão" solto e o texto cru com `{{ }}`. Agora a informação de campos está na própria folha (etiquetas) e em "Preenche sozinho".

#### 2.6 Menu "Mais"
- Abre logo abaixo/acima do botão "Mais", card branco com borda clara, sombra e cantos arredondados (o mesmo estilo do menu "⋯" atual).
- Itens, cada um com ícone à esquerda:
  1. `Criar minha versão` (ícone de lápis) — mesma ação que o botão antigo fazia.
  2. `Baixar modelo em branco (.docx)`
  3. `Baixar modelo em branco (.pdf)`
- **NÃO coloque** no menu: `Usar modelo`, `Pré-visualizar`, `Adicionar aos favoritos` (já estão no drawer) e **remova o item `Ver campos usados`** — a folha do drawer já mostra os campos.
- Esse item `Ver campos usados` deve sair **somente do menu dentro do drawer**. Se o mesmo menu "⋯" for usado no card da grade da biblioteca, mantenha lá como está (não mude o menu do card).

#### 2.7 Comportamento
- Abrir o drawer: busca os dados da peça + configurações de layout; enquanto carrega, mostre um esqueleto/spinner na área da folha (padrão do sistema).
- Fechar: X, clique na camada escura ou ESC.
- "Usar este modelo": mesma ação de hoje.
- "Favoritar": mesma ação de hoje; atualiza o texto do botão sem fechar o drawer.
- O zoom escolhido é mantido enquanto o drawer estiver aberto; ao abrir de novo, volta a "Ajustar à tela".
- Acessibilidade: o drawer tem `role="dialog"` e `aria-label` com o nome da peça; botões de zoom com `aria-label` ("Diminuir zoom", "Aumentar zoom", "Ajustar à tela").

#### 2.8 Referência visual
O usuário tem o **mock aprovado** do Gerador de peças (drawer largo com a folha à esquerda e os dados à direita). Se você tiver acesso a ele, o resultado tem que ficar **idêntico**. As medidas e cores acima foram tiradas dele.

---

## Regras gerais
- Front "burro": regra de negócio (quais campos preenchem sozinho, obrigatórios, montagem do layout da folha, versão) fica no **back**. O front só exibe.
- Reutilize componentes, estilos, ícones e serviços que já existem (diálogo de confirmação, toast, botões, menu). Só crie algo novo se não houver equivalente.
- Não altere outras telas.

ESTILO DE CÓDIGO (perfil do Jeziel — obrigatório)
- Nomes mistos: domínio em português (ObterCliente, valorTotal), termos técnicos em inglês (Repository, GetById).
- Comentário-resumo em português no topo de cada método.
- Retorno antecipado; if de uma linha sem chaves; ternário só simples; switch clássico; var.
- Nulos: ?. e ?? liberados em cadeia curta (até 2 ?. + ?? no fim) com comentário de 1 linha; se "" também precisar virar padrão, string.IsNullOrWhiteSpace(x) ? "padrão" : x com comentário de 1 linha; em TS nunca usar || para valor padrão.
- LINQ básico encadeado (um operador por linha). Avançado só com comentário explicando.
- Back: seguir Controller → Business → Repository; sem genéricos/extension methods novos; Model→DTO manual; erro de negócio com objeto de resultado; Mongo com $set só dos campos alterados.
- Front: subscribe simples atribuindo em variáveis + takeUntilDestroyed(this.destroyRef) com inject(DestroyRef) (comentário de 1 linha: por que a fonte não termina sozinha e que o pipe encerra a assinatura ao fechar a tela); RxJS além de map/filter/tap só com explicação; template só exibe e condições simples.
- Valores fixos direto no código (constante só se repetir ou for regra configurável).
- Clean code/boas práticas: aplique, mas EXPLIQUE antes (na mini-spec) e na entrega.
- Todo trecho avançado: comentário curto em português no código + seção "Explicações" na entrega (o que faz, por que, versão simples equivalente, como debugar).
- Prefira variáveis intermediárias nomeadas (bom para breakpoint) a expressões longas.

## Entrega
1. Lista de arquivos alterados/criados, com uma linha do que mudou em cada um.
2. Seção **"Explicações"** (conforme o ESTILO DE CÓDIGO).
3. Checklist conferido: ☐ confirmação ao excluir rascunho (Grade e Lista) ☐ drawer sem cabeçalho roxo, igual ao mock ☐ folha A4 com logo, cor, fonte, margens, marca d'água, cabeçalho e rodapé do usuário ☐ campos como etiquetas `[Nome]` ☐ zoom em pílula ☐ coluna direita (Classificação, dados, Preenche sozinho, ações) ☐ menu "Mais" sem "Ver campos usados".
