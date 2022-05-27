#! /bin/bash

rootpath=/etc/bind/zones

#generate_keys <path> <zone>
generate_keys () {
  rm $rootpath/$1/K${2}*
  dnssec-keygen -a NSEC3RSASHA1 -b 2048 -K $rootpath/$1 -n ZONE $2
  dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -K $rootpath/$1 -n ZONE $2
  ls -l $rootpath/$1/
}


generate_keys net net

