#!/bin/sh
source ~/.zshrc
chruby ruby-2.6.6
cd /Users/jonkob/Code/bt-check/
bundle exec rake scan:run