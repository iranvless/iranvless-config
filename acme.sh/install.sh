sudo apt-get install -y socat
sudo apt-get remove -y certbot
rm -rf /opt/iranvless/

mkdir -p /opt/iranvless-config/acme.sh/lib/
curl -L https://get.acme.sh| sh -s -- home /opt/iranvless-config/acme.sh/lib \
    --config-home /opt/iranvless-config/acme.sh/lib/data \
    --cert-home  /opt/iranvless-config/acme.sh/lib/certs

sed -i 's|_sleep_overload_retry_sec=$_retryafter|_sleep_overload_retry_sec=$_retryafter; if [[ "$_retryafter" > 20 ]];then return 10; fi|g' lib/acme.sh
./lib/acme.sh --register-account -m my@example.com
mkdir -p ../ssl/
