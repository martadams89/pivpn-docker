FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update --fix-missing && apt upgrade -f --no-install-recommends

RUN apt install -y -f --no-install-recommends sudo systemd nano procps curl ca-certificates dhcpcd5 \
    tar grep dnsutils whiptail net-tools bsdmainutils bash-completion git tar grep dnsutils whiptail \
    net-tools bsdmainutils bash-completion apt-transport-https dhcpcd5 iptables-persistent dhcpcd5 \
    iptables-persistent apt-transport-https unattended-upgrades

COPY setupVars.conf /etc/pivpn/

ARG pivpnFilesDir=/etc/pivpn
ARG PIVPN_TEST=false
ARG PLAT=Debian
ARG useUpdateVars=true
ARG SUDO=
ARG SUDOE=
ARG INSTALLER=/etc/pivpn/install.sh

RUN curl -fsSL0 https://install.pivpn.io -o "${INSTALLER}" \
    && sed -i 's/debconf-apt-progress --//g' "${INSTALLER}" \
    && sed -i '/systemctl start/d' "${INSTALLER}" \
    && sed -i '/setStaticIPv4 #/d' "${INSTALLER}" \
    && chmod +x "${INSTALLER}" \
    && "${INSTALLER}" --unattended /etc/pivpn/setupVars.conf --reconfigure

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*

WORKDIR /home/pivpn
COPY run .
RUN chmod +x /home/pivpn/run
CMD ["./run"]    
