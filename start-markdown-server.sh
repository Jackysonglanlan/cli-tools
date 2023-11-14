#!/bin/sh
#
# This is a server to launch docker caddy to view the markdown files.
#
# Dependency:
#  https://github.com/Jackysonglanlan/devops.git
#  https://github.com/Jackysonglanlan/docker.git

set -euo pipefail

. "$DEVOPS_ROOT/scripts/libs/utils.sh"

ROOT=$(git rev-parse --show-toplevel)
PATH_TO_DOCKER_REPO="$ROOT/../docker"

REPO_URL="github.com/Jackysonglanlan/docker"
if [[ $(is_git_repo $PATH_TO_DOCKER_REPO $REPO_URL) != 1 ]]; then
  red "[Error] No repo is found at $PATH_TO_DOCKER_REPO. Pls clone from $REPO_URL"
  exit 1
fi

start_caddy(){
  cd "$ROOT" # change to project root
  
  local docker_image_to_run="jacky/support/caddy"
  
  jacky docker start_container_of_image "$PATH_TO_DOCKER_REPO/images/support" $docker_image_to_run \
  'jacky docker dc_up caddy'
}

(start_caddy)

### 访问 http://localhost:10000/site 即可

