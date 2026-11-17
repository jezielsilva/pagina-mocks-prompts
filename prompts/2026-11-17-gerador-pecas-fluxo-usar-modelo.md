# Prompt Codex: Gerador de peças, fluxo "usar modelo" (modal de nova peça, erro 400 e etapas iguais ao mock)

> Cole tudo abaixo no Codex (Luna). Siga À RISCA. Não invente nada fora do que está escrito. Se algo não bater com o código, PARE e pergunte. Não adivinhe.

---

## 0. Antes de começar (obrigatório)

1. Leia o arquivo de instruções de agentes da raiz do repositório do front e o guia de UI-Kit da pasta de agentes. As regras deles valem mais que o seu gosto.
2. Abra o **mock do Gerador de peças** no portal (item fixo "Mock: Gerador de peças") e percorra este caminho:
   1. clique em qualquer modelo da biblioteca;
   2. clique em **"Usar este modelo"**;
   3. veja a tela **"De onde vêm os dados da peça?"** (4 cards: Processo, Cliente, Fornecedor, Preencher manualmente);
   4. escolha **Processo**, selecione um processo e veja o bloco **"Partes do processo"**;
   5. clique em **Continuar** para a **Revisão dos campos**;
   6. clique em **Continuar** para **Salvar peça**;
   7. clique em **Gerar peça** para a tela **"Peça gerada"**;
   8. volte e teste também **Preencher manualmente** (passo a passo por grupos).

   **Esse fluxo do mock é a referência visual e de comportamento.** Deixe-o aberto do lado enquanto codifica.
3. Não vou passar nomes de arquivos. **Localize no código pela função descrita.** Tudo o que precisa já existe no módulo: o assistente de 3 etapas (origem, revisão e salvar), a modal de cadastro de partes, a modal de novo modelo, o facade do assistente e os endpoints de revisão e geração. **Você vai corrigir e refazer o visual, não criar um módulo novo.**
4. Antes de mudar qualquer coisa, escreva uma **mini-spec** curta: arquivos encontrados (front e back), o que vai mudar em cada um e por quê.
5. **NÃO** crie testes. **NÃO** rode testes, lint nem navegador. A validação é **só o build** do front (e do back, se mexer nele).
6. **NÃO** crie índice, coleção nem migração de banco. **NÃO** altere arquivos de variáveis de cor gerados automaticamente nem estilos globais.
7. Todo texto novo de interface vai para o arquivo central de mensagens do front, em pt-BR. Nada de texto fixo no HTML/TS.
8. Botões: sempre o componente de botão compartilhado (`e-button`), **quadrado** (formato padrão, sem a entrada de arredondado). Ação primária sempre **à direita**.

---

## ITEM 1: BUG. Erro 400 na "Revisão dos campos" (código f9512c80)

### Sintoma

Na biblioteca, o usuário usa a frase **"Quero fazer [peça] para [processo]"**, escolhe a peça "Agravo Interno contra decisão que nega efeito suspensivo a recurso" e um processo. O assistente abre direto na etapa 2 (**Revisão dos campos**) e mostra:

> Não foi possível concluir a ação. Confira os dados informados para revisar a peça. (f9512c80)

Também aparecem o botão "Tentar novamente", o "Continuar" desabilitado e nenhum campo ou prévia.

### O que JÁ FOI VERIFICADO no código (confie, não refaça)

