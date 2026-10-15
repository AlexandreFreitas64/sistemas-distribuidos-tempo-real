# Nós de homologação no Proxmox

O fork usa a branch `hml` para homologação. Usuário padrão dos nós:
`administrador`, integrante do grupo `docker`. Com uma nova sessão de login,
esse usuário executa Docker sem `sudo`; o socket permanece `root:docker` com
modo `660`. O grupo Docker concede administração do daemon, conforme a
[documentação Docker](https://docs.docker.com/engine/install/linux-postinstall/).

## Preparação da base

1. Registrar inventário e tirar snapshot antes das alterações.
2. Preservar credenciais pessoais em backup privado e retirá-las do template.
3. Clonar o fork na branch `hml` em
   `/home/administrador/sistemas-distribuidos-tempo-real`.
4. No Proxmox, substituir a mídia de instalação pelo disco Cloud-Init, configurar
   `ciuser=administrador` e `ipconfig0=ip=dhcp` e manter boot pelo disco do sistema.
5. Como root dentro da base, executar `preparar-template.sh` deste diretório.
6. Desligar graciosamente e aguardar estado parado. O Proxmox não converte VMs
   que contenham snapshots: preserve uma recuperação independente e verificada
   antes de remover os snapshots da base e convertê-la em template.

No ambiente ZFS validado, o clone direto de snapshot foi impedido pelo disco EFI
e o rollback para um snapshot antigo foi impedido por outro mais recente.
A recuperação original foi preservada por exportação nativa `zfs send` dos dois
discos e da configuração, com conferência dos streams e SHA256, em diretório
privado no armazenamento do host. Detalhes e caminhos reais ficam em `temp/`.
Não remover snapshots sem um backup independente confirmado.

O script remove a configuração de rede vinculada ao MAC do instalador, habilita
NoCloud e limpa o estado cloud-init/machine-id. Não instala pacotes nem inicia
o laboratório. Não inicialize novamente a base após a limpeza; o próximo boot
deve ser de um clone com Cloud-Init configurado.

## Criar próximos nós

No host Proxmox que contém o template, escolha um VMID livre em todo o cluster
(incluindo containers LXC). Exemplo, substituindo os marcadores:

```sh
pvesh get /cluster/nextid --vmid <VMID_LIVRE>
qm clone <VMID_TEMPLATE> <VMID_LIVRE> --name node-2 --full 1
qm set <VMID_LIVRE> --ciuser administrador --ipconfig0 ip=dhcp --ciupgrade 0
qm cloudinit update <VMID_LIVRE>
qm config <VMID_LIVRE>
qm start <VMID_LIVRE>
```

Defina o nome `node-2`, `node-3` etc. **antes do primeiro boot**: o Cloud-Init
usa o nome configurado no Proxmox para definir o hostname. O clone deve ter MAC,
UUID SMBIOS e VM generation ID distintos; confira a configuração antes de
iniciar. No convidado, confirme machine-id, IP DHCP e fingerprints SSH próprios.
Não basta renomear a VM no painel após o primeiro boot para mudar o hostname.

Cada clone completo tem disco independente. O endereço IP DHCP é descoberto
pelo QEMU Guest Agent ou pelo servidor DHCP; não está fixado no repositório.
Para distribuir a base fora do laboratório, defina credenciais de acesso
apropriadas aos destinatários antes da distribuição.

## Atualizar e iniciar como administrador

```sh
cd /home/administrador/sistemas-distribuidos-tempo-real
git switch hml
git pull --ff-only origin hml
docker compose config --quiet
docker compose --profile ferramentas pull
docker compose up -d --wait --wait-timeout 120
docker compose run --rm --no-deps cliente sh /testes/verificar.sh normal
```

Para uma VM na rede da aula, o Compose continua publicado somente no loopback
por padrão. Consultas entre contêineres funcionam pelo cliente do laboratório;
para consultas diretas de colegas, configure o `.env` conforme o tutorial BIND.

## Evidências e recuperação

IPs, identificação do cluster, backups de autenticação, inventários e logs reais
ficam exclusivamente em `temp/`, ignorada pelo Git. O template não contém login
pessoal do GitHub; ele é restaurado somente no nó de homologação quando previsto.

O snapshot anterior preserva a base original. Recuperação deve ser coordenada
no Proxmox, com os clones desligados quando necessário; nunca reverta recursos
de outros serviços do cluster. Não executar limpeza global do Docker.

Referências: [Cloud-Init CLI](https://docs.cloud-init.io/en/latest/reference/cli.html),
[Cloud-Init no Proxmox](https://pve.proxmox.com/wiki/Cloud-Init_Support).
