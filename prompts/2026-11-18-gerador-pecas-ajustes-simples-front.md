# Prompt Codex: Gerador de peças, ajustes simples de front (6 itens)

> Cole tudo abaixo no Codex (Luna). Siga À RISCA. Não invente nada fora do que está escrito. Se algo não bater com o código, PARE e pergunte. Não adivinhe.

---

## 0. Antes de começar (obrigatório)

1. Leia o arquivo de instruções de agentes que fica na raiz do repositório do front e o guia de UI-Kit da pasta de agentes. Siga as regras deles.
2. Não sei os nomes dos arquivos e não vou passar. **Localize no código pela função descrita.** Antes de mudar qualquer coisa, escreva uma **mini-spec** curta com os arquivos encontrados, o que vai mudar em cada um e o porquê.
3. **NÃO** crie testes. **NÃO** rode testes, lint nem navegador. A validação é **só o build** do front.
4. **NÃO** altere estilos globais nem os arquivos de variáveis de cor gerados automaticamente. Estilo vai no SCSS do próprio componente.
5. Todo texto novo de interface vai para o arquivo central de mensagens do front, em pt-BR.
6. **NÃO mexa** na etapa **Revisão dos campos** do assistente nem na geração dos arquivos (Word/PDF): outra pessoa está trabalhando nelas agora. Se algum item abaixo parecer exigir isso, PARE e pergunte.

---

## ITEM 1: Tirar a marca d'água da personalização

**Onde:** Gerador de peças > Configurações > Personalização (identidade do escritório e a pré-visualização da folha ao lado).

**O que fazer:**

- Remova da tela o switch **"Marca d'água com o logo"** e o controle **"Intensidade da marca d'água"**.
- Remova a marca d'água da **pré-visualização** da folha nessa modal e no drawer de pré-visualização do modelo da biblioteca.
- No **editor de layout da folha** (papel timbrado por arraste), remova a opção de adicionar o bloco de marca d'água.
- **Não** apague campos do contrato com a API nem do banco. Só deixe de exibir e de enviar como ligado. Se o front enviar o valor da marca d'água no salvamento, envie desligado.

---

## ITEM 2: Aviso "fazendo download" vira snackbar

**Onde:** biblioteca de modelos (grade/lista). Ao clicar em **Baixar modelo em branco (DOCX)** ou **Baixar modelo em branco (PDF)**, hoje aparece uma mensagem de "fazendo download" **entre a grade e o bloco "Quero fazer peça para processo"**, empurrando a grade para baixo.

**O que fazer:**

- Tire essa mensagem do layout. Nada pode empurrar a grade.
- No lugar, mostre o **snackbar do sistema** (o mesmo usado no resto do produto) com o texto de download em andamento enquanto baixa.
- Em caso de erro no download, use o snackbar de erro que já existe no fluxo. Não crie outro.

---

## ITEM 3: Tirar a opção "Gerar em lote"

**Onde:** assistente de geração, etapa **"De onde vêm os dados desta peça?"** (cards Processo, Cliente, Fornecedor, Preencher manualmente).

**O que fazer:**

- Remova a opção/controle **gerar em lote** e tudo que só existe por causa dela nessa tela (multisseleção liberada pelo lote, contador, textos).
- A seleção volta a ser **de um item só** (um processo, ou um cliente, ou um fornecedor).
- Remova variáveis, métodos e textos de mensagem que ficarem sem uso.

---

## ITEM 4: Badge "Recomendado" menor com o componente de badge

**Onde:** mesma etapa do item 3, no card **Processo** existe uma badge **"Recomendado"**.

**O que fazer:**

- Troque pelo **componente de badge do sistema** (`e-badge`), no tamanho menor que ele oferece.
- Remova o CSS local que desenhava a badge antiga.

---

## ITEM 5: Autocomplete cortado na etapa de origem

**Onde:** mesma etapa do item 3. Ao abrir o autocomplete de **Processo**, **Cliente** ou **Fornecedor**, a lista de opções aparece **cortada** pelo card/container que envolve o campo.

**O que fazer:**

- Encontre o ancestral que corta a lista (normalmente `overflow: hidden`/`auto` no card ou no container de rolagem).
- Corrija para a lista aparecer **inteira por cima** do conteúdo de baixo. Prefira, nesta ordem:
  1. se o componente de autocomplete tiver opção de abrir a lista no corpo da página (anexada ao `body`/overlay), use essa opção;
  2. senão, ajuste o `overflow` **só** do container local que corta, sem quebrar a rolagem da etapa.
- **Não** use `!important` nem `z-index` gigante como gambiarra.

---

## ITEM 6: Card "Cor do logo" do mesmo tamanho do campo de fonte

**Onde:** Configurações > Personalização. O card **"Cor do logo"** (quadrado de cor + texto `#xxxxxx`) está **mais alto** que o campo **"Fonte das peças"** ao lado.

**O que fazer:**

- Deixe o card de cor com a **mesma altura** do campo de fonte, alinhados na mesma linha.
- Ajuste o quadrado de cor e o espaçamento interno para caber nessa altura.
- Use os tokens de tamanho/raio que o campo de fonte já usa. Nada de medida inventada.

---

## Entrega

- Mini-spec antes, código depois.
- Build do front sem erro.
- Commit no padrão do repositório: `fix(gerador-pecas): <mensagem>`.

```
ESTILO DE CÓDIGO (perfil do Jeziel — obrigatório)
- Nomes mistos: domínio em português (ObterCliente, valorTotal), termos técnicos em inglês (Repository, GetById).
- Comentário-resumo em português no topo de cada método.
- Retorno antecipado; if de uma linha sem chaves; ternário só simples; switch clássico; var.
- Nulos: ?. e ?? liberados em cadeia curta (até 2 ?. + ?? no fim) com comentário de 1 linha; se "" também precisar virar padrão, string.IsNullOrWhiteSpace(x) ? "padrão" : x com comentário de 1 linha; em TS nunca usar || para valor padrão.
- LINQ básico encadeado (um operador por linha). Avançado só com comentário explicando.
- Back: seguir Controller → Business → Repository; sem genéricos/extension methods novos; Model→DTO manual; erro de negócio com objeto de resultado; Mongo com $set só dos campos alterados.
- Front: subscribe simples atribuindo em variáveis + takeUntilDestroyed(this.destroyRef) com inject(DestroyRef) (comentário de 1 linha: por que a fonte não termina sozinha e que o pipe encerra a assinatura ao fechar a tela); RxJS além de map/filter/tap só com explicação; template só exibe e condições simples.
- Valores fixos direto no código (constante só se repetir ou for regra configurável).
- Clean code/boas práticas: aplique, mas EXPLIQUE antes (na mini-spec) e na entrega.
- Todo trecho avançado: comentário curto em português no código + seção "Explicações" na entrega (o que faz, por que, versão simples equivalente, como debugar).
- Prefira variáveis intermediárias nomeadas (bom para breakpoint) a expressões longas.
```

Na entrega, inclua a seção **"Explicações"**: para cada item, o que mudou, por quê e como conferir.
