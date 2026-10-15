# Roteiro de demonstração — BIND 9

Ensaio e tempos medidos: pendentes. Janela: 15 minutos + 5 para perguntas.
Escolha um operador e um narrador entre os integrantes antes da aula.
Use sempre a mesma pasta e o mesmo `-p`, se houver.

## Antes da aula

- Execute `docker compose --profile ferramentas pull` e faça o teste normal.
- Confira as duas portas TCP/UDP, a rede Docker, memória e acesso de um colega.
- Se houver participação pela LAN, ajuste `DNS_BIND_ADDRESS=0.0.0.0`, recrie os
  serviços e libere as portas no firewall. Não dependa de mDNS ou do DNS do host.
- Deixe uma segunda janela preparada e grave previamente consultas, falha e recuperação.
- Preencha o caminho/link da gravação, integrantes, versões e data do ensaio.

## Ato 1 — Subir (00:00–03:00)

Apresente a issue, o problema de nomeação e o diagrama no README.

```text
docker compose up -d --wait --wait-timeout 120
docker compose ps
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
```

Esperado: dois DNS `healthy` e linhas `OK` no teste. Explique que a cópia do
secundário veio de transferência de zona, não de um arquivo compartilhado.

## Ato 2 — Funcionar (03:00–10:00)

```text
docker compose run --rm --no-deps cliente dig @dns-primario app.lab.test A
docker compose run --rm --no-deps cliente dig @dns-primario www.lab.test CNAME +short
docker compose run --rm --no-deps cliente dig @dns-primario _http._tcp.lab.test SRV +short
docker compose run --rm --no-deps cliente dig @dns-secundario lab.test SOA +short
```

Esperado: A `192.0.2.80` com `aa`, CNAME `app.lab.test.`, SRV
`0 5 8080 app.lab.test.` e SOA igual ao primário. Os endereços A da aplicação
são fictícios; não abra um navegador esperando um site.

Peça a um colega para consultar seu IP LAN nas portas 1053 e 2053, conforme
os comandos da seção 6 do README. Confirme a resposta observada no notebook dele.

Se houver internet, mostre encaminhamento/cache e TTL com os comandos dessa
seção. Compare a ausência de `aa` na resposta externa. Se o acesso externo
falhar, siga com a autoridade local e explique o limite sem consumir o tempo.

## Ato 3 — Falhar e recuperar (10:00–15:00)

```text
docker compose stop dns-primario
docker compose run --rm --no-deps cliente sh /testes/verificar.sh falha
docker compose run --rm --no-deps cliente dig @dns-secundario app.lab.test A +short
docker compose up -d --wait --wait-timeout 120
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
```

Esperado: primário indisponível, secundário responde `192.0.2.80`, recuperação
e teste normal aprovado. Peça ao colega que consulte novamente a porta 2053.
O teste de recriação/persistência fica preparado na seção 7 para perguntas,
sem consumir os 15 minutos se o ensaio indicar tempo insuficiente.

Fechamento: **A replicação de zona mantém a resolução disponível no secundário
durante a queda do primário, limitada pela validade da cópia e pela escolha do
servidor DNS pelo cliente.**

## Plano B

Imagens já baixadas; ambiente pré-iniciado em segunda janela; gravação local
do fluxo normal, falha e recuperação. Caminho/link da gravação: **a preparar**.
A zona `lab.test` funciona sem internet; as consultas externas são opcionais.

## Depois da demonstração

```text
docker compose down --volumes --remove-orphans
```

Desfaça a escuta LAN e as liberações de firewall. Registre duração, resultados,
erros reais, consumo e revisão cruzada antes de entregar.
