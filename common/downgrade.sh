cd /opt/hiddify-config/hiddify-panel
python3 -m hiddifypanel downgrade
cd ..
pip install iranvlesspanel==7.2.0
curl -L -o hiddify-config.zip   https://github.com/iranvless/iranvless-config/releases/iranvless/v10.1.3/iranvless-config.zip  
unzip -o hiddify-config.zip
rm hiddify-config.zip
bash install.sh
