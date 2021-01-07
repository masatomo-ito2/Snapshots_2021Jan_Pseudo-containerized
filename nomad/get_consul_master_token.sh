#!/bin/bash

terraform -chdir=../terraform output -json | jq -r '.consul_master_token.value' 
