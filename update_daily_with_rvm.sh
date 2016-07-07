#!/usr/bin/env bash

#PATH=~/.rvm/bin/rvm:$PATH

RVM_PATH=`~/.rvm/bin/rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

./daily_update.sh
