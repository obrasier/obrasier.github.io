#!/bin/bash

LOCAL_CONFIG="_local_development.yml"
# copy the current config
cp _config.yml $LOCAL_CONFIG
# find the line with the remote_theme setting, delete it
sed -i '/remote_theme/d' $LOCAL_CONFIG

# minimal-mistakes-jekyll is the only place where the full theme name is used, replace it
# yes I know this is bad, no, I don't care
sed -i '/minimal-mistakes-jekyll"/c\theme                    : "minimal-mistakes-jekyll"' $LOCAL_CONFIG

# run the server
bundle exec jekyll serve --config $LOCAL_CONFIG
