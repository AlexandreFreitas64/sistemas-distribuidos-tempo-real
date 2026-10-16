# Tutorial: <software>

> MODELO INCOMPLETO: substitua os marcadores antes de entregar. Este arquivo
> não documenta um laboratório já implementado ou testado.

Copie esta pasta para `tutoriais/<tema>/<software>/` e renomeie
`docker-compose.yml.example` para `docker-compose.yml`. Adapte a topologia,
imagens, configuração e testes ao software reservado pelo grupo.

Integrantes: <nomes e links GitHub>. Issue de reserva: <link>.

## 1. Visão geral

<Problema distribuído resolvido, aplicação, alternativas e quando não usar.>

<Inclua um diagrama simples da arquitetura e identifique dois ou mais nós/clientes.>

## 2. Conceitos mínimos

<Glossário de 5 a 8 termos necessários para acompanhar a demonstração.>

## 3. Pré-requisitos

<Sistemas e arquiteturas suportados; versões Docker/Compose; memória e disco
necessários e medidos. Registre data e máquinas realmente testadas.>

| Porta no host | Protocolo | Serviço | Finalidade |
| --- | --- | --- | --- |
| <porta alta> | <TCP/UDP> | <serviço> | <uso> |

## 4. Instalação

<Preparação das imagens e dos arquivos. O Compose final deve subir sem exigir
copiar um .env: use valores padrão de laboratório explícitos e documentados.>

```text
docker compose config --quiet
docker compose up -d
docker compose ps
```

<Saída esperada e critérios de prontidão de cada serviço.>

## 5. Configuração

<Explique os arquivos comentados, versões das imagens, rede, volumes, variáveis
e valores de laboratório. Monte configurações por caminhos relativos, preferindo
somente leitura. Não use segredos reais.>

<Exponha apenas portas necessárias, usando portas altas. Para participação de
colegas na rede da sala, documente o endereço de escuta e a liberação necessária
no firewall; esse acesso precisa ser testado antes da apresentação.>

## 6. Demonstração

Complete o [roteiro](roteiro-demo.md): subir em 3 minutos, funcionar com
participação da turma em 7 minutos e provocar uma falha em 5 minutos.

<Inclua comandos, saídas esperadas, participação dos colegas e frase final
relacionando a demonstração a um conceito da disciplina.>

## 7. Verificação e teste de falhas

<Verifique o fluxo normal com dois ou mais nós/clientes. Descreva a falha,
comportamento observado, recuperação e limites das garantias demonstradas.>

<Teste persistência ao reiniciar o ambiente e ausência dos dados após limpeza
dos volumes. Diferencie o resultado observado do comportamento apenas previsto.>

## 8. Problemas comuns

<Registre somente erros realmente encontrados pelo grupo, com sintomas, causa
identificada e correção verificada. Identifique orientações preventivas como tais.>

## 9. Limpeza

Na pasta deste tutorial, encerre preservando os dados:

```text
docker compose down --remove-orphans
```

Para apagar os dados de laboratório e permitir uma execução do zero:

```text
docker compose down --volumes --remove-orphans
```

<Se usar -p, inclua o mesmo nome em todos os comandos. Descreva outros artefatos
que precisem de limpeza; evite comandos globais que afetem outros projetos.>

## 10. Referências

<Documentação oficial, versões consultadas e data de consulta.>
