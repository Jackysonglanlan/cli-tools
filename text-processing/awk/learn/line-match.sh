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

FRUITS=$(cat <<EOF
fruit   qty
apple   42
banana  31
fig     90
guava   6
EOF
)

POEM=$(cat <<EOF
Roses are red,
Violets are blue,
Sugar is sweet,
And so are you.
EOF
)

# 多行匹配
multiline_match() {
  # 注意 {p = $0} 前面并没有匹配条件，所以每一行都要执行，所以这句的含义就是保存上一行内容到 p
  #   P.S: 其实这一块写在前面就很清晰，不知道是不是 awk 的 idiomatic，很多例子都是写在后面的
  #
  # 连起来就是: 匹配第一行包含 are，第二行包含 is 的行，然后打印出这两行
  # printf '%s' "$POEM" | awk 'p ~ /are/ && /is/ {print p ORS $0} {p = $0}'

  # 匹配这样的 3 行: 第一行包含 red，第二行包含 blue，第 3 行包含 is，打印第 1 行
  printf '%s' "$POEM" | awk 'p2~/red/ && p1~/blue/ && /is/{print p2} {p2=p1; p1=$0}'

  # 如果匹配的行数量太多，把行全部存到数组，然后引用，会方便些(代价就是多占内存)
}
# multiline_match

range_match() {
  local data='''
  foo
  BEGIN
  1234
  6789
  END
  bar
  BEGIN
  a
  b
  c
  END
  baz
  '''

  # how "n && n--" works:
  #
  # need to note that right hand side of && is processed only if left hand side is true
  # so if initially n=2, then we get
  # 2 && 2; n=1 - evaluates to true
  # 1 && 1; n=0 - evaluates to true
  # 0 && - evaluates to false ... no decrementing n and hence will be false until n is re-assigned non-zero value

  # 匹配从 BEGIN 开始的 2 行(包含 BEGIN)
  # printf '%s' "$data" | awk '/BEGIN/{n=2} n && n--'

  # 打印匹配 BEGIN 后的第 3 行
  # printf '%s' "$data" | awk 'n && !--n; /BEGIN/{n=3}'

  # 打印匹配 END 前的第 2 行
  # printf '%s' "$data" | awk '{p2=p1; p1=$0} /END/{print p2}'

  # 如果隔得太远，可以用数组，比如下面是打印匹配 END 前的第 4 行
  printf '%s' "$data" | awk '{a[NR] = $0} /END/{print a[NR-4]}'
}
range_match

regex_match(){
  # printf '%s' "$POEM" | awk '/are/'

  # printf '%s' "$POEM" | awk '! /are/'

  # printf '%s' "$POEM" | awk '/are/ && !/so/'

  # print last field of all lines containing 'are'
  # printf '%s' "$POEM" | awk '/are/ {print $NF}'

  # shell like regex match
  # printf '%s' "$POEM" | awk '$0 !~ "are"'
  # printf '%s' "$FRUITS" | awk '$0 ~ "^[ab]"'

  # if first field contains 'a'
  printf '%s' "$FRUITS" | awk '$1 ~ /a/'

  # if first field does NOT contain 'a'
  printf '%s' "$FRUITS" | awk '$1 !~ /a/'

  # if first field contains 'a' and qty > 20
  printf '%s' "$FRUITS" | awk '$1 ~ /a/ && $2 > 20'

}
# regex_match

fixed_string_matching(){
  local EQNS='''
  a=b,a-b=c,c*d
  a+b,pi=3.14,5e12
  i*(t+9-g)/8,4-a+b
  '''

  ### 使用 index 做字符串精确匹配

  # 包含 a+b 的行
  printf '%s' "$EQNS" | awk 'index($0, "a+b")'
  # 注意如果是正则，需要把 + 转义
  printf '%s' "$EQNS" | awk '/a\+b/'

  # 如果是下面这种，用 index 就方便了
  printf '%s' "$EQNS" | awk 'index($0, "i*(t+9-g)")'

  # index 返回匹配的字符位置
  printf '%s' "$EQNS" | awk 'index($0, "a+b") == 1'
}
# fixed_string_matching

case_match(){
  printf '%s' "$POEM" | awk 'tolower($0) ~ /rose/'

  printf '%s' "$POEM" | awk -v IGNORECASE=1 '/rose/'
}
# case_match

early_return(){
  # awk 默认每一行都要处理，但如果数据量太大，处理完以后可以使用 exit 提前退出

  # 处理完 234 以后就退出
  seq 14323 14563435 | awk 'NR == 234 {print; exit}'

  # 没有 exit，所有的行都要进入 awk，浪费
  seq 14323 14563435 | awk 'NR == 234 {print;}'
}
# early_return

