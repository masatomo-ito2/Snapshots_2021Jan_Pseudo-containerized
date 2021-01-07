#!/bin/bash

consul config write service-defaults.hcl 
consul config write service-resolver.hcl
consul config write service-router.hcl
