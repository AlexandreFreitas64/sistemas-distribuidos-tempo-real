# Imagens da demonstração

O diagrama está em Mermaid no README do tutorial. As capturas abaixo foram
obtidas no navegador, a partir do console real das VMs e do painel Proxmox.
Os comandos do laboratório foram executados como `administrador`, sem sudo.

| Captura | Evidência |
| --- | --- |
| [01 — Ambiente primário](01-ambiente-primario.png) | Versões, usuário, interface e uma instância saudável |
| [02 — Ambiente secundário](02-ambiente-secundario.png) | Versões, usuário, interface e uma instância saudável |
| [03 — Configuração primária](03-configuracao-primario.png) | Configuração efetiva e validação da zona |
| [04 — Configuração secundária](04-configuracao-secundario.png) | Configuração e zona recebida pela rede |
| [05 — Testes e replicação](05-testes-e-replicacao.png) | Consultas e nova transferência autenticada TSIG |
| [06 — Consultas e AXFR](06-consultas-e-axfr.png) | SOA, A/TCP, SRV e recusa de AXFR sem chave |
| [07 — Falha do primário](07-falha-do-primario.png) | Secundário recriado e respondendo com a VM primária desligada |
| [08 — Recuperação](08-recuperacao.png) | Consultas aprovadas após religar o primário |
| [09 — Host primário](09-host-primario.png) | VM primária no host cosmos |
| [10 — Host secundário](10-host-secundario.png) | VM secundária no host pve |

Os prints de console mostram saídas reais, com o prefixo `+` do rastreamento do
shell. Os prints 09–10 são recortes nativos do navegador que preservam a
identificação, o estado e o host; outras VMs, SDN e armazenamentos ficam fora
da imagem. Os originais completos e registros privados não são publicados.

Os resultados e o alcance dos testes estão no [registro de validação](../validacao.md).
