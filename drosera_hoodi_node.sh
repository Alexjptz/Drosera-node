#!/bin/bash

tput reset
tput civis

# SYSTEM COLOURS
show_orange() { echo -e "\e[33m$1\e[0m"; }
show_blue()   { echo -e "\e[34m$1\e[0m"; }
show_green()  { echo -e "\e[32m$1\e[0m"; }
show_red()    { echo -e "\e[31m$1\e[0m"; }
show_cyan()   { echo -e "\e[36m$1\e[0m"; }
show_purple() { echo -e "\e[35m$1\e[0m"; }
show_gray()   { echo -e "\e[90m$1\e[0m"; }
show_white()  { echo -e "\e[97m$1\e[0m"; }
show_blink()  { echo -e "\e[5m$1\e[0m"; }

# SYSTEM FUNCS
exit_script() {
    echo
    show_red   "🚫 Script terminated by user"
    show_gray  "────────────────────────────────────────────────────────────"
    show_orange "⚠️  All processes stopped. Returning to shell..."
    show_green "Goodbye, Agent. Stay legendary."
    echo
    sleep 1
    exit 0
}

incorrect_option() {
    echo
    show_red   "⛔️  Invalid option selected"
    show_orange "🔄  Please choose a valid option from the menu"
    show_gray  "Tip: Use numbers shown in brackets [1] [2] [3]..."
    echo
    sleep 1
}

process_notification() {
    local message="$1"
    local delay="${2:-1}"

    echo
    show_gray  "────────────────────────────────────────────────────────────"
    show_orange "🔔  $message"
    show_gray  "────────────────────────────────────────────────────────────"
    echo
    sleep "$delay"
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        show_green "✅ Success"
    else
        sleep 1
        show_red "❌ Error while executing command"
    fi
    echo
}

menu_header() {
    local container_status=$(docker inspect -f '{{.State.Status}}' drosera-operator 2>/dev/null || echo "not installed")
    local operator_status="🔴 OFFLINE"

    if [ "$container_status" = "running" ]; then
        operator_status="🟢 RUNNING"
    fi

    echo
    show_gray  "────────────────────────────────────────────"
    show_cyan  "     ⚙️  DROSERA OPERATOR - DOCKER STATUS"
    show_gray  "────────────────────────────────────────────"
    echo
    show_orange "Agent: $(whoami)   🕒 $(date +"%H:%M:%S")   📆 $(date +"%Y-%m-%d")"
    show_green  "Container: ${container_status^^}"
    show_blue   "Operator status: $operator_status"
    echo
}

menu_item() {
    local num="$1"
    local icon="$2"
    local title="$3"
    local description="$4"

    local formatted_line
    formatted_line=$(printf "  [%-1s] %-2s %-20s - %s" "$num" "$icon" "$title" "$description")
    show_blue "$formatted_line"
}

print_logo() {
    clear
    tput civis

    local logo_lines=(
        "  _______  .______        ______        _______. _______ .______           ___ "
        " |       \ |   _  \      /  __  \      /       ||   ____||   _  \         /   \ "
        " |  .--.  ||  |_)  |    |  |  |  |    |   (---- |  |__   |  |_)  |       /  ^  \ "
        " |  |  |  ||      /     |  |  |  |     \   \    |   __|  |      /       /  /_\  \ "
        " |  '--'  ||  |\  \----.|   --'  | .----)   |   |  |____ |  |\  \----. /  _____  \ "
        " |_______/ | _|  ._____| \______/  |_______/    |_______|| _| ._____|/__/     \__\ "
    )

    local messages=(
        ">> Initializing Drosera module..."
        ">> Establishing secure connection..."
        ">> Loading node configuration..."
        ">> Syncing with Hoodi Network..."
        ">> Checking system requirements..."
        ">> Terminal integrity: OK"
    )

    echo
    show_cyan "🛰️ INITIALIZING MODULE: \c"
    show_purple "DROSERA NETWORK"
    show_gray "────────────────────────────────────────────────────────────"
    echo
    sleep 0.5

    show_gray "Loading: \c"
    for i in {1..30}; do
        echo -ne "\e[32m█\e[0m"
        sleep 0.02
    done
    show_green " [100%]"
    echo
    sleep 0.3

    for msg in "${messages[@]}"; do
        show_gray "$msg"
        sleep 0.15
    done
    echo
    sleep 0.5

    for line in "${logo_lines[@]}"; do
        show_cyan "$line"
        sleep 0.08
    done

    echo
    show_green "⚙️  SYSTEM STATUS: ACTIVE"
    show_orange ">> ACCESS GRANTED. WELCOME TO PIPE NETWORK."
    show_gray "[DROSERA / Secure Terminal Session]"
    echo

    echo -ne "\e[1;37mAwaiting commands"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo -e "\e[0m"
    sleep 0.5

    tput cnorm
}


