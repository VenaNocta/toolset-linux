#!/bin/bash
cd $1
dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $2
dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -n ZONE $2
