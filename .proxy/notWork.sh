/etc/init.d/iptables-persistent flush
/etc/init.d/iptables-persistent reload
before="$(cat /etc/resolv.conf)"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "$before" >> /etc/resolv.conf
