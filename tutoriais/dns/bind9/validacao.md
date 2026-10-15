# Registro de validação

Os resultados iniciais abaixo descrevem a topologia histórica de dois BIND na
mesma VM. Ela foi substituída por um BIND por VM; os resultados distribuídos
estão registrados ao final deste documento.

## Preparação inicial — 14/10/2026

Preparação inicial na branch `tutorial/bind9`, promovida à branch `hml` do fork
para homologação em VM Linux. O PR de identificação de usuários é independente.
Este registro lista as verificações iniciais; resultados de execução são
acrescentados após validação real. Dados privados do ambiente ficam em `temp/`.

## Verificações concluídas

| Verificação | Ferramenta | Resultado |
| --- | --- | --- |
| Compose da raiz e do tutorial | Compose oficial 2.39.4 para Windows, sem daemon | Configuração válida, incluindo perfil `ferramentas` |
| Montagens após expansão de `include` | Saída JSON do Compose | Fontes existem e são somente leitura |
| Isolamento e parâmetros | Saída JSON do Compose | Dois DNS padrão, cliente opcional, quatro volumes e portas substituíveis por variáveis |
| Zona `lab.test` | Python 3.10.11 e dnspython 2.8.0 temporário | Parse e registros A, CNAME, SRV, SOA e dois NS aprovados |
| Script de testes | Git Bash, `bash -n` | Sintaxe aprovada; testes funcionais não executados |
| Imagens | API pública do Docker Hub e manifests OCI | Digests selecionados existem e oferecem AMD64/ARM64 |
| Higiene | `git diff --check` | Sem erros de whitespace nas alterações rastreadas |

O binário Compose temporário foi conferido com o SHA256 publicado na release
oficial. Ele permite validar o modelo sem instalar Docker Engine. O parser da
zona não substitui `named-checkzone`, e a validação Compose não inicia serviços.
Ferramentas temporárias ficaram em `.cache/`, ignorada pelo Git, e foram removidas
ao concluir a validação; não houve instalação global de dependências DNS.

## Homologação Linux AMD64 — 15/10/2026

Ambiente: VM Ubuntu 26.04.1 LTS; Docker Engine 29.9.1; Compose 5.6.0;
BIND efetivo `9.20.24-1ubuntu0.3-Ubuntu`. Comandos Docker executados como
`administrador`, integrante do grupo `docker`, sem `sudo`.

| Verificação | Resultado observado |
| --- | --- |
| Atualização do fork | `git pull --ff-only origin hml` aplicou o commit de correção `452bcbd` |
| Configuração BIND e zona | `named-checkconf` em ambos e `named-checkzone` aprovados |
| Prontidão | Dois contêineres `healthy` |
| Consultas e replicação | A por UDP/TCP, CNAME, SRV, NS, NXDOMAIN autoritativo e SOA iguais aprovados |
| Transferência sem autenticação | AXFR do cliente sem chave recusado |
| Queda do primário | Secundário continuou respondendo; teste `falha` aprovado |
| Persistência | Secundário recriado com primário parado e teste `falha` novamente aprovado |
| Recuperação | Primário reiniciado; teste `normal` aprovado; ambos deixados saudáveis |
| Portas publicadas | 1053/2053 por UDP e TCP consultadas via loopback da VM, com cliente temporário em rede host |
| Memória | Amostra inicial: primário 16,01 MiB e secundário 7,68 MiB; não representa pico nem consumo total do host |
| CI no fork | [Execução 38675418774](https://github.com/guiguichinelo/sistemas-distribuidos-tempo-real/actions/runs/38675418774) aprovada |

A primeira execução de CI revelou que montar `/etc/bind` inteiro como somente
leitura impedia criar os destinos aninhados `shared` e `zones`. O Compose passou
a montar somente o arquivo `named.conf`; a CI e o laboratório real passaram.
Logs e dados identificadores do ambiente permanecem em `temp/`, fora do Git.

## Pendências registradas na topologia anterior

- Consultar a partir do notebook de um colega na LAN; loopback foi testado.
- Reproduzir limpeza completa e nova subida na VM; a CI executou sua limpeza final.
- Observar encaminhamento/cache com internet e funcionamento local sem internet.
- Medir picos de memória/disco, ensaiar os 15 minutos e preparar a gravação do plano B.
- Executar em Windows e macOS/Apple Silicon; obter revisão cruzada.

Na máquina Windows de desenvolvimento, Docker não estava no PATH e o serviço
WSL estava desativado; por isso a execução real foi feita na VM Linux.

## Homologação distribuída em duas VMs — 15/10/2026

A topologia anterior foi substituída no commit `b4f9676` da branch `hml` do
fork. O node-1 executa somente o primário e o node-2 somente o secundário.
Cada VM possui uma interface na mesma LAN, IP/MAC/machine-id próprios e disco
independente. Ambas estão no mesmo host Proxmox: o teste demonstra tolerância
à falha de VM, não à falha desse host físico.

| Verificação | Resultado observado |
| --- | --- |
| Recuperação preventiva | Snapshot do node-1 criado antes da migração |
| Migração | Dupla antiga removida do node-1; novo node-2 clonado do template e iniciado |
| Atualização e usuário | Ambos em `hml`, Docker como `administrador` sem sudo |
| Quantidade de servidores | Um `dns` saudável por VM; configurador termina com código zero |
| Configuração | Compose da raiz e `named-checkconf` aprovados; zona primária carregada com serial `2026101501` |
| Replicação | Logs do secundário confirmam transferência pela LAN com TSIG e serial `2026101501` |
| Consultas | A por UDP/TCP, CNAME, SRV, NS, NXDOMAIN autoritativo e SOA iguais aprovados |
| Acesso externo às VMs | Windows na LAN consultou os dois IPs diretamente, inclusive por TCP, na porta 53 |
| Transferência sem autenticação | AXFR sem chave recusado |
| Falha de nó | VM primária desligada graciosamente; Proxmox confirmou `stopped`; teste `falha` no secundário aprovado |
| Cliente durante a falha | Consulta TCP do Windows ao secundário respondeu `192.0.2.80` |
| Recuperação | VM primária religada; teste `normal` aprovado novamente; ambos deixados ligados |
| CI por papel | [Execução 38678228812](https://github.com/guiguichinelo/sistemas-distribuidos-tempo-real/actions/runs/38678228812) aprovada para primário e secundário em runners separados |

O secundário recebeu a zona pela rede, sem montagem do arquivo de zona do
primário. Os endereços de ambos no SOA/NS foram conferidos pelos testes. Os IPs,
VMIDs, logs completos e inventário permanecem em `temp/`, ignorada pelo Git.
A validação automática por papel não substitui o teste real entre VMs.

Continuam pendentes: execução dos servidores em Docker Desktop Windows/macOS,
revisão por colega, ensaio de 15 minutos, medições de pico e tolerância à falha
do host físico. O Windows foi validado como cliente DNS externo nesta etapa.
