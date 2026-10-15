# Ambiente Docker dos laboratórios

O Docker executa middlewares e ferramentas de demonstração. O primeiro
laboratório é [BIND 9](../tutoriais/dns/bind9/README.md), com DNS primário e
secundário. O site original da disciplina e seu `mkdocs.yml` são preservados;
não há serviço Docker de documentação nesta base.

## Pré-requisitos por sistema

| Sistema | Preparação |
| --- | --- |
| Windows | Docker Desktop, backend WSL2, contêineres Linux e virtualização habilitada |
| Linux | Docker Engine e plugin Compose, com acesso do usuário ao daemon |
| macOS | Docker Desktop para Intel ou Apple Silicon |

Confira `docker version` (cliente e servidor) e `docker compose version`.
Use Compose **2.20 ou superior**: a raiz usa `include` para reutilizar o Compose
do tutorial sem duplicação. Os comandos são iguais no PowerShell, Linux e
macOS; as ferramentas DNS ficam no contêiner cliente.

As imagens selecionadas têm variantes Linux AMD64 e ARM64, verificadas no
registro em 14/10/2026. Isso não substitui testes reais em cada sistema.

## Iniciar, consultar e encerrar

Na raiz do clone:

```text
docker compose config --quiet
docker compose up -d --wait --wait-timeout 120
docker compose ps
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
docker compose down --remove-orphans
```

Resultado esperado: dois servidores saudáveis; consultas, replicação e bloqueio
de transferência não autenticada aprovados. O teste aguarda a transferência
inicial. Execute também o teste de falha descrito no tutorial.

Também é possível iniciar diretamente de `tutoriais/dns/bind9/` com
`docker compose up -d`. **Escolha uma pasta e mantenha-a em todos os comandos**:
por padrão, raiz e pasta do tutorial geram nomes de projeto diferentes. Para
operar o mesmo ambiente das duas pastas, use explicitamente o mesmo
`docker compose -p sdtr-bind9 ...` em todos os comandos.

## Montagens, persistência e limpeza

Configurações, zona primária e testes ficam no projeto e são montados somente
para leitura. Cache e zona recebida pelo secundário ficam em quatro volumes
nomeados. Dependências ficam nas imagens; logs vão para `docker compose logs`.
Nenhum serviço grava nos arquivos versionados do host.

O encerramento normal preserva os volumes. Para apagar os dados **desse ambiente**:

```text
docker compose down --volumes --remove-orphans
```

As imagens permanecem no cache Docker para reutilização e demonstrações offline.
Não use limpeza global do Docker para reiniciar um laboratório.

## Portas e instâncias simultâneas

Por padrão, primário em `127.0.0.1:1053` e secundário em `127.0.0.1:2053`,
ambos TCP/UDP. Não há servidor HTTP em `localhost:8000`.

O `.env` é opcional. Copie `.env.example` para `.env` **na pasta escolhida para
os comandos** e ajuste as portas. Os padrões funcionam sem essa cópia.
Para outra instância, escolha portas livres, outro nome de projeto com `-p` e
outra sub-rede interna. O tutorial usa `172.30.53.0/24` e explica como alterá-la.

Para acesso pela turma, ajuste `DNS_BIND_ADDRESS=0.0.0.0`, recrie os serviços e
libere somente as portas DNS do laboratório no firewall da rede da aula.
Os colegas consultam o IP LAN do apresentador e a porta publicada, não o IP do
contêiner. Retorne a `127.0.0.1` depois. Não altere o DNS do sistema operacional.

## Verificação e limites

A CI valida o Compose, arquivos BIND e zona; testa consultas UDP/TCP,
replicação, recusa de AXFR sem chave, falha do primário e persistência do
secundário após recriação. A execução do fork na branch `hml` passou, assim
como a homologação real em VM Linux AMD64 em 15/10/2026.

Nesta máquina Windows, Docker não foi encontrado e o serviço WSL está desativado.
O runtime local Windows não foi instalado. A homologação foi realizada numa VM
Ubuntu 26.04.1 LTS, como usuário `administrador` do grupo Docker, sem `sudo`.
Consulte o [registro de validação](../tutoriais/dns/bind9/validacao.md).
Windows, macOS/ARM64, revisão cruzada e ensaios de sala seguem pendentes.

Consulte diagnósticos e referências no tutorial. As instruções de colaboração
ficam em [colaboracao.md](colaboracao.md).
