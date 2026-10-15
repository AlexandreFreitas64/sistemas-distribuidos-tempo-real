# Registro de validação — 14/10/2026

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

## Verificações pendentes

- Executar `named-checkconf` e `named-checkzone` da imagem selecionada.
- Iniciar os servidores e confirmar RNDC saudável e transferência autenticada.
- Executar testes funcionais, queda, recuperação, persistência e limpeza.
- Testar portas publicadas TCP/UDP e consultas a partir do notebook de um colega.
- Observar encaminhamento/cache com internet e funcionamento local sem internet.
- Medir memória/disco, ensaiar os 15 minutos e preparar a gravação do plano B.
- Executar em Linux, Windows e macOS/Apple Silicon; obter revisão cruzada.

Docker não está no PATH nem no local padrão verificado; o serviço WSL respondeu
como desativado. A CI contém os testes de runtime, mas não foi enviada nem executada.
