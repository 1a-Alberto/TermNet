#!/bin/bash

dockercheck() {
    # Verificar si Docker ya está instalado
    if ! command -v docker &>/dev/null; then
        echo "$(tput setaf 2)Docker no está instalado en este sistema. Instalando Docker...$(tput sgr0)"

        # Instalar Docker utilizando el script oficial de instalación de Docker
        curl -sSL https://get.docker.com | sh

        # Iniciar el servicio de Docker
        systemctl start docker.service

        sleep 5
        clear
        echo "$(tput setaf 2)¡Docker se ha instalado correctamente!$(tput sgr0)"
    else
        echo "$(tput setaf 2)Docker ya está instalado en este sistema.$(tput sgr0)"
    fi

    sleep 5
    clear
}

ipcheck() {
    # Obtener la dirección IP local
    local_ip=$(hostname -I | awk '{print $1}')

    # Obtener las direcciones IP públicas
    public_ipv4=$(curl -s https://api.ipify.org)
    public_ipv6=$(curl -6s https://api6.ipify.org)

    # Obtener la dirección IPv6
    ipv6=$(ip -6 addr show dev eth0 | awk '/inet6/ {print $2}')

    # Verificar si se asignó la dirección IPv6
    if [ -z "$ipv6" ]; then
        ipv6="$(tput setaf 2)No asignada$(tput sgr0)" # Establecer el texto en rojo si no está asignada
    fi

    # Mostrar las direcciones IP
    echo "Información de IP:"
    echo "------------------------------------"
    echo "Dirección IP local: $local_ip"
    echo "Dirección IPv4 pública: $public_ipv4"
    echo "Dirección IPv6 pública: $public_ipv6"
    echo "Dirección IPv6: $ipv6"
    echo ""
}

sysinfo() {
    echo "Información del sistema:"
    echo "------------------------------------"

    echo "Nombre del kernel: $(uname -s)"
    echo "Versión del kernel: $(uname -r)"
    echo "Arquitectura de la máquina: $(uname -m)"
    echo ""

    echo "Información del sistema operativo:"
    echo "------------------------------------"

    if [ -f /etc/os-release ]; then
        cat /etc/os-release
        echo ""
    fi

    echo "Información de la memoria:"
    echo "------------------------------------"

    free -m
    echo ""
}

servermenu() {
    clear
    sysinfo
    ipcheck

    PS3="Seleccione una opción: "

    options=("Ejecutar Ubuntu-Optimizer" "Instalar Docker" "Instalar CFwarp" "Volver al menú principal")

    select opt in "${options[@]}"; do
        case $opt in
            "Ejecutar Ubuntu-Optimizer")
                echo "Ejecutar Ubuntu-Optimizer"
                bash <(curl -s https://raw.githubusercontent.com/samsesh/Ubuntu-Optimizer/main/ubuntu-optimizer.sh)
                ;;
            "Instalar Docker")
                echo "Instalar Docker"
                dockercheck
                ;;
            "Instalar CFwarp")
                # Descargar y ejecutar el script CFwarp.sh
                wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && chmod +x CFwarp.sh && ./CFwarp.sh
                ;;
            "Volver al menú principal")
                echo "Volver al menú principal"
                break
                ;;
            *) echo "Opción inválida. Por favor, seleccione otra opción." ;;
        esac
    done
}

mainmenu() {
    while true; do
        clear
        echo "Menú principal:"
        echo "------------------------------------"
        echo "1. Verificar Docker"
        echo "2. Verificar IP"
        echo "3. Información del sistema"
        echo "4. Menú del servidor"
        echo "5. Salir"
        read -rp "Seleccione una opción: " choice

        case $choice in
            1)
                echo "Verificar Docker"
                dockercheck
                sleep 3
                ;;
            2)
                echo "Verificar IP"
                ipcheck
                sleep 3
                ;;
            3)
                echo "Información del sistema"
                sysinfo
                sleep 5
                ;;
            4)
                echo "Menú del servidor"
                servermenu
                ;;
            5)
                echo "Salir"
                exit
                ;;
            *)
                echo "Opción inválida. Por favor, seleccione otra opción."
                sleep 3
                ;;
        esac
    done
}

mainmenu
