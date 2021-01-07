#!/bin/bash

consul config delete -kind service-splitter -name backend
consul config delete -kind service-router -name backend
consul config delete -kind service-resolver -name backend
consul config delete -kind service-defaults -name backend
