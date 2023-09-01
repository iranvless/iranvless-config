


if ! command -v redis-server ;then
    sudo add-apt-repository -y universe
    # sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
    sudo apt install -y redis-server
fi
systemctl disable --now redis-server
ln -sf $(pwd)/iranvless-redis.service /etc/systemd/system/iranvless-redis.service
touch /opt/iranvless-config/log/system/redis-server.log
chown redis:redis /opt/iranvless-config/log/system/redis-server.log
chown redis:redis /opt/iranvless-config/other/redis
systemctl enable iranvless-redis
systemctl start iranvless-redis
