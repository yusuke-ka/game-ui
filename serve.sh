#!/bin/sh
BASE_VUE_DIR=/home/ec2-user/environment/game/game-ui
BASE_VUE_CONFIG=$BASE_VUE_DIR/vue.config.js
SWITCHED_VUE_CONFIG=$BASE_VUE_DIR/vue.config.c9.js

PUBLIC_HOST=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
sed -E "s/\/\* _REPLACE_POINT_ \*\//public : '$PUBLIC_HOST:8080',/" $BASE_VUE_CONFIG > $SWITCHED_VUE_CONFIG
export VUE_CLI_SERVICE_CONFIG_PATH=$SWITCHED_VUE_CONFIG

yarn serve
rm $SWITCHED_VUE_CONFIG