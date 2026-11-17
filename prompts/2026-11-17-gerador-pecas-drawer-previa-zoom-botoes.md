# Prompt Codex: Gerador de peças, drawer de pré-visualização do modelo

> Cole tudo abaixo no Codex (Luna). Siga À RISCA. Não invente nada fora do que está escrito. Se algo não bater com o código, PARE e pergunte. Não adivinhe.

---

## 0. Antes de começar (obrigatório)

1. Leia o arquivo de instruções de agentes que fica na raiz do repositório do front e o guia de UI-Kit da pasta de agentes. Siga as regras deles. Elas valem mais que o seu gosto pessoal.
2. Abra o **mock do Gerador de peças** no portal (item fixo "Mock: Gerador de peças"). Clique em qualquer modelo da biblioteca para abrir o drawer largo. **Esse drawer é a referência visual.** Deixe o mock aberto do lado enquanto codifica.
3. Não sei os nomes dos arquivos e não vou passar. **Localize no código pela função descrita.** Antes de mudar qualquer coisa, escreva uma **mini-spec** curta com:
   - os arquivos encontrados (front e back);
   - o que vai mudar em cada um;
   - o porquê de cada mudança.
4. **NÃO** crie testes. **NÃO** rode testes, lint nem navegador. A validação é **só o build** do front (e do back, se você mexer nele).
5. **NÃO** crie índice, coleção nem migração de banco. **NÃO** altere arquivos de variáveis de cor gerados automaticamente. **NÃO** altere estilos globais.
6. Todo texto novo de interface vai para o arquivo central de mensagens do front, em pt-BR. Nada de texto fixo no HTML/TS.

### Onde estamos

Módulo **Gerador de peças**, tela da **biblioteca de modelos**. Ao clicar uma vez num modelo (card da grade ou linha da lista), abre um **drawer lateral** com:

- **cabeçalho roxo** com o nome do modelo e o X;
- **coluna esquerda**: "Pré-visualização do modelo", controles de zoom e a folha;
- **coluna direita**: Classificação, Modelos/Base/Usos/Versão/Obrigatórios/Layout, "Preenche sozinho" (pílulas com ✓) e os botões "Usar este modelo", "Adicionar aos favoritos" e "Mais".

O drawer já existe e funciona. Você vai **corrigir e refinar**, não recriar do zero.

---

## ITEM 1: BUG. O drawer sempre mostra o mesmo modelo ("Agravo Interno")

### Sintoma

Qualquer modelo que o usuário clique na biblioteca abre o drawer com o conteúdo do **Agravo Interno**: título, classificação e texto da folha. Os outros modelos nunca aparecem.

### O que já se sabe (não refaça essa análise, use-a)

- No front, o clique chama a ação "abrir detalhe" com o id do modelo. Uma fonte reativa (BehaviorSubject + switchMap) busca o detalhe na API de "obter modelo por id".
- No back, o fluxo é Controller → Business → Repository. O repository filtra por "modelos visíveis ao usuário" **E** "id igual ao pedido", acrescenta a contagem de usos por agregação e pega o primeiro resultado.
- Pela leitura, o código parece correto. Então a causa está em um destes pontos, **nesta ordem de investigação**:
  1. **O id que sai do card.** Confira se o card/linha passa o id do **próprio** modelo. Procure: id fixo, id do primeiro item da lista, variável de laço capturada errado, `track` errado, ou a lista enxuta de opções do campo "Quero fazer [peça]" sendo usada no lugar da lista da biblioteca. Coloque um `console.log` **temporário** do id no clique e no momento em que a requisição sai. Remova antes de entregar.
  2. **O id que chega no back.** Coloque um log temporário no Business com o id recebido e o id/nome do modelo devolvido pelo repository.
  3. **O filtro do repository.** Confira se o filtro de id está sendo aplicado de fato. Exemplos do que pode dar errado: o mapeamento do campo `_id` como string e ObjectId não bate e o filtro é ignorado; a ordem dos estágios da agregação faz o `$match` do id se perder; o "primeiro resultado" vem sem o filtro de id. Se o filtro de id não estiver funcionando, o resultado seria exatamente o sintoma: o primeiro modelo visível, que em ordem alfabética é o **Agravo Interno**.
  4. **Os dados.** Se os 3 itens acima estiverem certos, confira no banco de homologação (**só leitura**, não altere nada) se os modelos do sistema têm o **mesmo conteúdo** (conteúdo copiado do Agravo Interno na carga). Se for isso, **não corrija o banco**: pare e me avise com a lista dos modelos afetados.
  5. **Cache.** Confira se existe cache (no front, num interceptor, ou no back) com chave que **não inclui o id** do modelo.
  6. **Fechamento do drawer.** Confira se, ao fechar o drawer, o estado do detalhe é zerado. Ao abrir outro modelo, o drawer **nunca** pode mostrar o conteúdo anterior nem por um instante: tem que aparecer o carregamento (skeleton) e depois o modelo certo.

