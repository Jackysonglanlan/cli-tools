#!/usr/bin/env bash

################
#
################

##### global #####



##### private #####

_hurl() {
  hurl --verbose --color $@
}

##### public #####

run() {
  local playbook_file=$1
  _hurl "$playbook_file"
}

test() {
  local playbook_file=$1
  _hurl --test "$playbook_file"
}

$@
