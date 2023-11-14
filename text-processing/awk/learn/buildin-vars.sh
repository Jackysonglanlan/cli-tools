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

use_default_fs_ofs() {
  # 当需要还原分隔符为空格(默认)时，awk 的 idiomatic way 是使用 $1 = $1

  echo 'foo:123:bar:789' | awk -F: -v OFS='-' '{$1 = $1; print $0}'

  echo 'Sample123string54with908numbers' | awk -F'[0-9]+' '{$1 = $1; print $0}'
}
use_default_fs_ofs

# field separator
fs_ofs() {
  # 可以动态修改 ORS 值
  seq 9 | awk '{ORS = (NR % 3) ? "-" : "\n"} 1'
}
# fs_ofs

# 如果把连续的空行作为 RS，就可以触发"段落模式"，即把每个段落作为一个 record 来处理，而不是每一行
paragraph_mode() {
  local data='''
  Hello World

  Good day
  How are you


  Just do-it
  Believe it

  Today is sunny
  Not a bit funny
  No doubt you like it too

  Much ado about nothing
  He he he
  '''

  # RS 为空，代表连续的空行作为 record 分隔符，这样由空行分开的段，就成为了一个 field，下面打印所有包含 it 的段
  # printf "$data" | awk -v RS= -v ORS='\n\n' '/it/'

  # FS 为 \n，每一行是一个 field，所以 $1 就是一行，下面 "所有总共有 3 行的段，打印每段的第 2 行"
  # printf "$data" | awk -F'\n' -v RS= -v ORS='\n\n' 'NF==3 {print $2}' # 注意最后一段的最后一行是个空行，它也是 3 行

  # $1 = $1，即用默认的 FS OFS 格式化每个 record，然后写回 record，这样每个段就变成了一行，原来的行之间用空格分隔
  printf "$data" | awk -v RS= '{$1 = $1} 1'
}
# paragraph_mode

# 多个字符作为 RS，可以实现按自定义规则把数据分块，每块对应一个 field
multichar_rs(){
  # 尤其适合块状的数据，比如错误日志
  local data='''
  blah blah
  Error: something went wrong
  more blah
  whatever
  Error: something surely went wrong
  some text
  some more text
  blah blah blah
  '''

  # 按 Error: 分块，下面统计 Error 数量
  # printf "$data" | awk -v RS='Error:' 'END{print NR-1}'

  # 打印第一个 Error
  # printf "$data" | awk -v RS='Error:' 'NR==1'

  # 打印包含某个关键字的 error
  # printf "$data" | awk -v RS='Error:' '/whatever/ {print RS $0}' # print RS 即是打印 'Error:'

  # 打印行数超过阈值的 error
  printf "$data" | awk -F'\n' -v RS='Error:' 'NF>4 {print RS $0}'
}
# multichar_rs

# 根据正则匹配的 RS
regex_rs(){
  local s='Sample123string54with908numbers'

  # 当 RS 是正则时，RT 中包含匹配到的字符串
  # printf "$s" | awk -v RS='[0-9]+' '{print NR ": " $0 " - " RT}'

  # 当 RS 匹配到数据的开头时，第一个 field 是空
  printf '123string54with908' | awk -v RS='[0-9]+' '{print NR ": " $0}'

  # 换行符会作为一个完整的行，它的 field 都是空
  printf '123string54with908\n' | awk -v RS='[0-9]+' '{print NR " : " $0}'
}
# regex_rs

# 根据自定义的字符 join 行
process_line_end(){
  local data='''
  Hello there.
  It will rain to-
  day. Have a safe
  and pleasant jou-
  rney.
  '''

  # 在输入时做，把 - 结尾的行 join 下一行
  # printf "$data" | awk -v RS='-\n' -v ORS= '1'

  # 在输出时做，在合适的地方加入 \n
  printf "$data" | awk '{ORS = sub(/-$/,"") ? "" : "\n"} 1'
}
# process_line_end

