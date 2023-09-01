systemctl kill iranvless_monitoring_web.service
systemctl disable iranvless_monitoring_web.service
rm -rf /etc/cron.d/iranvless-monitoring
service cron reload
