# Prompt — Gerador de peças: aplicar a personalização do escritório em TODO lugar (editor + PDF + Word)

## Problema
A tela "Personalizar documento" do escritório salva: logo (iniciais/imagem + cor do logo), nome e contatos do escritório no cabeçalho com linha separadora, linha de identificação do processo/cliente abaixo do cabeçalho, bloco de local/data + assinatura do advogado, rodapé com endereço e linha separadora, fonte, tamanho, entrelinha e margens. A pré-visualização dessa tela mostra tudo certo.

Mas quando o editor abre a peça (pré-visualização do modelo, "Revisão dos campos", novo documento, rascunho — TODAS as telas com editor) e no download PDF e Word:
- o cabeçalho vem como texto simples no corpo (sem logo, sem cor, sem linha separadora);
- não há rodapé com endereço nem linha;
- formatação não segue a personalização (fonte, entrelinha, margens).

Resultado: a peça não fica igual ao modelo salvo.

## Causa provável (confirmar no código)
Cada tela/exportação monta o documento por conta própria, e a personalização só é usada na pré-visualização da tela de personalização. O cabeçalho é inserido como parágrafo do corpo em vez de cabeçalho/rodapé reais da seção do documento.

## Solução definitiva
1. **Uma única fonte no back-end:** criar/usar UM serviço no back-end (camada Business) que recebe o conteúdo da peça + a personalização do escritório e devolve o documento final já estilizado. Toda regra de estilo fica nele; o front só exibe.
2. **Cabeçalho e rodapé reais:** aplicar como header/footer da seção do documento (repetem em todas as páginas e não são editáveis por engano no corpo):
   - cabeçalho: logo (imagem ou iniciais com a cor salva) + nome + contatos + linha separadora;
   - linha de identificação (processo nº / cliente) conforme a personalização;
   - rodapé: endereço do escritório + linha separadora;
   - bloco de assinatura (local/data, nome e OAB) conforme o modelo salvo.
3. **Formatação padrão:** fonte, tamanho, entrelinha e margens da personalização aplicados como estilo padrão do documento ("Normal"), preservando títulos e destaques próprios do texto do modelo (como já diz a tela de personalização).
4. **Usar em TODOS os pontos:** pré-visualização do modelo, revisão dos campos, novo documento (em branco ou a partir de modelo), rascunho reaberto, download PDF e download Word. Localize cada um e troque a montagem local pela chamada a esse serviço. PDF e Word devem sair da MESMA conversão do documento estilizado (não montar PDF separado).
5. **Sem personalização salva:** usar o padrão atual do sistema, sem quebrar.
6. **Sem duplicar:** se o texto do modelo já trouxer o cabeçalho antigo como parágrafo no corpo, não duplicar (remover o bloco antigo ao aplicar o cabeçalho real, ou documentar o critério usado).
7. Se a personalização mudar, documentos novos e reabertos usam a versão atual; peças já finalizadas/baixadas não mudam.

## Aceite
- Abrir qualquer tela com editor: cabeçalho com logo, cor e linha; rodapé com endereço; fonte/entrelinha/margens iguais à pré-visualização da personalização.
- PDF e Word baixados idênticos ao editor (cabeçalho/rodapé em todas as páginas).
- Sem duplicação de cabeçalho.

## Entregar também
Lista de todos os pontos que montavam o documento por conta própria e como ficaram.

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
