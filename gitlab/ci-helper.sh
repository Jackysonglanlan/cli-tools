#!/bin/sh

################
# gitlab ci helper
################

echo "[ci-helper] start"


network_test() {
  ping -c1 10.81.132.103
}


# see https://docs.gitlab.com/ee/ci/ssh_keys/
#
# 需要提前设置 file-type variable:
#   Key: SSH_PRIVATE_KEY  -  Value: the content of your private key
# file-type variable 在使用的时候，gitlab 会把 $SSH_PRIVATE_KEY 替换为一个临时文件的路径，这个文件的内容就是 value
# 这样就可以用于 "只接受文件" 的场景，比如像这里配置 ssh
prepare_ci_ssh() {
  ## Install ssh-agent if not already installed, it is required by Docker.
  ## (change apt-get to yum if you use an RPM-based image)
  command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )

  ## Run ssh-agent (inside the build environment)
  eval $(ssh-agent -s)

  ## Give the right permissions, otherwise ssh-add will refuse to add files
  ## Add the SSH key stored in SSH_PRIVATE_KEY file type CI/CD variable to the agent store
  chmod 400 "$SSH_PRIVATE_KEY" # 这个值就是 gitlab 生成的临时文件路径
  ssh-add "$SSH_PRIVATE_KEY"

  ## Create the SSH directory and give it the right permissions
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
}

echo "[ci-helper] end"
