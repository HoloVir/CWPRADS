#!/bin/bash

panelurl=https://$(hostname -f):2087/

dateVar=$(curl $panelurl -vI 2>&1 | grep -oh "expire date: .*" | sed 's/expire date: //');getCurrent=$(TZ='Greenwich' date +"%b %d %T %Y %Z");
untrustErr=$(curl $panelurl 2>&1 | grep -i "not trusted");
if [[ $(date -d "$dateVar" +%s) < $(date -d "$getCurrent" +%s) ]] || [[ ! -z "$untrustErr" ]];
then
  echo "SSL Certificate for $panelurl bad, renewing"
  HOME=/root /scripts/install_acme
  /scripts/generate_hostname_ssl
  HOME=/root /usr/bin/bash /root/.acme.sh/acme.sh --issue --cert-home /root/.acme.sh/cwp_certs -d $(hostname -f) -w /usr/local/apache/autossl_tmp/ --certpath /etc/pki/tls/certs/hostname.cert --keypath /etc/pki/tls/private/hostname.key --fullchainpath /etc/pki/tls/certs/hostname.bundle --keylength 2048 --force --renew-hook /scripts/hostname_ssl_restart_services --log
  systemctl restart cwpsrv
else
  echo "SSL Certificate for $panelurl good, not renewing"
fi
