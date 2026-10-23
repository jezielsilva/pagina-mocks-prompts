# Portal de transferência — regras para o Claude

- A CADA publicação (prompt novo e/ou mock), no mesmo commit:
  - apagar as imagens de `prints/` (manter só `prints/LEIA-ME.txt`), depois de lê-las;
  - apagar os prompts anteriores (arquivos em `prompts/` + entradas no `itens.json`), deixando SÓ o(s) prompt(s) gerado(s) agora (itens com `"fixo": true` NUNCA são apagados);
  - o prompt novo contém SOMENTE os itens tratados na interação atual. NUNCA somar itens de prompts anteriores, a não ser que o usuário peça.
  - manter só o mock PRINCIPAL (`"principal": true` no `itens.json`). O mock publicado/atualizado agora passa a ser o principal; os outros mocks (de outros projetos) são apagados (arquivo + entrada).
- Assets (imagens/SVG para o sistema) são publicados em `assets/` como artefato com `"asset": true`; não contam como mock e são apagados junto com os prompts na publicação seguinte.
- Formulários (`formularios/`, artefato com `"formulario": true`) NÃO contam como mock nem prompt: ficam no portal até as respostas chegarem (Issue). Depois de processadas, apagar o formulário.
- Perfil de código do usuário: `perfil/PERFIL-DE-CODIGO.md` (item FIXO no portal, `"fixo": true`; NUNCA apagar na limpeza de prompts). Todo prompt de implementação para o Codex/Luna DEVE incluir o bloco "ESTILO DE CÓDIGO" da seção 10 desse arquivo (copiado inteiro) e pedir a seção "Explicações" na entrega.
- Treino diário: página `treino/index.html?d=AAAA-MM-DD` + dados `treino/AAAA-MM-DD.json` (item `"tipo":"artefato"`, `"treino": true`, `"fixo": true` até ser respondido). Respostas chegam como Issue "Treino AAAA-MM-DD — respostas". Progresso em `perfil/PROGRESSO-TREINO.md`.
- "Tornar principal": a página abre uma Issue "Tornar principal: <id>". Ao ler essa Issue: marcar esse mock como principal, apagar os outros mocks, fechar a Issue e avisar no chat. Os mocks ficam guardados no histórico do git e na pasta de trabalho do Claude (podem ser republicados).
- Fora as regras acima, NÃO apagar itens automaticamente: o usuário exclui pelo ícone 🗑 da página.
  - Artefato: um arquivo por projeto, sempre sobrescrito (ex.: `artefatos/documentos-mock.html`), com a data atualizada no `itens.json`.
  - Prompt: cada prompt novo é um arquivo novo em `prompts/` + entrada no `itens.json`.
  - Antes de editar `itens.json`, dar `git pull` (a página também altera esse arquivo ao excluir).
- `itens.json` é o índice da página: atualizar `atualizado` e as entradas a cada push.
- Respostas do usuário chegam como Issues; ao resolver, avisar no chat (imagens das Issues não são acessíveis deste ambiente).
- Commits terminam com as linhas de atribuição da sessão.