- O código **f9512c80** é o mapeamento do filtro de erros do controller do gerador para **revisar peça + HTTP 400** (resultado de negócio "pedido inválido"). Então o back **recusou o pedido**. Não é erro de rede nem de permissão.
- O front monta o pedido da revisão com: `origem`, `registroId` (id do processo escolhido), `versaoModelo`, `valoresManuais` e `escolhasGenero`.
- O id do processo da frase vem da mesma lista de processos do autocomplete do sistema, que devolve `id` como texto. Em tese é um ObjectId válido.
- No back, o Business de revisão devolve "pedido inválido" (400) em **qualquer** um destes casos:
  1. pedido nulo ou `versaoModelo < 1`;
  2. `origem` fora de `manual | processo | prazo | cliente | fornecedor`;
  3. origem diferente de manual com `registroId` que **não é ObjectId**, ou origem manual **com** `registroId`;
  4. `escolhasGenero` ou `valoresManuais` nulos, com mais de 200 itens, valor de gênero diferente de `masculino`/`feminino`, ou valor manual do tipo objeto ou maior que 8000 caracteres;
  5. `valoresManuais` com **chave que não existe nos campos do modelo** (tanto no modelo HTML quanto no modelo do editor);
  6. modelo do **editor** (com conteúdo JSON) cujo processamento do documento lança exceção (o processador transforma `ArgumentException`, `InvalidOperationException`, `JsonException`, `FormatException` e `OverflowException` em "pedido inválido");
  7. o resolvedor dos dados da origem recusando o `registroId`.

### Como investigar (nesta ordem; pare no primeiro que explicar)

1. **Network:** reproduza o erro com o DevTools aberto. Copie o **corpo do POST de revisão** e a **resposta**. Confira os itens 1 a 4 e 7 acima só olhando o payload.
2. **Chaves manuais (item 5):** se `valoresManuais` vier com chaves, compare com os campos do modelo (GET do modelo por id). Um caso provável é o **rascunho de outro modelo/versão** reaproveitado, ou valores que ficaram no estado do assistente de uma sessão anterior.
3. **Documento do editor (item 6):** se o modelo tiver conteúdo JSON (modelos novos cadastrados pelo gerenciador de peças), coloque um log temporário no `catch` do processador com a mensagem da exceção e o id do modelo. Reproduza e veja qual exceção é.
4. Mostre a causa com a prova (payload, log ou trecho) **antes** de corrigir.

### Como corrigir

- Corrija **a causa**, no lado certo (front se o pedido sai errado; back se o conteúdo é válido e o processamento falha).
- **Não afrouxe validação** do back para "passar". Se a causa for conteúdo de modelo inválido no banco, **não altere o banco**: pare e me devolva o id e o nome do modelo.
- Quando a revisão falhar, a mensagem precisa dizer **o que fazer**, e não apenas "confira os dados". Se a API devolver uma mensagem específica (o processador já devolve "Não foi possível preparar o documento…"), mostre essa mensagem no alerta.
- Remova os logs temporários antes de entregar.

---

## ITEM 2: Nova entrada do fluxo. Escolheu peça + processo → abre a modal de nova peça

### Hoje

Na biblioteca, a frase **"Quero fazer [peça] para [processo]"**: quando as duas escolhas estão feitas, o sistema abre o assistente **direto na Revisão dos campos**.

### Como deve ficar

1. Quando o usuário escolher a **peça** e o **processo** na frase, **não abra o assistente direto**. Abra a **modal de novo modelo que já existe** (a mesma do botão "Novo modelo": nome, Categoria/Subcategoria/Tipo e "Começar"), **já preenchida**:
   - **Nome:** o nome da peça escolhida;
   - **Categoria, Subcategoria e Tipo:** a classificação do modelo escolhido (o detalhe do modelo traz o id do tipo; derive a subcategoria e a categoria pelo catálogo de classificações, o mesmo que a modal já carrega);
   - **Começar:** "A partir de um modelo pronto", com o modelo escolhido selecionado (ver item 3).
2. O usuário pode trocar qualquer coisa antes de confirmar.
3. O botão primário **continua com o mesmo texto de hoje** ("Criar e abrir no editor"). **Não mude o texto.**
4. Ao confirmar, quando a modal foi aberta **por esta frase** (peça + processo), **feche a modal e abra o assistente na etapa 1 (Origem dos dados)**, com:
   - o modelo escolhido (ou o de base, se o usuário trocou);
   - a origem **Processo** já selecionada e o processo da frase já marcado na lista;
   - o bloco **"Partes do processo"** já carregado (item 4).
   - **Não pule para a revisão.** O usuário confere a origem e clica em Continuar.
