#!/bin/bash

LOG="/home/ubuntu/user-data.log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] Início do script em $(date)"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

until ping -c1 8.8.8.8 &>/dev/null; do
  echo "[INFO] Aguardando rede..."
  sleep 5
done


apt update && apt upgrade -y
apt install -y git ansible

iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

apt install -y iptables-persistent
netfilter-persistent save

git clone https://github.com/sauloadones/Atividade2-Terraform.git /home/ubuntu/projeto


cd /home/ubuntu/projeto
chown -R ubuntu:ubuntu .
sudo -u ubuntu ansible-playbook playbook.yaml --connection=local

echo "[INFO] Fim do script em $(date)"

