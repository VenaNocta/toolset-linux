# Bind9


## DNS
> [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-14-04)

Root hints under: /usr/share/dns/root.hints or in bind named.conf.default-zones

### Structure
| folder            | description           |
|-------------------|-----------------------|
| /etc/bind/        | bind9 - config folder |
| /etc/bind/zones/  | put zones here        |
| /etc/bind/slaves/ | for slaves            |

Master2:
``` bash
/etc/bind/zones/net - folder for net. zone
/etc/bind/zones/org/beta - folder for beta.org. zone
```

### Install
```bash
sudo apt-get update
sudo apt-get install bind9 bind9utils bind9-doc haveged
```

## DNS-SEC
> [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-setup-dnssec-on-an-authoritative-bind-dns-server-2)

### Activate DNSSEC in bind9

``` bash
dnssec-validation yes;
```

### Generate DNSSEC-Keys
``` bash
dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE <zonename>
dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -n ZONE <zonenname>
```

### Include keys in zonefile
> Attention!!! With the default command, both keys AND the zonefile MUST be placed in the same context

Include keys in zonefile

``` bash
$INCLUDE Kalpha.net.+007+13775.key
$INCLUDE Kalpha.net.+007+18573.key
```

### Sign DNS-Zone
``` bash
dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N INCREMENT -o <zonenname> -t <zonefile>
```
The `desset` file generated after signing the keys holds the hash of the 257 key. It must be included in the above zone:

``` bash
$INCLUDE dsset-beta.org
```

### Install trust-anchor

Get the 257 key from the root and place it in the `named.conf.options` file of the resolver below the `options {};`
``` bash
trusted-keys {
  . 257 3 7 "AwEAAbchyLPG5GVdghr6ZjJoNn7dTnK21K3qmptEzVT
             t4u7p7+minW5yvS5gl9ebI1cCYDtMleULHMsRMFtoAq
             ...
             ...
             ....
             YuRbrFpYY4uWY9f/AkiEfxNyCOg5O3vmYm6CPHyJ";
};
```

### Scripts
Generate all keys:

```bash
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
#generate_keys org/beta beta.org
```

Sign Files:

requires each ZONE to be in a folder on his own!

to add signatures of subdomains just copy the files in the folder of the zonefile (db.zone)

the dsset-* file will be put by default into the zones root folder (/etc/bind/zones) the signed file (db.keyed-zone.signed) will stay in the same folder as the zone file (db.zone)

EX: net. zone is in the file >> zones/net/db.zone

```bash
#! /bin/bash

rootpath=/etc/bind/zones

#sign_zone <path> <zone>
sign_zone () {
  cd $rootpath/$1/
  cat db.zone > db.keyed-zone
  # include key files
  for key in `ls K${2}*.key`
  do
  echo "\$INCLUDE $key">> db.keyed-zone
  done
  # include DS entries
  for key in `ls dsset-*`
  do
  echo $(cat $key)>> db.keyed-zone
  done

# if is missing crypt pkg missing!
# comment out next line and generate the salt.txt on you client
# and upload it to the $rootpath
  head -c 1000 /dev/random | sha1sum | cut -b 1-16 > $rootpath/salt.txt

  local salt=$(cat $rootpath/salt.txt)
  echo salt=$salt
  echo dir=$(pwd)
  dnssec-signzone -A -3 $salt -N INCREMENT -o $2 -t db.keyed-zone

  mv dsset-${2}* $rootpath/
  ls -l
  cd $rootpath/
}

sign_zone net net
#sign_zone org/beta beta.org
```


## MAIL

## WEB
