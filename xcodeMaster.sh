#!/bin/bash

#< Directory varibales
xcodeDir=$(xcode-select -p)
#>
#< functions
check() {
  # This checks for flags
  while getopts 'x' flag; do
    case "${flag}" in
      x) xcodeCall $@;;
         exit 1 ;;
    esac
  done
}
#< xcode funtions
xcodeCall() {
  if [[ ! -d $xcodeDir ]]; then
    printf "xcode directory not defined\n"
    while true; do
      read -p "Do you wish to install xcode? [Y/N] " yn
      case $yn in
          [Yy]* ) xcodeInstall;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
      esac
    done
  fi
  # This checks for flags
  while getopts 'vliruh' flag; do
    case "${flag}" in
      v) xcodeCheckVersion ;;
      l) xcodeLatestVersion ;;
      i) xcodeInstall ;;
      r) xcodeRemove ;;
      u) xcodeUpdate ;;
      h) xcodeHelp ;;
    esac
  done
}
xcodeCheckVersion() {
    xcodeVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | awk -F"version: " '{print $2}' | awk -v ORS="" '{gsub(/[[:space:]]/,""); print}' | awk -F"." '{print $1"."$2}')
    printf "installed xcode Version $xcodeVersion\n"
}
xcodeLatestVersion(){
  # Tricks apple software update
  printf "sudo priviledges are reqired to check the latest version of xcode\n"
  /usr/bin/sudo /usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  printf "Checking for the latest version of xcode. This may take some time\n"
  xcodeLatestVersion=$(/usr/bin/sudo /usr/sbin/softwareupdate -l | awk -F"Version:" '{ print $1}' | awk -F"Xcode-" '{ print $2 }' | sort -nr | head -n1)
  printf "xcode latest version: $xcodeLatestVersion\n"
}
xcodeInstall () {
  xcodeLatestVersion
  /usr/bin/sudo /usr/sbin/softwareupdate -i Command\ Line\ Tools\ for\ Xcode-$xcodeLatestVersion
  printf "\nXcode info:\n$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | sed 's/^/\t\t/')\n"
  exit 0
}
xcodeRemove () {
  if [[ -d /Library/Developer/CommandLineTools ]]; then
    printf "Uninstalling xcode\n"
    sudo rm -r /Library/Developer/CommandLineTools
  else
    printf "xcode not installed\n"
    exit 0
  fi
  if [[ -d /Library/Developer/CommandLineTools ]]; then
    printf "error"
    exit 1
  else
    printf "xcode uninstalled\n"
  fi
}
xcodeUpdate() {
  xcodeLatestVersion
  xcodeCheckVersion
  if echo $xcodeVersion $xcodeLatestVersion | awk '{exit !( $1 < $2)}'; then
    printf "\nXcode is outdate, updating Xcode version $xcodeVersion to $xcodeLatestVersion"
    xcodeRemove
    xcodeInstall
  else
    printf "xcode is up to date.\n"
  fi
}
xcodeHelp() {
  printf "xcodeMaster\n\\t-xv: Checks for installed version of xcode\n\t-xl: Checks for latest version of xcode available\n\t-xi: Installs the latest version of xcode\n\t-xu: Updates xcode to the latest version\n\t-xr: Removes xcode\n"
}
#>
#>
check $@
