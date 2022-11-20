
HEX_TELEGRAM_DOMAIN=$(echo -n "$TELEGRAM_FAKE_TLS_DOMAIN"| xxd -ps | tr -d '\n')
CLOUD_PROVIDER=${CLOUD_PROVIDER:-$ROOT_DOMAIN}
GUID_SECRET="${USER_SECRET:0:8}-${USER_SECRET:8:4}-${USER_SECRET:12:4}-${USER_SECRET:16:4}-${USER_SECRET:20:12}"

IP=$(curl -Lso- https://api.ipify.org);

for template_file in $(find . -name "*.template"); do
    out_file=${template_file/.template/}
    cp $template_file $out_file

    sed -i "s|defaultusersecret|$USER_SECRET|g" $template_file 
    sed -i "s|defaultuserguidsecret|$GUID_SECRET|g" $template_file 
    sed -i "s|defaultcloudprovider|$CLOUD_PROVIDER|g" $template_file 
    sed -i "s|defaultserverip|$IP|g" $template_file 
    sed -i "s|defaultserverhost|$ROOT_DOMAIN|g" $template_file 
    sed -i "s|telegramadtag|$TELEGRAM_AD_TAG|g" $template_file 
    sed -i "s|telegramtlsdomain|$TELEGRAM_FAKE_TLS_DOMAIN|g" $template_file 
    sed -i "s|sstlsdomain|$SS_FAKE_TLS_DOMAIN|g" $template_file 
    sed -i "s|hextelegramdomain|$HEX_TELEGRAM_DOMAIN|g" $template_file 

    sed "s|GITHUB_REPOSITORY|$GITHUB_REPOSITORY|g" $template_file 
    sed "s|GITHUB_USER|$GITHUB_USER|g" $template_file 
    sed "s|GITHUB_BRANCH|$GITHUB_BRANCH_OR_TAG|g" $template_file 
    
    

done
