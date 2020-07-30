#!/usr/bin/env bash

OPTIONS=""

# TODO: make this robust
for file in ../script/*; do
  OPTIONS+=" $(basename "$file")"
done

echo $OPTIONS

complete -W "$OPTIONS" dev-nginx
