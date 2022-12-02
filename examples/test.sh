#!/bin/sh
if [ -z $1 ] ; then
  echo "No hostname specified"
  exit
fi
if [ -z $2 ] ; then
  ansible-playbook main.yaml -i hosts.yaml --flush-cache --scp-extra-args="-c aes128-ctr" --module-path .. -l $1 -v
else
  if [ -z $3 ] ; then
    ansible-playbook main.yaml -i hosts.yaml --flush-cache --scp-extra-args="-c aes128-ctr" --module-path .. -l $1 --tags $2
  else
    ansible-playbook main.yaml -i hosts.yaml --flush-cache --scp-extra-args="-c aes128-ctr" --module-path .. -l $1 --tags $2 $3
  fi
fi
