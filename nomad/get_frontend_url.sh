#!/bin/bash

PROTOCOL=http   # or https

FRONTEND_IP=$(dig +short @${CONSUL_ADDR} -p 8600 frontend.service.consul)

PUBLIC_IP=$(aws ec2 describe-instances --filter Name=private-ip-address,Values=${FRONTEND_IP} Name=instance-state-name,Values=running --query Reservations[*].Instances[*].PublicIpAddress[][] --output text )

PORT=$(dig +short @${CONSUL_ADDR} -p 8600 frontend.service.consul srv | awk 'NR==1 { printf "%s", $3 }')

echo ${PROTOCOL}://${PUBLIC_IP}:${PORT}

