# Bind9


## DNS
> [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-14-04)

Root hints under: /usr/share/dns/root.hints or in bind named.conf.default-zones

### Structure
folder | description
---|---
/etc/bind/ | bind9 - config folder
/etc/bind/zones/ | put zones here
/etc/bind/slaves/ | for slaves

Master2:
```
/etc/bind/zones/net - folder for net. zone
/etc/bind/zones/org/beta - folder for btea.org. zone
```

## DNS-SEC
> [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-setup-dnssec-on-an-authoritative-bind-dns-server-2)

### Generate DNSSEC-Keys
```
dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE <zonename>
dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -n ZONE <zonenname>
```

### Include keys in zonefile
> Attention!!! With the default command, both keys AND the zonefile MUST be placed in the same context

Include keys in zonefile

```
$INCLUDE Kalpha.net.+007+13775.key
$INCLUDE Kalpha.net.+007+18573.key
```

### Sign DNS-Zone
```
dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N INCREMENT -o <zonenname> -t <zonefile>
```
The `desset` file generated after signing the keys holds the hash of the 257 key. It must be included in the above zone:

```
$INCLUDE dsset-beta.org
```

## MAIL

## WEB
