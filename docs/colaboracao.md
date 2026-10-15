# Colaboração pelo fork

O repositório do professor é a referência para as entregas. Desenvolva no seu
fork e envie a contribuição por pull request quando estiver pronta para revisão.
As regras acadêmicas continuam no README da raiz.

## Remotes e sincronização

Confira os destinos antes de enviar qualquer alteração:

```text
git remote -v
git status
```

`origin` deve apontar para o fork do aluno ou grupo; `upstream`, para
`https://github.com/joaoepj2/sistemas-distribuidos-tempo-real.git`.
Se `upstream` ainda não existir, cadastre-o:

```text
git remote add upstream https://github.com/joaoepj2/sistemas-distribuidos-tempo-real.git
```

Com a árvore de trabalho limpa, sincronize a base antes de iniciar uma contribuição:

```text
git fetch upstream
git switch main
git merge --ff-only upstream/main
git push origin main
git switch -c tutorial/bind9
```

O último comando exemplifica a branch do primeiro laboratório. Para tutoriais, use
`tutorial/<software>`; para correções, `fix/<descricao>`. Caso o avanço simples
de `main` falhe por divergência, preserve os commits e revise o histórico antes
de reconciliar; não use reset ou push forçado como rotina.

## Contribuições pequenas e identificáveis

- Reserve o software com uma issue `Tutorial: <software>` no repositório da
  disciplina, conforme as orientações do professor.
- Cada integrante configura seu nome e e-mail Git e faz seus próprios commits.
- Confira `git diff` e prepare somente os arquivos pertinentes ao commit.
- Nunca versione senhas reais, `.env`, dados de execução ou dependências locais.
- Mantenha correções de infraestrutura e tutoriais distintos em branches e PRs próprios.

Para atualizar uma branch em andamento, busque as novidades e faça merge da
base explícita, resolvendo eventuais conflitos e repetindo as verificações:

```text
git fetch upstream
git merge upstream/main
```

## Criar um tutorial a partir do modelo

Na raiz do repositório, copie a pasta `templates/tutorial/` para
`tutoriais/<tema>/<software>/` pelo gerenciador de arquivos ou editor. Use nomes
minúsculos, sem espaços ou acentos. O modelo é um ponto de partida incompleto,
não uma demonstração executável.

1. Renomeie `docker-compose.yml.example` para `docker-compose.yml`.
2. Substitua os marcadores e selecione imagens com versões explícitas.
3. Complete as dez seções e o roteiro de 15 minutos com saídas verificadas.
4. Inclua ao menos dois nós ou clientes e uma falha demonstrável, conforme o software.
5. Teste o tutorial isoladamente, a partir da própria pasta, com `docker compose up -d`.
6. Registre os erros reais encontrados, o consumo e os sistemas efetivamente testados.
7. Atualize o catálogo em `tutoriais/README.md` com um link para o tutorial.

Cada tutorial escolhe as linguagens necessárias à sua demonstração e mantém
suas ferramentas nos contêineres. Esta base não impõe uma linguagem de aplicação.
Arquivos de configuração ficam no projeto; dados persistentes usam volumes
nomeados. Evite `container_name`, nomes globais de rede/volume, modo privilegiado
e dependência do ambiente Compose da raiz.

## Revisar e enviar

Confira a configuração com os comandos do [guia de ambiente](ambiente.md).
Execute as verificações funcionais, falha, recuperação e limpeza do tutorial.
A CI inicial verifica o laboratório BIND 9; novos middlewares precisarão de
validações próprias. A branch `hml` do fork é usada para homologação nas VMs.
O envio ao repositório do professor continua sendo uma etapa separada, por PR.

```text
git diff --check
git status
git push -u origin tutorial/bind9
```

Troque o nome da branch pelo utilizado. No GitHub, escolha como destino
`joaoepj2/sistemas-distribuidos-tempo-real`, branch `main`, e como origem a branch
do seu fork. Descreva o problema, o resultado e as verificações executadas.
Preencha o modelo de PR e indique explicitamente os testes pendentes.

Para tutoriais, peça a revisão cruzada de outro grupo em máquina limpa e registre
as correções antes da apresentação. O histórico deve mostrar contribuições dos
integrantes. A aprovação e o merge pertencem ao fluxo de revisão do professor.

## Organização

```text
docs/                  Conteúdo da disciplina e guias da base
templates/tutorial/    Modelo incompleto para copiar e adaptar
tutoriais/             Catálogo e ambientes independentes dos grupos
.github/               Validação automática e modelos de colaboração
```

Os tutoriais são publicados inicialmente como Markdown no repositório. Sua
integração integral ao site poderá ser proposta depois; esta etapa não duplica
o conteúdo nem adiciona plugins para importar pastas externas.
