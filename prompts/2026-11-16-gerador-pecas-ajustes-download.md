# PROMPT PARA O CODEX (Luna 6) — Gerador de peças: 4 ajustes de tela + correção do download (DOCX/PDF)

Você vai trabalhar no módulo **Gerador de peças** (front Angular + back .NET). LEIA TUDO antes de começar. Faça os itens NA ORDEM. Não pule nenhum. Não invente telas novas: só altere o que está descrito. Se algo não existir com o nome que eu imaginei, LOCALIZE no código pela função descrita (use busca por texto visível na tela, ex.: "Quero fazer", "Cor do logo", "Mostrando", "Página", "Fonte das peças").

Antes de codar, me entregue uma **mini-spec** (lista curta): para cada item, quais arquivos você vai mexer e o que muda. Depois implemente.

---

## ITEM 1 — Campo "Peça" (autocomplete da barra "Quero fazer ... para ...") está apertado

**Onde:** na aba Biblioteca, card do topo com o texto "Quero fazer [Peça] para [Processo] · os dados entram sozinhos".

**Problema:** o campo "Peça" está estreito (~220px). O nome selecionado aparece cortado ("Agravo Interno (execu...") e as opções do dropdown também ficam cortadas com reticências ("Agravo Interno (Regim...", "Agravo Interno contra ...").

**O que fazer:**
1. Aumentar a largura do campo "Peça" para **mínimo 360px** (sugestão: `min-width: 360px; width: 420px;` e `flex: 1 1 420px` se o container for flex). Deve ficar visivelmente mais largo que o campo "Processo".
2. O **painel do dropdown** (lista de opções que abre embaixo) deve ter **no mínimo a mesma largura do campo** e pode passar dela: `min-width: 100%` do campo e `max-width: 560px`. Se for `mat-select`/`mat-autocomplete`, use a propriedade de largura do painel (`panelWidth` no autocomplete / classe CSS no `panelClass` do select) — NÃO use `::ng-deep` global sem escopo; se precisar de estilo de overlay, crie uma classe específica (ex.: `peca-select-panel`) e coloque no `panelClass`.
3. As opções do dropdown devem **quebrar linha** em vez de cortar com "...": `white-space: normal; line-height: 1.3; height: auto; padding-block: 8px;`. O texto do valor selecionado dentro do campo pode continuar com reticências, mas com a largura nova deve caber a maioria dos nomes.
4. O campo de busca dentro do dropdown deve ocupar 100% da largura do painel.
5. Em telas estreitas (< 900px), a linha pode quebrar: "Peça" e "Processo" ficam um embaixo do outro com 100% de largura. Não pode aparecer scroll horizontal.

**Pronto quando:** "Agravo Interno (execução)" aparece inteiro no campo e as opções longas aparecem inteiras no dropdown (em 2 linhas se precisar).

---

## ITEM 2 — Modal "Classificações", aba "Logs": paginação incompleta

**Onde:** botão "Classificações" no painel lateral direito → abre a modal roxa "Classificações" → aba "Logs".

**Problema:** o rodapé de paginação dessa aba mostra só "Mostrando 1–10 de 15 | ‹ Página 1 de 2 ›". Há uma barrinha vertical solta à esquerda do "Mostrando" (sobra de um bloco que não renderiza) e faltam partes que o paginador padrão da tela tem.

**Referência correta:** o paginador da grade principal da Biblioteca (embaixo dos cards), que tem: `Ir para a página [ 1 ] de 10 [→]` | `Itens por página [ 14 ]` | `137 modelos` | `|‹  ‹  ›  ›|`.

**O que fazer:**
1. Localize o componente de paginação usado na grade principal da Biblioteca. **Reutilize o MESMO componente** na aba Logs da modal (não crie outro paginador do zero, não copie HTML solto).
2. Remova o markup antigo/parcial da aba Logs (o que gera "Mostrando 1–10 de 15", a barrinha vertical solta e o "Página 1 de 2").
3. Ligue o componente reutilizado aos dados dos logs:
   - total = total de logs do filtro atual (Todos / Tipos / Arquivos classificados);
   - itens por página padrão = 10 (opções que o componente já oferece);
   - texto do total: "15 registros" (no lugar de "137 modelos" — se o componente tiver o texto fixo "modelos", adicione um `@Input()` simples de rótulo, ex.: `rotuloTotal = 'modelos'`, e passe `'registros'` na modal).
4. Ao trocar o filtro (chips Todos/Tipos/Arquivos), voltar para a página 1.
5. A paginação dos logs deve ser feita no **back-end** (já existe ou deve existir um endpoint de logs com página e tamanho). Se hoje o front recebe tudo e fatia na mão, mova a paginação para o back (parâmetros página e tamanho, retorno com itens + total). O front só exibe.
6. Centralizar o paginador no rodapé da lista, com o mesmo espaçamento da grade principal; ele não pode ficar dentro da área com scroll (fica fixo abaixo da lista, acima do botão "Fechar").

