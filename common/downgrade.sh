cd /opt/iranvless-config/iranvless-panel
python3 -m iranvlesspanel downgrade
cd ..
pip install iranvlesspanel==7.2.0
curl -L -o iranvless-config.zip   https://github.com/iranvless/iranvless-config/releases/iranvless/v10.1.3/iranvless-config.zip  
unzip -o iranvless-config.zip
rm iranvless-config.zip
bash install.sh
