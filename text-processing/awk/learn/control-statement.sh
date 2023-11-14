#!/usr/bin/env bash

################
#
################

# WARNING: - 是打开，+ 是关闭
shopt -s expand_aliases # alias 在脚本中生效
set -euo pipefail       # e: 有错误及时退出 u: 使用未设置的变量时报警 o pipefail: pipeline 中出错时退出
# set +o posix          # 关闭 posix 的兼容检查，以便使用不兼容 posix 的语法，比如 <() 和 >()
# set -x                # 打印出所有实际执行的命令和参数
# set -f                # 禁止扩展 '*' 号(要恢复使用 +f)
trap "echo 'error: Script failed: see failed command above'" ERR

NUMBERS=$(cat <<EOF
42
-2
10101
-3.14
-75
EOF
)

# awk 会自动转换 str 和 number，也可以强制转换，类似 js 的语法用 '+'
str_to_number() {
  # 自动转换
  echo "$NUMBERS" | awk '{sum += $1} END{print sum}'

  # 强制转换，空字符串(没有赋值)会变成 0
  printf '' | awk '{sum += $1} END{print +sum}'
}
str_to_number

# 三元操作符
ternary() {
  # 正负号互换
  printf "$NUMBERS" | awk '{$0 ~ /^-/ ? sub(/^-/,"") : sub(/^/,"-")} 1'
}
# ternary

#
for_loop() {
  local s='scat:cat:no cat:abdicate:cater'
  echo "$s" | awk -F: -v OFS=: '{ for(i = 1; i <= NF; i++) if($i == "cat") $i="CAT" } 1'
}
# for_loop

while_loop() {
  awk 'BEGIN{ i=2; while(i < 11){ print i; i+=2 } }'

  # 利用 sub 的返回值，递归替换
  echo 'titillate' | awk '{ while( gsub(/til/, "") ) print }'
}
# while_loop

