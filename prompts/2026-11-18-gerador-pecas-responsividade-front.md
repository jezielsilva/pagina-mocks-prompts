# Prompt Codex: Gerador de peças, tapa de responsividade e textos (fora do editor)

> Cole tudo abaixo no Codex (Luna). Siga À RISCA. Não invente nada fora do que está escrito. Se algo não bater com o código, PARE e pergunte. Não adivinhe.

---

## 0. Antes de começar (obrigatório)

1. Leia o arquivo de instruções de agentes da raiz do front e o guia de UI-Kit da pasta de agentes. Siga as regras deles.
2. Localize os arquivos **pela função descrita**. Antes de mudar qualquer coisa, escreva uma **mini-spec** curta: arquivos encontrados, o que muda em cada um e por quê.
3. **NÃO** crie nem rode testes, lint ou navegador. A validação é **só o build** do front.
4. **NÃO** altere estilos globais nem os arquivos de variáveis de cor gerados automaticamente. Estilo vai no SCSS do próprio componente.
5. Todo texto novo de interface vai para o arquivo central de mensagens do front, em pt-BR.
6. **NÃO mexa** na área do **editor de texto** que agora aparece ao lado dos campos nas etapas **Revisão dos campos**, **Salvar peça**, na tela **Peça gerada** e no drawer de **pré-visualização do modelo** da biblioteca. Nem no tamanho/altura dessas áreas. Outra pessoa acabou de montar isso. Se algum item exigir mexer lá, PARE e pergunte.

Larguras de referência para conferir cada item: **1440px, 1280px, 1024px, 768px e 390px**.

---

## ITEM 1: Plural da "Checagem final"

**Onde:** assistente, etapa **Salvar peça**, alerta amarelo "Checagem final".

Hoje, com um campo vazio, aparece **"1 campos ainda vazios"**. Use singular quando o total for 1 ("1 campo ainda vazio (...)") e plural nos demais. Mesma regra para o alerta do topo da etapa Revisão ("4 campos sem dado"): confira se com 1 campo fica "1 campo sem dado".

---

## ITEM 2: Cabeçalho do assistente (passos) em telas estreitas

**Onde:** topo do assistente: botão **"← Modelos"**, nome e caminho do modelo à esquerda; passos **Origem dos dados — Revisão dos campos — Salvar peça** à direita.

- Até 1024px: os passos descem para uma linha própria, abaixo do nome do modelo, sem cortar texto.
- Até 768px: mostre só o número/check de cada passo e o nome **do passo atual**; os demais ficam só com o círculo (com o nome no `aria-label`/tooltip).
- O caminho da classificação (ex.: "Recursos › Contra decisões interlocutórias › …") pode quebrar linha; nunca empurrar a página para o lado.

---

## ITEM 3: Rodapé fixo das etapas no celular

**Onde:** rodapé com **Voltar / Continuar** (Origem e Revisão) e **Voltar / Abrir no editor / Gerar peça** (Salvar).

- Até 576px: botões em coluna, largura total, ação primária **por último** (embaixo), e o texto "O original do modelo não é alterado." acima dos botões.
- O rodapé não pode cobrir o botão de chat flutuante do canto inferior direito nem ser coberto por ele: deixe espaço à direita para ele em telas acima de 576px.

---

## ITEM 4: Etapa Origem dos dados no celular

**Onde:** primeira etapa do assistente (cards de origem e o campo de busca do registro).

- Até 768px: cards de origem em **uma coluna**.
- A lista do autocomplete deve abrir por cima do conteúdo, com a largura do campo, sem ser cortada pelo card.

---

## ITEM 5: Biblioteca e lateral "Peças geradas"

**Onde:** página inicial do Gerador (aba Biblioteca): grade de modelos, filtros/abas, bloco "Quero fazer peça para processo" e a lateral **Peças geradas**.

- Até 1024px: a lateral **Peças geradas** desce para baixo da grade (largura total).
- Até 768px: grade com 1 coluna de cards; filtros/abas com rolagem horizontal própria (sem rolagem horizontal da página).
- Nenhum texto de card pode estourar o card: nome longo quebra linha.

---

## ITEM 6: Tela "Peça gerada", botões de ação

**Onde:** tela final depois de gerar ("Peça gerada"), botões **Baixar .docx / Baixar .pdf / Abrir no editor / Ver em Documentos / Modelos**.

- Os botões quebram linha com espaçamento igual (use `gap`), sem um botão ficar mais alto que o outro.
- Até 576px: botões em coluna, largura total, **Baixar** primeiro.
- Os nomes de arquivo e da pasta (números de processo longos) quebram linha em vez de estourar.

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

Na entrega, inclua a seção **"Explicações"**: para cada item, o que mudou, por quê e como conferir.
