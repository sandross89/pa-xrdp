#!/bin/bash
#
echo "USANDO PACOTES DE KERNEL HWE"
#
HWE=""
#
if [ "$(id -u)" -ne 0 ]; then
    echo 'ESTE SCRIPT DEVE SER EXECUTADO COM PRIVILÉGIOS DE ROOT' >&2
    exit 1
fi
echo "ATUALIZANDO O SISTEMA"
apt update -y
apt upgrade -y
if [ -f /var/run/reboot-required ]; then
    echo "UMA REINICIALIZAÇÃO É NECESSÁRIO PARA PROSSEGUIR COM A INSTALAÇÃO" >&2
    echo "REINICIE E EXECUTE NOVAMENTE ESTE SCRIPT PARA CONCLUIR A INSTALAÇÃO" >&2
    exit 1
fi
#
clear
echo "INSTALANDO PACOTES"
apt install -y linux-tools-virtual${HWE} linux-cloud-tools-virtual${HWE} xrdp
#
clear
echo "PARANDO XRDP"
systemctl stop xrdp
systemctl stop xrdp-sesman
#
clear
echo "CONFIGURANDO OS ARQUIVOS INI XRDP INSTALADOS"
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini
#
clear
echo "ADICIONAANDO SCRIPT PARA CONFIGURAR A SESSÃO DO UBUNTU CORRETAMENTE"
if [ ! -e /etc/xrdp/startubuntu.sh ]; then
cat >> /etc/xrdp/startubuntu.sh << EOF
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
exec /etc/xrdp/startwm.sh
EOF
chmod a+x /etc/xrdp/startubuntu.sh
fi
sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini
sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
#
clear
echo "ADICIONANDO LISTA NEGRA DO MÓDULO VMW"
if [ ! -e /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf ]; then
  echo "blacklist vmw_vsock_vmci_transport" > /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf
fi
#
clear
echo "CERTIFICANDO QUE HV_SOCK SEJA CARREGADO"
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
  echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi
#
clear
echo "CONFIGURANDO A SESSÃO XRDP DA POLÍTICA"
cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
#
clear
echo "RECONFIGURANDO OS SERVIÇOS"
systemctl daemon-reload
systemctl start xrdp
#
clear
echo "FIM"
echo "DESLIGUE A VM"
#