5. Quando a modal é aberta pelo botão **"Novo modelo"** (sem processo), o comportamento atual continua igual (abre o editor de modelo do drawer). Use uma entrada da modal (ex.: um modo/origem da abertura) para distinguir os dois casos. **Não crie uma segunda modal.**
6. Se o usuário **fechar/cancelar** a modal, limpe a peça e o processo da frase, para não reabrir sozinho.

> Se a regra do item 4 (abrir o assistente em vez do editor) conflitar com algo que o código já faz, por exemplo criar um modelo do escritório no back ao confirmar, **pare e me pergunte** antes de seguir.

---

## ITEM 3: Modal de novo modelo, com classificação obrigatória

### Hoje

Categoria, Subcategoria e Tipo têm a opção **"Escolher depois"**, e o usuário consegue criar sem classificar.

### Como deve ficar

1. **Remova a opção "Escolher depois"** dos três selects. Remova também a mensagem do arquivo central se ela ficar sem uso.
2. Os três passam a ser **obrigatórios**: Categoria → habilita Subcategoria → habilita Tipo (a cascata atual continua).
3. Ao clicar em criar sem algum dos três, **não feche a modal**: marque o campo inválido com o feedback padrão do sistema (borda e texto de erro abaixo, como o campo Nome já faz). Mensagens:
   - "Escolha a categoria."
   - "Escolha a subcategoria."
   - "Escolha o tipo da peça."
4. **"Começar"** (toggle Em branco / A partir de um modelo pronto):
   - **Em branco:** como hoje;
   - **A partir de um modelo pronto:** mostre, logo abaixo do toggle, um **autocomplete do sistema** (o mesmo componente de autocomplete usado na frase "Quero fazer [peça]") com os modelos **visíveis ao escritório** daquele **Tipo**. Se o tipo não tiver modelo, liste todos e mostre o aviso "Nenhum modelo deste tipo. Escolha outro ou comece em branco." É obrigatório quando essa opção estiver marcada ("Escolha o modelo base.").
5. Ordem dos botões: "Cancelar" à esquerda e o primário à direita (como já está).

---

## ITEM 4: Etapa 1, "De onde vêm os dados da peça?", igual ao mock

Refaça o visual da etapa de origem que já existe, seguindo o mock. **A lógica atual (buscar registros, verificar acesso por origem, cadastro de partes) continua.** Mexa só no que for preciso para o comportamento abaixo.

### 4.1 Topo do assistente (vale para as 3 etapas)

Hoje há um botão "Modelos", o título e **um badge azul repetindo o mesmo título**, além de uma barra de progresso larga. Troque por:

- à esquerda: botão **"← Modelos"** (volta para a biblioteca, passando pela confirmação de saída que já existe);
- ao lado: **nome do modelo** (uma linha, com reticências se não couber) e, embaixo, em texto menor e cor secundária, o **caminho da classificação** (Categoria › Subcategoria › Tipo);
- **remova o badge azul duplicado** com o nome do modelo;
- à direita, no mesmo topo: o **indicador de etapas** compacto do mock, com 3 etapas (Origem dos dados, Revisão dos campos, Salvar peça), círculo numerado e texto. Etapa atual em roxo preenchido; concluída em verde com ✓; futura com contorno cinza; separador curto entre elas. Se o componente de etapas do sistema tiver uma variante compacta horizontal, use-a; se não tiver, **remova a barra de progresso larga** ("2 de 3") e deixe só o indicador.
- Tudo dentro de **um card** (superfície branca, borda do tema, raio do card padrão). O rodapé de ações fica **dentro do card**, separado por uma linha.

### 4.2 Os 4 cards de origem

