#!/bin/bash

CONFIG_FILE=_config.yml 

jekyll_pid=$(pgrep -f jekyll)
if [ ! -z "$jekyll_pid"]; then
kill -KILL $jekyll_pid
fi

/bin/bash -c "exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling"&

SY=$(uname -r)

if [[ $SY = *"WSL"* ]]; then
  SUM=$(md5sum "$CONFIG_FILE")
  while true; do
    sleep 2
    SUMN=$(md5sum "$CONFIG_FILE")
    if [ "$SUM" != "$SUMN" ]; then
    SUM=$SUMN
    echo "Change detected to $CONFIG_FILE, restarting Jekyll"

    jekyll_pid=$(pgrep -f jekyll)
    kill -KILL $jekyll_pid

    /bin/bash -c "rm -f Gemfile.lock && exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling"&
    fi
  done
else

while true; do

  inotifywait -q -e modify,move,create,delete $CONFIG_FILE

  if [ $? -eq 0 ]; then
 
    echo "Change detected to $CONFIG_FILE, restarting Jekyll"

    jekyll_pid=$(pgrep -f jekyll)
    kill -KILL $jekyll_pid

    /bin/bash -c "rm -f Gemfile.lock && exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling"&

  fi

done

fi