**Pronto quando:** o rodapé da aba Logs é idêntico visualmente ao da grade principal (ir para página, itens por página, total, primeira/anterior/próxima/última) e funciona.

---

## ITEM 3 — Modal "Configurações": "Cor do logo" desalinhada

**Onde:** item "Configurações" no painel lateral → modal de configurações → linha com o campo "Fonte das peças" e o seletor "Cor do logo".

**Problema:** o rótulo "Cor do logo" fica em cima e o quadradinho de cor fica mais baixo que o campo "Fonte das peças"; não estão na mesma linha visual.

**O que fazer:**
1. Deixe "Fonte das peças" e "Cor do logo" na **mesma linha**, alinhados verticalmente pelo centro do campo (container `display: flex; align-items: center; gap: 16px;`).
2. Transforme o "Cor do logo" em um bloco com a **mesma altura do campo de fonte** (56px, igual ao `mat-form-field` outline), com borda igual à dos outros campos e o rótulo "Cor do logo" no mesmo estilo de label flutuante dos campos (pequeno, em cima da borda) — OU, se for mais simples, o quadradinho de cor (32x32, cantos 6px) à esquerda e o texto "Cor do logo" + o código hex (ex.: `#5B3FB5`) à direita, tudo dentro desse bloco de 56px. Clicar em qualquer ponto do bloco abre o seletor de cor.
3. Larguras: "Fonte das peças" `flex: 1`; "Cor do logo" largura fixa ~200px.
4. Em telas < 600px os dois ficam um embaixo do outro, 100% de largura.

**Pronto quando:** o topo e a base do bloco "Cor do logo" ficam exatamente alinhados com o campo "Fonte das peças".

---

## ITEM 4 — Envolver a grade de peças em um card branco

**Onde:** aba Biblioteca, modo "Grade" (e também o modo "Lista"), a área com os cards das peças + o paginador.

**Problema:** os cards das peças ficam soltos sobre o fundo cinza da página e não destacam.

**O que fazer:**
1. Criar um **card branco** que envolve TODOS os cards das peças **e o paginador** de baixo: `background: #fff; border: 1px solid #E6E3EC; border-radius: 12px; padding: 16px; box-shadow: 0 1px 2px rgba(16,24,40,.04);` (use as variáveis de cor/tema que o projeto já tiver para branco e borda, se existirem — procure as variáveis usadas no card "Quero fazer...").
2. O card "Quero fazer ... para ..." continua separado, em cima, como já está. O novo card fica logo abaixo dele, com o mesmo espaçamento lateral (as bordas esquerda/direita alinhadas com o card de cima).
3. Como agora o fundo atrás dos cards de peça é branco, dê a cada card de peça uma borda visível (`1px solid #E6E3EC`) e, no hover, `box-shadow: 0 4px 12px rgba(16,24,40,.08)` para não "sumirem" no branco.
4. O paginador fica dentro do card, separado da grade por `border-top: 1px solid #EFEDF3; margin-top: 16px; padding-top: 12px;`.
5. Estado vazio e carregando também ficam dentro do card.

---

## ITEM 5 — DOWNLOAD DA PEÇA (o mais importante): baixa sempre a mesma peça, sem formatação, e o PDF sai em formato de slide

São **3 bugs**. Corrija os três.

### 5.1 — Baixa sempre a mesma peça (não a selecionada)
**Sintoma:** escolho a peça X (no card, no menu "...", ou no campo "Peça") e clico em baixar; o arquivo que vem é sempre a mesma peça (provavelmente a primeira da lista ou a primeira que foi aberta).

**Como investigar (faça nesta ordem e descreva o que achou na entrega):**
1. Localize a ação de baixar/gerar no front (menu "..." do card e botão de gerar/baixar do "Gerador atual"). Veja **qual id** é enviado para o back. Suspeitas comuns que você deve verificar uma por uma:
   - id pego de uma variável "peça atual/selecionada" que só é preenchida na primeira vez e nunca atualizada;
   - id fixo ou do primeiro item da lista (`lista[0]`);
   - `subscribe` antigo que não foi encerrado e responde com a peça anterior;
   - cache no service do front (um `shareReplay`/variável guardando o primeiro arquivo) ou cache no back por chave errada (ex.: chave só pelo usuário/processo, sem o id da peça);
   - nome do arquivo fixo + o navegador reaproveitando o download.
