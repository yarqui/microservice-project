#!/bin/bash

# --- Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

command_exists() {
    command -v "$1" &> /dev/null
}


install_docker() {
    if command_exists docker; then
        echo -e "${GREEN}Docker is already installed. Skipping.${NC}"
    else
        echo -e "${YELLOW}Installing Docker from the default repository...${NC}"
        sudo apt-get install -y docker.io
    fi
}

install_docker_compose() {
    if command_exists docker-compose; then
        echo -e "${GREEN}Docker Compose is already installed. Skipping.${NC}"
    else
        echo -e "${YELLOW}Installing Docker Compose from the default repository...${NC}"
        sudo apt-get install -y docker-compose
    fi
}

install_python_and_pip() {
    if command_exists python3 && command_exists pip3; then
        echo -e "${GREEN}Python 3 and Pip are already installed. Skipping.${NC}"
    else
        echo -e "${YELLOW}Installing Python 3 and Pip...${NC}"
        sudo apt-get install -y python3 python3-pip
    fi
}

install_django_with_pip() {
    if python3 -m pip show django &> /dev/null; then
        echo -e "${GREEN}Django is already installed. Skipping.${NC}"
    else
        echo -e "${YELLOW}Installing Django via pip...${NC}"
        # --break-system-packages flag to override the environment protection (specific requirement of the task)
        sudo pip3 install django --break-system-packages

        if python3 -m pip show django &> /dev/null; then
            echo -e "${GREEN}Django installed successfully.${NC}"
        else
            echo -e "${RED}Failed to install Django using pip.${NC}"
        fi
    fi
}


echo "Starting development tools setup..."

sudo apt-get update -y

install_docker
install_docker_compose
install_python_and_pip
install_django_with_pip

echo -e "\n${GREEN}Setup complete! All tools have been checked.${NC}"