# NODE FUNCTIONS

install_dependencies() {
    process_notification "🔧 Installing system dependencies..."

    run_commands "sudo apt-get update && sudo apt-get upgrade -y"
    run_commands "sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y"

    show_green "✅ System dependencies installed"
}

install_docker() {
    process_notification "🐳 Checking Docker installation..."

    if command -v docker >/dev/null 2>&1; then
        show_green "✓ Docker already installed: $(docker --version | cut -d' ' -f3 | tr -d ',')"
        return
    fi

    process_notification "⬇️ Installing Docker..."

    run_commands "for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y \$pkg; done"
    run_commands "sudo apt-get update"
    run_commands "sudo apt-get install -y ca-certificates curl gnupg"

    run_commands "sudo install -m 0755 -d /etc/apt/keyrings"
    run_commands "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
    run_commands "sudo chmod a+r /etc/apt/keyrings/docker.gpg"

    run_commands "echo \
  \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \$(. /etc/os-release && echo \"\$VERSION_CODENAME\") stable\" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"

    run_commands "sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

    if sudo docker run hello-world >/dev/null 2>&1; then
        show_green "✅ Docker test successful"
    else
        show_red "❌ Docker test failed"
        show_gray "Try restarting the Docker service or rebooting"
    fi

}

configure_firewall() {
    process_notification "🛡️ Configuring firewall (ufw)..."

    declare -A PORT_DESCRIPTIONS=(
        [22]="SSH access"
        [31313]="Drosera P2P network"
        [31314]="Drosera Operator API"
    )

    show_orange "📢 Checking and opening required ports:"

    for PORT in 22 31313 31314; do
        DESCRIPTION=${PORT_DESCRIPTIONS[$PORT]}
        if sudo ss -tulpen | awk '{print $5}' | grep -q ":$PORT\$"; then
            show_red   "⚠️  Port $PORT is already in use! ($DESCRIPTION)"
        else
            show_blue  "🔓 Opening port $PORT ($DESCRIPTION)"
            run_commands "sudo ufw allow ${PORT}/tcp"
        fi
    done

    run_commands "sudo ufw allow ssh"  # Redundant but ensures fallback SSH rule
    run_commands "sudo ufw --force enable"

    show_green "✅ Firewall configuration complete"
    show_gray  "💡 Check status: sudo ufw status numbered"
}

install_cli_tools() {
    process_notification "🧰 Installing CLI tools for Drosera Trap..."

    curl -L https://app.drosera.io/install | bash
    curl -L https://foundry.paradigm.xyz | bash
    curl -fsSL https://bun.sh/install | bash
    show_green "✅ CLI toolchain ready"

    show_orange "⚠️ To apply environment changes, run:"
    show_blue   "   source ~/.bashrc"
    show_gray   "💡 Or restart the terminal session"
}

