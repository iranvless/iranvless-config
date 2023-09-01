systemctl kill iranvless-admin.service >/dev/null 2>&1
systemctl disable iranvless-admin.service >/dev/null 2>&1
#userdel -f iranvless-panel 2>&1
useradd -m iranvless-panel -s /bin/bash >/dev/null 2>&1
chown -R iranvless-panel:iranvless-panel /home/iranvless-panel/ >/dev/null 2>&1
su iranvless-panel -c localectl set-locale LANG=C.UTF-8 >/dev/null 2>&1
su iranvless-panel -c update-locale LANG=C.UTF-8 >/dev/null 2>&1

chown -R iranvless-panel:iranvless-panel . >/dev/null 2>&1
# apt install -y python3-dev
for req in pip3 uwsgi python3 iranvlesspanel lastversion jq sqlite3mysql; do
    which $req >/dev/null 2>&1
    if [[ "$?" != 0 ]]; then
        apt --fix-broken install -y
        apt update
        apt install -y python3-pip jq python3-dev
        pip3 install pip
        pip3 install -U iranvlesspanel lastversion uwsgi "requests<=2.29.0" sqlite3-to-mysql
        break
    fi
done
(cd ../other/redis/ && bash install.sh)
(cd ../other/mysql/ && bash install.sh)

sed -i '/SQLALCHEMY_DATABASE_URI/d' app.cfg
MYSQL_PASS=$(cat ../other/mysql/mysql_pass)
echo "SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://iranvlesspanel:$MYSQL_PASS@127.0.0.1/iranvlesspanel'" >>app.cfg

# if [ -f iranvlesspanel.db ]; then
#     sqlite3mysql -f iranvlesspanel.db -d iranvlesspanel -u iranvlesspanel -h 127.0.0.1 --mysql-password $MYSQL_PASS
#     mv iranvlesspanel.db hiranvlesspanel.db.old
# fi

# ln -sf $(which gunicorn) /usr/bin/gunicorn

#pip3 --disable-pip-version-check install -q -U iranvlesspanel
# pip uninstall -y hiddifypanel
# pip --disable-pip-version-check install -q -U git+https://github.com/iranvless/iranvlessPanel

# ln -sf $(which gunicorn) /usr/bin/gunicorn
ln -sf $(which uwsgi) /usr/local/bin/uwsgi >/dev/null 2>&1
# iranvlesspanel init-db
ln -sf $(pwd)/iranvless-panel.service /etc/systemd/system/iranvless-panel.service
systemctl enable iranvless-panel.service
if [ -f "../config.env" ]; then
    su iranvless-panel -c "iranvlesspanel import-config -c $(pwd)/../config.env"
    if [ "$?" == 0 ]; then
        rm -f config.env
        # echo "temporary disable removing config.env"
    fi
fi
systemctl daemon-reload >/dev/null 2>&1
echo "*/1 * * * * root $(pwd)/update_usage.sh" >/etc/cron.d/iranvless_usage_update
service cron reload >/dev/null 2>&1

systemctl start iranvless-panel.service
# systemctl status iranvless-panel.service --no-pager > /dev/null 2>&1

echo "0 */6 * * * iranvless-panel $(pwd)/backup.sh" >/etc/cron.d/iranvless_auto_backup
service cron reload

##### download videos

if [[ ! -e "GeoLite2-ASN.mmdb" || $(find "GeoLite2-ASN.mmdb" -mtime +1) ]]; then
    curl --connect-timeout 10 -L -o GeoLite2-ASN.mmdb1 https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb && mv GeoLite2-ASN.mmdb1 GeoLite2-ASN.mmdb
fi
if [[ ! -e "GeoLite2-Country.mmdb" || $(find "GeoLite2-Country.mmdb" -mtime +1) ]]; then
    curl --connect-timeout 10 -L -o GeoLite2-Country.mmdb1 https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb && mv GeoLite2-Country.mmdb1 GeoLite2-Country.mmdb
fi

bash download_yt.sh &
