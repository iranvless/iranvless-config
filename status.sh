#!/bin/bash
function main(){
# XRAY_NEW_CONFIG_ERROR=0
# xray run -test -confdir xray/configs > /dev/null 2>&1
# XRAY_NEW_CONFIG_ERROR=$?


# SINGBOX_NEW_CONFIG_ERROR=0
# xray run -test -confdir xray/configs > /dev/null 2>&1
# SINGBOX_NEW_CONFIG_ERROR=$?


# systemctl status --no-pager iranvless-nginx iranvless-xray iranvless-singbox iranvless-haproxy|cat

bash other/warp/status.sh

if [ -f "other/warp/xray_warp_conf.json" ];then
	# (cd other/warp&& wgcf update)
	# echo "Your IP for custom WARP:"
	# curl -s -x socks://127.0.0.1:1234 --connect-timeout 4 www.ipinfo.io

	echo "Your Global IP"
	curl -s -x socks://127.0.0.1:1234 --connect-timeout 1 http://ip-api.com?fields=message,country,countryCode,city,isp,org,as,query
fi


for s in other/**/*.service **/*.service wg-quick@warp;do
	s=${s##*/}
	s=${s%%.*}
	if systemctl is-enabled $s >/dev/null 2>&1 ; then
		printf "%-30s %-30s \n" $s $(systemctl is-active $s)
	fi
done


# echo "ignoring xray test"


# if [ "$XRAY_NEW_CONFIG_ERROR" != "0" ];then
# 	xray run -test -confdir xray/configs 
# 	echo "There is a big error in xray configuration."
# fi

# if [ "$SINGBOX_NEW_CONFIG_ERROR" != "0" ];then
# 	sing-box check -C singbox/configs 
# 	echo "There is a big error in xray configuration."
# fi
}
mkdir -p log/system/
main |& tee log/system/status.log
