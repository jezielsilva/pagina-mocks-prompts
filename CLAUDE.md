# Portal de transferência — regras para o Claude

- Manter SÓ o que importa: a cada envio, apagar as versões anteriores.
  - Artefato: um arquivo por projeto, sempre sobrescrito (ex.: `artefatos/documentos-mock.html`), com a data atualizada no `itens.json`.
  - Prompt: ao publicar um prompt novo, apagar os prompts anteriores (arquivo em `prompts/` e entrada no `itens.json`).
- `itens.json` é o índice da página: atualizar `atualizado` e as entradas a cada push.
- Respostas do usuário chegam como Issues; ao resolver, avisar no chat (imagens das Issues não são acessíveis deste ambiente).
- Commits terminam com as linhas de atribuição da sessão.
