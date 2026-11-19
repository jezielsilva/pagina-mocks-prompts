# Prompt Codex: Gerador de peças, layout da Revisão dos campos + drawer de pré-visualização mais largo

> Cole tudo abaixo no Codex (Luna). Siga À RISCA. Não invente nada fora do que está escrito. Se algo não bater com o código, PARE e pergunte. Não adivinhe.

---

## 0. Antes de começar (obrigatório)

1. Leia o arquivo de instruções de agentes da raiz do front e o guia de UI-Kit da pasta de agentes. Siga as regras deles.
2. Localize os arquivos **pela função descrita**. Antes de mudar qualquer coisa, escreva uma **mini-spec** curta: arquivos encontrados, o que muda em cada um e por quê, e a **causa** de cada problema.
3. **NÃO** crie nem rode testes, lint ou navegador. A validação é **só o build** do front.
4. **NÃO** altere estilos globais nem os arquivos de variáveis de cor gerados automaticamente. Estilo vai no SCSS do próprio componente.
5. É só front e só layout: não mude regra, dados, campos nem o comportamento do editor.

Larguras para conferir: **1920px, 1440px, 1280px e 1024px**.

---

## ITEM 1: Etapa "Revisão dos campos", conteúdo empurrado para a direita

**Onde:** assistente do Gerador de peças, etapa 2 **Revisão dos campos** (mesmo problema vale para conferir em **Salvar peça**).

**Hoje:** os avisos amarelos (campos sem dado / dados que não vieram pela API) ocupam a largura do card, e o bloco de **campos** + **editor** aparece **ao lado** deles, empurrado para a direita e cortado na borda da tela. A área abaixo dos avisos fica vazia.

**Correto:**
- Dentro do card, a ordem vertical é: **avisos em cima (largura total)** → **abaixo deles**, uma linha com **campos à esquerda** e **editor à direita**.
- Nada pode passar da largura do card nem gerar rolagem horizontal da página.
- Coluna de campos com largura fixa razoável (a atual), editor ocupando o resto (`minmax(0, 1fr)` ou equivalente para não estourar).
- Na mini-spec, diga a causa (ex.: avisos e área de trabalho no mesmo container flex em linha, falta de `min-width: 0`, wrapper com largura fixa etc.).

---

## ITEM 2: Drawer de pré-visualização do modelo (biblioteca de peças)

**Onde:** drawer que abre ao clicar em uma peça da biblioteca (cabeçalho roxo com o nome da peça, editor no meio, painel "Classificação / Preenche sozinho / Usar este modelo" à direita).

### 2.1 Mais largo, só no caso de peças
- Aumentar a largura **deste drawer** para dar mais espaço ao editor: `min(1600px, 92vw)`.
- Não alterar a largura de outros drawers do sistema (aplicar por classe/config própria deste drawer).
- O painel da direita mantém a largura atual; o ganho vai todo para o editor.

### 2.2 Rolagem visível no editor com zoom
- Ao aumentar o zoom do editor (botões + / − / %), o conteúdo passa da área e hoje **não aparece barra de rolagem**.
- A área da folha deve ter rolagem **vertical e horizontal visíveis** (`overflow: auto`) quando o conteúdo passar do espaço, nos dois eixos, sem cortar a folha.
- A barra de ferramentas do editor e a régua continuam fixas no topo da área; só a folha rola.

### 2.3 Painel da direita sempre fixo
- O painel de informações da peça (Classificação, Modelos/Base/Usos/Versão/Obrigatórios/Layout, Preenche sozinho e os botões **Usar este modelo / Adicionar aos favoritos / Mais**) fica **sempre visível**, sem rolar junto com o editor.
- Estrutura: corpo do drawer com altura total disponível (abaixo do cabeçalho), em grid `minmax(0,1fr) <largura atual do painel>`; cada coluna com sua própria rolagem; os botões ficam presos no rodapé do painel.
- Se o conteúdo do painel passar da altura, só a parte de cima do painel rola; os botões continuam visíveis.

**NÃO mexer:** cabeçalho roxo do drawer, conteúdo do painel, abas Campos/Blocos/Versões e funções do editor.

---

## Entrega

- Rode **só o build** e informe o resultado.
- Commit no padrão do repositório: `fix(gerador-pecas): <mensagem>`.

```
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
```

Na entrega, inclua a seção **"Explicações"**: para cada item, a causa, o que mudou, por quê e como conferir.
