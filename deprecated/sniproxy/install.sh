apt install sniproxy -y

systemctl disable sniproxy
kill -9 `lsof -t -i:443`
kill -9 `lsof -t -i:80`
ln -sf $(pwd)/iranvless-sniproxy.service /etc/systemd/system/iranvless-sniproxy.service
systemctl enable iranvless-sniproxy.service