- Título da seção: **"De onde vêm os dados da peça?"** (`var(--font-head)`, 15px, semibold).
- Grade de **4 colunas iguais** (`repeat(4, minmax(0,1fr))`, gap 14px); **2 colunas** abaixo de ~900px; **1 coluna** no celular.
- Cada card é um **botão** com ícone em quadrado arredondado, título em negrito e descrição em cor secundária, com altura mínima de 132px, padding de 18px, borda de 1px e raio de 16px:
  - **Processo** (ícone de balança): "Partes, vara, tribunal e cliente do processo";
  - **Cliente** (ícone de pessoas): "Qualificação completa do cliente";
  - **Fornecedor** (ícone de caminhão): "Dados do fornecedor (contratos, notificações)";
  - **Preencher manualmente** (ícone de lápis): "Passo a passo guiado, campo por campo".
- Selecionado: borda e fundo leve na cor primária (tokens do tema), com `aria-pressed="true"`.
- O card da **origem recomendada do modelo** ganha o badge **"Recomendado"** ao lado do título (componente de badge do sistema).
- Sem acesso àquela origem: card desabilitado (`cursor: default`) com o motivo em texto pequeno (o assistente já verifica acesso por origem; só exiba).
- **Trocar de origem:**
  - se a escolha for diferente da recomendada, ou se já houver um registro selecionado, abra uma **modal de confirmação** como no mock: "Gerar com base em <origem>?", com o comparativo "Este modelo foi feito para X → Você escolheu Y", a lista dos campos que vão ficar vazios e o aviso de que a seleção atual será descartada. Botões: "Manter <origem atual>" (esquerda) e "Usar <nova origem>" (direita, primário);
  - com origem diferente da recomendada, mostre abaixo dos cards um alerta de atenção (`e-alert` tipo warning): "Gerando com base em <origem>, mas este modelo foi feito para <recomendada>. Alguns campos ficarão vazios na revisão."
  - A lista de "campos que ficam vazios" deve vir dos campos do modelo × campos que a origem preenche sozinha (o detalhe do modelo já traz os automáticos da origem recomendada). Se não houver dado para calcular isso no front, mostre só o aviso, sem a lista, e me avise.

### 4.3 Busca e lista de registros (Processo, Cliente, Fornecedor)

- Abaixo dos cards: campo de busca com ícone de lupa e placeholder conforme a origem:
  - "Buscar por número, parte ou cliente…";
  - "Buscar cliente por nome ou CPF…";
  - "Buscar fornecedor…".
- Lista em **um bloco com borda** (raio de 12px, altura máxima de 320px com rolagem). Cada linha tem: um quadradinho de seleção à esquerda, título em negrito (processo em formato CNJ / nome), subtítulo em cor secundária (cliente, vara / CPF) e uma seta `›` à direita. A linha selecionada fica marcada.
- **"Gerar em lote"** aparece no mock, mas **não implemente agora** (fora do escopo).

### 4.4 Bloco "Partes do processo" (só origem Processo, com processo selecionado)

- Abaixo da lista: card com o título **"Partes do processo"** (ícone de pessoas) e, à direita, o resumo "N sem cadastro em Clientes" (cor de atenção) ou "todas cadastradas".
- Uma linha por parte: badge **Autor** ou **Réu**, nome e, à direita:
  - já é cliente: "✓ Cliente cadastrado" (cor positiva);
  - não é cliente: checkbox **"Cadastrar como cliente"**.
- Autores vêm **marcados**; a parte contrária (réu) vem **desmarcada**.
- Texto de ajuda embaixo: "Marcadas são cadastradas antes da revisão. Desmarcadas entram só nesta peça. A parte contrária (réu) vem desmarcada."
- Com N marcadas, o botão Continuar vira **"Cadastrar N e continuar"**.
- Use os dados e o cadastro de partes que **já existem** no módulo (modal de cadastro de partes e o resolvedor de partes do back). **Não crie endpoint novo.** Se faltar dado para montar a lista (papel da parte, se já é cliente), pare e me diga o que falta.

### 4.5 Preencher manualmente

- Ao escolher, mostre o alerta positivo: "Você vai preencher os campos em etapas curtas (Partes, Processo, Valores…), vendo a peça ser montada ao lado."
- **Não precisa** do passo a passo do mock por grupos agora: Continuar leva para a Revisão dos campos com todos os campos vazios.

