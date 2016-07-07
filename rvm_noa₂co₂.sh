#!/usr/bin/env bash

RVM_PATH=`~/.rvm/bin/rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

ruby ./noa₂co₂.rb
