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

# $1: awk script to run
_run() {
  local script=$1
  awk "$script" "${@:2}"
}

array_is_map() {
  local script='''
  BEGIN{
    a["z"]=1;  /* array 就像 map */
    a["x"]=12;
    a["b"]=42;

    for(k in a) print k, a[k]; /* 支持 for in 遍历，默认是乱序 */
  }
  '''
  # _run "$script"

  ##### 改变默认排序: https://www.gnu.org/software/gawk/manual/html_node/Controlling-Scanning.html#Controlling-Scanning

  # index sorted ascending order as strings
  script='''
  BEGIN{
    PROCINFO["sorted_in"] = "@ind_str_asc"; /* 按 key 字母升序排 */

    a["z"]=1; a["x"]=12; a["b"]=42;
    for(k in a) print k, a[k];
  }
  '''
  # _run "$script"

  # value sorted ascending order as numbers
  script='''
  BEGIN{
    PROCINFO["sorted_in"] = "@val_num_asc"; /* 按 value 升序排 */

    a["z"]=1; a["x"]=12; a["b"]=42;
    for(k in a) print k, a[k];
  }
  '''
  _run "$script"
}
# array_is_map

looping(){
  # average marks for each department
  local script='''
  NR > 1 {dep[$1]+=$3; count[$1]++}
  END{
    for(k in dep) print k, dep[k]/count[k];
  }
  '''
  _run "$script" ./data.txt
}
# looping

del_array_element(){
  # update entry if a match is found, else append the new entries
  local script='''
  {k = $1_$2}
  NR == FNR {upd[k]=$0; next} /* NR 是整个进程读取的 record number，FNR 即 file NR，所以 NR == FNR 代表读完第1个文件 */
  k in upd {$0=upd[k]; delete upd[k]} 1; /* 1 代表永远为 ture，后面没有执行语句，所以默认为 {print $0} */
  END{
    for(k in upd) print upd[k];
  }
  '''

  _run "$script" ./list.txt ./data.txt
}
# del_array_element

# see https://www.gnu.org/software/gawk/manual/html_node/Arrays-of-Arrays.html#Arrays-of-Arrays
length_of_sub_arrays_need_not_be_same(){
  local script='''
  NR > 1 { d[$1][$2] = $3 }
  END{
    for(k in d["ECE"]) print k
  }
  '''
  # _run "$script" ./data.txt

  script='''
  NR > 1 { d[$1][$2] = $3 }
  END{
    for(k in d[f]) print k, d[f][k]
  }
  '''
  # f 是变量参数
  awk -v f='CSE' "$script" ./data.txt
}
# length_of_sub_arrays_need_not_be_same

remove_dup(){
  # 通过 array 计数
  # printf 'mad\n42\n42\ndam\n42\n' | awk '{print $0 "\t count:" int(a[$0]); a[$0]++}'

  # 把数字当 bool 用，只打印数组中值 == 0 的 entry，见上面的例子，因为如果有重复，值 > 0，所以这样就删除了重复
  # printf 'mad\n42\n42\ndam\n42\n' | awk '!seen[$0]++'

  local data='''
  abc  7   4
  food toy ****
  abc  7   4
  test toy 123
  good toy ****
  '''

  # 再进一步，可以统计去重后的总数
  # 注意这里是统计第二个 field 去重后的个数(data 有空行，所以有 3 个)，使用 in 可以确保 c 只在需要时再 ++，-M 设置数字不会 overflow
  # printf "$data" | awk -M '!($2 in seen){c++} {seen[$2]} END{print +c}'

  # 第 2 和 3 个 field 去重后输出，注意 array 的 key，这样相当于模拟了一个 2d array
  # printf "$data" | awk '!seen[$2,$3]++'

  # 输出第二个 field 在第 3 次重复时的记录
  # printf "$data" | awk '++seen[$2] == 3'

  # 输出有重复的第二个 field 的最后一次重复时的记录( tac 是 linux only )
  # printf "$data" | tac | awk '!seen[$2]++' | tac
}
remove_dup


