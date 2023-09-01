systemctl kill iranvless-sniproxy > /dev/null 2>&1
systemctl stop iranvless-sniproxy > /dev/null 2>&1
systemctl disable iranvless-sniproxy > /dev/null 2>&1

systemctl kill haproxy > /dev/null 2>&1
systemctl stop haproxy > /dev/null 2>&1
systemctl disable haproxy > /dev/null 2>&1
# pkill -9 haproxy
pkill -9 sniproxy > /dev/null 2>&1
if ! command -v haproxy ;then
    add-apt-repository ppa:vbernat/haproxy-2.8 -y
    apt update
    apt install haproxy=2.8.\* -y
fi
ln -sf $(pwd)/iranvless-haproxy.service /etc/systemd/system/iranvless-haproxy.service
systemctl enable iranvless-haproxy.service

rm haproxy.cfg*
