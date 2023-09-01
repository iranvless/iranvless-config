useradd nginx
if ! command -v nginx ;then
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list
    sudo apt update -y

    apt-get install -y nginx
fi
#  certbot python3-certbot-nginx python3-pip
# pip3 install pip pyopenssl --upgrade

systemctl kill nginx > /dev/null 2>&1
systemctl disable nginx > /dev/null 2>&1
systemctl kill apache2 > /dev/null 2>&1
systemctl disable apache2 > /dev/null 2>&1
# pkill -9 nginx

rm /etc/nginx/conf.d/web.conf
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/conf.d/default.conf
rm /etc/nginx/conf.d/xray-base.conf
rm /etc/nginx/conf.d/speedtest.conf




# sed -i "s/listen 444 ssl;/listen 444 ssl http2;/" web.conf

# ln -sf  $(pwd)/xray-base.conf /etc/nginx/conf.d/xray-base.conf
# mkdir -p /etc/nginx/stream.d/ 
# ln -sf $(pwd)/sni-proxy.conf /etc/nginx/stream.d/sni-proxy.conf
# ln -sf $(pwd)/signal.conf /etc/nginx/stream.d/signal.conf

# certbot certonly  --webroot -w $(pwd)/certbot --register-unsafely-without-email -d $MAIN_DOMAIN --non-interactive --agree-tos  --logs-dir $(pwd)/../log/system/certbot.log
# certbot --nginx --register-unsafely-without-email -d $MAIN_DOMAIN --non-interactive --agree-tos  --https-port 444 --no-redirect --logs-dir $(pwd)/../log/system/certbot.log
# if ! grep -Fxq "stream{include /etc/nginx/stream.d/*.conf;}" /etc/nginx/nginx.conf; then
#   echo "stream{include /etc/nginx/stream.d/*.conf;}">>/etc/nginx/nginx.conf;
# fi

mkdir run
ln -sf $(pwd)/iranvless-nginx.service /etc/systemd/system/iranvless-nginx.service
systemctl enable iranvless-nginx.service
