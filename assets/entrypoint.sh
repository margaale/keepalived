#!/usr/bin/env bash
set -e

IP=$(ifconfig ${INTERFACE} | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
CONFIG=${CONFIG:-/etc/keepalived/keepalived.conf}

if grep -q '{{' $CONFIG
then
  sed -i "s|{{ STATE }}|$STATE|g" $CONFIG
  sed -i "s|{{ ROUTER_ID }}|$ROUTER_ID|g" $CONFIG
  sed -i "s|{{ INTERFACE }}|$INTERFACE|g" $CONFIG
  sed -i "s|{{ PRIORITY }}|$PRIORITY|g" $CONFIG
  sed -i "s|{{ PASSWORD }}|$PASSWORD|g" $CONFIG

  if [ "$USE_VMAC" = "true" ]; then
    sed -i "s|{{ USE_VMAC }}|use_vmac|g" $CONFIG
    sed -i "s|{{ VMAC_XMIT_BASE }}|vmac_xmit_base|g" $CONFIG
  else
    sed -i "/{{ USE_VMAC }}/d" $CONFIG
    sed -i "/{{ VMAC_XMIT_BASE }}/d" $CONFIG
  fi

  if [ -n "$NOTIFY" ]; then
    sed -i "s|{{ NOTIFY }}|\"$NOTIFY\"|g" $CONFIG
    chmod +x $NOTIFY
  else
    sed -i "/{{ NOTIFY }}/d" $CONFIG
  fi

  if [ -n "$TRACK_SCRIPT" ]; then
    sed -i "s|{{ TRACK_SCRIPT }}|\"$TRACK_SCRIPT\"|g" $CONFIG
    chmod +x $TRACK_SCRIPT
  else
    sed -i "/{{ TRACK_SCRIPT }}/d" $CONFIG
  fi

  for peer in $UNICAST_PEERS; do
    if [ "$peer" != "$IP" ]; then
      sed -i "s|{{ UNICAST_PEERS }}|${peer}\n    {{ UNICAST_PEERS }}|g" $CONFIG
    fi
  done
  sed -i "/{{ UNICAST_PEERS }}/d" $CONFIG

  for vip in $VIRTUAL_IPS; do
    sed -i "s|{{ VIRTUAL_IPS }}|${vip}\n    {{ VIRTUAL_IPS }}|g" $CONFIG
  done
  sed -i "/{{ VIRTUAL_IPS }}/d" $CONFIG
fi

exec /usr/local/sbin/keepalived -f $CONFIG --dont-fork --log-console ${ARGUMENTS}
