# Gerador de peças — card de modelo como "folha escrita" (Biblioteca)

Referência visual: mock "Gerador de peças" no portal (aba Biblioteca, grade de modelos).

## Contexto
Na Biblioteca do Gerador de peças, os cards de modelo hoje têm um espaço vazio grande, duas linhas decorativas em volta do título, a estrela dentro de uma caixa e o "..." num círculo no canto inferior esquerdo. Queremos um card minimalista e profissional, em que cada card pareça uma folha de documento diferente.

Localize no código o componente do card de modelo da Biblioteca (o item da grade "Todos os modelos") e o SCSS dele. Não altere a listagem, a paginação nem as regras de negócio.

## O que fazer

### 1. Folha com texto simulado (o principal)
- O card continua sendo uma folha A4 reta (proporção 210/297), fundo branco e borda clara. **Sem inclinação nem rotação.**
- Dentro da folha, desenhe um "texto simulado" com barras cinza arredondadas, como um skeleton:
  - linhas comuns com 3px de altura e cor #e4e4e7;
  - título com 5px, #c9c9cf, centralizado;
  - subtítulo com 4px, #d6d6db;
  - intertítulo com 4px, #cfcfd5;
  - espaço vertical entre parágrafos.
- **14 estruturas de folha diferentes.** Cada card de uma página usa uma estrutura distinta, escolhida pelo índice do card na página (índice % 14). Com 14 itens por página, nenhuma se repete. As estruturas:
  1. texto corrido com intertítulos ocasionais;
  2. papel timbrado (linha fina no topo);
  3. endereçamento (3 linhas curtas antes do título) e assinatura centralizada no fim;
  4. lista com marcadores;
  5. citação recuada com barra à esquerda;
  6. timbre e data alinhada à direita;
  7. título à esquerda, texto denso e assinatura;
  8. seções com intertítulos;
  9. duas colunas;
  10. tabela (cabeçalho mais escuro e linhas com divisória);
  11. texto centralizado;
  12. memorando (pouco texto, espaços maiores, assinatura);
  13. checklist (quadradinho antes das linhas);
  14. bloco denso e justificado, sem subtítulo.
- Variação dentro da estrutura: largura das linhas, tamanho dos parágrafos (2 a 6 linhas, última linha curta), recuo na primeira linha e presença de subtítulo. Tudo sorteado com um gerador pseudoaleatório **determinístico**, com semente = id do modelo + índice. O mesmo modelo na mesma posição sempre desenha a mesma folha; nada muda a cada renderização.
- O skeleton é decorativo: `aria-hidden="true"`, `pointer-events:none` e `overflow:hidden` na folha.
- Para performance, gere a estrutura uma vez por item quando a lista carregar (por exemplo, guardar no item da view ou num map por id). **Não** recalcule no template a cada detecção de mudança.

### 2. Título
- O nome do modelo continua **centralizado no meio da folha**, por cima do skeleton, com fundo branco em volta para não perder a leitura.
- Remova as duas linhas decorativas acima e abaixo do título.

### 3. Estrela e menu
- **Sem fita ou cor por categoria** no card.
- Estrela no canto superior direito, **sem caixa nem borda**. Cinza quando não é favorito, laranja e preenchida quando é. Clicar nela só alterna o favorito; não pode abrir ou selecionar o modelo (pare a propagação do clique).
- O "..." vai para o canto inferior direito e só aparece no hover ou no foco do card. Em telas pequenas, fica sempre visível.

## Fora do escopo
Não mexa no cabeçalho roxo, nos filtros, na paginação, no painel lateral nem na visualização em lista.

## Entrega
1. Mini-spec curta antes de codar: onde fica o card, como você vai gerar e guardar o skeleton, e quais arquivos mudam.
2. Código seguindo o estilo abaixo.
3. Seção **"Explicações"**: o gerador pseudoaleatório determinístico (o que faz, por que existe, versão simples equivalente e como debugar), além de onde ajustar as cores e as estruturas.

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
