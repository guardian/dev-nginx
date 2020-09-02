#!/usr/bin/env bash

OPTIONS=""

for file in $SCRIPT_DIR/*
do
 OPTIONS+=" $(basename "$file")"
done

# TODO: make this robust
OPTIONS="add-to-hosts-file link-config locate-nginx restart-nginx setup-app setup-cert"

complete -W "$OPTIONS" dev-nginx
