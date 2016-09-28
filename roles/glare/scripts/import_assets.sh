
set -e
PATH=$PATH:/usr/local/bin
rm /tmp/glare.sqlite | true
sudo -u ubuntu glare-db-manage --config-file /etc/glare/glare.conf upgrade
sudo -u ubuntu glare-api --config-file /etc/glare/glare.conf &
sleep 5
app-catalog-import-assets
pkill glare-api
