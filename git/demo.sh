# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

alias g=git
alias gco='g checkout'
alias gaa='g add --all'
alias gcam='g commit -am'
alias grm='g reset --hard ORIG_HEAD' # reset merge

_build_git_repo(){
  mkdir -p $1 && cd $1
  git init
}

# g merge
_gmg(){
  g merge --no-ff -m "merge $1" $1
}

_add_commit(){
  touch $1
  gaa
  gcam "[${2:-add}] $1"
}

workflow_env(){
  _build_git_repo $1
  
  # 项目初始化
  _add_commit init 'init'
  
  # 刚刚开始 dev
  gco -b dev
  _add_commit a
  
  # 产品排期了一个需求
  gco -b feature-xxx
  _add_commit feature-xxx 'begin'
  _add_commit feature-xxx-2
  _add_commit feature-xxx-3
  
  # 产品又加了一个需求
  gco dev # 回到 dev 开分支
  gco -b feature-yyy
  _add_commit feature-yyy 'begin'
  _add_commit feature-yyy-2
  _add_commit feature-yyy-3
  _add_commit feature-yyy-4
  
  # 开发中....你可以按自己的习惯推进 feature-xxx 和 feature-yyy ，one-by-one 或 穿插进行 都可以
  
  # feature-xxx 开发完成
  gco dev
  _gmg feature-xxx
  
  # feature-yyy 开发完成
  gco dev
  _gmg feature-yyy
  
  # 准备发版
  gco -b release
  echo 1.0 > version # 创建一个 version 文件，方便知道当前快照处于哪个版本(比看 tag 好，因为 log 通常很复杂，要追踪很久才能看出)
  gaa
  gcam '[ready] 1.0'
  
  # 发版前突然要新加一个需求
  gco -b hotfix-xxx
  _add_commit bug-fix 'bugfix'
  
  # 确认改好了，合并到release (上一步和这一步 可以反复执行，直到发版前的新需求添加完毕)
  gco release
  _gmg hotfix-xxx
  
  # 同步到 dev
  gco dev
  _gmg release
  
  # 归档到 master
  gco master
  _gmg release
  g tag 1.0
  
  # hotfix-xxx 没用了
  # gb -d hotfix-xxx
  
  # 这里，可以继续开发，开分支，改 bug 都可以
  
  # 突然有一天，线上发现一个bug，需要修复
  gco release
  gco -b hotfix-1.0.1
  _add_commit fix-1.0.1 'bugfix'
  
  # 修好，合并到release (上一步和这一步 可以反复执行，直到 bug 修复完毕)
  gco release
  _gmg hotfix-1.0.1
  echo 1.0.1 > version # 更新版本
  gaa
  gcam '[ready] 1.0.1'
  
  # 同步到 dev
  gco dev
  _gmg release
  
  # 归档到 master
  gco master
  _gmg release
  g tag 1.0.1
  
  # hotfix 没用了
  # gb -d hotfix-1.0.1
  
  # 继续开发
  gco dev
}

patch_env(){
  _build_git_repo $1
  
  _add_commit aaa
  _add_commit bbb
  
  gco -b dev
  _add_commit 111
  _add_commit 222
  _add_commit 333
  
  gco master
  _add_commit ccc
  _add_commit ddd
  _add_commit eee
  
  gco dev
  g pull --rebase . master
  
  gco master
  _add_commit fff
}

# ./demo.sh _method_ _dirname_
$@
