# Prompt — Gerador de peças: miniaturas da Grade sempre preenchidas

## Referência visual (fonte da verdade)
- Mock: **https://jezielsilva.github.io/pagina-mocks-prompts/artefatos/gerador-pecas-mock.html** (aba "Grade")
- Código do mock (funções `skel` e `paperCard`, CSS `.paper .sk`): **https://github.com/jezielsilva/pagina-mocks-prompts/blob/main/artefatos/gerador-pecas-mock.html**

## Problema
Na Grade do Gerador de peças, a miniatura de alguns modelos (folha A4 com linhas de esqueleto + nome no centro) fica com espaço em branco embaixo. Causa: o esqueleto gera poucas linhas fixas e alguns layouts (tabela, cláusulas, assinatura) param antes do fim da folha.

## O que fazer (somente front, só visual)
Localize no código o componente que desenha a miniatura de modelo na Grade do Gerador de peças.
1. Contêiner do esqueleto ocupando a folha inteira (absoluto, inset 0) com `overflow: hidden`.
2. Gerar linhas suficientes para SEMPRE passar do fim da folha (mock: limite 42 em vez de 15); o excesso é cortado, então a folha fica cheia em qualquer largura.
3. Depois do layout específico de cada variação, completar com parágrafos comuns (linhas 86–100%, última 25–70%, espaço entre parágrafos) até o limite.
4. Manter: geração determinística pelo id do modelo, nome centralizado com fundo branco por cima, estrela de favorito, selo "Do escritório" e menu de opções.
5. Sem regra de negócio; nada de back-end.

## Aceite
- Todos os cards da Grade com linhas até a borda inferior, sem faixa branca.
- Visual igual ao mock em desktop, tablet e celular.

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

Na entrega, inclua a seção **"Explicações"** (o que mudou, por que, versão simples equivalente, como debugar).
