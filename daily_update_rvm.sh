#!/usr/bin/env bash

RVM_PATH=`rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

./daily_update.sh