### 4.6 Rodapé da etapa

- À esquerda, texto informativo em cor secundária: "Dica: abrindo o gerador de dentro de um processo, ele já vem selecionado."
- À direita: "Cancelar" (secundário) e **"Continuar ›"** (primário), desabilitado até haver origem manual ou registro selecionado.

---

## ITEM 5: Etapa 2, "Revisão dos campos", igual ao mock (sem o editor de texto)

- Layout em **2 colunas**: campos à esquerda (`minmax(320px, 400px)`) e a **folha A4 de prévia** à direita (o resto). Uma coluna só no celular (campos em cima).
- **Topo da coluna de campos:**
  - se houver campos sem dado: alerta de atenção "**N campos sem dado** no cadastro. Complete aqui mesmo ou deixe em branco para preencher depois no editor.";
  - se não houver: alerta positivo "**Tudo preenchido.** Confira a peça ao lado antes de continuar.";
  - se a origem for diferente da recomendada: alerta de atenção "Peça gerada com base em <origem> (o modelo é de <recomendada>)."
- **Grupos de campos** (os grupos que a API de revisão devolve): cada grupo é uma seção recolhível com borda e raio de 14px. O cabeçalho tem ícone, nome do grupo e, à direita, "N pendentes" (atenção) ou "X de X ✓".
  - **Só um grupo aberto por vez.** Ao abrir um, os outros fecham. Abre primeiro o grupo que tiver pendência.
- **Cada campo:** ícone de status à esquerda (✓ verde preenchido / ⚠ atenção vazio), rótulo (`var(--font-head)`, 14px, cor secundária) e o input. Campo vazio fica com borda e fundo de atenção (tokens do tema). Se o campo tiver formato (data por extenso, valor por extenso), mostre a dica embaixo, com ícone pequeno.
- **Prévia:** a folha A4 com as **configurações salvas do usuário** (identidade e papel timbrado, se ativado), reaproveitando o componente de folha que já existe, como no drawer da biblioteca. Acima, em texto pequeno: "Pré-visualização · clique num campo destacado para editá-lo". Embaixo: "Página 1 de 1".
  - Clicar numa variável destacada na folha **abre o grupo e foca o input** daquele campo (o componente de prévia já emite o campo selecionado; ligue isso).
  - Editar um campo atualiza a folha (a revisão já é refeita com debounce; mantenha).
- **NÃO** coloque o painel lateral de campos para arrastar/inserir nem o editor de texto. Isso virá com o editor de texto, depois.
- **Rodapé:**
  - à esquerda: "Dados de: <processo/cliente/fornecedor>" ou "Dados de: preenchimento manual";
  - à direita: "← Voltar" (secundário) e "Continuar ›" (primário).
  - Continuar segue liberado mesmo com campos vazios (a peça sai com o espaço destacado). Bloqueie **só** se a API disser que não pode gerar (`podeGerar` falso), e nesse caso mostre o motivo.

---

## ITEM 6: Etapa 3, "Salvar peça", igual ao mock

- Layout em 2 colunas: formulário à esquerda e, à direita (300px), a **mini prévia** da folha com o título "Prévia".
- No topo, a **checagem final**:
  - com campos vazios: alerta de atenção "**Checagem final:** N campos ainda vazios (A, B, C…). A peça sai com o espaço destacado.";
  - sem campos vazios: alerta positivo "**Checagem final:** dados conferidos."
- **Formulário** (rótulos com `var(--font-head)`):
  - **Nome do arquivo** (largura toda), pré-preenchido como "<nome do modelo> — <número do processo> — <nome do cliente>", sem traços sobrando quando faltar parte. Mantenha a validação de nome que já existe;
  - **Salvar em** (pasta): as opções que o fluxo de salvar já oferece hoje;
  - **Classificação:** select com as classificações (agrupadas por Categoria › Subcategoria), já selecionando o **tipo do modelo**. Embaixo, em texto pequeno: "Vem do modelo. A peça já entra classificada em Documentos.";
  - **Vincular a** (largura toda): o que o fluxo atual já suporta (processo, prazo, tarefa, não vincular). **Não invente** vínculo que a API não aceita;
  - **Formatos:** opções selecionáveis "Word (.docx)" e "PDF" (pelo menos uma marcada).
