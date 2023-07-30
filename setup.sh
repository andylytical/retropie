#!/bin/bash

set -x

BASE=$( dirname $0 )
RC=bashrc
RCDIR=~/.bashrc.d
PROFILE=bash_profile
GREP_PATTERN='CUSTOM INCLUDE FROM GITHUB/ANDYLYTICAL/RETROPIE'
SUFFIX=$(date +%s)


die() {
  echo "Error: ${*}" >&2
  exit 2
}


assert_root() {
    [[ $EUID -eq 0 ]] || {
      die "This script must be run as root"
    }
}


assert_var_is_not_empty() {
  local _var_name="$1"
  [[ $# -lt 1 ]] && die "Missing varname parameter in ssert_var_is_not_empty"
  [[ -z "${!_var_name}" ]] && die "No value set for variable '${_var_name}'"
}


mount_roms_dir() {
  local _src _tgt _usr _pwd _opts _fstab
  _src='//depot.lc.net/ROMs'
  _tgt='/home/pi/RetroPie/roms'
  _usr='username=retropie'
  _pwd="password=${CIFSPASSWD}"
  _opts='nounix,noserverino,defaults,users,auto'

  grep -q "$_tgt" /etc/fstab \
  && >>/etc/fstab echo "$_src $_tgt cifs ${_usr},${_pwd},${_opts} 0 0"

  mount "$_tgt"
}


disable_wifi() {
  local _tgt='/boot/config.txt'
  grep -q "$GREP_PATTERN" $_tgt || {
    cat << EOF >>$_tgt
dtoverlay=disable-wifi
dtoverlay=disable-bt
EOF
  }
  systemctl disable hciuart
}


# install_retroflag() {
#   export QS_REPO=https://gitlab.com/andylytical/retroflag-picase
#   curl https://raw.githubusercontent.com/andylytical/quickstart/master/quickstart.sh \
#   | bash
# }


### DO WORK

assert_root

assert_var_is_not_empty CIFSPASSWD

mount_roms_dir

disable_wifi

# install_retroflag