initialize_trap_project() {
    process_notification "📁 Initializing Drosera Trap project..."

    droseraup
    foundryup

    cd
    mkdir /root/my-drosera-trap
    cd /root/my-drosera-trap

    echo
    read -rp "$(show_orange '📧 Enter your Git email: ')" GIT_EMAIL
    while ! [[ "$GIT_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; do
        show_red "❌ Invalid email format"
        read -rp "$(show_orange '📧 Please enter a valid Git email: ')" GIT_EMAIL
    done

    read -rp "$(show_orange '👤 Enter your Git username: ')" GIT_USERNAME
    while [[ -z "$GIT_USERNAME" ]]; do
        show_red "❌ Username cannot be empty"
        read -rp "$(show_orange '👤 Enter your Git username: ')" GIT_USERNAME
    done

    git config --global user.email $GIT_EMAIL
    git config --global user.name $GIT_USERNAME

    show_orange "📦 Cloning template project..."
    run_commands "forge init -t drosera-network/trap-foundry-template"
    sleep 2

    show_green "✅ Project initialized at ~/my-drosera-trap"
}

configure_trap_project() {
    process_notification "⚙️ Configuring trap project..."

    cd /root/my-drosera-trap

    read -rp "$(show_orange '🔑 Enter your Operator wallet (0x...): ')" OPERATOR_WALLET
    while [[ ! "$OPERATOR_WALLET" =~ ^0x[a-fA-F0-9]{40}$ ]]; do
        show_red "❌ Invalid Ethereum address"
        read -rp "$(show_orange '🔑 Please enter a valid 0x address: ')" OPERATOR_WALLET
    done

    if [ -f "drosera.toml" ]; then
        sed -i "s|whitelist = \[.*\]|whitelist = [\"$OPERATOR_WALLET\"]|" drosera.toml
        show_green "✅ Operator wallet set in drosera.toml"
    else
        show_red "❌ drosera.toml not found!"
        return 1
    fi

    echo
    show_orange "🧠 What do you want:"
    show_blue   " [1] Create new (no trap deployed yet)"
    show_blue   " [2] Recover with a trap address"

    read -rp "$(show_gray 'Select option [1/2] ➤ ') " trap_status
    echo

    if [ "$trap_status" = "1" ]; then
        show_green "✅ Marked as CREATE NEW"

    elif [ "$trap_status" = "2" ]; then
        read -rp "$(show_orange '📦 Enter your existing trap address (0x...): ')" TRAP_ADDRESS
        while [[ ! "$TRAP_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; do
            show_red "❌ Invalid address"
            read -rp "$(show_orange '📦 Please enter valid 0x trap address: ')" TRAP_ADDRESS
        done

        sed -i '/^address *=/d' drosera.toml
        echo "address = \"$TRAP_ADDRESS\"" >> drosera.toml
        show_green "✅ Existing trap address added to drosera.toml"

    else
        show_red "⛔️ Invalid selection. Skipping address field update."
    fi

    mkdir -p ~/Drosera-Network
    cd ~/Drosera-Network || exit 1
    touch .env

    echo
    read -rp "$(show_orange '🔐 Enter your ETH private key (starts with 0x): ')" ETH_PRIVATE_KEY

    VPS_IP=$(hostname -I | awk '{print $1}')
    show_orange "🌐 Detected VPS IP: $VPS_IP"

    cat > .env <<EOF
ETH_PRIVATE_KEY=$ETH_PRIVATE_KEY
VPS_IP=$VPS_IP
EOF

    show_green "✅ .env file created at ~/Drosera-Network/.env"
}

deploy_operator() {
    process_notification "🐳 Deploying Drosera Operator via Docker Compose..."

    cd ~/Drosera-Network || exit 1

    # Проверяем наличие .env
    if [ ! -f .env ]; then
        show_red "❌ .env file not found. Please run configure_trap_project first."
        return 1
    fi

    source .env

    # Генерация docker-compose.yaml
    cat > docker-compose.yaml <<EOF
version: '3'
services:
  drosera-operator:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-operator
    network_mode: host
    environment:
      - DRO__DB_FILE_PATH=/data/drosera.db
      - DRO__DROSERA_ADDRESS=0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
      - DRO__LISTEN_ADDRESS=0.0.0.0
      - DRO__DISABLE_DNR_CONFIRMATION=true
      - DRO__ETH__CHAIN_ID=560048
      - DRO__ETH__RPC_URL=https://ethereum-hoodi-rpc.publicnode.com
      - DRO__ETH__BACKUP_RPC_URL=https://ethereum-hoodi-rpc.publicnode.com
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__P2P_PORT=31313
      - DRO__NETWORK__EXTERNAL_P2P_ADDRESS=${VPS_IP}
      - DRO__SERVER__PORT=31314
    volumes:
      - drosera_data:/data
    command: ["node"]
    restart: always

volumes:
  drosera_data:
EOF

    show_green "✅ docker-compose.yaml created"

    run_commands "docker pull ghcr.io/drosera-network/drosera-operator:latest"
    run_commands "docker compose down -v"
    run_commands "docker stop drosera-node || true"
    run_commands "docker rm drosera-node || true"
    run_commands "docker compose up -d"

    show_green "✅ Drosera Operator launched"
    show_orange "📡 Monitoring logs..."
    sleep 1
    docker compose logs -f
}

register_operator() {
    source ~/Drosera-Network/.env

    process_notification "📝 Registering your Operator..."

    run_commands "drosera-operator register \
        --eth-rpc-url https://ethereum-hoodi-rpc.publicnode.com \
        --eth-private-key $ETH_PRIVATE_KEY \
        --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"
}

optin_trap() {
    source ~/Drosera-Network/.env

    echo
    read -rp "$(show_orange '📦 Enter your deployed Trap address (0x...): ')" TRAP_ADDR
    while [[ ! "$TRAP_ADDR" =~ ^0x[a-fA-F0-9]{40}$ ]]; do
        show_red "❌ Invalid address"
        read -rp "$(show_orange '📦 Enter a valid 0x Trap address: ')" TRAP_ADDR
    done

    process_notification "📬 Opting in Trap..."
    run_commands "drosera-operator optin \
        --eth-rpc-url https://ethereum-hoodi-rpc.publicnode.com \
        --eth-private-key $ETH_PRIVATE_KEY \
        --trap-config-address $TRAP_ADDR"
}

restart_operator() {
    process_notification "♻️ Restarting drosera-operator container..."
    run_commands "docker restart drosera-operator"
}

update_operator() {
    process_notification "⬆️ Updating Drosera Operator..."

    run_commands "docker pull ghcr.io/drosera-network/drosera-operator:latest"
    run_commands "docker compose down"
    run_commands "docker compose up -d"

    show_green "✅ Operator updated and restarted"
}

view_operator_logs() {
    process_notification "📜 Viewing Drosera Operator logs..."

    if docker ps --format '{{.Names}}' | grep -q '^drosera-operator$'; then
        show_blue "🖥️ Streaming logs (Ctrl+C to exit)..."
        sleep 1
        docker logs -f drosera-operator
    else
        show_red "❌ drosera-operator container is not running"
        show_gray "💡 Start it first using 'Deploy Operator' or restart via menu"
    fi
}

delete_operator() {
    process_notification "🗑 Deleting Drosera Operator..."

    run_commands "docker compose down -v"
    run_commands "docker rm -f drosera-operator || true"
    run_commands "docker rmi ghcr.io/drosera-network/drosera-operator:latest || true"
    run_commands "rm -rf ~/Drosera-Network"

    show_green "✅ Operator and data removed"
}

operator_menu() {
    while true; do
        clear
        menu_header
        menu_item 1 "📝" "Register Operator"    "Регистрация в сети"
        menu_item 2 "📬" "Opt-in Trap"          "Подключить Trap"
        menu_item 3 "♻️" "Restart Operator"     "Перезапуск"
        menu_item 4 "⬆️" "Update Operator"      "Обновить"
        menu_item 5 "🗑" "Delete Operator"      "Удаление"
        menu_item 6 "📜" "View logs"            "Логи"
        menu_item 7 "↩️" "Back"                 "Назад в главное меню"
        echo; read -rp "$(show_gray 'Select operation ➤ ') " op_option
        echo

        case $op_option in
            1) register_operator ;;
            2) optin_trap ;;
            3) restart_operator ;;
            4) update_operator ;;
            5) delete_operator ;;
            6) view_operator_logs ;;
            7) break ;;
            *) incorrect_option ;;
        esac
    done
}

drosera_main_menu() {
    print_logo
    while true; do
        menu_header
        menu_item 1 "🧱" "Install System"     "Установка зависимостей"
        menu_item 2 "🧰" "Deploy Trap Project"  "Установка контракта"
        menu_item 3 "🐳" "Deploy Operator"    "Установка оператора"
        menu_item 4 "🎛️" "Manage Operator"    "Управление"
        menu_item 5 "🚪" "Exit"               "Выход"
        echo; read -rp "$(show_gray 'Select option ➤ ') " option
        echo

        case $option in
            1)
                install_dependencies && \
                install_docker && \
                configure_firewall && \
                install_cli_tools
                ;;
            2)
                initialize_trap_project && \
                configure_trap_project
                ;;
            3) deploy_operator ;;
            4) operator_menu ;;
            5) exit_script ;;
            *) incorrect_option ;;
        esac
    done
}

drosera_main_menu


