#!/bin/bash

# colours
YELLOW='\033[1;33m'
NC='\033[0m' # no colour - reset console colour

echo -e "${YELLOW}Restarting nginx. This requires sudo access.${NC}"

sudo nginx -s stop
sudo nginx
