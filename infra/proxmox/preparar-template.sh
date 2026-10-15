#!/bin/sh
# Executar como root SOMENTE após snapshot, backup das credenciais pessoais
# e preparação do disco Cloud-Init no Proxmox. Não desliga a VM automaticamente.
set -eu

[ "$(id -u)" = 0 ] || { echo 'Execute como root na VM base.' >&2; exit 1; }
id administrador >/dev/null
command -v docker >/dev/null
command -v cloud-init >/dev/null
if [ -f /home/administrador/.config/gh/hosts.yml ]; then
    echo 'Retire o login GitHub pessoal do template após backup privado.' >&2
    exit 1
fi

usermod -aG docker administrador
systemctl enable docker.service containerd.service

# O instalador do Ubuntu desabilita cloud-init e fixa a interface no MAC antigo.
# Não aplicar netplan agora: a rede atual permanece até o desligamento planejado.
rm -f /etc/cloud/cloud-init.disabled
rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg
rm -f /etc/cloud/cloud.cfg.d/00-subiquity-disable-cloudinit-networking.cfg
rm -f /etc/netplan/00-installer-config.yaml
cat > /etc/cloud/cloud.cfg.d/99-sdtr-template.cfg <<'EOF'
datasource_list: [NoCloud]
preserve_hostname: false
manage_etc_hosts: true
ssh_deletekeys: true
ssh_genkeytypes: [rsa, ecdsa, ed25519]
ssh_pwauth: true
package_update: false
package_upgrade: false
system_info:
  default_user:
    name: administrador
    lock_passwd: false
    gecos: Administrador dos nos de laboratorio
    groups: [adm, sudo, docker]
    shell: /bin/bash
EOF
chmod 644 /etc/cloud/cloud.cfg.d/99-sdtr-template.cfg

# O próximo boot é do clone: systemd cria machine-id e cloud-init gera chaves SSH.
cloud-init clean --logs --machine-id --seed
sync
echo 'Base preparada. Desligue, converta em template e inicie apenas os clones.'
