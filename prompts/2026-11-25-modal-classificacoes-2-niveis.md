# Prompt — Modal de Classificações (ADV · Documentos): categorias e subcategorias, igual ao mock

## Referência visual (fonte da verdade)
- Mock: **https://jezielsilva.github.io/pagina-mocks-prompts/artefatos/documentos-mock.html**
- Código do mock: **https://github.com/jezielsilva/pagina-mocks-prompts/blob/main/artefatos/documentos-mock.html**
- Como abrir: na tela, menu lateral → card **"Classificações"** (abre a modal). No código do mock, a modal é a função `dlgTipos()` (bloco "Classificações: central de gestão (Categoria › Subcategoria)"), dados em `CL2`, estilos nas classes `.cls-*`.
- **Abra o mock no navegador, use a modal e leia esse trecho do código antes de começar.** O resultado tem que ficar visualmente igual, usando os componentes do **UI kit do sistema** (não copiar o CSS do mock; mapear cada elemento para o componente equivalente do kit).

## Onde mexer (localize por função)
No sistema web ADV: a **modal "Classificações"** aberta a partir da tela de Documentos (hoje tem abas Classificações/Logs, botão "Novo tipo", filtros "Só os do escritório"/"Mostrar desativados", lista de categorias à esquerda e "Não há tipos nesta categoria" à direita). Mais o serviço/API de classificações que alimenta essa modal.

**Antes de codar:** entregue uma **mini-spec** (arquivos que vai alterar, contratos de API, mapeamento elemento do mock → componente do UI kit) e **aguarde meu OK**.

## Regra de negócio nova
- **Só 2 níveis:** Categoria → Subcategoria. O nível **Tipo sai** desta modal (textos, contadores, botões, filtros).
- Um arquivo pode ser classificado com **só a categoria** ou com **categoria + subcategoria**.
- Categorias e subcategorias **padrão** do sistema: somente leitura (cadeado "Padrão").
- O escritório **só cria subcategorias** (dentro de qualquer categoria). Não cria categoria.
- Subcategoria do escritório: **renomear, desativar, reativar, excluir**.
  - **Desativar preserva os vínculos** (arquivos continuam classificados; item some das opções de escolha). Hoje o sistema desvincula — mudar.
  - **Excluir bloqueado** se algum arquivo usa a subcategoria (mensagem com a contagem, sugerindo desativar).
  - Nome único dentro da categoria (padrão + escritório), comparando nome normalizado.
- **Toda regra no back-end.** O front só envia a ação e exibe o resultado/mensagem.

## Layout (igual ao mock)
1. **Abas:** "Classificações" | "Logs (N)".
2. **Barra:** busca "Buscar categoria ou subcategoria…", botão-filtro **"Só as do escritório"**, botão-filtro **"Mostrar desativadas"**, botão verde **"+ Nova subcategoria"**.
3. **Formulário de nova subcategoria** (inline, no topo): nome + select "Dentro da categoria" (pré-selecionada a categoria aberta), Cancelar / Criar subcategoria. Enter salva.
4. **Resumo:** "N categorias · N subcategorias · N do escritório" · "N arquivos classificados" · "N sem classificação — Classificar agora" · à direita "🔒 Itens "Padrão" são do sistema e não mudam".
5. **Coluna esquerda:** **todas as categorias** (ícone colorido, nome, "N subcategorias · N arquivos"), com rolagem própria; selecionada em destaque.
6. **Painel direito (categoria selecionada):**
   - Título + selo "Padrão" + texto "Os arquivos podem ser classificados só com a categoria ou com uma subcategoria dela".
   - Resumo: **N arquivos no total · N só na categoria · N subcategorias ativas**.
   - Rótulo "Subcategorias" + link "+ Criar subcategoria nesta categoria".
   - Linhas: nome · selo "Criada pelo escritório" / "Desativada" · "N arquivos" · ações (padrão = cadeado; escritório = Renomear (edição inline), Desativar, Excluir; desativada = Reativar).
   - Vazio: "Esta categoria não tem subcategorias. Os arquivos são classificados só com a categoria — ou crie uma subcategoria do escritório."
7. **Busca:** resultados agrupados por categoria com as subcategorias que batem; categoria que bate sem subcategorias aparece como item clicável.
8. **Logs:** filtros "Todos" / "Subcategorias (criar, renomear, desativar, excluir)" / "Arquivos classificados"; textos "criou/renomeou/desativou/reativou/excluiu a subcategoria X em Categoria"; paginação como hoje.
9. Mensagens (toast) como no mock; responsivo como o restante do sistema (em telas pequenas a lista de categorias vira faixa horizontal, como já acontece hoje).

## Back-end (o mínimo para a modal)
- **Listar catálogo do escritório:** categorias + subcategorias (padrão + do escritório) com: padrão?, ativo?, contagem de arquivos do escritório por subcategoria, contagem "só na categoria" e total por categoria, e os totais do resumo.
- **Criar / renomear / desativar / reativar / excluir** subcategoria do escritório, com as validações acima e retorno por objeto de resultado (mensagem pronta para o toast).
- **Log** de cada ação (já existe — ajustar textos/campos para subcategoria).
- Bloquear no back qualquer alteração em item padrão ou de outro escritório.

## Fora do escopo agora
- Seletor de classificar arquivo ("Classificar agora" e detalhe do documento): mantém o fluxo atual; será outro prompt.
- Promover/rebaixar/mover/mesclar (ficam no Gerenciador).
- Migração de dados (o catálogo será recriado por seed).

## Entrega
1. Mini-spec (aguardar OK). 2. Implementação completa (front + back). 3. Lista de arquivos alterados. 4. Print da modal nova ao lado do mock (mesmo estado: Direito Civil aberto; Direito Trabalhista com 1 subcategoria do escritório ativa e 1 desativada). 5. Seção **"Explicações"**.

> Sigilo: na resposta pode citar arquivos/classes do sistema normalmente (fica só entre nós).

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
