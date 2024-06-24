#! /bin/bash

rootpath=/etc/bind/zones

#sign_zone <path> <zone>
sign_zone () {
  pushd $rootpath/$1/
  cat db.zone > db.keyed-zone
  # include key files
  for key in `ls K${2}*.key`
  do
    echo "\$INCLUDE $key">> db.keyed-zone
  done
  # include DS entries
  for key in `ls *.dsset`
  do
    echo "added dsset: $key"
    echo $(cat $key)>> db.keyed-zone
  done

# crypt pkg missing!
#  head -c 1000 /dev/random | sha1sum | cut -b 1-16 > $rootpath/salt.txt

  local salt=$(cat $rootpath/salt.txt)
  echo salt=$salt
  echo dir=$(pwd)
  dnssec-signzone -A -3 $salt -N INCREMENT -o $2 -t db.keyed-zone

#  mv dsset-${2}* $rootpath/
  ls -l
#  cd $rootpath/
  popd
}


sign_zone com com
sign_zone com/aperture aperture.com