- **Rodapé:**
  - à esquerda: "O original do modelo não é alterado";
  - à direita: "← Voltar", "Abrir no editor" (desabilitado, com o tooltip "Em breve") e **"✓ Gerar peça"** (primário).
- **Gerar:** use o endpoint de geração que já existe. Não use tela de carregamento global: botão em carregamento e UI utilizável. Sucesso → tela "Peça gerada".

### 6.1 Tela "Peça gerada"

- Card com a mini prévia à esquerda e, à direita:
  - ícone de sucesso, o título "Peça gerada" e o subtítulo "Já está em Documentos, classificada e vinculada.";
  - uma lista de dados: Arquivo, Salvo em, Classificação (Categoria › Subcategoria › **Tipo**), Vinculado a e Modelo (nome · versão);
  - as ações: "Baixar .docx" (primário), "Baixar PDF", "Abrir no editor" (desabilitado, "Em breve") e "Ver em Documentos";
  - o link "← Voltar aos modelos".
- "Enviar ao cliente" do mock fica **fora do escopo**.
- Se já existir uma tela de peça concluída no módulo, **ajuste a existente**. Não crie outra.

---

## Fora do escopo (NÃO faça)

- Editor de texto (Word) e o painel lateral de campos para inserir.
- Gerar em lote.
- Passo a passo por grupos do "Preencher manualmente".
- Enviar ao cliente.
- Qualquer alteração de banco ou de regra de negócio no back que não seja a correção do item 1. Se precisar, **pergunte**.

---

## Regras visuais (checar em todo SCSS/HTML tocado)

- Só tokens de cor do tema. Sem hex novo, `rgba()`, gradiente, `box-shadow` novo nem `!important`.
- Nada de faixa colorida em um lado só de card ("borda de IA").
- Botão desabilitado com `cursor: default`.
- Nada de `<br>` para espaçamento; use utilitários e gap.
- `@if`/`@for` (nunca `*ngIf`/`*ngFor`); ordem de atributos do lint; sem estilo inline.
- Títulos e rótulos com `var(--font-head)`; texto com `var(--font-body)`.
- Alertas inline com o componente de alerta do sistema (só título, tipo e mensagem).

---

## Checklist final

- [ ] Causa do 400 (f9512c80) explicada com prova e corrigida na origem.
- [ ] Peça + processo na frase → modal de novo modelo preenchida → assistente na etapa 1 com processo e partes já carregados.
- [ ] Modal sem "Escolher depois"; categoria/subcategoria/tipo obrigatórios; "A partir de um modelo" com escolha do modelo.
- [ ] Topo do assistente sem o badge duplicado e com o indicador de etapas compacto.
- [ ] Etapa 1 com os 4 cards, Recomendado, troca de origem com confirmação, busca/lista e Partes do processo.
- [ ] Etapa 2 com grupos (um aberto por vez), status por campo e prévia A4 com as configurações do usuário, sem o editor.
- [ ] Etapa 3 com checagem final, formulário, mini prévia e geração; tela "Peça gerada".
- [ ] Botões `e-button` quadrados; primário à direita.
- [ ] Logs temporários e código morto removidos.
- [ ] Build do front passou (e do back, se mexeu).

---

ESTILO DE CÓDIGO (perfil do Jeziel, obrigatório)

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

---

## Entrega

1. A mini-spec (antes de codar).
2. A causa exata do erro 400, com a prova.
3. Resumo curto do que mudou, por item (1 a 6).
4. Lista de arquivos alterados/criados.
5. Seção **"Explicações"** para cada trecho avançado.
6. Log de evolução da feature em `docs/logs-evolucao` (um por branch; atualize se já existir) e a atualização da regra de negócio do fluxo (classificação obrigatória e nova entrada peça + processo) em `docs/business-rules`.
