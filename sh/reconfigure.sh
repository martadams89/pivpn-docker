#!/bin/bash

echo "Writung setupVars.conf"
bash /etc/pivpn/setupVars.sh

echo "Reconfigure PIVPN"
INSTALLER=/etc/pivpn/install.sh
curl -fsSL0 https://install.pivpn.io -o "${INSTALLER}" \
    && sed -i '/setStaticIPv4 #/d' "${INSTALLER}" \
    && chmod +x "${INSTALLER}" \
    && "${INSTALLER}" --unattended /etc/pivpn/setupVars.conf --reconfigure

pivpn -a nopass -n "${CLIENT_NAME}" -d 1080 || true
