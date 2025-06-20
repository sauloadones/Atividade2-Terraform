#!/bin/bash

LOG="/home/ubuntu/user-data.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Início do script em $(date)"

# Corrige DNS para garantir acesso externo
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf

# Espera rede
sleep 10

# Atualiza pacotes
apt update -y && apt upgrade -y

# Instala dependências
apt install -y ansible git

# Verifica se o playbook foi entregue
PLAYBOOK_PATH="/home/ubuntu/ansible-config/playbook.yaml"

if [ -f "$PLAYBOOK_PATH" ]; then
  echo "[INFO] Playbook encontrado, executando..."
  chown -R ubuntu:ubuntu /home/ubuntu/ansible-config
  sudo -u ubuntu ansible-playbook "$PLAYBOOK_PATH"
else
  echo "[ERRO] Playbook não encontrado em $PLAYBOOK_PATH"
fi

echo "[INFO] Fim do script em $(date)"
