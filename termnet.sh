#!/bin/bash

install_dependencies() {
    # Instalar dependencias necesarias
    pkg install -y curl wget tar proot

    # Descargar el script de instalación de Docker
    wget https://get.docker.com -O install-docker.sh

    # Ejecutar el script de instalación de Docker
    sh install-docker.sh

    # Iniciar el servicio de Docker
    dockerd &>/dev/null &

    sleep 5
    clear
    echo "$(tput setaf 2)¡Docker se ha instalado correctamente!$(tput sgr0)"
}

configure_openvpn() {
    # Descargar el archivo de configuración de OpenVPN
    read -rp "Ingrese la URL del archivo de configuración de OpenVPN: " config_url
    wget -O openvpn.ovpn "$config_url"

    # Obtener el nombre de usuario y contraseña de OpenVPN
    read -rp "Ingrese el nombre de usuario de OpenVPN: " vpn_username
    read -rsp "Ingrese la contraseña de OpenVPN: " vpn_password
    echo

    # Agregar las credenciales de OpenVPN al archivo de configuración
    echo "auth-user-pass" >> openvpn.ovpn
    echo "$vpn_username" >> openvpn.ovpn
    echo "$vpn_password" >> openvpn.ovpn

    # Mover el archivo de configuración a la ubicación correcta
    mkdir -p $HOME/.termux/openvpn
    mv openvpn.ovpn $HOME/.termux/openvpn/client.conf

    # Iniciar el servicio de OpenVPN
    termux-vpn start

    sleep 5
    clear
    echo "$(tput setaf 2)¡OpenVPN se ha configurado correctamente!$(tput sgr0)"
}

ipcheck() {
    # Obtener la dirección IP local
    local_ip=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    # Obtener las direcciones IP públicas
    public_ipv4=$(curl -s https://api.ipify.org)

    # Mostrar las direcciones IP
    echo "Información de IP:"
    echo "------------------------------------"
    echo "Dirección IP local: $local_ip"
    echo "Dirección IPv4 pública: $public_ipv4"
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

    if [ -f /data/data/com.termux/files/usr/lib/os-release ]; then
        cat /data/data/com.termux/files/usr/lib/os-release
        echo ""
    fi

    echo "Información de la memoria:"
    echo "------------------------------------"

    free -m
    echo ""
}

configure_vpn() {
    clear
    echo "Configuración del VPN:"
    echo "------------------------------------"
    read -rp "Ingrese la URL del archivo de configuración de OpenVPN: " config_url
    read -rp "Ingrese el nombre de usuario de OpenVPN: " vpn_username
    read -rsp "Ingrese la contraseña de OpenVPN: " vpn_password
    echo
    echo

    # Configurar el archivo de configuración de OpenVPN
    echo "auth-user-pass" > openvpn.ovpn
    echo "$vpn_username" >> openvpn.ovpn
    echo "$vpn_password" >> openvpn.ovpn

    # Mover el archivo de configuración a la ubicación correcta
    mkdir -p $HOME/.termux/openvpn
    mv openvpn.ovpn $HOME/.termux/openvpn/client.conf

    # Reiniciar el servicio de OpenVPN
    termux-vpn restart

    sleep 5
    clear
    echo "$(tput setaf 2)¡El VPN se ha configurado correctamente!$(tput sgr0)"
}

servermenu() {
    clear
    sysinfo
    ipcheck

    PS3="Seleccione una opción: "

    options=("Instalar dependencias" "Configurar OpenVPN" "Volver al menú principal")

    select opt in "${options[@]}"; do
        case $opt in
            "Instalar dependencias")
                echo "Instalar dependencias"
                install_dependencies
                ;;
            "Configurar OpenVPN")
                echo "Configurar OpenVPN"
                configure_openvpn
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
        echo "1. Verificar IP"
        echo "2. Información del sistema"
        echo "3. Configurar VPN"
        echo "4. Menú del servidor"
        echo "5. Salir"
        read -rp "Seleccione una opción: " choice

        case $choice in
            1)
                echo "Verificar IP"
                ipcheck
                sleep 3
                ;;
            2)
                echo "Información del sistema"
                sysinfo
                sleep 5
                ;;
            3)
                echo "Configurar VPN"
                configure_vpn
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
