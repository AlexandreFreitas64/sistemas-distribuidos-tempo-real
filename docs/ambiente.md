# Ambiente Docker

O laboratório BIND usa duas máquinas ou VMs na mesma rede: uma primária e uma
secundária. Cada uma possui uma interface de rede e executa um único BIND.
Não é necessário adicionar interfaces, VLANs ou configurar macvlan.

Instale Docker Engine com Compose >= 2.20 no Linux, ou Docker Desktop com
contêineres Linux no Windows/macOS. Os comandos Compose são iguais nos três
sistemas; os testes rodam em contêiner, sem instalar ferramentas DNS no host.
A execução distribuída foi homologada em duas VMs Linux; Windows e macOS
precisam de validação de publicação de portas e firewall no ambiente utilizado.

1. Clone o fork em cada máquina e selecione a branch de trabalho.
2. Copie `.env.example` para `.env` na raiz em cada máquina.
3. Configure os IPs reais dos dois nós, a rede dos clientes e o papel local,
   conforme o [tutorial BIND](../tutoriais/dns/bind9/README.md).
4. Em cada nó, execute:

```sh
docker version
docker compose version
docker compose --profile ferramentas config --quiet
docker compose --profile ferramentas pull
docker compose up -d --wait --wait-timeout 120
docker compose ps -a
```

O serviço `dns` é o único servidor BIND. `configurador` termina após gerar os
arquivos; `cliente` é uma ferramenta de testes sob demanda. A raiz inclui o
Compose do tutorial; também é possível executar dentro da pasta do tutorial,
criando o `.env` naquela pasta. Escolha uma dessas formas por nó.

Configurações e testes são montados do projeto somente para leitura. Arquivos
gerados, cache e zona recebida usam volumes Docker próprios de cada nó. `.env`,
`temp/` e `.cache/` são ignorados: credenciais e inventário reais ficam fora do Git.
O Docker não executa MkDocs.

Após iniciar os dois nós, execute em qualquer um:

```sh
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
```

Para parar preservando dados: `docker compose down`. Para apagar os dados
somente deste laboratório: `docker compose down --volumes --remove-orphans`.
Não use limpeza global do Docker. Alterações de configuração exigem
`docker compose up -d --force-recreate --wait`; a zona primária deve ter o serial
incrementado para que o secundário receba alterações.
