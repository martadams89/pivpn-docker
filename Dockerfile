FROM debian:stretch-20211011
# debian:stretch-20211011
# ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN XDG_RUNTIME_DIR=/run/user/`id -u`

RUN echo "deb http://deb.debian.org/debian buster-backports main non-free" >> /etc/apt/sources.list
RUN apt-get update --fix-missing && apt-get upgrade -f -y --no-install-recommends
RUN apt-get install -y -f --no-install-recommends systemd sudo curl git systemd  \
    apt-transport-https iproute2 grepcidr openvpn expect whiptail net-tools bsdmainutils 
    sh-completion git tar dnsutils nano procps ca-certificates grep dhcpcd5 iptables-persistent


COPY sh/ /usr/local/bin/
RUN mkdir /etc/pivpn/
RUN sudo bash setupVars

ARG INSTALLER=/etc/pivpn/install.sh
RUN apt update --fix-missing && apt-get upgrade -f -y --no-install-recommends
#RUN mkdir -p -v /usr/local/src/pivpn/
RUN curl -fsSL0 https://install.pivpn.io -o "${INSTALLER}" \
    && sed -i 's/debconf-apt-progress --//g' "${INSTALLER}" \
    && sed -i '/setStaticIPv4 #/d' "${INSTALLER}" \
    && sed -i 's/WIREGUARD_SUPPORT=0/WIREGUARD_SUPPORT=1/g' "${INSTALLER}" \
    && sed -i 's/PIVPN_DEPS+=(linux-headers-amd64 wireguard-dkms)/sleep 1/g' "${INSTALLER}" \
    && sed -i 's/PIVPN_DEPS+=(linux-headers-generic wireguard-dkms)/sleep 1/g' "${INSTALLER}" \
    && sed -i 's/sync/# sync/g' "${INSTALLER}" \
    && chmod +x "${INSTALLER}" \
    && bash "${INSTALLER}" --unattended /etc/pivpn/setupVars.conf --reconfigure

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/pivpn/openvpn/* /etc/openvpn/* /etc/wireguard/* /tmp/* || true

WORKDIR /home/pivpn
COPY run .
RUN chmod +x /home/pivpn/run
CMD ["./run"]    
