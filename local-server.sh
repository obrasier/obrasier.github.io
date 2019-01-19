#!/bin/bash

# copy the current config
cp _config.yml _local_development.yml

# find the line with the remote_theme setting, delete it
sed -i '/remote_theme/d' _local_development.yml

# minimal-mistakes-jekyll is the only place where the full theme name is used, replace it
# yes I know this is bad, no, I don't care
sed -i '/minimal-mistakes-jekyll"/c\theme                    : "minimal-mistakes-jekyll"' _local_development.yml

# run the server
bundle exec jekyll serve --config _local_development.yml
