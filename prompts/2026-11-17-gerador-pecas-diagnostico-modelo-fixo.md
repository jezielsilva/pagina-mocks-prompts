# Prompt Codex: diagnóstico do drawer que sempre abre o mesmo modelo ("Agravo Interno")

> Cole tudo abaixo no Codex (Luna). Isto é **só diagnóstico**: NÃO altere código, banco nem configuração sem me mostrar a causa antes. Não crie testes.

---

Módulo **Gerador de peças**, biblioteca de modelos. Ao clicar num modelo, abre um drawer com a pré-visualização. Localize no código pela função descrita; não vou passar nomes de arquivos.


### Sintoma

Qualquer modelo que o usuário clique na biblioteca abre o drawer com o conteúdo do **Agravo Interno**: título, classificação e texto da folha. Os outros modelos nunca aparecem.

### O que JÁ FOI VERIFICADO no código (linha por linha; não refaça, confie)

Todo o caminho do id foi lido e **está correto**:

- **Front, grade:** cada card está num `@for` com `track modelo.id` e chama a ação de clique com o **próprio** modelo do laço. Clique simples → após 250ms abre o detalhe com `modelo.id`; duplo clique/Enter → usa o modelo.
- **Front, lista (tabela):** o botão de opções da linha abre o menu ancorado e procura a linha pelo id certo; "Pré-visualizar" chama a mesma ação de abrir detalhe.
- **Front, facade da biblioteca:** um BehaviorSubject de "id do modelo aberto" + `switchMap` chama o GET de "obter modelo por id" com o id na URL (`encodeURIComponent`). Fechar o drawer manda `null` e zera o estado.
- **Front, interceptor HTTP:** só põe token/refresh. **Não há cache.**
- **Back, controller:** o GET de modelo por id repassa o id da rota para o Business.
- **Back, Business "obter modelo":** valida o acesso, confere se o id é ObjectId válido, chama o repository e monta o detalhe (nome, conteúdo, prévia, campos, classificação) **a partir do documento que o repository devolveu**.
- **Back, repository:** o filtro é "modelos visíveis" **E** `Id == id pedido`. O campo `Id` tem `[BsonId, BsonRepresentation(ObjectId)]`, então o Eq funciona. A agregação faz `$match` primeiro e depois o `$lookup` de usos.
- **Back, lista:** a projeção da lista devolve o `Id` de cada documento.

**Conclusão:** o código não troca o id. O defeito está nos **dados** ou no **ambiente**. Investigue nesta ordem:

1. **Network do navegador (5 minutos, resolve a dúvida):** abra a biblioteca com o DevTools > Network filtrado por `modelos/`. Clique em 3 modelos diferentes e anote, para cada clique, o **id da URL** e, na resposta, o **`id`**, o **`nome`** e o começo do **`conteudoHtml`**.
   - **Ids da URL diferentes, mas respostas com `nome` diferentes e `conteudoHtml` igual (texto do Agravo Interno):** os modelos do sistema foram cadastrados com o **mesmo conteúdo** (carga/lote copiou o texto). **Não corrija o banco.** Pare e me devolva a lista de modelos com conteúdo repetido (nome + id). A correção é recadastrar pelo gerenciador de peças.
   - **Ids diferentes e resposta com o mesmo `id`/`nome` (Agravo Interno):** o filtro de id está sendo perdido no back. Coloque um log temporário no Business (id recebido × id devolvido) e no repository (filtro renderizado). Corrija e explique.
   - **Mesmo id na URL em todos os cliques:** o card está mandando o id errado. Depure o clique no front.
2. **API apontando para outro banco:** confira se o front local aponta para a API certa e se a API aponta para o banco onde estão os modelos novos (o build antigo da API pode estar rodando). Reinicie a API depois do pull.
3. **Prévia da folha:** mesmo com o texto certo, a folha pode parecer "sempre igual" se o componente da prévia não atualizar quando o `html` muda (ex.: algo calculado só uma vez). Confirme que trocar de modelo troca o texto renderizado, e não só o título.

### O que você entrega (sem corrigir nada ainda)

1. A tabela do teste de Network: clique, id da URL, `id` da resposta, `nome` da resposta e as primeiras 80 letras do `conteudoHtml`.
2. Qual dos cenários aconteceu e a **causa exata**, com a prova (print do Network, trecho de log ou consulta de leitura).
3. Se a causa for **dado repetido**: a lista dos modelos afetados (nome + id), obtida **só por leitura**.
4. Se a causa for **código ou ambiente**: o arquivo, o trecho e a correção proposta (antes/depois), **sem aplicar**.
5. Remova todo log temporário antes de entregar.
