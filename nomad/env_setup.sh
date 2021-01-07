#!/bin/bash

SERVER_ADDR=$(terraform -chdir=../terraform output -json | jq -r '.public_ips_servers.value[0][0]')

# set the address of nomade server
export NOMAD_ADDR=http://${SERVER_ADDR}:4646

# consul's server IP
export CONSUL_ADDR=${SERVER_ADDR}

# set the address of consul server
export CONSUL_HTTP_ADDR=http://${SERVER_ADDR}:8500

# set the token for consul
export CONSUL_HTTP_TOKEN=$(terraform -chdir=../terraform output -raw consul_master_token)
