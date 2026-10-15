# Verificação do laboratório BIND 9

Este roteiro descreve como conferir configuração, consultas, replicação e
recuperação. Execute-o no seu laboratório e registre separadamente os resultados
obtidos; os comandos abaixo não representam uma execução automática já concluída.

## Preparação e configuração

Configure o `.env` em cada nó conforme o [tutorial](README.md), com IPs reais,
distintos e estáveis. O primário e o secundário devem se alcançar por TCP/UDP
na porta definida em `DNS_PORT`. Execute os comandos sempre na mesma pasta
usada para iniciar o Compose: a raiz do projeto ou a pasta do tutorial.

Em cada nó:

```sh
docker compose --profile ferramentas config --quiet
docker compose --profile ferramentas pull
docker compose up -d --wait --wait-timeout 120
docker compose ps -a
docker compose exec -T dns named-checkconf /etc/bind/named.conf
docker compose exec -T dns rndc -c /etc/bind/shared/rndc.conf status
```

Resultado esperado: um serviço `dns` saudável por nó e um `configurador`
finalizado com código zero. `named-checkconf` deve encerrar sem erros; `rndc`
deve informar que o servidor está funcionando. O cliente é iniciado sob demanda.

Somente no primário, confira também o arquivo de zona:

```sh
docker compose exec -T dns named-checkzone lab.test /etc/bind/zones/db.lab.test
```

Resultado esperado: zona carregada com o serial configurado e mensagem `OK`.

## Consultas e replicação

Com os dois nós ligados, execute em qualquer um:

```sh
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
```

O teste deve encerrar com código zero e confirmar:

- Registro A de `app.lab.test` igual a `192.0.2.80`, endereço fictício do exercício,
  por UDP e TCP em ambos os servidores.
- Registros CNAME, SRV e NS conforme a zona de exemplo.
- Resposta `NXDOMAIN` autoritativa para um nome inexistente.
- SOA igual nos dois nós e endereços de `ns1` e `ns2` correspondentes ao `.env`.
- Recusa de transferência AXFR solicitada sem chave.

Para solicitar uma nova transferência e conferir a autenticação, no secundário:

```sh
docker compose exec -T dns rndc -c /etc/bind/shared/rndc.conf retransfer lab.test
docker compose logs --tail=80 dns
```

Aguarde a conclusão da transferência. Os logs devem indicar o primário
configurado, a chave TSIG `lab-transfer`, o serial recebido e o sucesso da
operação. Repita `normal` para conferir novamente as respostas dos dois nós.

## Falha do primário

Desligue somente a VM ou máquina do primário, mantendo o secundário e o cliente
disponíveis. Em um laboratório virtual, use o hipervisor escolhido.
No secundário:

```sh
docker compose run --rm --no-deps cliente sh /testes/verificar.sh falha
```

Resultado esperado: o primário não responde, mas o secundário atende por UDP/TCP
com a zona recebida. O teste deve encerrar com código zero.

Como alternativa, `docker compose stop dns` no primário permite testar a falha
do serviço. Identifique qual falha foi provocada: parar um contêiner não equivale
a desligar o nó. Para demonstrar isolamento entre hospedeiros, distribua as VMs
por máquinas físicas diferentes.

## Persistência do secundário

Com o primário ainda indisponível, recrie somente o contêiner DNS do secundário:

```sh
docker compose up -d --no-deps --force-recreate --wait --wait-timeout 120 dns
docker compose run --rm --no-deps cliente sh /testes/verificar.sh falha
```

Resultado esperado: o secundário utiliza a zona armazenada no volume e continua
respondendo. Não remova volumes durante esse teste. A cópia permanece válida
até o prazo de expiração definido no SOA; execute o ensaio dentro desse prazo.

## Recuperação e encerramento

Religue o nó primário. Se apenas o serviço tiver sido parado, inicie-o novamente.
No primário:

```sh
docker compose up -d --wait --wait-timeout 120
```

Em qualquer nó, repita `normal`. Confira também `docker compose ps -a` em ambos.
Resultado esperado: os dois servidores saudáveis, serial igual e todas as
consultas aprovadas.

Para encerrar preservando os dados, execute em cada nó:

```sh
docker compose down
```

Para descartar os dados deste laboratório, use
`docker compose down --volumes --remove-orphans`. A remoção dos volumes apaga
a zona recebida e o cache; preserve os dados necessários antes da limpeza.

## Registro da execução e CI

Registre data, versões efetivamente utilizadas, arquitetura, tipo de falha
provocada, resultados e limitações. Inventários, credenciais e procedimentos
operacionais particulares devem permanecer fora da contribuição pública.

A CI confere o Compose da raiz e do tutorial, gera as configurações, valida
o BIND e inicia cada papel em um runner separado. No primário, também consulta
a zona local. A CI não estabelece comunicação entre esses runners e não
substitui os ensaios de replicação, falha, persistência e recuperação acima.
