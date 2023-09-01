
systemctl kill iranvless_monitoring_web.service
mkdir -p ../log/stats/
ln -sf $(pwd)/iranvless_monitoring_web.service /etc/systemd/system/iranvless_monitoring_web.service
echo "0,15,30,45 * * * * root $(pwd)/cron.sh" > /etc/cron.d/iranvless-monitoring
service cron reload
systemctl enable iranvless_monitoring_web.service
systemctl restart iranvless_monitoring_web.service
