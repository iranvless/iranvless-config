#!/bin/bash

cd $( dirname -- "$0"; )
function main(){
    echo "trying to update usage"
    pgrep -f 'update-usage' || su iranvless-panel -c "python3 -m iranvlesspanel update-usage"
    rm ../log/update_usage.lock
}


if [[ -f ../log/update_usage.lock && $(( $(date +%s) - $(cat ../log/update_usage.lock) )) -lt 300 ]]; then
    echo "Another usage update is running.... Please wait until it finishes or wait 5 minutes or execute 'rm -f ../log/update_usage.lock'"
    exit 1
fi

echo "$(date +%s)" > ../log/update_usage.lock
main |& tee -a ../log/system/update_usage.log