### Como deve ficar

- Clicou no modelo X → o drawer mostra **o título, a classificação, os metadados, as pílulas e a folha do modelo X**.
- Trocou rápido de modelo → a requisição anterior é cancelada (o switchMap já faz isso; não remova) e só o último aparece.
- Na entrega, explique **qual era a causa exata** com o trecho do código antes/depois.

---

## ITEM 2: Folha da pré-visualização igual ao mock, com as configurações do usuário

### Problema

Hoje a folha do drawer é uma folha genérica. O cabeçalho tem o nome do escritório, OAB e e-mail, mas **não respeita** a personalização que o usuário fez em **Configurações do gerador > Personalização** (identidade do escritório + papel timbrado/layout da folha por arraste). Além disso, o **endereço do rodapé aparece sobreposto no meio do texto**, colado ao lado do título "AGRAVO INTERNO" no corpo. A folha também está **cortada**: mostra só o começo da página, e não a A4 inteira.

### Regra

**Toda vez** que o drawer abrir, a folha tem que ser montada com as **configurações salvas do usuário** (as que vêm da API de configurações do gerador, **nunca** o rascunho não salvo da modal de configurações), exatamente como no mock:

1. **Folha A4 de verdade**: proporção 210 × 297, fundo branco, sombra leve, centralizada numa área de fundo neutro (use um token de superfície do tema; **não** use cor hex nova).
2. **Folha inteira visível ao abrir**: ao abrir o drawer, a folha aparece **inteira** (ajustada à altura/largura disponível) e o zoom mostra **100%**. Isso já existe parcialmente ("escala de ajuste" × "zoom do usuário"); mantenha esse conceito.
3. **Se o usuário ativou o papel timbrado/layout personalizado** (configuração "layout > usar" = verdadeiro):
   - Reaproveite o **componente de folha A4 que já existe** e que desenha os blocos do layout em milímetros (o mesmo usado no editor de papel timbrado e na prévia da modal de Configurações). **Não crie outro.**
   - Posicione cada bloco (logo, nome do escritório, dados, linha, data, assinatura, rodapé, marca d'água, texto livre, imagem) nas posições/tamanhos em mm salvos pelo usuário.
   - O bloco **corpo** recebe o **texto do modelo** (o HTML de prévia que já vem da API), com as variáveis destacadas como hoje (badges laranja/itálico, ver item 2.6), em vez do texto de exemplo. Se o componente de folha só sabe mostrar texto de exemplo no corpo, **acrescente** uma entrada opcional (ex.: um conteúdo de corpo) sem quebrar o editor de layout nem a prévia da modal de configurações. Quando a entrada não for informada, o comportamento atual continua igual.
   - O texto do corpo **não pode vazar** para fora do bloco corpo nem passar por cima de rodapé/assinatura. Se não couber, corte no limite do bloco (como no mock: `overflow: hidden`).
4. **Se o usuário NÃO ativou o layout personalizado**, use o **layout padrão** com a **identidade** dele:
   - cabeçalho com logo (ou as iniciais, se não tiver logo), nome do escritório, subtítulo/OAB/contato, com a fonte e a cor da marca escolhidas;
   - linha separadora;
   - corpo com o texto do modelo;
   - **rodapé no pé da página** (não no meio do texto);
   - marca d'água só se o usuário ligou, com a intensidade escolhida;
   - margens, fonte, tamanho da fonte, entrelinha e recuo da primeira linha vindos das configurações da página do modelo, como já é lido hoje.
5. **Bug do rodapé sobreposto**: corrija a causa. Provavelmente o rodapé/endereço está com posição absoluta relativa ao elemento errado, ou dentro do fluxo do texto. O rodapé deve ficar **preso ao pé da folha**, dentro da margem inferior, e o corpo deve terminar **acima** dele.
6. **Badges das variáveis**: o estilo atual (texto laranja, itálico, sublinhado pontilhado, entre colchetes, ex.: `[Nome do cliente]`) está **aprovado**. **Não mude.**
7. **Fonte da folha**: a folha simula um documento impresso, então ela usa a **fonte escolhida pelo usuário** na identidade do escritório. Isso é conteúdo do documento, não tipografia da interface; está liberado. Se o usuário não escolheu, use a fonte padrão que já é usada hoje na prévia.

### Referência do mock (copie o comportamento, não o CSS literal)

- área da folha: `flex: 1; min-height: 0; overflow: auto; padding: 12px; display: flex; justify-content: safe center; align-items: flex-start`;
- folha: largura base **600px** (sem max-width), escalada por zoom;
- ajuste inicial: `escala = min((larguraÁrea - 24) / 600, (alturaÁrea - 24) / 848)`, com mínimo de 0,3.

---

## ITEM 3: Componente de zoom novo, `e-zoom`

### Problema

Os controles de zoom do drawer hoje são 3 botões quadrados separados com o "100%" solto no meio. Ficou feio. O mock tem um controle **único, redondinho, em pílula**.

### O que fazer

1. Crie um **componente compartilhado novo** de zoom, na pasta de componentes compartilhados (**não** dentro do Gerador), com o seletor **`e-zoom`**. Standalone, OnPush.
2. **Visual (igual ao mock):**
   - um único contêiner em pílula (`display: inline-flex; align-items: center; gap: 2px; padding: 2px; border-radius: 999px`), fundo de superfície branca do tema e borda de 1px com o token de borda do tema;
   - dentro, na ordem: botão **−**, texto **"100%"**, botão **+**, botão **ajustar à tela** (ícone de camadas, o mesmo `layers` de hoje);
   - os botões ficam **sem borda e sem fundo** (`border: 0; background: none`), com 34 × 30px e `border-radius: 999px`; no hover, fundo de superfície suave do tema. Cor do ícone/texto: token de texto secundário;
   - o percentual: 14px, mínimo de 38px de largura, centralizado, `font-family: var(--font-body)`;
   - **sem `box-shadow`**, sem gradiente, sem `!important`, sem `rgba()`. Use só tokens de cor já mapeados no tema. Se faltar um token, siga a regra do arquivo de instruções (mapear no contexto de componente do tema) e me avise.
3. **Contrato do componente** (entradas e saídas simples):
   - entrada `valor` (número, percentual atual, ex.: 100);
   - entrada `minimo` (padrão 50) e `maximo` (padrão 250);
   - entrada `passo` (padrão 10);
   - saída `valorChange` (novo percentual);
   - saída `ajustar` (clicou em "ajustar à tela").
   - O componente **não** sabe nada de folha nem de drawer. Ele só emite. Quem usa decide o que fazer.
4. **Comportamento:**
   - **−** diminui `passo`, sem passar do mínimo; desabilitado no mínimo, com **`cursor: default`** (não `not-allowed`);
   - **+** aumenta `passo`, sem passar do máximo; desabilitado no máximo;
   - **ajustar** emite `ajustar` (no drawer: volta a folha inteira na tela e o zoom para 100%);
   - acessibilidade: `role="group"` com aria-label "Zoom da folha"; cada botão com aria-label ("Diminuir zoom", "Aumentar zoom", "Ajustar à tela") e tooltip com o mesmo texto; o percentual com `aria-live="polite"`.
   - Textos no arquivo central de mensagens (reaproveite as chaves de zoom que já existem, se servirem).
5. **Use o `e-zoom`** no drawer de pré-visualização do modelo, no lugar dos 3 botões atuais. Se existir outro controle de zoom igual dentro do Gerador (prévia da peça no assistente, editor de papel timbrado), **troque também** pelo `e-zoom`. Liste na entrega onde trocou.
6. Remova o código que ficar morto (métodos, mensagens sem uso, estilos) depois da troca.

---

## ITEM 4: Drawer mais largo

- Aumente a largura do drawer de pré-visualização do modelo para dar mais espaço à folha e à coluna direita. Referência do mock: **`min(1240px, 76vw)`**.
- Coluna direita: largura fixa de **340px** (no mock: `grid-template-columns: minmax(0, 1fr) 340px`). A folha fica com o resto.
- Se o componente de drawer compartilhado não tiver um tamanho que chegue nessa largura, **não altere os tamanhos existentes** (outras telas usam). Acrescente um tamanho novo ao tipo de tamanhos do drawer (ex.: `"wide-xl"`) e use só aqui. Explique na mini-spec.
- Em telas estreitas (até ~760px de largura do drawer), as colunas viram uma só: folha em cima (mínimo 70vh) e informações embaixo, como no mock.
- **Cabeçalho roxo: NÃO mexer.** Mantenha cor, altura, título e X como estão.
- **Disposição das informações da direita: NÃO mexer** (Classificação, metadados e Preenche sozinho estão aprovados).

---

## ITEM 5: Botões do rodapé do drawer, iguais ao mock

### Como deve ficar (coluna direita, presa embaixo, `margin-top: auto`)

```text
[ ✎  Usar este modelo                       ]   ← primário, largura total, 48px de altura
[ ☆ Adicionar aos favoritos ] [ Mais ⋮      ]   ← duas colunas iguais (grid 1fr 1fr, gap 8px), 42px de altura
```

- "Usar este modelo": botão **primário**, ícone de lápis, ocupa a **largura toda**.
- Embaixo, uma grade de **2 colunas iguais**:
  - "Adicionar aos favoritos" / "Remover dos favoritos" (secundário/contorno, ícone de estrela vazia/cheia), **largura total da coluna**;
  - "Mais" (secundário/contorno, ícone de três pontinhos **à direita do texto**), **largura total da coluna**, abrindo o menu de ações que já existe.
- Espaço de 8px entre as linhas.
- Hoje o "Mais" está menor e desalinhado: corrija para ter **a mesma altura e largura** do botão de favoritos.

### Aplicar também no Meus documentos

O drawer de detalhe/visualização de arquivo do **Meus documentos** tem botões de ação no rodapé. Aplique **o mesmo arranjo** (ação principal em largura total em cima; ações secundárias em grade de 2 colunas iguais embaixo; "Mais" com os três pontinhos). **Não mude** quais ações existem lá, só a disposição e o estilo. Se o drawer de Meus documentos não tiver uma ação principal clara, pare e me pergunte qual é antes de mexer.

---

## ITEM 6: Todos os botões QUADRADOS, com o componente de botão compartilhado

Regra que vale **sem exceção** para **todos os botões**:

- da tela do **Gerador de peças** (biblioteca, lateral, filtros, drawers, modais do gerador, assistente, rascunhos, peças geradas);
- da tela do **Meus documentos** (inclusive drawers e modais dela).

Regras:

1. Todo botão deve usar o **componente de botão compartilhado do sistema** (`e-button`). Se encontrar `<button>` cru com classes do Bootstrap (`btn btn-*`), troque pelo componente compartilhado, mantendo o tipo (primário/secundário/perigo), o ícone, o texto, o desabilitado e o evento.
2. **Quadrado** = o formato **padrão** do componente: **não** passe a entrada de arredondado e **remova** qualquer `border-radius` local (SCSS da tela) que deixe botão em pílula/redondo.
3. **Exceções** (ficam como estão): badges, chips/pílulas de filtro, pílulas do "Preenche sozinho", o switch de lista/grade, **os botões internos do novo `e-zoom`** (redondos por definição) e o X do cabeçalho do drawer.
4. Não mude tamanho, cor nem ordem dos botões, só o formato. Ações primárias de modal continuam **à direita**.
5. Na entrega, liste cada arquivo onde trocou botão cru por `e-button` ou removeu o arredondamento.

---

## ITEM 7: Menu "Mais": incluir "Duplicar para o escritório"

### Hoje

O menu "Mais" do drawer (modo detalhe) tem: Criar minha versão/Editar modelo, Baixar .docx e Baixar PDF.

### O que fazer

1. Acrescente a opção **"Duplicar para o escritório"** (ícone de copiar, `content_copy`) no menu "Mais" do drawer, **logo abaixo** de "Criar minha versão/Editar modelo".
2. **Back-end: já existe.** Existe um endpoint de **copiar modelo** no controller do gerador (POST que recebe o id do modelo original e um nome) e um método correspondente no serviço HTTP do front que **hoje não é usado por nenhuma tela**. **Reaproveite os dois. Não crie endpoint novo.** Antes de usar, leia o Business da cópia e confirme na mini-spec:
   - que a cópia vira um modelo **do escritório** (não do sistema), do usuário logado;
   - que mantém conteúdo, campos, classificação e configuração de página do original;
   - quais validações e códigos de erro existem (o filtro de erros do controller tem as mensagens).
   - Se o Business **não** fizer algum desses pontos, **pare e me pergunte**. Não altere regra de negócio sozinho.
3. **Fluxo na tela:**
   1. Clicou em "Duplicar para o escritório" → abre uma **modal pequena** com o título "Duplicar para o escritório", com um campo "Nome do modelo" preenchido com `<nome original> (cópia)` e os botões "Cancelar" (esquerda) e "Duplicar" (direita, primário). Use a modal/confirmação padrão do sistema que aceita campo; se não existir, crie uma modal simples **dentro do Gerador**.
   2. "Duplicar" → **não** use tela de carregamento global. Desabilite o botão "Duplicar", mostre aviso de "Duplicando modelo…" e mantenha a UI usável (regra do fluxo de criação não bloqueante).
   3. Sucesso (HTTP 200) → fecha a modal, mostra o snackbar de sucesso "Modelo duplicado para o escritório.", **recarrega a lista da biblioteca** (consulta atual, mesmos filtros e página) e **abre o drawer do modelo novo** (id retornado pela API).
   4. Erro → mantém a modal aberta, reabilita o botão e mostra a mensagem de erro que vier da API (padrão de feedback do gerador).
4. Tipos: acrescente a nova ação ao tipo de ações de modelo de peça que já existe (na pasta de types compartilhados) e trate-a no `switch` central de ações da biblioteca (switch clássico com `case`/`return`, como já está).
5. A opção aparece **também** no menu "⋯" do card da grade e da linha da lista? **Não.** Só no drawer, por enquanto.
6. Textos novos no arquivo central de mensagens: título da modal, rótulo do campo, sufixo "(cópia)", botões, "Duplicando modelo…", sucesso.

---

## Fora do escopo (NÃO faça)

- Não mexa no cabeçalho roxo do drawer nem na disposição das informações da direita.
- Não mude o estilo das badges das variáveis nem das pílulas do "Preenche sozinho".
- Não implemente o editor de texto (continua "Em breve").
- Não altere regra de negócio no back (cópia, visibilidade, favoritos). Só **leia** e, se algo estiver diferente do descrito, **pergunte**.
- Não mexa no banco.

---

## Checklist final (confira item por item antes de entregar)

- [ ] Clicar em 5 modelos diferentes abre 5 conteúdos diferentes; a causa do bug foi explicada.
- [ ] A folha abre inteira, em A4, com a identidade (logo/iniciais, nome, fonte, cor, rodapé, marca d'água) e, se ativado, o papel timbrado do usuário.
- [ ] O rodapé fica no pé da folha; nada sobreposto ao texto.
- [ ] `e-zoom` criado nos componentes compartilhados, em pílula, e usado no drawer (e onde mais houver zoom no Gerador).
- [ ] Drawer em `min(1240px, 76vw)`, coluna direita de 340px, responsivo.
- [ ] Rodapé de ações: primário em largura total + favoritos/Mais em 2 colunas iguais. Mesmo arranjo no drawer do Meus documentos.
- [ ] Todos os botões do Gerador e do Meus documentos com `e-button` quadrado (exceções respeitadas).
- [ ] "Duplicar para o escritório" funcionando com o endpoint existente.
- [ ] Sem `!important`, `rgba()`, `box-shadow` novo, gradiente, cor hex nova, `cursor: not-allowed` nem `<br>` para espaçamento.
- [ ] Logs temporários removidos; código morto removido.
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
2. Resumo curto do que mudou, por item (1 a 7).
3. A causa exata do bug do item 1.
4. Lista de arquivos alterados/criados.
5. Seção **"Explicações"** (o que faz, por quê, versão simples equivalente, como debugar) para cada trecho avançado.
6. Um log de evolução da feature em `docs/logs-evolucao` (um por branch; atualize se já existir) e a documentação do `e-zoom` em `docs`.
