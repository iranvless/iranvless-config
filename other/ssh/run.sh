

sed -i "s/:2222/:$ssh_server_port/g" .env
ln -sf $(pwd)/iranvless-ssh-liberty-bridge.service /etc/systemd/system/iranvless-ssh-liberty-bridge.service
systemctl enable iranvless-ssh-liberty-bridge
systemctl restart iranvless-ssh-liberty-bridge
