# Resposta ao Codex: ajustes da mini-spec (Revisão dos campos + drawer da peça)

> Cole no Codex como resposta à mini-spec dele.

```
Mini-spec aprovada com estes ajustes:

1. Revisão dos campos — a causa existe, procure no SCSS e não só no HTML:
   - Reproduza com os DOIS avisos visíveis (campos sem dado + dados que não vieram pela API).
   - O sintoma: o 1º aviso ocupa a linha toda, e o bloco de campos/editor começa na MESMA linha do 2º aviso, encostado à direita e cortado.
   - Hipótese principal: os avisos estão dentro do mesmo container grid/flex (em linha) que campos + editor, e cada aviso vira uma célula da grade.
   - Correção: os avisos ficam num bloco próprio, fora do grid, em largura total. O grid (campos | editor) fica abaixo, com `minmax(0, 1fr)` no editor e `min-width: 0` nos filhos.
   - Se de fato não estiverem no mesmo container, inspecione o estilo calculado do container pai e me mostre qual regra causa o deslocamento antes de mudar.

2. Salvar peça: a mudança proposta (aviso em largura total acima das colunas) está ok, mas use exatamente o mesmo padrão do item 1.

3. Rolagem do editor com zoom:
   - Localize a origem do componente do editor da folha (pode estar em uma lib interna, em `projects/`/`libs/` ou em pacote do node_modules).
   - Se for externo e não puder ser editado, NÃO altere o pacote: aplique no wrapper que envolve o editor dentro do drawer:
     - a área da folha com `overflow: auto` nos dois eixos e altura definida (flex: 1; min-height: 0);
     - barra de ferramentas e régua fora dessa área de rolagem;
     - se precisar atingir o interno do componente, use estilo escopado à classe deste drawer, nunca global.
   - Explique na entrega onde ficou o scroll e por quê.

4. Largura do drawer em `min(1600px, 92vw)` e painel direito com topo rolável e botões fixos no rodapé: ok, siga.

Pode implementar. Só o build no final.
```