2. No back, localize o endpoint/serviço que monta o documento da peça. Confirme que ele usa **o id recebido** para buscar o modelo (template) e os dados do processo. Se houver cache, a chave deve incluir id da peça + id do processo.
3. Corrija para que **o id enviado seja sempre o da peça em que o usuário clicou** (passar o item como parâmetro do método do clique: `baixar(peca)`, e não ler de variável global do componente).
4. O nome do arquivo baixado deve ser o nome da peça + número do processo (ex.: `Agravo Interno (execução) - 1000001-35.2023.8.19.6691.docx`), removendo caracteres inválidos de nome de arquivo (`\ / : * ? " < > |`).

### 5.2 — Documento sai sem os padrões (margens, fonte, logo, espaçamento)
**Sintoma:** o arquivo baixado não respeita a formatação de peça jurídica nem as configurações do escritório.

**O que fazer (no back-end, na montagem do documento):**
1. Página **A4** (21 x 29,7 cm), **retrato**.
2. Margens padrão ABNT para peças: **superior 3 cm, esquerda 3 cm, inferior 2 cm, direita 2 cm**.
3. Fonte: a escolhida em Configurações → "Fonte das peças" (ex.: Georgia). Se não tiver configuração, usar Times New Roman. Tamanho 12 no corpo.
4. Espaçamento entre linhas **1,5**; parágrafos justificados; recuo de primeira linha 2 cm no corpo; citações longas com recuo de 4 cm, fonte 10, espaçamento simples.
5. Cabeçalho com o **logo** do escritório (cor do logo da configuração) e rodapé com o endereço do escritório (o que está em Configurações) e numeração de página "Página X de Y".
6. Título da peça centralizado, negrito, caixa alta.
7. Essas regras devem estar **num lugar só** no back (um método/serviço de "aplicar formatação padrão da peça"), usado tanto pelo DOCX quanto pelo PDF. Valores fixos direto no código (são regra de formatação; se o projeto já tiver configuração de escritório para algum deles, use a configuração).
8. Se a peça vier do editor com estilos próprios (negrito, listas, tabelas), mantenha esses estilos; só aplique o padrão no que não tiver estilo definido.

### 5.3 — PDF sai em "modo slide" (paisagem/16:9) e deveria ser A4 normal
**Sintoma:** ao baixar em PDF, as páginas saem largas, tipo slide de apresentação.

**O que fazer:**
1. Localize como o PDF é gerado (conversão do DOCX para PDF no back, biblioteca de PDF, ou impressão/`html2canvas`/`jsPDF` no front).
2. Se o PDF é gerado no **front**, mova a geração para o **back** (front só pede o arquivo e baixa). Regra de negócio e formatação ficam no back.
3. Configure explicitamente: tamanho **A4**, orientação **retrato (portrait)**, as mesmas margens do item 5.2. Não deixe nenhum valor padrão da biblioteca decidir o tamanho (é isso que provavelmente está gerando 16:9/paisagem). Se for conversão via HTML, garanta `@page { size: A4 portrait; margin: 3cm 2cm 2cm 3cm; }`.
4. O PDF deve ter texto selecionável (não pode ser imagem/print da tela).
5. O conteúdo do PDF deve ser o mesmo do DOCX da mesma peça (mesma formatação do 5.2).

### 5.4 — Front do download
- Ao clicar em baixar: mostrar carregando no botão (desabilitado até terminar), para evitar clique duplo.
- Receber o arquivo como blob, pegar o nome do header `Content-Disposition` (o back deve mandar esse header com o nome do 5.1) e baixar.
- Em erro, mostrar o snackbar/toast de erro que o projeto já usa, com mensagem vinda do back.
- `subscribe` simples + `takeUntilDestroyed(this.destroyRef)` (ver estilo abaixo).

**Pronto quando:** baixar a peça A e depois a peça B gera dois arquivos diferentes, com o nome certo; DOCX e PDF saem em A4 retrato, com margens 3/3/2/2, fonte da configuração, espaçamento 1,5, logo no cabeçalho e numeração no rodapé.

---

## REGRAS GERAIS
- Não mude nada fora destes 5 itens. Não renomeie coisas existentes sem necessidade.
- Front só exibe; regra de negócio, paginação de logs e montagem/formatação de documento ficam no back.
- Reutilize componentes existentes (paginador, campos, snackbar). Só crie algo novo se não existir equivalente.
- Não crie testes.

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

## ENTREGA
1. Lista de arquivos alterados, por item (1 a 5).
2. Para o item 5.1: qual era a causa exata de baixar sempre a mesma peça.
3. Para o item 5.3: qual era a causa do formato slide.
4. Seção **"Explicações"** (o que faz, por que, versão simples equivalente, como debugar) para cada trecho não trivial.
