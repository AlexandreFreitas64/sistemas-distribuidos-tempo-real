#!/bin/sh
# Executado no contêiner cliente: não requer shell ou dig no host.
set -eu

falhar() { echo "FALHOU: $*" >&2; exit 1; }
consultar() { dig +time=1 +tries=1 "$@"; }
igual() { [ "$1" = "$2" ] || falhar "$3: esperado '$2', recebido '$1'"; }

aguardar_zona() {
    tentativas=0
    until [ "$(consultar "@$1" app.lab.test A +short 2>/dev/null || true)" = "192.0.2.80" ]; do
        tentativas=$((tentativas + 1))
        [ "$tentativas" -lt 20 ] || falhar "zona indisponível em $1"
        sleep 1
    done
}

verificar_servidor() {
    servidor=$1
    aguardar_zona "$servidor"
    igual "$(consultar "@$servidor" app.lab.test A +short)" "192.0.2.80" "$servidor A/UDP"
    igual "$(consultar "@$servidor" app.lab.test A +tcp +short)" "192.0.2.80" "$servidor A/TCP"
    igual "$(consultar "@$servidor" www.lab.test CNAME +short)" "app.lab.test." "$servidor CNAME"
    igual "$(consultar "@$servidor" _http._tcp.lab.test SRV +short)" "0 5 8080 app.lab.test." "$servidor SRV"
    igual "$(consultar "@$servidor" lab.test NS +short | sort)" "$(printf 'ns1.lab.test.\nns2.lab.test.')" "$servidor NS"
    resposta=$(consultar "@$servidor" inexistente.lab.test A)
    echo "$resposta" | grep -q 'status: NXDOMAIN' || falhar "$servidor não devolveu NXDOMAIN"
    echo "$resposta" | grep -Eq 'flags:.* aa[ ;]' || falhar "$servidor não respondeu autoritativamente"
    echo "OK: $servidor UDP/TCP, A, CNAME, SRV, NS e NXDOMAIN autoritativo"
}

case "${1:-normal}" in
    normal)
        verificar_servidor dns-primario
        verificar_servidor dns-secundario
        igual "$(consultar @dns-primario lab.test SOA +short)" "$(consultar @dns-secundario lab.test SOA +short)" "SOA replicado"
        # dig pode devolver zero mesmo para alguns erros DNS: confira a resposta.
        transferencia=$(consultar @dns-primario lab.test AXFR 2>&1 || true)
        echo "$transferencia" | grep -Eq 'Transfer failed|REFUSED' || falhar "AXFR sem chave não foi recusado"
        echo 'OK: SOA replicado e AXFR sem chave recusado'
        ;;
    falha)
        # IP fixo evita confundir indisponibilidade com DNS de nomes do Docker.
        if consultar @172.30.53.10 app.lab.test A +short >/dev/null 2>&1; then
            falhar 'o primário ainda responde; execute docker compose stop dns-primario'
        fi
        verificar_servidor dns-secundario
        echo 'OK: secundário responde com o primário indisponível'
        ;;
    *) falhar 'modo esperado: normal ou falha' ;;
esac
