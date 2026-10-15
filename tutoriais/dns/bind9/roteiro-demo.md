# Demonstração — 15 minutos

| Tempo | Ação | Evidência |
| --- | --- | --- |
| 0–2 min | Explicar DNS, zona, primário e secundário | Diagrama com duas VMs na mesma LAN |
| 2–4 min | Mostrar hostname, IP e `docker compose ps -a` nos dois nós | Um BIND por VM; configurador já finalizado |
| 4–7 min | Executar `docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal` | Registros corretos e SOA igual |
| 7–9 min | Mostrar logs e pedir a um colega consulta ao IP de cada nó | Respostas autoritativas e transferência |
| 9–12 min | Desligar a VM primária; no secundário executar o teste `falha` | Primário indisponível; secundário responde |
| 12–14 min | Religar primário e repetir `normal` | Recuperação com ambos disponíveis |
| 14–15 min | Explicar limite de expiração e limpar se apropriado | `docker compose down` em cada nó |

Antes da aula, baixe as imagens, configure os dois `.env`, reserve os IPs e
valide firewall e transferência. Tenha acesso ao hipervisor para desligar e
religar somente a VM do laboratório. Recursão externa requer Internet, mas a
zona local não. Não interrompa serviços de colegas.

Plano B: se o hipervisor estiver indisponível, pare apenas `dns` no primário
com `docker compose stop dns` e repita o teste de falha a partir do secundário.
Restaure com `docker compose up -d --wait`. Declare que isso comprova falha do
serviço, e não desligamento da VM. Se a rede falhar, use evidências registradas
em `validacao.md`, identificando claramente que não são execução ao vivo.
