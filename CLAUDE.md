# Portal de transferência — regras para o Claude

- Prints: a CADA prompt publicado, apagar as imagens de `prints/` no mesmo commit (manter só `prints/LEIA-ME.txt`). Ler os prints ANTES de apagar.
- NÃO apagar itens automaticamente (exceto os prints, regra acima): o usuário exclui pelo ícone 🗑 da página.
  - Artefato: um arquivo por projeto, sempre sobrescrito (ex.: `artefatos/documentos-mock.html`), com a data atualizada no `itens.json`.
  - Prompt: cada prompt novo é um arquivo novo em `prompts/` + entrada no `itens.json`.
  - Antes de editar `itens.json`, dar `git pull` (a página também altera esse arquivo ao excluir).
- `itens.json` é o índice da página: atualizar `atualizado` e as entradas a cada push.
- Respostas do usuário chegam como Issues; ao resolver, avisar no chat (imagens das Issues não são acessíveis deste ambiente).
- Commits terminam com as linhas de atribuição da sessão.
