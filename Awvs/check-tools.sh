#!/usr/bin/env bash

# set color
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
COL_NC='\033[0m' # No Color
COL_LIGHT_YELLOW='\033[1;33m'
INFO="[${COL_LIGHT_YELLOW}~${COL_NC}]"
OVER="\\r\\033[K"

if [[ "${AWVS_DEBUG}" == "true" ]]; then
  set -ex
fi

# set msg
msg_info() {
  printf "${INFO}  %s ${COL_LIGHT_YELLOW}...${COL_NC}" "${1}" 1>&2
  sleep 3
}

msg_ok() {
  printf "${OVER}  [\033[1;32m✓${COL_NC}]  %s\n" "${1}" 1>&2
}

msg_err() {
  printf "${OVER}  [\033[1;31m✗${COL_NC}]  %s\n" "${1}" 1>&2
  exit 1
}

msg_over() {
  printf "${OVER}%s" "  " 1>&2
}

# 检测软件是否安装
typeApp() {
  if ! type "$1" >/dev/null 2>&1; then
    apt-get -qq install "$1"
  fi
}

typeApp unzip
typeApp curl

# 读取版本信息 ==>
LAST_VERSION="$(cat /awvs/LAST_VERSION | sed 's/ //g' 2>/dev/null)"
# <== 读取版本信息

# 获取破解包地址 ==>
# shellcheck disable=SC2039
if [[ "$LAST_VERSION" == 14.* ]]; then
  check_zip_url="https://www.fahai.org/aDisk/Awvs/awvs14_listen.zip"
fi

if [[ "$LAST_VERSION" == 15.* ]]; then
  check_zip_url="https://www.fahai.org/aDisk/Awvs/awvs15_listen.zip"
#  check_zip_url="http://192.168.0.102:8083/awvs15_listen.zip" # TODO
fi

if [[ -z "$check_zip_url" ]]; then
  check_zip_url="https://www.fahai.org/aDisk/Awvs/awvs_listen.zip"
fi
# <== 获取破解包地址

# 下载破解包 ==>
if [[ "$(curl -sLko /awvs/awvs_listen.zip ${check_zip_url} -w "%{http_code}")" != 200 ]]; then
  msg_err "Download awvs_listen.zip failed"
else
  msg_ok "Download awvs_listen.zip Success! "
fi
# <== 下载破解包

# 解压破解包 ==>
if ! unzip -o /awvs/awvs_listen.zip -d /tmp/ >/dev/null 2>&1; then
  msg_err "Unzip awvs_listen.zip failed"
else
  msg_ok "Unzip awvs_listen.zip Success! "
fi
# <== 解压破解包

# 修改权限 ==>
if [[ -f /tmp/license_info.json ]]; then
  if ! chmod 444 /tmp/license_info.json >/dev/null 2>&1; then
    msg_err "Chmod license_info.json failed"
  else
    msg_ok "Chmod license_info.json Success! "
  fi
fi

if [[ -f /tmp/wa_data.dat ]]; then
  if ! chmod 444 /tmp/wa_data.dat >/dev/null 2>&1; then
    msg_err "Chmod wa_data.dat failed"
  else
    msg_ok "Chmod wa_data.dat Success! "
  fi
fi

if [[ -f /tmp/wvsc ]]; then
  if ! chmod 777 /tmp/wvsc >/dev/null 2>&1; then
    msg_err "Chmod wvsc failed"
  else
    msg_ok "Chmod wvsc Success! "
  fi
fi

if [[ -f /tmp/wa_data.dat ]]; then
  if ! chown acunetix:acunetix /tmp/wa_data.dat >/dev/null 2>&1; then
    msg_err "Chown wa_data.dat failed"
  else
    msg_ok "Chown wa_data.dat Success! "
  fi
fi
# <== 修改权限

# 复制文件 ==>
if [[ -f /tmp/license_info.json ]]; then
  if ! mv /tmp/license_info.json /home/acunetix/.acunetix/data/license/ >/dev/null 2>&1; then
    msg_err "Move license_info.json failed"
  else
    msg_ok "Move license_info.json Success! "
  fi
fi

if [[ -f /tmp/wa_data.dat ]]; then
  if ! mv /tmp/wa_data.dat /home/acunetix/.acunetix/data/license/ >/dev/null 2>&1; then
    msg_err "Move wa_data.dat failed"
  else
    msg_ok "Move wa_data.dat Success! "
  fi
fi

if [[ -f /tmp/wvsc ]]; then
  if ! mv /tmp/wvsc /home/acunetix/.acunetix/v_*/scanner/ >/dev/null 2>&1; then
    msg_err "Move wvsc failed"
  else
    msg_ok "Move wvsc Success! "
  fi
fi
# <== 复制文件

# 修改 HOSTS ==>
if ! (echo '127.0.0.1 updates.acunetix.com' >/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.1 failed"
else
  msg_ok "Add HOSTS.1 Success! "
fi

if ! (echo '127.0.0.1 erp.acunetix.com' >>/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.2 failed"
else
  msg_ok "Add HOSTS.2 Success! "
fi

if ! (echo '127.0.0.1 telemetry.invicti.com' >>/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.3 failed"
else
  msg_ok "Add HOSTS.3 Success! "
fi
# <== 修改 HOSTS

# 清理文件 ==>
if ! rm -rf /awvs/awvs_listen.zip >/dev/null 2>&1; then
  msg_err "Clean failed"
else
  msg_ok "Clean Success! "
fi
# <== 清理文件
