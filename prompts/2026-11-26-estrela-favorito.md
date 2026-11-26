# Prompt — Gerador de peças: estrela de favorito igual ao mock

## Referência visual (fonte da verdade)
- Mock (aba "Grade", canto superior direito de cada folha): **https://jezielsilva.github.io/pagina-mocks-prompts/artefatos/gerador-pecas-mock.html**
- Código do mock (classe `.pa-star`, ícone `star`): **https://github.com/jezielsilva/pagina-mocks-prompts/blob/main/artefatos/gerador-pecas-mock.html**

## O que fazer (só front, só visual)
Localize no código o botão de favoritar modelo do Gerador de peças (grade, lista e painel/modal de detalhes, onde houver estrela) e use EXATAMENTE este ícone e estilo, num componente reutilizável (ou o equivalente que já exista no projeto — não criar se já houver um botão-ícone para reaproveitar).

### Ícone (SVG de traço, 24×24, exibido em 15px)
```html
<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 3l2.8 5.7 6.2.9-4.5 4.4 1.1 6.2L12 17.3 6.4 20.2l1.1-6.2L3 9.6l6.2-.9z"/>
</svg>
```
- **Não favorito:** `fill="none"` (só contorno).
- **Favorito:** mesmo SVG com `fill="currentColor"` (estrela cheia).

### Estilo
```css
.pa-star{position:absolute;top:6px;right:6px;z-index:1;border:0;background:none;padding:2px;
  display:grid;place-items:center;cursor:pointer;color:#94a3b8}   /* cinza (slate-400) */
.pa-star.on{color:#d97706}                                         /* laranja (warning) */
.pa-star:hover{color:#d97706}
```
- Sem fundo, sem borda, sem círculo. Se o projeto tiver as variáveis de cor equivalentes (cinza 400 e warning), usar as variáveis.
- Acessibilidade: `aria-label` "Adicionar aos favoritos" / "Remover dos favoritos" e `aria-pressed`.
- Clique na estrela NÃO abre o modelo (parar a propagação do clique).

### Comportamento
- O estado de favorito vem do back-end (já existente); o front só alterna a classe/preenchimento conforme a resposta. Sem regra de negócio no front.

## Aceite
- Estrela idêntica ao mock: contorno cinza fino; ao favoritar, cheia e laranja; hover laranja.
- Mesmo visual em todos os lugares que mostram favorito no Gerador de peças.

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
