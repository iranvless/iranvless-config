#!/bin/bash
#ln -sf $(pwd)/iranvless-warp.service /etc/systemd/system/iranvless-warp.service
systemctl disable iranvless-warp.service

# if [[ $warp_mode == 'disabled' ]];then
#   bash uninstall.sh
# else

if ! [ -f "wgcf-account.toml" ];then
    mv wgcf-account.toml wgcf-account.toml.backup
    wgcf register --accept-tos -m iranvless -n $(hostname)
fi

#api.zeroteam.top/warp?format=wgcf for change warp
export WGCF_LICENSE_KEY=$WARP_PLUS_CODE
wgcf update
if [ $? != 0 ];then
  mv wgcf-account.toml wgcf-account.toml.backup
  wgcf update
  if [ $? != 0 ];then
    mv wgcf-account.toml wgcf-account.toml.backup
    export WGCF_LICENSE_KEY=
    wgcf update
  fi 
fi 



wgcf generate
sed -i 's/\[Peer\]/Table = off\n\[Peer\]/g'  wgcf-profile.conf

curl --connect-timeout 1 -s http://ipv6.google.com 2>&1 >/dev/null

#if [ $? != 0 ]; then
ipv6_exists=$(ip addr | grep -o 'inet6')
if [ ! -n "$ipv6_exists" ]; then
  sed -i '/Address = [0-9a-fA-F:]\{4,\}/s/^/# /' wgcf-profile.conf
fi
sed -i '/DNS = 1.1.1.1/s/^/# /' wgcf-profile.conf
mkdir -p /etc/wireguard/
ln -sf $(pwd)/wgcf-profile.conf /etc/wireguard/warp.conf  
systemctl enable --now wg-quick@warp

systemctl restart wg-quick@warp
