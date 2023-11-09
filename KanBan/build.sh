#!/usr/bin/env bash

################
# KanBan 构建器
################

# WARNING: - 是打开，+ 是关闭
shopt -s expand_aliases # alias 在脚本中生效
set -euo pipefail       # e: 有错误及时退出 u: 使用未设置的变量时报警 o pipefail: pipeline 中出错时退出
# set +o posix          # 关闭 posix 的兼容检查，以便使用不兼容 posix 的语法，比如 <() 和 >()
# set -x                # 打印出所有实际执行的命令和参数
# set -f                # 禁止扩展 '*' 号(要恢复使用 +f)
trap "echo 'error: Script failed: see failed command above'" ERR

#exit_hook(){
#  echo "exit_hook"
#}
#trap exit_hook EXIT

##### utils #####

use_red_green_echo() {
  prefix="$1"
  red() {
    printf "$(tput bold)$(tput setaf 1)[$prefix] $*$(tput sgr0)\n";
  }

  green() {
    printf "$(tput bold)$(tput setaf 2)[$prefix] $*$(tput sgr0)\n";
  }

  yellow() {
    printf "$(tput bold)$(tput setaf 178)[$prefix] $*$(tput sgr0)\n";
  }
}
use_red_green_echo 'builder'

##### global #####

_CURR_YEAR_=$(date +'%Y')

init() {
  # 创建不同类别 Task 的资料文件夹目录
  mkdir -p {LONGTERM,ARCHIVE,TODO,DOING,DONE,IMPULSION}
}
init

##### private #####

# 新建看板文件，如果已经有了，则忽略
#
# $1: file_name 看板文件名
_create_board_file_if_none() {
  local file_name="$1"

  if [[ -e $file_name ]]; then
    yellow "[create board file] file exist: $file_name"
  else
    green "[create board file] file created: $file_name"

    # 看板模板，新建看板文件时使用
    local template=$(cat ./board/board.template)

    # 模板参数替换，生成最终内容
    template=${template//\{\{year\}\}/$_CURR_YEAR_}

    echo "$template" > "$file_name"
  fi
}

##### public #####

# 在 board-$year.md 中的 Task 表格中添加一条记录，其中 year 为执行命令时的年份
#
# $1: 任务名，即 task 列，默认为 '任务描述 xxx'。due 列为当前日期 + 1 week
add_task() {
  local name=${1:-'任务描述 xxx'}
  # 生成 task id，unit timestamp
  local task_id=$(date +'%s')
  local taskRow="| $task_id | $name |     |      | $(date -v+1w +'%m.%d') |"

  local board_file="./board/board-${_CURR_YEAR_}.md"

  _create_board_file_if_none "$board_file"

  green "[adding task] to $board_file:\n  -> $taskRow"

  # 用 awk 添加一条表格记录到 board.md

  local script='
  /^## TODO Task/ {inTask = 1}
  inTask == 1 && /^\| / {inTask = 0; inRow = 1;}
  inRow == 1 && length($0) == 0 {print "'$taskRow'"; inRow = 0}
  {print}
  '
  # 上面第 3 行，inRow == 1 并且当前行是空行，代表处于 TODO Tasks 表格的末尾行

  awk -i inplace -v INPLACE_SUFFIX=.bak "$script" "$board_file"

  green "[make task dir] $task_id in TODO"
  mkdir -p "TODO/$task_id"

  sort_out
}

# 按时间整理文件夹
#
# 长期使用后，TODO DOING 这些文件夹下面会有很多子文件夹，如果只有一层，效率会越来越低
# 这个方法会读取子文件夹的名称(一个 unix timestamp)，解析为 YY-MM-dd，然后分层放置，解决效率问题，同时方便查看
#
# 以 DONE 文件夹为例，整理前如下:
#
# DONE
#   - task_id_xxx
#   - task_id_yyy
#
# 整理后如下:
#
# DONE
#   - YY
#     - MM
#       - task_id_xxx
#       - task_id_yyy
#
# $1: dir to sort out, default to "DONE"
sort_out() {
  local target_dir=${1:-DONE} # 最容易出现这个问题的就是 DONE，所以默认值是它
  green "[sort out] in $target_dir"

  while read -r dir; do
    local "name"=$(basename "$dir")
    if [[ "$name" =~ [0-9]{10,} ]]; then # 只有 > 10 位 的数字才是 unix timestamp
      local date_name=$(date -r "$name" '+%Y/%m' 2>/dev/null) # 注意 Y/M 恰好形成文件夹结构
      local gene_dir="$target_dir/$date_name"
      mkdir -p "$gene_dir"
      green "[moving] $dir to $gene_dir"
      mv "$dir" "$gene_dir"
    fi
  done <<< "$(find "$target_dir" -type d -maxdepth 1)"
}

"$@"
